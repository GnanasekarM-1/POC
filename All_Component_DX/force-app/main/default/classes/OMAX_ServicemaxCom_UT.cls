@isTest
(SeeAllData = True)
Private class OMAX_ServicemaxCom_UT {

    static testMethod void OMAX_ServicemaxCom_UT() {
        Test.startTest();
        OMAX_ServicemaxCom.organization org  = new OMAX_ServicemaxCom.organization();
        OMAX_ServicemaxCom.parameter param  = new OMAX_ServicemaxCom.parameter();
        OMAX_ServicemaxCom.territorySchedule TerritorySchedule  = new OMAX_ServicemaxCom.territorySchedule();
        List<OMAX_ServicemaxCom.territorySchedule> ListTerritory = new List<OMAX_ServicemaxCom.territorySchedule>();
        OMAX_ServicemaxCom.status Status  = new OMAX_ServicemaxCom.status();
        OMAX_ServicemaxCom.OMAX_Org_Definition_WSResponse OrgDefResponse  = new OMAX_ServicemaxCom.OMAX_Org_Definition_WSResponse();
        OMAX_ServicemaxCom.OMAX_Org_Definition_WS OrgDefinition  = new OMAX_ServicemaxCom.OMAX_Org_Definition_WS();
        OMAX_ServicemaxCom.organizationParameter orgparam  = new OMAX_ServicemaxCom.organizationParameter();
        OMAX_ServicemaxCom.OptimaxServicePort OmaxServicePort= new OMAX_ServicemaxCom.OptimaxServicePort();
        OMAX_ServicemaxCom.OMAX_Dispatch_Process_Definition_WS DCdef = new OMAX_ServicemaxCom.OMAX_Dispatch_Process_Definition_WS();
        OMAX_ServicemaxCom.OMAX_Dispatch_Process_Definition_WSResponse DCdefResponse= new OMAX_ServicemaxCom.OMAX_Dispatch_Process_Definition_WSResponse();
        OMAX_ServicemaxCom.credential Credential= new OMAX_ServicemaxCom.credential();
        OMAX_ServicemaxCom.OMAX_Execute_Job_WS exeJob = new OMAX_ServicemaxCom.OMAX_Execute_Job_WS();
        OMAX_ServicemaxCom.OMAX_Execute_Job_WSResponse execJobWsResp = new OMAX_ServicemaxCom.OMAX_Execute_Job_WSResponse();
        OMAX_ServicemaxCom.OMAX_Suspend_Job_WS suspendJob = new OMAX_ServicemaxCom.OMAX_Suspend_Job_WS();
        OMAX_ServicemaxCom.OMAX_Suspend_Job_WSResponse suspendJobResp = new OMAX_ServicemaxCom.OMAX_Suspend_Job_WSResponse();
        Test.stopTest();
    }
    
   /* static testMethod void OMAX_ServicemaxCom_UT2() {
        OMAX_ServicemaxCom.OptimaxServicePort port = new OMAX_ServicemaxCom.OptimaxServicePort();
        Test.setMock(WebServiceMock.class, new OMAX_Execute_Job_WS_Impl());
        OMAX_ServicemaxCom.status statusObj = port.OMAX_Execute_Job_WS(new OMAX_ServicemaxCom.credential(), 'jobId');
        System.assertEquals('SUCCESS', statusObj.status);
    }
    
    static testMethod void OMAX_ServicemaxCom_UT3() {
        OMAX_ServicemaxCom.OptimaxServicePort port = new  OMAX_ServicemaxCom.OptimaxServicePort();
        Test.setMock(WebServiceMock.class, new OMAX_Org_Definition_WS_Impl());
        OMAX_ServicemaxCom.status statusObj = port.OMAX_Org_Definition_WS(new OMAX_ServicemaxCom.credential(), new OMAX_ServicemaxCom.organization(), 'New', 'Enable');
        System.assertEquals('SUCCESS', statusObj.status);
    }
    
    static testMethod void OMAX_ServicemaxCom_UT4() {
        OMAX_ServicemaxCom.OptimaxServicePort port = new  OMAX_ServicemaxCom.OptimaxServicePort();
        Test.setMock(WebServiceMock.class, new OMAX_Dispatch_Process_Definition_WS_Impl());
        OMAX_ServicemaxCom.status statusObj = port.OMAX_Dispatch_Process_Definition_WS(new OMAX_ServicemaxCom.credential(), 'orgId', 'dispatchProcessId', new OMAX_ServicemaxCom.territorySchedule[]{});
        System.assertEquals('SUCCESS', statusObj.status);
    }
    
    static testMethod void OMAX_ServicemaxCom_UT5() {
        OMAX_ServicemaxCom.OptimaxServicePort port = new  OMAX_ServicemaxCom.OptimaxServicePort();
        Test.setMock(WebServiceMock.class, new OMAX_Suspend_Job_WS_Impl());
        OMAX_ServicemaxCom.status statusObj = port.OMAX_Suspend_Job_WS(new OMAX_ServicemaxCom.credential(), 'jobId');
        System.assertEquals('SUCCESS', statusObj.status);
    }*/
    
    public class OMAX_Execute_Job_WS_Impl implements WebServiceMock {
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
            OMAX_ServicemaxCom.OMAX_Execute_Job_WSResponse respElement = new OMAX_ServicemaxCom.OMAX_Execute_Job_WSResponse();
            OMAX_ServicemaxCom.status statusObj = new OMAX_ServicemaxCom.status();
            statusObj.status = 'SUCCESS';
            respElement.return_x = statusObj;
            response.put('response_x', respElement);
        }
    }
    
    public class OMAX_Org_Definition_WS_Impl implements WebServiceMock {
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
            OMAX_ServicemaxCom.OMAX_Org_Definition_WSResponse respElement = new OMAX_ServicemaxCom.OMAX_Org_Definition_WSResponse();
            OMAX_ServicemaxCom.status statusObj = new OMAX_ServicemaxCom.status();
            statusObj.status = 'SUCCESS';
            respElement.return_x = statusObj;
            response.put('response_x', respElement);
        }
    }
    
    public class OMAX_Dispatch_Process_Definition_WS_Impl implements WebServiceMock {
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
            OMAX_ServicemaxCom.OMAX_Dispatch_Process_Definition_WSResponse respElement = new OMAX_ServicemaxCom.OMAX_Dispatch_Process_Definition_WSResponse();
            OMAX_ServicemaxCom.status statusObj = new OMAX_ServicemaxCom.status();
            statusObj.status = 'SUCCESS';
            respElement.return_x = statusObj;
            response.put('response_x', respElement);
        }
    }
    
    public class OMAX_Suspend_Job_WS_Impl implements WebServiceMock {
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
            OMAX_ServicemaxCom.OMAX_Suspend_Job_WSResponse respElement = new OMAX_ServicemaxCom.OMAX_Suspend_Job_WSResponse();
            OMAX_ServicemaxCom.status statusObj = new OMAX_ServicemaxCom.status();
            statusObj.status = 'SUCCESS';
            respElement.return_x = statusObj;
            response.put('response_x', respElement);
        }
    }
}