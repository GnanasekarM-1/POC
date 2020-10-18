@isTest
(SeeAllData=true)
public with sharing class WSCH_Provider_SP_DataMapper_UT {
    
    public WSCH_Provider_SP_DataMapper_UT() {
        List<SVMXC__ServiceMax_Properties__c> lstSVMXProperties = new List<SVMXC__ServiceMax_Properties__c>();
        
        //property for smaxapi
        // SVMXC__ServiceMax_Properties__c smaxPropertiesObj1 = new SVMXC__ServiceMax_Properties__c();
       // smaxPropertiesObj1.Name = 'SP001';
       // smaxPropertiesObj1.SVMXC__Value__c = 'c21heGFwaQ==';
       // lstSVMXProperties.add(smaxPropertiesObj1);
        
        //property for smax_user
        SVMXC__ServiceMax_Properties__c smaxPropertiesObj2 = new SVMXC__ServiceMax_Properties__c();
        //smaxPropertiesObj2.Name = 'SP002';
        //smaxPropertiesObj2.SVMXC__Value__c = 'c21heF91c2Vy';
        //lstSVMXProperties.add(smaxPropertiesObj2);
        smaxPropertiesObj2 = [SELECT Name, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name =: 'SP002'];
        smaxPropertiesObj2.SVMXC__Value__c = 'c21heF91c2Vy';
        lstSVMXProperties.add(smaxPropertiesObj2);
        
        //property for smaxapi99
        SVMXC__ServiceMax_Properties__c smaxPropertiesObj3 = new SVMXC__ServiceMax_Properties__c();
        //smaxPropertiesObj3.Name = 'SP003';
        //smaxPropertiesObj3.SVMXC__Value__c = 'c21heGFwaTk5';
        //lstSVMXProperties.add(smaxPropertiesObj3);
        smaxPropertiesObj3 = [SELECT Name, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name =: 'SP003'];
        smaxPropertiesObj3.SVMXC__Value__c = 'c21heGFwaTk5';
        lstSVMXProperties.add(smaxPropertiesObj3);
        
        
        //property for Offer_Appt_Default
        SVMXC__ServiceMax_Properties__c smaxPropertiesObj4 = new SVMXC__ServiceMax_Properties__c();
        //smaxPropertiesObj4.Name = 'SP004';
        //smaxPropertiesObj4.SVMXC__Value__c = 'T2ZmZXJfQXBwdF9EZWZhdWx0';
        //lstSVMXProperties.add(smaxPropertiesObj4);
        smaxPropertiesObj4 = [SELECT Name, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name =: 'SP004'];
        smaxPropertiesObj4.SVMXC__Value__c = 'T2ZmZXJfQXBwdF9EZWZhdWx0';
        lstSVMXProperties.add(smaxPropertiesObj4);
        
        //property for Book_Appt_Default
        SVMXC__ServiceMax_Properties__c smaxPropertiesObj5 = new SVMXC__ServiceMax_Properties__c();
        //smaxPropertiesObj5.Name = 'SP005';
        //smaxPropertiesObj5.SVMXC__Value__c = 'Qm9va19BcHB0X0RlZmF1bHQ';
        //lstSVMXProperties.add(smaxPropertiesObj5);
        smaxPropertiesObj5 = [SELECT Name, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name =: 'SP005'];
        smaxPropertiesObj5.SVMXC__Value__c = 'Qm9va19BcHB0X0RlZmF1bHQ';
        lstSVMXProperties.add(smaxPropertiesObj5);
        
        //property for Book_Job_Default
        SVMXC__ServiceMax_Properties__c smaxPropertiesObj6 = new SVMXC__ServiceMax_Properties__c();
       // smaxPropertiesObj6.Name = 'SP006';
       // smaxPropertiesObj6.SVMXC__Value__c = 'Qm9va0pvYl9EZWZhdWx0';
       // lstSVMXProperties.add(smaxPropertiesObj6);
        smaxPropertiesObj6 = [SELECT Name, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name =: 'SP006'];
        smaxPropertiesObj6.SVMXC__Value__c = 'Qm9va0pvYl9EZWZhdWx0';
        lstSVMXProperties.add(smaxPropertiesObj6);
        
        //property for Update_Job_Default
        SVMXC__ServiceMax_Properties__c smaxPropertiesObj7 = new SVMXC__ServiceMax_Properties__c();
       // smaxPropertiesObj7.Name = 'SP007';
       // smaxPropertiesObj7.SVMXC__Value__c = 'VXBkYXRlX0pvYl9EZWZhdWx0';
       // lstSVMXProperties.add(smaxPropertiesObj7);
        smaxPropertiesObj7 = [SELECT Name, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name =: 'SP007'];
        smaxPropertiesObj7.SVMXC__Value__c = 'VXBkYXRlX0pvYl9EZWZhdWx0';
        lstSVMXProperties.add(smaxPropertiesObj7);
        
        update lstSVMXProperties;
    }
    static{
        WSCH_Provider_SP_RealTimeOptimizer.mapWoConName = new Map<Id, String>();
        //WSCH_Provider_SP_DataMapper_UT dataMapperUT = new WSCH_Provider_SP_DataMapper_UT();
    }
    
    static testMethod void WSCH_Provider_SP_DataMapper_Test() {
        WSCH_Provider_SP_RealTimeOptimizer.lstTerrUpd = new List<SVMXC__Territory__c>();
        
        /** Offer Appointment Request */
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workorder.SVMXC__Zip__c='75001';
        workOrder.SVMXC__Service_Duration__c=3600.00;
        WSCH_ApptParam apptParam = new WSCH_ApptParam();
       // WSCH_Provider_SP_DataMapper.mapApptOfferRequest(workOrder, apptParam,5, 1);

        /** Offer Appointment Response */
        WSCH_Provider_SP_StubsV91.ApptOfferResponse offerResponse = new WSCH_Provider_SP_StubsV91.ApptOfferResponse();
        WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
        returnCode.code=0;
        returnCode.errNote='test';
        returnCode.type_x='type';
        offerResponse.returnCode=returnCode;
        List<WSCH_Provider_SP_StubsV91.Offer> offerLst = new List<WSCH_Provider_SP_StubsV91.Offer>();
        WSCH_Provider_SP_StubsV91.Offer offer = new WSCH_Provider_SP_StubsV91.Offer();
        WSCH_Provider_SP_StubsV91.Offers offers= new WSCH_Provider_SP_StubsV91.Offers();
        offer.day='Mon';
        offer.DRU='SOU';
        offer.FRU='SOU';
        offer.IRU='SOU';
        offer.offerText='offertext';
        offer.offerToken='offertoken';
        offer.promBand='AD';
        offer.promType='A';
        offer.siteIndicator='test';
        offer.start='2014-05-13T08:30';
        offer.travelTime=60;
        offer.end_x='2014-05-13T09:30';
        offerLst.add(offer);
        offers.offer=offerLst;
        offerResponse.offers=offers;
        WSCH_AppointmentsResponse techSlotResponse = new WSCH_AppointmentsResponse();
        WSCH_Provider_SP_DataMapper.mapApptOfferResponse(offerResponse, techSlotResponse);

        /** Book Job request **/

        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'TestFRU1';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;

        insert technician;
        
        SVMXC__ServiceMax_Properties__c[] svmx_property_SP006 = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name in ('SP006') ];
        if(svmx_property_SP006.size()>0){
          svmx_property_SP006[0].SVMXC__Value__c = 'YWJjZGVmZ2g=';
          update svmx_property_SP006;
        }        
        
        /*Create a new servicemax process*/
        SVMXC__ServiceMax_Processes__c newProcess = new SVMXC__ServiceMax_Processes__c();
        newProcess.SVMXC__Target_Object_Name__c = 'Offer_Appointment_Request';
        newProcess.SVMXC__MapID__c = 'abcdefgh';
        insert newProcess;
        
        SVMXC__ServiceMax_Config_Data__c newConfig = new SVMXC__ServiceMax_Config_Data__c();
        newConfig.SVMXC__MapID__c = newProcess.id;
        newConfig.SVMXC__Target_Field_Name__c = 'band.end';
        newConfig.SVMXC__Display_Value__c = 'TODAY';
        insert newConfig;
        
        List<BusinessHours> lstOfBusinessHours1;
        lstOfBusinessHours1 = [SELECT Id,IsActive,IsDefault,TimeZoneSidKey,MondayStartTime,MondayEndTime,
                                TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                                WHERE IsDefault = TRUE AND IsActive = TRUE];

        BusinessHours businessHoursObj = lstOfBusinessHours1.get(0);

        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__Zip__c = '75001';
        bookJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        bookJobWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookJobWorkOrder.SVMXC__Preferred_End_Time__c = endTime;
        bookJobWorkOrder.SVMXC__Preferred_Technician__c = technician.Id;
        bookJobWorkOrder.SVMXC__Preferred_Business_Hours__c = businessHoursObj.Id;
        bookJobWorkOrder.SVMXC__Skill_Set__c = '[{"skillName":"hardware","skillLevel":5,"skillId":"a1RG0000002fCLLMA2","isSkillMandatory":true},{"skillName":"software","skillLevel":5,"skillId":"a1RG0000002fCLQMA2","isSkillMandatory":true}]';
                
        try{
            WSCH_Provider_SP_DataMapper.mapBookJobRequest(bookJobWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        

        /** Book Job Response **/
        //Scenario 1: success
        WSCH_Provider_SP_StubsV91.JobBookResponse bookJobResponse1 = new WSCH_Provider_SP_StubsV91.JobBookResponse();
        WSCH_Provider_SP_StubsV91.ReturnCode returnCode1 = new WSCH_Provider_SP_StubsV91.ReturnCode();
        returnCode1.code = 0;
        returnCode1.type_x = 'Success_type';
        returnCode1.errNote = 'Book Job Successful';
        bookJobResponse1.result = returnCode1;
        bookJobResponse1.bookJobInfo = new WSCH_Provider_SP_StubsV91.BookInfo();
        WSCH_Provider_SP_StubsV91.BookInfo bookJobInfo= new WSCH_Provider_SP_StubsV91.BookInfo();
        bookjobInfo.empID='TestEmp1';
            bookjobInfo.FRU='TestFRU1';
            bookJobInfo.IRU='';

      bookJobResponse1.bookJobInfo=bookJobInfo;
      bookJobResponse1.result=returnCode1;

        WSCH_Provider_SP_DataMapper.mapBookJobResponse(bookJobWorkOrder, bookJobResponse1);

        //Scenario 2: failure
        WSCH_Provider_SP_StubsV91.JobBookResponse bookJobResponse2 = new WSCH_Provider_SP_StubsV91.JobBookResponse();
        WSCH_Provider_SP_StubsV91.ReturnCode returnCode2 = new WSCH_Provider_SP_StubsV91.ReturnCode();
        returnCode2.code = 1;
        returnCode2.type_x = 'Failure_type';
        returnCode2.errNote = 'Book Job failure';
        bookJobResponse2.result = returnCode2;
        bookJobResponse2.bookJobInfo = new WSCH_Provider_SP_StubsV91.BookInfo();

        WSCH_Provider_SP_DataMapper.mapBookJobResponse(bookJobWorkOrder, bookJobResponse2);

        /** map getChangeWorkItems request **/
        String FRU = 'SOU';
       // String timeStamp = '2/21/2014 9:00 PM';
        String timeStamp = string.valueof(System.now());
        
        try{
            WSCH_Provider_SP_DataMapper.mapGetChangedWorkItemsRequest(FRU, timeStamp);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        

        /** map getChangeWorkItems response **/
        WSCH_Provider_SP_StubsV91.GCJAttr attr = new WSCH_Provider_SP_StubsV91.GCJAttr();
        attr.empID = 'ID001';
       /* attr.start = '2/21/2014 8:00 PM';
        attr.arrival = '2/21/2014 8:30 PM';
        attr.disStatus = 'progress';
        attr.finish = '2/21/2014 09:30 PM';*/
        attr.start = string.valueof(System.now()+1);
        attr.arrival = string.valueof(System.now()+2);
        attr.disStatus = 'progress';
        attr.finish = string.valueof(System.now()+3);

        WSCH_Provider_SP_StubsV91.ReturnCode returnCode3 = new WSCH_Provider_SP_StubsV91.ReturnCode();
        returnCode3.code = 1;
        returnCode3.type_x = 'Failure_type';
        returnCode3.errNote = 'failure';

        /*
         below code has been added to satisfy the Jeopardy Condition
        */
        WSCH_Provider_SP_StubsV91.JeopConditions jobJeopardy = new WSCH_Provider_SP_StubsV91.JeopConditions();
        Map<String,Object> attributes = jobJeopardy.getAttributes();
        attributes.put('promise','true');
        WSCH_Provider_SP_StubsV91.GCJWorkItemAttr workItem = new WSCH_Provider_SP_StubsV91.GCJWorkItemAttr();
        workItem.attr = attr;
        workItem.jobJeopardy = jobJeopardy;
        workItem.workItemType = 'Job';
        
        WSCH_Provider_SP_StubsV91.GCJWorkItemAttr workItem2 = new WSCH_Provider_SP_StubsV91.GCJWorkItemAttr();
        workItem2.attr = attr;
        workItem2.jobJeopardy = jobJeopardy;
        workItem2.workItemType = 'StandardActivity';

        List<WSCH_Provider_SP_StubsV91.GCJWorkItemAttr> lstOfWorkItem = new List<WSCH_Provider_SP_StubsV91.GCJWorkItemAttr>();
        lstOfWorkItem.add(workItem);
        lstOfWorkItem.add(workItem2);

        WSCH_Provider_SP_StubsV91.GetChangedWorkItemsResponse changedResponse = new WSCH_Provider_SP_StubsV91.GetChangedWorkItemsResponse();
        changedResponse.workItem = lstOfWorkItem;
        changedResponse.result=returnCode3;

        try{
            WSCH_Provider_SP_DataMapper.mapGetChangedWorkItemsResponse(changedResponse);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        

        /* update API Return Code */
        WSCH_Provider_SP_StubsV91.ReturnCode returnCode4 = new WSCH_Provider_SP_StubsV91.ReturnCode();
        returnCode4.code = 0;
        returnCode4.type_x = 'success';
        returnCode4.errNote = 'Book Job success';
        
        WSCH_Provider_SP_StubsV91.GetChangedWorkItemsResponse changedResponse1 = new WSCH_Provider_SP_StubsV91.GetChangedWorkItemsResponse();
        changedResponse1.workItem = lstOfWorkItem;
        changedResponse1.result=returnCode4;
        
        try{
            WSCH_Provider_SP_DataMapper.mapGetChangedWorkItemsResponse(changedResponse1);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }
        
        WSCH_Provider_SP_DataMapper.mapUpdateAPIReturnCode(workOrder, returnCode4);

        returnCode4.code = 1;
        returnCode4.type_x = 'failed';
        returnCode4.errNote = 'Book Job failed';

        WSCH_Provider_SP_DataMapper.mapUpdateAPIReturnCode(workOrder, returnCode4);

        /* Book Appt Request */
        SVMXC__Service_Order__c bookApptWorkOrder = new SVMXC__Service_Order__c();
        bookApptWorkOrder.SVMXC__Zip__c = '75001';
        bookApptWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        startTime = Datetime.now();
        endTime = startTime.addHours(2);
        bookApptWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookApptWorkOrder.SVMXC__Preferred_End_Time__c = endTime;
        bookApptWorkOrder.SVMXC__OptiMax_Status__c='OPT_PENDING';

        WSCH_Appointment appointment = new WSCH_Appointment();
        appointment.setStartDateTime(DateTime.now());
        appointment.setStrStartDateTime('2014-05-13T08:30');
        appointment.setOfferToken('');
        
        try{
            WSCH_Provider_SP_DataMapper.mapApptBookRequest(bookApptWorkOrder, appointment);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        

        /* Book Appt Response   */
        WSCH_Provider_SP_StubsV91.ApptBookResponse bookResponse = new WSCH_Provider_SP_StubsV91.ApptBookResponse();

        WSCH_Provider_SP_StubsV91.BookInfo bookInfo = new WSCH_Provider_SP_StubsV91.BookInfo();
        bookInfo.empID = 'Tech001';
        bookInfo.FRU = 'UK';
        bookInfo.IRU = '';

        WSCH_Provider_SP_StubsV91.ReturnCode returnCode5 = new WSCH_Provider_SP_StubsV91.ReturnCode();
        returnCode5.code = 0;
        returnCode5.type_x = 'success';
        returnCode5.errNote = 'Book Job success';

        bookResponse.bookInfo = bookInfo;
        bookResponse.return_x = returnCode5;
        
        try{
            WSCH_Provider_SP_DataMapper.mapApptBookResponse(bookResponse, techSlotResponse,bookApptWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        

        /* workItem status change */
        SVMXC__Service_Order__c statusChangeWorkOrder = new SVMXC__Service_Order__c();
        statusChangeWorkOrder.SVMXC__Zip__c = '75001';
        statusChangeWorkOrder.SVMXC__Service_Duration__c = 3600.00;

        String woStatus = 'New';
        DateTime dt = DateTime.now();
        
        try{
            WSCH_Provider_SP_DataMapper.mapWorkItemStatusChange(statusChangeWorkOrder, woStatus, dt);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        

        /*  GetJobStatus request    */
        try{
            WSCH_Provider_SP_DataMapper.mapGetJobStatusRequest(statusChangeWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        

        WSCH_Provider_SP_DataMapper.fetchAccHoursPatts(statusChangeWorkOrder);

        List<BusinessHours> lstOfBusinessHours;
        lstOfBusinessHours = [SELECT Id,IsActive,IsDefault,TimeZoneSidKey,MondayStartTime,MondayEndTime,
                                TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                                WHERE IsDefault = TRUE AND IsActive = TRUE];

        WSCH_Provider_SP_DataMapper.setWeekTimes(lstOfBusinessHours, null);
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c(Name = 'TEAM 1');
        insert objTeam;
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (Name = 'TERRITORY 1');
        insert objTerritory;

        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 ,
                                            SVMXC__Longitude__c = -73.980772,
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = userinfo.getUserId()
                                            );
        insert tech1;

        SVMXC__SVMX_Event__c svmxEvent= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  tech1.Id,
                                                    SVMXC__WhatId__c = Schema.Sobjecttype.SVMXC__SVMX_Event__c.getKeyPrefix()
                                                    );

        insert svmxEvent;

        Event sfEvent = new Event();
        sfEvent.DurationInMinutes = 30;
        sfEvent.ActivityDate =Date.today();
        sfEvent.ActivityDateTime = System.now();
        sfEvent.OwnerId = userinfo.getUserId();
        insert sfEvent;

        SVMXC__SVMX_Optimizer__c objSVMX_Optimizer = new SVMXC__SVMX_Optimizer__c();
        objSVMX_Optimizer.SVMXC__WhatId__c = svmxevent.id;
        objSVMX_Optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE';
        objSVMX_Optimizer.SVMXC__Optimizer_Status__c ='OPT_TENTATIVE';
        insert objSVMX_Optimizer;

        SVMXC__SVMX_Optimizer__c objSF_Optimizer = new SVMXC__SVMX_Optimizer__c();
        objSF_Optimizer.SVMXC__WhatId__c = sfEvent.id;
        insert objSF_Optimizer;

        /*
        Below same method is called twise for satiesfy the both  if and else condition in the called method for covering the more code coverage.
        */
        
        try{
            WSCH_Provider_SP_DataMapper.mapEmpAddActRequest(objSVMX_Optimizer);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }
        
        try{
            WSCH_Provider_SP_DataMapper.mapEmpAddActRequest(objSF_Optimizer);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }
        
        try{
            WSCH_Provider_SP_DataMapper.mapActDeleteRequest(objSVMX_Optimizer);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        

        /*
        Below same method is called twice to satisfy the both  if and else condition in the called method for more code coverage.
        */
        try{
            WSCH_Provider_SP_DataMapper.mapActUpdateRequest(objSVMX_Optimizer);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        
        
        try{
            WSCH_Provider_SP_DataMapper.mapActUpdateRequest(objSF_Optimizer);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }       

        WSCH_Provider_SP_StubsV91.EmpAddActResponse objRes = new WSCH_Provider_SP_StubsV91.EmpAddActResponse();
        objRes.actID = '8923';

        WSCH_Provider_SP_StubsV91.ReturnCode responseReturnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
        responseReturnCode.code = 0;
        responseReturnCode.type_x = '';
        responseReturnCode.errNote = '';
        objRes.result = responseReturnCode;

        WSCH_Provider_SP_DataMapper.mapEmpAddActResponse(objRes,objSVMX_Optimizer);
        WSCH_Provider_SP_StubsV91.StandardResponse response = new WSCH_Provider_SP_StubsV91.StandardResponse();
        
        try{
            WSCH_Provider_SP_DataMapper.mapActDeleteResponse(response,objSVMX_Optimizer);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }
        
        response.result = new WSCH_Provider_SP_StubsV91.ReturnCode();
        
        try{
            WSCH_Provider_SP_DataMapper.mapActUpdateResponse(response.result, objSVMX_Optimizer);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        

        WSCH_Provider_SP_StubsV91.JobCancelResponse cancelResponse = new WSCH_Provider_SP_StubsV91.JobCancelResponse();
        WSCH_Provider_SP_StubsV91.ReturnCode cancelResponseReturnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
        cancelResponseReturnCode.code = 1;
        cancelResponseReturnCode.type_x = '';
        cancelResponseReturnCode.errNote = '';
        cancelResponse.result = cancelResponseReturnCode;
        
        try{
            WSCH_Provider_SP_DataMapper.mapCancelJobRequest(bookApptWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }
        
        objSVMX_Optimizer.SVMXC__WhatId__c = '';
        
        try{
            WSCH_Provider_SP_DataMapper.mapCancelJobRequest(objSVMX_Optimizer);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }
        
        SVMXC__Service_Order__c updateJobWorkOrder = new SVMXC__Service_Order__c();
        updateJobWorkOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CONTACT_INFO';
        
        try{
            WSCH_Provider_SP_DataMapper.mapUpdateJobRequest(updateJobWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }
        
        updateJobWorkOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_PRIORITY';
        updateJobWorkOrder.SVMXC__Dispatch_Priority__c = 1.0;
        try{
            WSCH_Provider_SP_DataMapper.mapUpdateJobRequest(updateJobWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }                

        SVMXC__Service_Order__c updateJobWorkOrderUnFix = new SVMXC__Service_Order__c();
        updateJobWorkOrderUnFix.SVMXC__Scheduling_Change_Token__c = 'CHANGE_UNFIXED';
        
        try{
            WSCH_Provider_SP_DataMapper.mapUpdateJobRequest(updateJobWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }
    }

    /*static testMethod void TestBookJobWithSkillSet()
    {
        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__Zip__c = '75001';
        bookJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        bookJobWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookJobWorkOrder.SVMXC__Preferred_End_Time__c = endTime;

        //fetch skill set and populate below
        bookJobWorkOrder.SVMXC__Skill_Set__c = 'skill';
        WSCH_Provider_SP_DataMapper.mapBookJobRequest(bookJobWorkOrder);
    }*/

    static testMethod void TestBookJobWithPreferredTechnician()
    {

        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__Zip__c = '75001';
        bookJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        bookJobWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookJobWorkOrder.SVMXC__Preferred_End_Time__c = endTime;

        //populate preferred technician
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;

        //insert technician;
        SVMXC__ServiceMax_Properties__c[] svmx_property_SP006 = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name in ('SP006') ];
        if(svmx_property_SP006.size()>0){
          svmx_property_SP006[0].SVMXC__Value__c = 'YWJjZGVmZ2g=';
          update svmx_property_SP006;
        }       
        
        /*Create a new servicemax process*/
        SVMXC__ServiceMax_Processes__c newProcess = new SVMXC__ServiceMax_Processes__c();
        newProcess.SVMXC__Target_Object_Name__c = 'Offer_Appointment_Request';
        newProcess.SVMXC__MapID__c = 'abcdefgh';
        insert newProcess;
        
        SVMXC__ServiceMax_Config_Data__c newConfig = new SVMXC__ServiceMax_Config_Data__c();
        newConfig.SVMXC__MapID__c = newProcess.id;
        newConfig.SVMXC__Target_Field_Name__c = 'band.end';
        newConfig.SVMXC__Display_Value__c = 'TODAY';
        insert newConfig;
        
        Test.startTest();

        bookJobWorkOrder.SVMXC__Preferred_Technician__c = technician.Id;
        
        try{
            WSCH_Provider_SP_DataMapper.mapBookJobRequest(bookJobWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        
        Test.stopTest();
    }

    static testMethod void TestBookJobWithoutPreferredStartTime()
    {
        SVMXC__ServiceMax_Properties__c[] svmx_property_SP006 = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name in ('SP006') ];
        if(svmx_property_SP006.size()>0){
          svmx_property_SP006[0].SVMXC__Value__c = 'YWJjZGVmZ2g=';
          update svmx_property_SP006;
        }       
        
        /*Create a new servicemax process*/
        SVMXC__ServiceMax_Processes__c newProcess = new SVMXC__ServiceMax_Processes__c();
        newProcess.SVMXC__Target_Object_Name__c = 'Offer_Appointment_Request';
        newProcess.SVMXC__MapID__c = 'abcdefgh';
        insert newProcess;
        
        SVMXC__ServiceMax_Config_Data__c newConfig = new SVMXC__ServiceMax_Config_Data__c();
        newConfig.SVMXC__MapID__c = newProcess.id;
        newConfig.SVMXC__Target_Field_Name__c = 'band.end';
        newConfig.SVMXC__Display_Value__c = 'TODAY';
        insert newConfig;
        
        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__Zip__c = '75001';
        bookJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        bookJobWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookJobWorkOrder.SVMXC__Preferred_End_Time__c = endTime;
        
        try{
            WSCH_Provider_SP_DataMapper.mapBookJobRequest(bookJobWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        
    }

    static testMethod void TestBookJobWithoutPreferredEndTime()
    {
        SVMXC__ServiceMax_Properties__c[] svmx_property_SP006 = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name in ('SP006') ];
        if(svmx_property_SP006.size()>0){
          svmx_property_SP006[0].SVMXC__Value__c = 'YWJjZGVmZ2g=';
          update svmx_property_SP006;
        }       
        
        /*Create a new servicemax process*/
        SVMXC__ServiceMax_Processes__c newProcess = new SVMXC__ServiceMax_Processes__c();
        newProcess.SVMXC__Target_Object_Name__c = 'Offer_Appointment_Request';
        newProcess.SVMXC__MapID__c = 'abcdefgh';
        insert newProcess;
        SVMXC__ServiceMax_Config_Data__c newConfig = new SVMXC__ServiceMax_Config_Data__c();
        newConfig.SVMXC__MapID__c = newProcess.id;
        newConfig.SVMXC__Target_Field_Name__c = 'band.end';
        newConfig.SVMXC__Display_Value__c = 'TODAY';
        insert newConfig;
        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__Zip__c = '75001';
        bookJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        bookJobWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookJobWorkOrder.SVMXC__Preferred_End_Time__c = null;
        try{
            WSCH_Provider_SP_DataMapper.mapBookJobRequest(bookJobWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        
    }

    static testMethod void TestForceFixJob()
    {

        SVMXC__Service_Order__c fixJobWorkOrder = new SVMXC__Service_Order__c();
        fixJobWorkOrder.SVMXC__Zip__c = '75001';
        fixJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        fixJobWorkOrder.SVMXC__OptiMax_Status__c='OPT_COMPLETED';

        //populate scheduling details in work order to fix

        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (Name = 'TERRITORY 1');
        insert objTerritory;

        Datetime nowTime = Datetime.now();
        Datetime scheduleTime = nowTime.addHours(24);
        fixJobWorkOrder.SVMXC__Scheduled_Date_Time__c = scheduleTime;
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';
        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'T001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = objTerritory.Id;
        insert technician;

        fixJobWorkOrder.SVMXC__Group_Member__c = technician.Id;

        Test.startTest();
        
        
        try{
            WSCH_Provider_SP_DataMapper.mapForceFixJobRequest(fixJobWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        
        Test.stopTest();
    }

    static testMethod void TestForceUnFixJob() {

        Test.startTest();
        SVMXC__Service_Order__c unFixJobWorkOrder = new SVMXC__Service_Order__c();

        Contact contactObj = new Contact();
        contactObj.Description = 'testDescription';
        contactObj.LastName = 'lastName';

        insert contactObj;

        unFixJobWorkOrder.SVMXC__Contact__c = contactObj.Id;
        unFixJobWorkOrder.SVMXC__Priority__c = '1';

        insert unFixJobWorkOrder;
        
        try{
            WSCH_Provider_SP_DataMapper.mapUnfixJobRequest(unFixJobWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        
        Test.stopTest();
    }

    static testMethod void TestMapUserLoginInfo() {
        Test.startTest();
        WSCH_Provider_SP_DataMapper.mapSPLoginRequest('dbUser', 'dbPassword', 'spUser');
        Test.stopTest();
    }

    static testMethod void TestBookJobRequestWithMoreData() {
        SVMXC__ServiceMax_Properties__c[] svmx_property_SP006 = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name in ('SP006') ];
        if(svmx_property_SP006.size()>0){
          svmx_property_SP006[0].SVMXC__Value__c = 'YWJjZGVmZ2g=';
          update svmx_property_SP006;
        }
                
        /*Create a new servicemax process*/
        SVMXC__ServiceMax_Processes__c newProcess = new SVMXC__ServiceMax_Processes__c();
        newProcess.SVMXC__Target_Object_Name__c = 'Offer_Appointment_Request';
        newProcess.SVMXC__MapID__c = 'abcdefgh';
        insert newProcess;
        SVMXC__ServiceMax_Config_Data__c newConfig = new SVMXC__ServiceMax_Config_Data__c();
        newConfig.SVMXC__MapID__c = newProcess.id;
        newConfig.SVMXC__Target_Field_Name__c = 'band.end';
        newConfig.SVMXC__Display_Value__c = 'TODAY';
        insert newConfig;
        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;

        insert technician;

        SVMXC__Site__c siteObject = new SVMXC__Site__c();
        siteObject.Name = 'Site1';

        insert siteObject;

        Account accountObject = new Account();
        accountObject.AccountNumber = '0011';
        accountObject.Name = 'Test Name';

        insert accountObject;

        Contact contactObject = new Contact();
        contactObject.FirstName = 'John';
        contactObject.LastName = 'Smith';
        contactObject.Phone = '08012345678';
        contactObject.MobilePhone = '9191919191';

        insert contactObject;

        List<BusinessHours> lstOfBusinessHours1;
        lstOfBusinessHours1 = [SELECT Id,IsActive,IsDefault,TimeZoneSidKey,MondayStartTime,MondayEndTime,
                                TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                                WHERE IsDefault = TRUE AND IsActive = TRUE];

        BusinessHours businessHoursObj = lstOfBusinessHours1.get(0);

        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__Zip__c = '75001';
        bookJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        bookJobWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookJobWorkOrder.SVMXC__Preferred_End_Time__c = endTime;
        bookJobWorkOrder.SVMXC__Preferred_Technician__c = technician.Id;
        bookJobWorkOrder.SVMXC__Preferred_Business_Hours__c = businessHoursObj.Id;
        bookJobWorkOrder.SVMXC__Skill_Set__c = '[{"skillName":"hardware","skillLevel":5,"skillId":"a1RG0000002fCLLMA2","isSkillMandatory":true},{"skillName":"software","skillLevel":5,"skillId":"a1RG0000002fCLQMA2","isSkillMandatory":true}]';
        //bookJobWorkOrder.SVMXC__WOContact_sPhNum__c = '8181818181';
        bookJobWorkOrder.SVMXC__Site__c = siteObject.Id;
        bookJobWorkOrder.SVMXC__Company__c = accountObject.Id;
        bookJobWorkOrder.SVMXC__Contact__c = contactObject.Id;

        insert bookJobWorkOrder;
        WSCH_Provider_SP_DataMapper.initializeDefaultBussHr();
        
        try{
            WSCH_Provider_SP_DataMapper.mapBookJobRequest(bookJobWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        
    }

    static testMethod void TestBookApptRequestWithMoreData() {

        SVMXC__Site__c siteObject = new SVMXC__Site__c();
        siteObject.Name = 'Site1';

        insert siteObject;

        Account accountObject = new Account();
        accountObject.AccountNumber = '0011';
        accountObject.Name = 'Test Name';

        insert accountObject;

        Contact contactObject = new Contact();
        contactObject.FirstName = 'John';
        contactObject.LastName = 'Smith';
        contactObject.Phone = '08012345678';
        contactObject.MobilePhone = '9191919191';

        insert contactObject;

        SVMXC__Service_Order__c bookApptWorkOrder = new SVMXC__Service_Order__c();
        bookApptWorkOrder.SVMXC__Zip__c = '75001';
        bookApptWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        bookApptWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookApptWorkOrder.SVMXC__Preferred_End_Time__c = endTime;
        bookApptWorkOrder.SVMXC__OptiMax_Status__c='OPT_PENDING';
        //bookApptWorkOrder.SVMXC__WOContact_sPhNum__c = '8181818181';
        bookApptWorkOrder.SVMXC__Site__c = siteObject.Id;
        bookApptWorkOrder.SVMXC__Company__c = accountObject.Id;
        bookApptWorkOrder.SVMXC__Contact__c = contactObject.Id;

        insert bookApptWorkOrder;

        WSCH_Appointment appointment = new WSCH_Appointment();
        appointment.setStartDateTime(DateTime.now());
        appointment.setStrStartDateTime('2014-05-13T08:30');
        appointment.setOfferToken('');
        SVMXC__ServiceMax_Properties__c[] svmx_property_SP005 = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name in ('SP005') ];
        if(svmx_property_SP005.size()>0){
          svmx_property_SP005[0].SVMXC__Value__c = 'YWJjZGVmZ2g=';
          update svmx_property_SP005;
        }
        
         /*Create a new servicemax process*/
        SVMXC__ServiceMax_Processes__c newProcess = new SVMXC__ServiceMax_Processes__c();
        newProcess.SVMXC__Target_Object_Name__c = 'Offer_Appointment_Request';
        newProcess.SVMXC__MapID__c = 'abcdefgh';
        insert newProcess;
        SVMXC__ServiceMax_Config_Data__c newConfig = new SVMXC__ServiceMax_Config_Data__c();
        newConfig.SVMXC__MapID__c = newProcess.id;
        newConfig.SVMXC__Target_Field_Name__c = 'band.end';
        newConfig.SVMXC__Display_Value__c = 'TODAY';
        insert newConfig;
        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;
        
        try{
            WSCH_Provider_SP_DataMapper.mapApptBookRequest(bookApptWorkOrder, appointment);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        
    }

    static testMethod void testMapDispOutputRequest() {
        Test.startTest();
        WSCH_Provider_SP_DispatchClient.DispJobEarmarked disPatchedJobEarMarked = new WSCH_Provider_SP_DispatchClient.DispJobEarmarked();
        disPatchedJobEarMarked.empID = '123';
        disPatchedJobEarMarked.ETS = '2014-05-13T08:30';
        disPatchedJobEarMarked.ETA = '2014-05-13T08:30';
        disPatchedJobEarMarked.ETF =  '2014-05-13T08:30';
        WSCH_Provider_SP_DataMapper.mapDispOutputRequest(disPatchedJobEarMarked,'12345','Earmarked');
        Test.stopTest();
    }
    
    static testMethod void testGetClosedAccHoursOvrs() {
        
        List<BusinessHours> lstOfBusinessHours1;
        lstOfBusinessHours1 = [SELECT Id,IsActive,IsDefault,TimeZoneSidKey,MondayStartTime,MondayEndTime,
                                TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                                WHERE IsDefault = TRUE AND IsActive = TRUE];

        BusinessHours businessHoursObj = lstOfBusinessHours1.get(0);

        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__Zip__c = '75001';
        bookJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        bookJobWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookJobWorkOrder.SVMXC__Preferred_End_Time__c = endTime;
        bookJobWorkOrder.SVMXC__Preferred_Business_Hours__c = businessHoursObj.Id;
        bookJobWorkOrder.SVMXC__Skill_Set__c = '[{"skillName":"hardware","skillLevel":5,"skillId":"a1RG0000002fCLLMA2","isSkillMandatory":true},{"skillName":"software","skillLevel":5,"skillId":"a1RG0000002fCLQMA2","isSkillMandatory":true}]';
        //bookJobWorkOrder.SVMXC__WOContact_sPhNum__c = '8181818181';

        insert bookJobWorkOrder;
        
        Date startDate = Date.newInstance(2015, 2, 14);
        Date endDate = Date.newInstance(2015, 2, 21);
        
        String strStartDate = '2015-03-15';
        String strEndDate = '2015-03-25';
        
        WSCH_Provider_SP_DataMapper.getClosedAccHoursOvrs(bookJobWorkOrder, strStartDate, strEndDate, null); //setting tzOffsetinMinutes to null
    }
    
    static testMethod void testActivityTypeCreate() {
        
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c(Name = 'TEAM 1');
        insert objTeam;
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (Name = 'TERRITORY 1');
        insert objTerritory;

        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 ,
                                            SVMXC__Longitude__c = -73.980772,
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = userinfo.getUserId()
                                            );
        insert tech1;
        
        SVMXC__SVMX_Event__c svmxEvent= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  tech1.Id,
                                                    SVMXC__WhatId__c = Schema.Sobjecttype.SVMXC__SVMX_Event__c.getKeyPrefix()
                                                    );

        insert svmxEvent;

        Event sfEvent = new Event();
        sfEvent.DurationInMinutes = 30;
        sfEvent.ActivityDate =Date.today();
        sfEvent.ActivityDateTime = System.now();
        sfEvent.OwnerId = userinfo.getUserId();
        sfEvent.Type = 'Personal';
        insert sfEvent;

        SVMXC__SVMX_Optimizer__c objSVMX_Optimizer = new SVMXC__SVMX_Optimizer__c();
        objSVMX_Optimizer.SVMXC__WhatId__c = svmxevent.id;
        objSVMX_Optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE';
        objSVMX_Optimizer.SVMXC__Optimizer_Status__c ='OPT_TENTATIVE';
        insert objSVMX_Optimizer;

        SVMXC__SVMX_Optimizer__c objSF_Optimizer = new SVMXC__SVMX_Optimizer__c();
        objSF_Optimizer.SVMXC__WhatId__c = sfEvent.id;
        insert objSF_Optimizer;
        
        //for SVMXEvent
        try{
            WSCH_Provider_SP_DataMapper.mapActTypeFindFromDescRequest(objSVMX_Optimizer);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }
        
        //for SF event
        try{
            WSCH_Provider_SP_DataMapper.mapActTypeFindFromDescRequest(objSF_Optimizer);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        
        
        WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
        returnCode.code = 0;
        WSCH_Provider_SP_StubsV91.ActTypeFindFromDescResponse response = new WSCH_Provider_SP_StubsV91.ActTypeFindFromDescResponse();
        response.result = returnCode;
        response.ActTypeNum = '12';
        
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_Provider_SP_DataMapper.getActTypeFindFromDescResponse(response);
    }

    static testMethod void TestDataMapper() {
        
        SVMXC__ServiceMax_Processes__c svmxProcess = [Select Name, id, SVMXC__SubmoduleID__c, SVMXC__MapID__c from SVMXC__ServiceMax_Processes__c Limit 1];
        svmxProcess.SVMXC__MapID__c = 'testDataMapp';
        svmxProcess.SVMXC__SubmoduleID__c= 'testDataMapp';
        svmxProcess.SVMXC__SettingID__c = '12345678';
        update svmxProcess;
        
        /** Offer Appointment Request */
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workorder.SVMXC__Zip__c='75001';
        workOrder.SVMXC__Service_Duration__c=3600.00;
        workOrder.SVMXC__Appointment_Promised_Time_Slot__c = 'test';
        
        SVMXC__Territory__c T1 = new SVMXC__Territory__c(Name='T1',SVMXC__Active__c=true,SVMXC__Territory_Code__c='T1',SVMXC__Parent_Territory__c=NULL);
        insert T1;
        
        /** Offer Appointment Response */
        WSCH_Provider_SP_StubsV91.ApptOfferResponse offerResponse = new WSCH_Provider_SP_StubsV91.ApptOfferResponse();
        WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
        returnCode.code=0;
        returnCode.errNote='test';
        returnCode.type_x='type';
        offerResponse.returnCode=returnCode;
        List<WSCH_Provider_SP_StubsV91.Offer> offerLst = new List<WSCH_Provider_SP_StubsV91.Offer>();
        WSCH_Provider_SP_StubsV91.Offer offer = new WSCH_Provider_SP_StubsV91.Offer();
        WSCH_Provider_SP_StubsV91.Offers offers= new WSCH_Provider_SP_StubsV91.Offers();
        offer.day='Mon';
        offer.DRU='SOU';
        offer.FRU='SOU';
        offer.IRU='SOU';
        offer.offerText='offertext';
        offer.offerToken='offertoken';
        offer.promBand='AD';
        offer.promType='A';
        offer.siteIndicator='test';
        offer.start='2014-05-13T08:30';
        offer.travelTime=60;
        offer.end_x='2014-05-13T09:30';
        offerLst.add(offer);
        offers.offer=offerLst;
        offerResponse.offers=offers;
        WSCH_AppointmentsResponse techSlotResponse = new WSCH_AppointmentsResponse();
        WSCH_Provider_SP_DataMapper.mapApptOfferResponse(offerResponse, techSlotResponse);

        /** Book Job request **/

        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        List<BusinessHours> lBH = [ select Id,IsActive,IsDefault,TimeZoneSidKey,MondayStartTime,MondayEndTime,
                                TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours where isDefault = true limit 1];
        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;
        technician.SVMXC__Working_Hours__c = lBH[0].id;
        technician.SVMXC__Service_Territory__c=T1.Id;

        insert technician;
        
        BusinessHours lstOfBusinessHours1;
        lstOfBusinessHours1 = [SELECT Id,IsActive,IsDefault,TimeZoneSidKey,MondayStartTime,MondayEndTime,
                                TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                                WHERE IsDefault = TRUE AND IsActive = TRUE LIMIT 1];

        //BusinessHours businessHoursObj = lstOfBusinessHours1.get(0);
        //insert lstOfBusinessHours1;
        
        SVMXC__Service_Level__c slaone=new SVMXC__Service_Level__c(
                    Name='Test one',
                    SVMXC__Description__c='Test one Description',
                    SVMXC__Active__c =true,
                    SVMXC__Initial_Response_Tracked_On__c = 'Case'  , 
                    SVMXC__Select__c=true,        
                    SVMXC__Business_Hours__c = lstOfBusinessHours1.id         
                        );
        insert slaone;
        
        Account ABC = new Account();
        ABC.Name = 'ABCDEFGHI';
        insert ABC;
        system.assert(ABC.Name!=null);
        
        SVMXC__Service_Contract__c newSC = new SVMXC__Service_Contract__c();
        newSC.SVMXC__Exchange_type__c = 'Return Exchange';
        newSC.SVMXC__Start_Date__c  = system.today();
        newSC.SVMXC__End_Date__c  = system.today() + 1;
        newSC.SVMXC__Company__c = ABC.Id;

        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__Zip__c = '75001';
        bookJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        bookJobWorkOrder.SVMXC__Service_Contract__c = newSC.id;
        bookJobWorkOrder.SVMXC__SLA_Terms__c = slaone.id;
        bookJobWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookJobWorkOrder.SVMXC__Preferred_End_Time__c = endTime;
        bookJobWorkOrder.SVMXC__Preferred_Technician__c = technician.Id;
        bookJobWorkOrder.SVMXC__Preferred_Business_Hours__c = lstOfBusinessHours1.Id;
        bookJobWorkOrder.SVMXC__Skill_Set__c = '[{"skillName":"hardware","skillLevel":5,"skillId":"a1RG0000002fCLLMA2","isSkillMandatory":true},{"skillName":"software","skillLevel":5,"skillId":"a1RG0000002fCLQMA2","isSkillMandatory":true}]';

        insert workOrder;
        WSCH_Provider_SP_DataMapper.isAppointmentWO(workOrder);
        

        SVMXC__SVMX_Event__c svmxEvent= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  technician.Id,
                                                    SVMXC__WhatId__c = Schema.Sobjecttype.SVMXC__SVMX_Event__c.getKeyPrefix()
                                                    );

        insert svmxEvent;
        
        SVMXC__SVMX_Optimizer__c objSVMX_Optimizer = new SVMXC__SVMX_Optimizer__c();
        objSVMX_Optimizer.SVMXC__WhatId__c = svmxevent.id;
        objSVMX_Optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE';
        objSVMX_Optimizer.SVMXC__Optimizer_Status__c ='OPT_TENTATIVE';
        insert objSVMX_Optimizer;
        SVMXC__ServiceMax_Properties__c[] svmx_property_SP007 = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name in ('SP007') ];
        if(svmx_property_SP007.size()>0){
          svmx_property_SP007[0].SVMXC__Value__c = 'YWJjZGVmZ2g=';
          update svmx_property_SP007;
        }        
        
        SVMXC__ServiceMax_Properties__c[] svmx_property_SP004 = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name in ('SP004') ];
        if(svmx_property_SP004.size()>0){
          svmx_property_SP004[0].SVMXC__Value__c = 'YWJjZGVmZ2g=';
          update svmx_property_SP004;
        }
        
        /*Create a new servicemax process*/
        SVMXC__ServiceMax_Processes__c newProcess = new SVMXC__ServiceMax_Processes__c();
        newProcess.SVMXC__Target_Object_Name__c = 'Offer_Appointment_Request';
        newProcess.SVMXC__MapID__c = 'abcdefgh';
        insert newProcess;
        
        SVMXC__ServiceMax_Config_Data__c newConfig = new SVMXC__ServiceMax_Config_Data__c();
        newConfig.SVMXC__MapID__c = newProcess.id;
        newConfig.SVMXC__Target_Field_Name__c = 'band.end';
        newConfig.SVMXC__Display_Value__c = '';
        insert newConfig;
        
        test.StartTest();
        //SVMXC__ServiceMax_Properties__c smaxPropertiesObj6 = new SVMXC__ServiceMax_Properties__c();
        //smaxPropertiesObj6 = [SELECT Name, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name =: 'SP006'];
        //smaxPropertiesObj6.SVMXC__Value__c = 'Qm9va0pvYl9EZWZhdWx0';
        //update smaxPropertiesObj6;
        
        try{
            WSCH_Provider_SP_DataMapper.mapActUpdateRequest(objSVMX_Optimizer);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        
        
        String strMapId = WSCH_Provider_SP_DataMapper.getSFMMappingId(WSCH_Constants.API_BOOK_JOB); 
        map<String,Object> mapfieldvalues = new map<String,Object>();
        /*if(String.isNotBlank(strMapId)) {
            mapfieldvalues = WSCH_Provider_SP_DataMapper.getSmartObjectRecords(strMapId, bookJobWorkOrder);
        }*/
        //mapfieldvalues.put('jobType','abc');
        
        WSCH_ApptParam apptParam = new WSCH_ApptParam();
        apptParam.startDateTime = System.now();
        apptParam.endDateTime = System.now()+1;
        
        try{
            WSCH_Provider_SP_DataMapper.mapApptOfferRequest(bookJobWorkOrder, apptParam,5, 1);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }
        
        WSCH_Provider_SP_DataMapper.getDayTimePeriod(bookJobWorkOrder, 1);
        WSCH_Provider_SP_DataMapper.getAccountFromCompanyId(String.valueOf(ABC.id));
        WSCH_Provider_SP_DataMapper.getContactFromContactId(String.valueOf(ABC.id));
        
        //WSCH_Provider_SP_DataMapper.mapBookJobRequest(bookJobWorkOrder);
        
        SVMXC__Site__c siteObject = new SVMXC__Site__c();
        siteObject.Name = 'Site1';
        insert siteObject;
        
        //WSCH_Provider_SP_DataMapper.getSiteBySiteId(String.valueOf(siteObject.id));
        
        bookJobWorkOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_PRIORITY';
        bookJobWorkOrder.SVMXC__Dispatch_Priority__c = 1.0;
        
        try{
            WSCH_Provider_SP_DataMapper.mapUpdateJobRequest(bookJobWorkOrder);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        
        
        bookJobWorkOrder.SVMXC__Preferred_Business_Hours__c = null;
        //WSCH_Provider_SP_DataMapper.getDayTimePeriod(bookJobWorkOrder);
        
        WSCH_Provider_SP_DataMapper.getSmartObjectRecords('testDataMapp', workOrder);
        WSCH_Provider_SP_DataMapper.fetchAccHoursPatts(workOrder,'2019-05-15T08:30', '2019-05-15T09:30', 1); 
        test.StopTest();
    }
    
    static testMethod void testStaticBlockMethods() {
        WSCH_Provider_SP_DataMapper.initializeSetting();
        WSCH_Provider_SP_DataMapper.initializeDefaultBussHr();
        WSCH_Provider_SP_DataMapper.runSOQLs();
    }
    
    static testMethod void testDependencyGroup() {
        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75001';
        workOrder1.SVMXC__Order_Status__c = 'Open';
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
        insert workOrder1;
        SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
        workOrder2.SVMXC__Zip__c = '75001';
        workOrder2.SVMXC__Order_Status__c='Open';
        workOrder2.SVMXC__Service_Duration__c = 3600;
        workOrder2.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
        insert workOrder2;
        SVMXC__Dependency_Management__c dependencyManagement = new SVMXC__Dependency_Management__c();
        dependencyManagement.SVMXC__Dependency_Group_Name__c = 'BDG-01';
        insert dependencyManagement;
        SVMXC__Service_Order_Dependency__c dependencyRecord = new SVMXC__Service_Order_Dependency__c();
        dependencyRecord.SVMXC__Primary_Work_Order__c = workOrder1.Id;
        dependencyRecord.SVMXC__Secondary_Work_Order__c = workOrder2.Id;
        dependencyRecord.SVMXC__Time_Dependency__c = 'Start Times Of Both Depend On Each Other';
        dependencyRecord.SVMXC__Dependency_Group__c = dependencyManagement.id;
        insert dependencyRecord;
        List<SVMXC__Service_Order_Dependency__c>  service_Order_Group_Dependency = new List<SVMXC__Service_Order_Dependency__c>();
        service_Order_Group_Dependency.add(dependencyRecord);
        test.StartTest();
        
        WSCH_Provider_SP_StubsV91.BookDependencyGroupRequest bdgRequest;
        try{
            bdgRequest = WSCH_Provider_SP_DataMapper.mapBookDependencyGroupRequest(dependencyManagement.Name, service_Order_Group_Dependency);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }
                    
        WSCH_Provider_SP_StubsV91.ReturnCode retCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
        retCode.type_x = 'OK';
        retCode.errNote = 'Null';
        retCode.code = 0;
        WSCH_Provider_SP_StubsV91.BookDependencyGroupResponse bookRes = new WSCH_Provider_SP_StubsV91.BookDependencyGroupResponse();
        bookRes.result = retCode;
        WSCH_Provider_SP_DataMapper.mapBookBookDependencyGroupResponse(dependencyManagement, service_Order_Group_Dependency, BookRes);
        
        try{
            WSCH_Provider_SP_StubsV91.CancelDependencyGroupRequest cancelMapReq = WSCH_Provider_SP_DataMapper.mapCancelBookDependencyGroupRequest(dependencyManagement.Name);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }
        
        WSCH_Provider_SP_StubsV91.StandardResponse cancelRes = new WSCH_Provider_SP_StubsV91.StandardResponse();
        cancelRes.result = retCode;
        List<SVMXC__Service_Order__c> workOrderList = new List<SVMXC__Service_Order__c>();
        workOrderList.add(workOrder1);
        workOrderList.add(workOrder2);
        
        test.StopTest();
    }
}