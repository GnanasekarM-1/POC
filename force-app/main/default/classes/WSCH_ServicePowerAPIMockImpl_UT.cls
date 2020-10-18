@isTest
global class WSCH_ServicePowerAPIMockImpl_UT implements WebServiceMock {
   global void doInvoke(Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
       
       //If BookAppt Request call BookApptMock API
       if(request instanceof WSCH_Provider_SP_StubsV91.ApptBookRequest){
           response.put('response_x', bookApptMock());
       }
       
       //If OfferAppt Request call OfferApptMock API
       if(request instanceof WSCH_Provider_SP_StubsV91.ApptOfferRequest){
           response.put('response_x', offerApptMock());
       }
       
       if(request instanceof WSCH_Provider_SP_StubsV91.ChangeWorkItemStatusRequest){
           response.put('response_x', changeWorkItemStatus());
       } 
       
       if(request instanceof WSCH_Provider_SP_StubsV91.GetChangedWorkItemsRequest){
           response.put('response_x', getChangedWorkOrders());
       }
       
       if(request instanceof WSCH_Provider_SP_StubsV91.GetJobStatusRequest){
           response.put('response_x', getJobStatus((WSCH_Provider_SP_StubsV91.GetJobStatusRequest)request));
       }
       
       //If Book Job request call Book Job API
       if(request instanceof WSCH_Provider_SP_StubsV91.JobBookRequest){
           response.put('response_x', bookJob());
       }
       
       //If add activity request call addAct API
       if(request instanceOf WSCH_Provider_SP_StubsV91.EmpAddActRequest) {
            response.put('response_x', addAct());
       }
       
       //If delete activity request call deleteAct API
       if(request instanceOf WSCH_Provider_SP_StubsV91.ActDeleteRequest) {
            response.put('response_x', deleteAct());
       }
       
        //If update activity request call updateAct API
       if(request instanceOf WSCH_Provider_SP_StubsV91.ActUpdateRequest) {
            response.put('response_x' , updateAct());
       }
       
       //If cancelJob activity request call cancelJob API
       if(request instanceOf WSCH_Provider_SP_StubsV91.JobCancelRequest) {
            response.put('response_x', cancelJob());
       }
       
       //If cancelJob activity request call cancelJob API
       if(request instanceOf WSCH_Provider_SP_StubsV91.JobCancelRequest) {
            response.put('response_x', cancelJob());
       }
       
       //If updateJob activity request call updateJob API
       if(request instanceOf WSCH_Provider_SP_StubsV91.JobUpdateRequest) {
            response.put('response_x', updateJob());
       }
       
       if(request instanceOf WSCH_Provider_SP_StubsV91.ActTypeFindFromDescRequest) {
            response.put('response_x', getActTypeNum());
       }
       
   }
   
   private Object bookApptMock(){
    
       WSCH_Provider_SP_StubsV91.ApptBookResponse apptBookResponse = new WSCH_Provider_SP_StubsV91.ApptBookResponse();
       WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
       returnCode.code = 0;    
       apptBookResponse.return_x = returnCode;
       apptBookResponse.return_x.errNote = 'No Error Testing';
       WSCH_Provider_SP_StubsV91.BookInfo bookInfo = new WSCH_Provider_SP_StubsV91.BookInfo(); 
       bookInfo.FRU = 'SOU';
       bookInfo.IRU = 'SOU';
       apptBookResponse.bookInfo = bookInfo;
       
       return apptBookResponse;
   }
   
   private Object offerApptMock() {
    
       WSCH_Provider_SP_StubsV91.ApptOfferResponse apptOfferRes = new WSCH_Provider_SP_StubsV91.ApptOfferResponse();
       WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
       returnCode.code = 0;    
       apptOfferRes.returnCode = returnCode;
       apptOfferRes.returnCode.errNote = 'No Error Testing';
       WSCH_Provider_SP_StubsV91.Offer slot= new WSCH_Provider_SP_StubsV91.Offer();
       slot.start = '2014-03-17T08:00';
       slot.offerToken = '123456789';
       slot.end_x = '2014-03-17T14:00';
       WSCH_Provider_SP_StubsV91.Offer[] offerList = new WSCH_Provider_SP_StubsV91.Offer[]{slot};
       WSCH_Provider_SP_StubsV91.Offers offers = new WSCH_Provider_SP_StubsV91.Offers();
       offers.offer = offerList;
       apptOfferRes.offers = offers ;
       
       return apptOfferRes;
   }
   
   private Object changeWorkItemStatus(){
        WSCH_Provider_SP_StubsV91.ChangeWorkItemStatusResponse response_x = new WSCH_Provider_SP_StubsV91.ChangeWorkItemStatusResponse();
        WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
        returnCode.code = 0;
        returnCode.errNote = 'No Error Testing';
        response_x.result = returnCode;
        return response_x;
   }
   
   private Object getChangedWorkOrders() {
    
        WSCH_Provider_SP_StubsV91.GetChangedWorkItemsResponse response = new WSCH_Provider_SP_StubsV91.GetChangedWorkItemsResponse();
        WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
        returnCode.code = 0;
        returnCode.errNote = 'No Error Testing';
        response.result = returnCode;
        WSCH_Provider_SP_StubsV91.GCJWorkItemAttr eachWorkItem = new WSCH_Provider_SP_StubsV91.GCJWorkItemAttr();
        eachWorkItem.workItemID = 'a1IG000000Pm06M';
        WSCH_Provider_SP_StubsV91.GCJAttr workItem = new WSCH_Provider_SP_StubsV91.GCJAttr();
        workItem.empID = 'SMITH';
        workItem.arrival = '2014-03-17T08:00';
        workItem.start = '2014-03-17T09:00';
        workItem.finish = '2014-03-17T10:00';
        workItem.disStatus = 'Completed';
        eachWorkItem.attr = workItem;
        WSCH_Provider_SP_StubsV91.GCJWorkItemAttr[] workItemArray = new WSCH_Provider_SP_StubsV91.GCJWorkItemAttr[] {eachWorkItem};
        response.workItem = workItemArray;
        
        return response;
   }
   
   private Object getJobStatus(WSCH_Provider_SP_StubsV91.GetJobStatusRequest req) {
        
        WSCH_Provider_SP_StubsV91.GetJobStatusResponse response = new WSCH_Provider_SP_StubsV91.GetJobStatusResponse();
        WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
        returnCode.code = 0;
        returnCode.errNote = 'No Error Testing';
        response.currentStatus = 'Tentative';
        response.result = returnCode;
        
        return response;
   }
   
   private Object bookJob(){
    
    WSCH_Provider_SP_StubsV91.JobBookResponse response = new WSCH_Provider_SP_StubsV91.JobBookResponse();
    WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
    returnCode.code = 0;
    returnCode.errNote = 'No Error Testing';
    response.result = returnCode;
    return response;
   }
   
   private Object addAct() {
    WSCH_Provider_SP_StubsV91.EmpAddActResponse response = new WSCH_Provider_SP_StubsV91.EmpAddActResponse();
    WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
    returnCode.code = 0;
    returnCode.errNote = 'Add activity successful';
    response.result = returnCode;
    
    return response;
   }
   
   private Object deleteAct() {
    WSCH_Provider_SP_StubsV91.StandardResponse response = new WSCH_Provider_SP_StubsV91.StandardResponse();
    WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
    returnCode.code = 0;
    returnCode.errNote = 'Delete activity successful';
    response.result = returnCode;
    
    return response;
   }
   
   private Object cancelJob() {
    WSCH_Provider_SP_StubsV91.JobCancelResponse response = new WSCH_Provider_SP_StubsV91.JobCancelResponse();
    WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
    returnCode.code = 0;
    returnCode.errNote = 'Job Canceled successfully';
    response.result = returnCode;
    
    return response;
   }
   
   private Object updateJob() {
    WSCH_Provider_SP_StubsV91.StandardResponse response = new WSCH_Provider_SP_StubsV91.StandardResponse();
    WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
    returnCode.code = 0;
    returnCode.errNote = 'Update activity successful';
    response.result = returnCode;
    
    return response;
   }
   
   
   private Object updateAct() {
    WSCH_Provider_SP_StubsV91.StandardResponse response = new WSCH_Provider_SP_StubsV91.StandardResponse();
    WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
    returnCode.code = 0;
    returnCode.errNote = 'Update activity successful';
    response.result = returnCode;
    
    return response;
   }
   
   private Object getActTypeNum() {
    WSCH_Provider_SP_StubsV91.ActTypeFindFromDescResponse response = new WSCH_Provider_SP_StubsV91.ActTypeFindFromDescResponse();
    WSCH_Provider_SP_StubsV91.ReturnCode returnCode = new WSCH_Provider_SP_StubsV91.ReturnCode();
    returnCode.code = 0;
    returnCode.errNote = 'Get Activity type num was successful';
    response.result = returnCode;
    response.ActTypeNum = '12';
    
    return response;
   }
}