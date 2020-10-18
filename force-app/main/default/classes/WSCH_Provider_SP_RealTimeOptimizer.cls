/**
A concrete ServicePower related implementation class for the IRealTimeOptimizer.
This class encapsulates all the logic of invoking SP webservices related to real time optimization such as bookJob,
getChangedJobs etc. In addition to invoking the webservices, it is the responsibility of this class to perform
the data transformations from input to webservice request and webservice response to required output format using
data mappers.
*/

public class WSCH_Provider_SP_RealTimeOptimizer implements WSCH_IRealTimeOptimizer {
    
    private Integer callOutsPending = WSCH_Constants.MAX_CALLOUTS;
    
    public static String dpId;
    public static Set<Id> setWoIds;
    public static Set<Id> setWoDispProcIds = new Set<Id>();
    
    public static Map<Id, List<String>> mapWrkOrdResPref = new Map<Id, List<String>>();
    public static Map<Id, String> mapDpIdSpUrl = new Map<Id, String>();
    public static Map<Id, String> mapWoConName;
    public static Map<String, String> mapEventConn;
    public static Map<String, String> mapWoIDName;
    public static Map<String,String> mapEventTech = new Map<String,String>();
    public static Set<Id> setSvmxTech = new Set<Id>(), setSfOwner = new Set<Id>();
    public static Map<String, String> mapFruConn;
    public static Map<String, String> mapTerrFruTemp;
    public static List<SVMXC__Territory__c> lstTerrUpd;
    public static Set<String> setTechTerr;
    public static Map<String, SVMXC__ServiceMax_Properties__c> allSpSettings = new Map<String, SVMXC__ServiceMax_Properties__c>();
    public static String strDefaultConnection;
    
    static {
        dpId = WSCH_CommonUtils.getDispatchProcessIdByName(WSCH_Constants.MOCK_DISPATCH_PROCESS);
        WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::static block: dpId - ' + dpId);
    }
    
    /**
?  Invokes the following SP API?s based on the SVMXC__Scheduling_Change_Token__c of work order.

o  BookJob
o  CancelJob
o  ChangeWorkItemStatus
o  UpdateJob
o  ForcefixJob
o  ForceBook


?  Invokes the GetChangedWorkItems web service call to get the latest changes using the timestamp logged before the first work order?s BookJob call is made.
?  Populates the WSCH_WorkOrderResponse with the input list of work orders (status code & status messages) and list of technician events (WSCH_TechnicianEvent objects) received from GetChangedWorkItems call.
?  Also works for retry AP call attempts for failed workorders.

*/
    public WSCH_WorkOrderResponse manageWorkOrders (List<SVMXC__Service_Order__c> workOrders) {
        WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::manageWorkOrders():strOldWO..'+WSCH_TriggerHandler.strOldWO);
        if(workOrders == null || workOrders.size() == 0){
            WSCH_AuditLogger.warn('WSCH_Provider_SP_RealTimeOptimizer::manageWorkOrders()::Invalid input.There are no work orders to be managed');
            throw new WSCH_EXCEPTION('Invalid input. There is no work orders to be managed');
        }
        
        List<SVMXC__Service_Order__c> batchList = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> retryBatchList = new List<SVMXC__Service_Order__c>();
        WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::manageWorkOrders()::start, No of Queries used in this transaction so far: ' + Limits.getQueries());
        WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::manageWorkOrders()::workOrders.size() - ' + workOrders.size());
        WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::manageWorkOrders()::WSCH_Constants.WO_BATCH_SIZE - ' + WSCH_Constants.WO_BATCH_SIZE);
        if(workOrders.size() > WSCH_Constants.WO_BATCH_SIZE){   //workOrders.size() > 9
            for (Integer workOrderIndex = workOrders.size()-1 ; workOrderIndex > WSCH_Constants.WO_BATCH_SIZE - 1 ; workOrderIndex--) { //workOrderIndex > 8
                SVMXC__Service_Order__c workOrder = workOrders.get(workOrderIndex);
                //Based on SVMXC__Scheduling_Retry_Count__c , decides whether new work order or retry work order.
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::manageWorkOrders():: Inside batch for loop ' );
                if(null == workOrder.SVMXC__Scheduling_Retry_Count__c || workOrder.SVMXC__Scheduling_Retry_Count__c == 0) {
                    workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_BATCH;
                    batchList.add(workOrder);
                } else {
                    workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_RETRY_BATCH;
                    retryBatchList.add(workOrder);
                }
                workOrders.remove(workOrderIndex);
            }
        }
        
        WSCH_WorkOrderResponse workOrderResponse = new WSCH_WorkOrderResponse();
        Map<String, String> terrFRUMap = WSCH_CommonUtils.getTerritoryFRUMap(workOrders);
        Set<String> fruChangesToGet = new Set<String>();
        String startTime = WSCH_DateUtils.getCurrentTimeStamp();
        boolean anySuccess = false;
        
        try{
            populateWORelatedIds(workOrders);
            populateWorkOrderResPrefMap(workOrders);
            //Populate map of Work Order Dispatch Process, and Connection Name.
            populateDispatchProcessSpURL(workOrders);
            lstTerrUpd = new List<SVMXC__Territory__c>();
            for (SVMXC__Service_Order__c workOrder : workOrders) {
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::manageWorkOrders()::Scheduling Change Token: '+workOrder.SVMXC__Scheduling_Change_Token__c);
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::manageWorkOrders(): Limits.getHeapSize() - ' + Limits.getHeapSize());
                system.debug('WSCH_Provider_SP_RealTimeOptimizer::manageWorkOrders(): Limits.getHeapSize() - ' + Limits.getHeapSize());
                //Checks whether call out is possible in the same transction, else add to batch list.
                if(!canCallOut(workOrder, fruChangesToGet, terrFRUMap)) {
                    //Based on SVMXC__Scheduling_Retry_Count__c , decides whether new work order or retry work order.
                    if(null == workOrder.SVMXC__Scheduling_Retry_Count__c || workOrder.SVMXC__Scheduling_Retry_Count__c == 0) {
                        workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_BATCH;
                        batchList.add(workOrder);
                    } else {
                        workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_RETRY_BATCH;
                        retryBatchList.add(workOrder);
                    }
                    continue;
                }
                
                //Changes work order status to pending prior to SP API Call.
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                
                //Updates the retry count.
                if(null == workOrder.SVMXC__Scheduling_Retry_Count__c || workOrder.SVMXC__Scheduling_Retry_Count__c == 0) {
                    workOrder.SVMXC__Scheduling_Retry_Count__c = 1;
                } else {
                    workOrder.SVMXC__Scheduling_Retry_Count__c = workOrder.SVMXC__Scheduling_Retry_Count__c + 1;
                }
                
                //Calls respective SP API based on SVMXC__Scheduling_Change_Token__c.
                if(WSCH_Constants.BOOKJOB_SCHDL_CHANGE_TOKENS.contains(workOrder.SVMXC__Scheduling_Change_Token__c)) {
                    //if(isWorkOrderValid(workOrder)) {
                    bookJob(workOrder);
                    //}
                } else if (WSCH_Constants.UPDATEJOB_SCHDL_CHANGE_TOKENS.contains(workOrder.SVMXC__Scheduling_Change_Token__c)) {
                    updateJob(workOrder);
                } else if ('CHANGE_STATUS'.equalsIgnoreCase(workOrder.SVMXC__Scheduling_Change_Token__c)) {
                    updateStatus(workOrder);
                } else if ('CHANGE_SCHEDULING_STATUS'.equalsIgnoreCase(workOrder.SVMXC__Scheduling_Change_Token__c)) {
                    changeWorkItemStatus(workOrder,WSCH_CommonUtils.getServicePowerJobStatus(workOrder.SVMXC__Work_Order_Scheduling_Status__c),Datetime.now());
                } else if('CHANGE_CANCEL_WO'.equalsIgnoreCase(workOrder.SVMXC__Scheduling_Change_Token__c)) {
                    cancelJob(workOrder);
                } else if(WSCH_Constants.FORCEFIXJOB_SCHDL_CHANGE_TOKENS.contains(workOrder.SVMXC__Scheduling_Change_Token__c)){
                    forceFixJob(workOrder);
                } else if('FORCE_SCHEDULE'.equalsIgnoreCase(workOrder.SVMXC__Scheduling_Change_Token__c)) {
                    forceBook(workOrder);
                }
                
                //Marks the territory to be fetched and adding the work order to success list.
                if(workOrder.SVMXC__OptiMax_Status__c.equals(WSCH_Constants.STATUS_OPT_TENTATIVE)) {
                    anySuccess = setFRU(workOrder,terrFRUMap,fruChangesToGet);
                } else if(workOrder.SVMXC__OptiMax_Status__c.equals(WSCH_Constants.STATUS_OPT_BATCH)) {
                    batchList.add(workOrder);
                    continue;
                }
                
                workOrderResponse.getLstWorkOrder().add(workOrder);
            }
            
            //Calls getChangedWorkOrders to get the updated work orders from SP.
            //Check if Push notification is enabled then skip the get changed workorders call.
            if('True' != WSCH_CommonUtils.getSettingValue('DCON004','SET010')){
                if(anySuccess) {
                    populateFruConNameMap(fruChangesToGet);
                    for(String fru: fruChangesToGet) {
                        WSCH_WorkOrderUpdateResponse woUpdateResponse = getChangedWorkOrders(fru, startTime);
                        List<WSCH_TechnicianEvent> events = woUpdateResponse.getWoResponse().getLstTechEvent();
                        if(null != events && events.size() > 0) {
                            workOrderResponse.getLstTechEvent().addAll(events);
                        }
                    }
                }
            }
            
        } catch (Exception ex) {
            String exceptionMsg = 'WSCH_Provider_SP_RealTimeOptimizer :: manageWorkOrders() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            throw new WSCH_EXCEPTION(exceptionMsg+ex.getStackTraceString());
        } finally {
            //Update the territory record for successful BookJob/BookAppointment Work Orders.
            if(!lstTerrUpd.isEmpty()){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstTerrUpd, COMM_SecurityUtils.Access.Updateable)){
                    Database.update(lstTerrUpd);
                }
            }
            //updte the manage work order batch list and start the manage work order batch processing.
            if(batchList.size() > 0) {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(batchList, COMM_SecurityUtils.Access.Updateable)){
                    update batchList;
                }
                WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.WO_BATCH_CLASS_NAME, WSCH_Constants.BATCH_APEX_START_TIME);
            }
            //updte the retry work order batch list and start the retry batch processing.
            if(retryBatchList.size() > 0) {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(retryBatchList, COMM_SecurityUtils.Access.Updateable)){
                    update retryBatchList;
                }
                
                WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.RETRY_WO_BATCH_CLASS_NAME, WSCH_Constants.BATCH_APEX_START_TIME);
            }
        }
        WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::manageWorkOrders()::end, No of Queries used in this transaction so far: ' + Limits.getQueries());
        return workOrderResponse;
    }
    
    private void bookJob(SVMXC__Service_Order__c workOrder) {
        
        try {
            WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::bookJob::Pending Callouts:'+callOutsPending);
            callOutsPending--;
            //String dpId=WSCH_CommonUtils.getDispatchProcessIdByName(WSCH_Constants.MOCK_DISPATCH_PROCESS);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::bookJob()::dpId - ' + dpId);
            //initialize and create map of WorkOrder Id, and Connection Name
            mapWoConName = new Map<Id, String>();
            getSpConnName(workOrder.SVMXC__Dispatch_Process__c, workOrder.SVMXC__Optimizer_Connection_Name__c, workOrder.Id);
            if(workOrder.SVMXC__Dispatch_Process__c != null && workOrder.SVMXC__Dispatch_Process__c == dpId) {
                //if dispatchProcess is a mock process execute mock book job
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::bookJob()::Invoked mock dispatch process');
                WSCH_Provider_SP_Utils.sp servicePowerMock = new WSCH_Provider_SP_Utils.sp();
                Integer startTime = Datetime.now().millisecond();
                WSCH_AuditLogger.setAPIName(WSCH_Constants.API_BOOK_JOB);
                WSCH_Provider_SP_StubsV91.JobBookResponse response = servicePowerMock.BookJob();
                System.debug('Mock WebService Response Time (In Milli Seconds) :: '+ (Datetime.now().millisecond() - startTime));
                WSCH_Provider_SP_DataMapper.mapBookJobResponse(workOrder, response);
            } else {
                //else execute bookJob
                //get the Connection Name for Work order, and set the corresponding Login Credentials in callout request.
                String strConName = mapWoConName.get(workOrder.Id);
                WSCH_Provider_SP_StubsV91.JobBookRequest request_x = WSCH_Provider_SP_DataMapper.mapBookJobRequest(workOrder);
                //set the login credentials as per the Work Order's Connection Name
                if(String.isNotBlank(strConName)){
                    request_x.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strConName);
                }
                WSCH_Status statusObj = new WSCH_Status();
                if(isJobBookRequestValid(request_x,workOrder)){
                    WSCH_AuditLogger.setAPIName(WSCH_Constants.API_BOOK_JOB);
                    WSCH_Provider_SP_StubsV91.JobBookResponse response = WSCH_Provider_SP_CalloutUtils.bookJob(workOrder,request_x,statusObj);
                    WSCH_Provider_SP_DataMapper.mapBookJobResponse(workOrder, response);
                }
            }
        } catch(Exception ex) {
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            String errorText = 'WSCH_Provider_SP_RealTimeOptimizer :: bookJob() '+ex.getMessage();
            WSCH_CommonUtils.setOptimizerErrorText(workOrder, errorText);
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: bookJob :: ' +  + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    
    public WSCH_Provider_SP_StubsV91.BookDependencyGroupResponse manageDependencyGroup(String multiJobId, List<Service_Order_Dependency__c> serviceOrderList) {
        WSCH_Provider_SP_StubsV91.BookDependencyGroupResponse response_x;
        try {
            List<SVMXC__Service_Order__c> relatedWorkOrders = new List<SVMXC__Service_Order__c>();
            List<String> dependentWorkOrderIds = new List<String>();
            Set<String> WOSetIds = new Set<String>();       
            for(Service_Order_Dependency__c serviceOrder : serviceOrderList){
                WOSetIds.add(serviceOrder.SVMXC__Primary_Work_Order__c);
                WOSetIds.add(serviceOrder.SVMXC__Secondary_Work_Order__c);
            }
            dependentWorkOrderIds.AddAll(WOSetIds);
            relatedWorkOrders = WSCH_CommonUtils.fetchWorkOrders(dependentWorkOrderIds);
            populateWorkOrderResPrefMap(relatedWorkOrders);
            mapWoConName = new Map<Id, String>();
            populateDispatchProcessSpURL(relatedWorkOrders);
            getSpURL('');
            WSCH_AuditLogger.debug('relatedWorkOrders: '+relatedWorkOrders);
            for(SVMXC__Service_Order__c WO: relatedWorkOrders){
                if((WO.SVMXC__Dispatch_Process__c != null) || (WO.SVMXC__Optimizer_Connection_Name__c != null)){
                    getSpConnName(WO.SVMXC__Dispatch_Process__c, WO.SVMXC__Optimizer_Connection_Name__c, WO.Id);
                }else{
                    mapWoConName.put(WO.Id, strDefaultConnection);
                }
            }
            
            SVMXC__Dependency_Management__c dependencyManagementRecord = new SVMXC__Dependency_Management__c();
            dependencyManagementRecord = [SELECT Id, Name, SVMXC__Dependency_Group_Name__c, SVMXC__Error_Text__c, SVMXC__Status__c FROM SVMXC__Dependency_Management__c Where Id =: multiJobId];
            //Multiple Instance Begin
            String strConName = '';
            if(!mapWoConName.isEmpty()){
                for(Service_Order_Dependency__c serviceOrder : serviceOrderList){
                    if(mapWoConName.get(serviceOrder.SVMXC__Primary_Work_Order__c)!=null){
                        strConName = mapWoConName.get(serviceOrder.SVMXC__Primary_Work_Order__c);
                    }
                    if(mapWoConName.get(serviceOrder.SVMXC__Secondary_Work_Order__c)!=null){
                        strConName = mapWoConName.get(serviceOrder.SVMXC__Secondary_Work_Order__c);
                    }
                }
            }
            WSCH_Provider_SP_StubsV91.BookDependencyGroupRequest request_x = WSCH_Provider_SP_DataMapper.mapBookDependencyGroupRequest(dependencyManagementRecord.Name, serviceOrderList);
            if(String.isNotBlank(strConName)){
                request_x.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strConName);
            }
            //Multiple Instance End
            WSCH_Status statusObj = new WSCH_Status();
            WSCH_AuditLogger.setAPIName(WSCH_Constants.API_BOOK_DEPENDANCY_GROUP);
            response_x = WSCH_Provider_SP_CalloutUtils.bookDependencyGroup(dependencyManagementRecord, serviceOrderList, request_x, statusObj);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::manageDependencyGroup::response_x:'+response_x);
            WSCH_Provider_SP_DataMapper.mapBookBookDependencyGroupResponse(dependencyManagementRecord, serviceOrderList, response_x);
        }catch(Exception ex) {
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: manageDependencyGroup() :: '+ex.getMessage());
        }        
        return response_x;
    }
    
    public WSCH_WorkOrderResponse manageDependencyBooking(List<SVMXC__Service_Order_Dependency__c>  lstOfServiceOrderGroupDependency, List<SVMXC__Service_Order__c> lstDependencyWOs) {
        
        return null;
    }
    
    public boolean setFRU(SVMXC__Service_Order__c workOrder,Map<String, String> terrFRUMap, Set<String> fruChangesToGet){
        
        if(workOrder.SVMXC__Service_Zone_ID__c != null) {
            fruChangesToGet.add(workOrder.SVMXC__Service_Zone_ID__c);
        } else if(workOrder.SVMXC__Primary_Territory__c != null) {
            String fru = terrFRUMap.get(workOrder.SVMXC__Primary_Territory__c);
            if(null != fru) {
                fruChangesToGet.add(fru);
            } else {
                String externalId = WSCH_CommonUtils.fetchExternalIdByTerritoryId(workOrder.SVMXC__Primary_Territory__c);
                fruChangesToGet.add(externalId);
            }
        }
        return true;
    }
    
    /**
Retrieve all the changed workorders from SP.
*/
    private WSCH_WorkOrderUpdateResponse getChangedWorkOrders(String fru, String timeStamp) {
        
        callOutsPending--;
        WSCH_WorkOrderUpdateResponse woUpdateResponse = new WSCH_WorkOrderUpdateResponse();
        try{
            String strFruConName = mapFruConn.get(fru);
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            WSCH_Provider_SP_StubsV91.GetChangedWorkItemsRequest request_x = WSCH_Provider_SP_DataMapper.mapGetChangedWorkItemsRequest(fru, timeStamp);
            if(String.isNotBlank(strFruConName)){
                request_x.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strFruConName);
                servicePowerWsdl.endpoint_x = getSpURL(strFruConName);
            }
            WSCH_Provider_SP_StubsV91.GetChangedWorkItemsResponse changedResponse = servicePowerWsdl.GetChangedWorkItems(request_x);
            woUpdateResponse = WSCH_Provider_SP_DataMapper.mapGetChangedWorkItemsResponse(changedResponse);
            /*if((lstTerrUpd != null) && (!lstTerrUpd.isEmpty()){
                //Database.update(lstTerrUpd);
            }*/
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: getChangedWorkOrders() :: '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return woUpdateResponse;
    }
    
    /**
Exposed method from SP-Adaptor for retrieving the Changed work orders from SP.
*/
    public WSCH_WorkOrderUpdateResponse getWorkOrderUpdates(SVMXC__Territory__c territory){
        
        WSCH_WorkOrderUpdateResponse woUpdateResponse = new WSCH_WorkOrderUpdateResponse();
        getSpURL('');
        if(territory.SVMXC__Optimizer_Last_Timestamp__c != null && !territory.SVMXC__Optimizer_Last_Timestamp__c.equals('0')){
            woUpdateResponse.setTimeStampOut(territory.SVMXC__Optimizer_Last_Timestamp__c);   
        }else{
            woUpdateResponse.setTimeStampOut(WSCH_DateUtils.getCurrentTimeStamp());
        }
        List<WSCH_TechnicianEvent>  updatedTechEvent = new List<WSCH_TechnicianEvent>();
        List<WSCH_Provider_SP_Push_Stubs.WorkItem>  updatedWorkItem = new List<WSCH_Provider_SP_Push_Stubs.WorkItem>();
        WSCH_WorkOrderResponse woResponse = new WSCH_WorkOrderResponse();
        do {
            if((mapFruConn == null) || (mapFruConn.get(territory.SVMXC__Optimizer_External_ID__c) == null)){
                mapFruConn = new Map<String, String>();
                if((territory.SVMXC__Optimizer_Connection_Name__c != null) && (String.isNotBlank(territory.SVMXC__Optimizer_Connection_Name__c))){
                    mapFruConn.put(territory.SVMXC__Optimizer_External_ID__c, territory.SVMXC__Optimizer_Connection_Name__c);
                }else{
                    mapFruConn.put(territory.SVMXC__Optimizer_External_ID__c, strDefaultConnection);
                }
            }
            woUpdateResponse = getChangedWorkOrders(territory.SVMXC__Optimizer_External_ID__c ,woUpdateResponse.getTimeStampOut());
            updatedTechEvent.addAll(woUpdateResponse.getWoResponse().getLstTechEvent());
            updatedWorkItem.addAll(woUpdateResponse.getWoResponse().getLstWorkItem());
        } while (woUpdateResponse.isMore() && callOutsPending > 0);
        woResponse.getLstTechEvent().addAll(updatedTechEvent);
        woResponse.getLstWorkItem().addAll(updatedWorkItem);
        woUpdateResponse.setWoResponse(woResponse);
        return woUpdateResponse;
    }
    
    /**
Following method makes a web service call to SP OfferAppts API.
*/
    public WSCH_AppointmentsResponse getAvailableAppointments(SVMXC__Service_Order__c workOrder , WSCH_ApptParam apptParamObj, Integer size, Integer currentIndex){
        
        WSCH_AppointmentsResponse techSlotResponse = new WSCH_AppointmentsResponse();
        List<SVMXC__Service_Order__c> lstApptWo = new List<SVMXC__Service_Order__c>();
        try{
            lstApptWo.add(workOrder);
            populateWorkOrderResPrefMap(lstApptWo);
            //get the Connection Name for Work order, and set the corresponding Login Credentials in callout request.
            populateDispatchProcessSpURL(lstApptWo);
            getSpConnName(workOrder.SVMXC__Dispatch_Process__c, workOrder.SVMXC__Optimizer_Connection_Name__c, workOrder.Id);
            String strConName = mapWoConName.get(workOrder.Id);
            SVMXC__Service_Order__c woObj = workOrder;
            WSCH_Provider_SP_StubsV91.ApptOfferRequest apptOfferReq = WSCH_Provider_SP_DataMapper.mapApptOfferRequest(woObj, apptParamObj, size, currentIndex);
            //set the login credentials as per the Work Order's Connection Name
            if(String.isNotBlank(strConName)){
                apptOfferReq.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strConName);
            }
            WSCH_AuditLogger.setLogContext(workOrder.Name);
            WSCH_Status statusObj = new WSCH_Status();
            WSCH_Provider_SP_StubsV91.ApptOfferResponse apptOfferRes = WSCH_Provider_SP_CalloutUtils.getAppointments(workOrder, apptOfferReq, statusObj);
            if(apptOfferRes != null) {
                WSCH_Provider_SP_DataMapper.mapApptOfferResponse(apptOfferRes, techSlotResponse);
                return techSlotResponse;
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: getAvailableAppointments() :: '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            throw new WSCH_Exception(ex.getMessage());
        }
        return null;
    }
    
    /**
?  Invoke the BookAppt web service call
?  Populates the WSCH_AppointmentsResponse with the status code and message of the API call.
?  Invoke the OfferAppts web service call again based on functional use cases (For example call OfferAppts on timeout?).
*/
    public WSCH_AppointmentsResponse bookAppointment(SVMXC__Service_Order__c workOrder, WSCH_Appointment slot){
        
        WSCH_AppointmentsResponse techSlotResponse = new WSCH_AppointmentsResponse();
        List<SVMXC__Service_Order__c> lstApptWo = new List<SVMXC__Service_Order__c>();
        lstTerrUpd = new List<SVMXC__Territory__c>();
        mapFruConn = new Map<String, String>();
        try{
            lstApptWo.add(workOrder);
            populateWorkOrderResPrefMap(lstApptWo);
            //get the Connection Name for Work order, and set the corresponding Login Credentials in callout request.
            populateDispatchProcessSpURL(lstApptWo);
            getSpConnName(workOrder.SVMXC__Dispatch_Process__c, workOrder.SVMXC__Optimizer_Connection_Name__c, workOrder.Id);
            String strConName = mapWoConName.get(workOrder.Id);
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
            WSCH_Provider_SP_StubsV91.ApptBookRequest apptBookReq = WSCH_Provider_SP_DataMapper.mapApptBookRequest(workOrder, slot);
            //set the login credentials as per the Work Order's Connection Name
            if(String.isNotBlank(strConName)){
                apptBookReq.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strConName);
            }
            WSCH_AuditLogger.setLogContext(workOrder.Name);
            if(isValidApptBookRequest(apptBookReq)){
                WSCH_Status statusObj = new WSCH_Status();
                WSCH_Provider_SP_StubsV91.ApptBookResponse apptBookResponse = WSCH_Provider_SP_CalloutUtils.bookAppointment(workOrder, apptBookReq, statusObj);
                WSCH_AuditLogger.debug('Inside sp_realTimeOptimizer bookAppt(), apptBookResponse - ' + apptBookResponse);
                System.debug('Inside sp_realTimeOptimizer bookAppt(), apptBookResponse - ' + apptBookResponse);
                if(apptBookResponse != null) {
                    WSCH_Provider_SP_DataMapper.mapApptBookResponse(apptBookResponse, techSlotResponse, workOrder);
                    if((apptBookResponse != null) && (apptBookResponse.bookInfo.FRU != null)){
                        mapFruConn.put(apptBookResponse.bookInfo.FRU, strConName);
                    }
                } else {
                    return null;
                }
            } else {
                //techSlotResponse.statusMessage = 'Failed to book appointment as the request is invalid';
                techSlotResponse.statusMessage = getTAG035();
                WSCH_AuditLogger.warn(techSlotResponse.statusMessage);
            }
            return techSlotResponse;
        }catch(CalloutException callOutEx){
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            String errorText = 'Failed to book appointment : ' + callOutEx.getMessage();
            WSCH_CommonUtils.setOptimizerErrorText(workOrder, errorText);
            //techSlotResponse.statusMessage = 'Failed to book appointment';
            techSlotResponse.statusMessage = getTAG036();
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: bookAppointment :: ' + callOutEx.getMessage() + '\n Stack Trace:: ' + callOutEx.getStackTraceString());
            throw new WSCH_Exception('Failed to make the bookAppointment SP API call.');
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: bookAppointment() :: '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        
        return techSlotResponse;
    }
    
    /**
Following method makes a web service call to SP ChangeWorkItemStatus API.
*/
    public boolean changeWorkItemStatus(SVMXC__Service_Order__c workOrder,String woStatus,Datetime updateDateTime){
        
        if (updateDateTime != null) {
            callOutsPending--;
            try {
                WSCH_Status statusObj = new WSCH_Status();
                //get the Connection Name for Work order, and set the corresponding Login Credentials in callout request.
                mapWoConName = new Map<Id, String>();
                getSpConnName(workOrder.SVMXC__Dispatch_Process__c, workOrder.SVMXC__Optimizer_Connection_Name__c, workOrder.Id);
                String strConName = mapWoConName.get(workOrder.Id);
                WSCH_Provider_SP_StubsV91.ChangeWorkItemStatusRequest changeWorkItemStatusReq = WSCH_Provider_SP_DataMapper.mapWorkItemStatusChange(workOrder, woStatus, updateDateTime);
                //set the login credentials as per the Work Order's Connection Name
                if(String.isNotBlank(strConName)){
                    changeWorkItemStatusReq.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strConName);
                }
                WSCH_AuditLogger.setAPIName(WSCH_Constants.API_CHANGE_WORK_ITEM_STATUS);
                WSCH_AuditLogger.setLogContext(workOrder.Name);
                WSCH_Provider_SP_StubsV91.ReturnCode returnCode = WSCH_Provider_SP_CalloutUtils.changeWorkItemStatus(workOrder, changeWorkItemStatusReq,statusObj);
                WSCH_Provider_SP_DataMapper.mapUpdateAPIReturnCode(workOrder, returnCode);
                if(workOrder.SVMXC__OptiMax_Status__c.equals(WSCH_Constants.STATUS_OPT_TENTATIVE)){
                    //if success, update the wo.pushMessageDateTime with current time in GMT
                    //this change is made during push scalability implementation(slow lane vs fast lane)
                    workOrder.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c = DateTime.now();
                    return true;
                }
            }catch(CalloutException callOutEx){
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
                WSCH_CommonUtils.setOptimizerErrorText(workOrder, 'Failed to change work item status : '  + callOutEx.getMessage());
                WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: changeWorkItemStatus :: ' + callOutEx.getMessage() + '\n Stack Trace:: ' + callOutEx.getStackTraceString());
            }catch(Exception ex){
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
                WSCH_CommonUtils.setOptimizerErrorText(workOrder, 'Failed to change work item status : '  + ex.getMessage());
                WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: changeWorkItemStatus() :: '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            }
        }
        return false;
    }
    
    /**
Following method gets the current job status of a SP job, based on which Change work items API call done.
**/
    public String getJobStatus(SVMXC__Service_Order__c workOrder) {
        
        callOutsPending--;
        try{
            WSCH_Status statusObj = new WSCH_Status();
            //get the Connection Name for Work order, and set the corresponding Login Credentials in callout request.
            mapWoConName = new Map<Id, String>();
            getSpConnName(workOrder.SVMXC__Dispatch_Process__c, workOrder.SVMXC__Optimizer_Connection_Name__c, workOrder.Id);
            String strConName = mapWoConName.get(workOrder.Id);
            WSCH_Provider_SP_StubsV91.GetJobStatusRequest getJobStatusReq = WSCH_Provider_SP_DataMapper.mapGetJobStatusRequest(workOrder);
            //set the login credentials as per the Work Order's Connection Name
            if(String.isNotBlank(strConName)){
                getJobStatusReq.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strConName);
            }
            WSCH_AuditLogger.setAPIName(WSCH_Constants.API_GET_JOB_STATUS);
            WSCH_AuditLogger.setLogContext(workOrder.Name);
            WSCH_Provider_SP_StubsV91.GetJobStatusResponse response = WSCH_Provider_SP_CalloutUtils.getJobStatus(workOrder,getJobStatusReq, statusObj);
            if(response != null) {
                WSCH_Provider_SP_DataMapper.mapUpdateAPIReturnCode(workOrder, response.result);
                if(WSCH_Provider_SP_ErrorCodesMapper.isSuccess(response.result.code)) {
                    return response.currentStatus;
                }
            }
        }catch(CalloutException callOutEx){
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            WSCH_CommonUtils.setOptimizerErrorText(workOrder, callOutEx.getMessage());
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: getJobStatus :: ' + callOutEx.getMessage()+ '\n Stack Trace:: ' + callOutEx.getStackTraceString());
        }catch(Exception ex){
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            WSCH_CommonUtils.setOptimizerErrorText(workOrder, ex.getMessage());
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: getJobStatus() :: '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return null;
    }
    
    /*public boolean isWorkOrderValid(SVMXC__Service_Order__c workOrder) {

//check for all the mandatory workorder fields for empty/null.If mandatory fields
// are not present then the work order is invalid
boolean isWOValid = false;
if(workOrder != null) {
WSCH_AuditLogger.debug('Inside isWorkOrderValid, workOrder.Id ' + workOrder.Id + 'workOrder.SVMXC__Zip__c ' + workOrder.SVMXC__Zip__c);
if(workOrder.Id != null && String.isNotEmpty(workOrder.SVMXC__Zip__c) && workOrder.SVMXC__Service_Duration__c != null) {
isWOValid = true;
}
}
if(!isWOValid){
String errorText = 'Work Order Id/Zip/Service Duration is null';
WSCH_CommonUtils.setOptimizerErrorText(workOrder, errorText);
workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
}
WSCH_AuditLogger.debug('isWOValid ' + isWOValid);
return isWOValid;
}*/
    
    public boolean isJobBookRequestValid(WSCH_Provider_SP_StubsV91.JobBookRequest request_x,SVMXC__Service_Order__c workOrder) {
        
        //check for all the mandatory fields for empty/null.If mandatory fields
        // are not present then the request is invalid
        boolean isJobBookRequestValid = false;
        if(request_x != null) {
            WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::isJobBookRequestValid():request_x.jobID :-' + request_x.jobID + 'request_x.postcode ' + request_x.postcode + 'request_x.extraDuration ' + request_x.extraDuration);
            //if(String.isNotEmpty(request_x.jobID) && String.isNotEmpty(request_x.postcode) && String.isNotEmpty(request_x.extraDuration)) {
            if(String.isNotEmpty(request_x.jobID) && String.isNotEmpty(request_x.postcode)) {
                isJobBookRequestValid = true;
            }
        }
        if(!isJobBookRequestValid){
            String errorText = 'Work Order Id/Zip/Service Duration is null';
            WSCH_CommonUtils.setOptimizerErrorText(workOrder, errorText);
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
        }
        WSCH_AuditLogger.debug('isJobBookRequestValid ' + isJobBookRequestValid);
        return isJobBookRequestValid;
    }
    
    /**
Check all the mandatory apptBookReq fields empty/null .
If Mandatory fields are not present then the ApptBook request is invalid.
*/
    public boolean isValidApptBookRequest(WSCH_Provider_SP_StubsV91.ApptBookRequest apptBookReq){
        
        boolean isApptBookReqValid = false;
        if(apptBookReq != null){
            isApptBookReqValid = String.isNotEmpty(apptBookReq.jobID);
            isApptBookReqValid = isApptBookReqValid && String.isNotEmpty(apptBookReq.jobType);
            isApptBookReqValid = isApptBookReqValid && String.isNotEmpty(apptBookReq.postcode);
            isApptBookReqValid = isApptBookReqValid && String.isNotEmpty(apptBookReq.date_x);
            isApptBookReqValid = isApptBookReqValid && String.isNotEmpty(apptBookReq.priority) && (Integer.valueof(apptBookReq.priority.trim()) > 0 || Integer.valueof(apptBookReq.priority.trim()) < 100);
            isApptBookReqValid = isApptBookReqValid && String.isNotEmpty(apptBookReq.importance) && (Integer.valueof(apptBookReq.importance.trim()) > -1 || Integer.valueof(apptBookReq.importance.trim()) < 10);
            
            if(apptBookReq.extraSkills != null && apptBookReq.extraSkills.reqSkills != null && apptBookReq.extraSkills.reqSkills.size() > 0){
                for(WSCH_Provider_SP_StubsV91.SkillWithLevel skill : apptBookReq.extraSkills.reqSkills){
                    isApptBookReqValid = isApptBookReqValid && String.isNotEmpty(skill.skillId);
                    isApptBookReqValid = isApptBookReqValid && String.isNotEmpty(skill.skillLevel);
                }
            }
            
            if(apptBookReq.reqEmps != null){
                isApptBookReqValid = isApptBookReqValid && apptBookReq.reqEmps.empIDs.size() > 0;
                isApptBookReqValid = isApptBookReqValid && String.isNotEmpty(apptBookReq.reqEmps.MPX);
            }
            
            if(apptBookReq.listReqEmps != null && apptBookReq.listReqEmps.reqEmp.size() > 0){
                for(WSCH_Provider_SP_StubsV91.reqEmp reqEmp : apptBookReq.listReqEmps.reqEmp){
                    isApptBookReqValid = isApptBookReqValid && String.isNotEmpty(reqEmp.empID);
                    isApptBookReqValid = isApptBookReqValid && String.isNotEmpty(reqEmp.MPX);
                }
            }
        }
        
        WSCH_AuditLogger.debug('isApptBookReqValid : '+isApptBookReqValid);
        return isApptBookReqValid;
    }
    
    /**
Extracts first 9 work orders from the work orders list and update their optimization status as per requirement,
which will be considered by respective Batch Apex class.
*/
    public List<SVMXC__Service_Order__c> getBatchList(List<SVMXC__Service_Order__c> workOrders, String optStatus) {
        
        List<SVMXC__Service_Order__c> updateOptBatchWOList = new List<SVMXC__Service_Order__c>();
        for (Integer workOrderIndex = workOrders.size() - 1; workOrderIndex > WSCH_Constants.WO_BATCH_SIZE - 1; workOrderIndex--){      //workOrderIndex > 8
            SVMXC__Service_Order__c workOrder = workOrders.get(workOrderIndex);
            workOrder.SVMXC__OptiMax_Status__c = optStatus;
            updateOptBatchWOList.add(workOrder);
            workOrders.remove(workOrderIndex);
        }
        
        return updateOptBatchWOList;
    }
    
    /**
?  Invokes the following SP API?s based on the type of change in non work order event.

o  EmpAddAct
o  ActUpdate
o  ActDelete

?  Invokes the GetChangedWorkItems web service call to get the latest changes using the timestamp logged before the first web service call.
?  Populates the WSCH_NonWOEventResponse with the updated list of events (status code & status messages) and list of technician events (WSCH_TechnicianEvent objects) received from GetChangedWorkItems call.
?  If the response error code is 371 , immediatly another call happens to sp without any ActOptions.

Following method invokes retrying failed the manage non workorder events.
Failed non work orders events are identified by SVMXC__Optimizer_Status__c having
OPT_FAIL or OPT_ERROR Value and having retry count less than equal to 3. As there is a probability of bulk objects can be requested for processing,
following method adds the remaining non work orders events(SVMXC__SVMX_Optimizer__c) to appropiate batch(WSCH_SP_ManageNonWOEventsBatchApex or WSCH_SP_ManageNonWOEventsBatchApex)
based on retry count. If retry count is null or 0 , following methos considers it as a new request else a retry request.
*/
    public WSCH_NonWOEventResponse manageNonWorkOrderEvents(List<SVMXC__SVMX_Optimizer__c> events){
        
        if(events == null || events.size() == 0){
            WSCH_AuditLogger.debug('Invalid input.There is non work order events to be managed');
            throw new WSCH_EXCEPTION('Invalid input. There is non work order events to be managed');
        }
        
        List<SVMXC__SVMX_Optimizer__c> batchList = new List<SVMXC__SVMX_Optimizer__c>();
        List<SVMXC__SVMX_Optimizer__c> retryBatchList = new List<SVMXC__SVMX_Optimizer__c>();
        if(events.size() > WSCH_Constants.EVENT_BATCH_SIZE){        //events.size() > 9
            for (Integer eventIndex = events.size() - 1; eventIndex > WSCH_Constants.EVENT_BATCH_SIZE - 1; eventIndex--){       //eventIndex > 8
                SVMXC__SVMX_Optimizer__c event = events.get(eventIndex);
                if(event.SVMXC__Optimizer_Retry_Count__c == null ||  event.SVMXC__Optimizer_Retry_Count__c == 0) {
                    event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_BATCH;
                    batchList.add(event);
                }else {
                    event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_RETRY_BATCH;
                    retryBatchList.add(event);
                }
                events.remove(eventIndex);
            }
        }
        
        WSCH_NonWOEventResponse response = new WSCH_NonWOEventResponse();
        Set<String> fruChangesToGet = new Set<String>();
        //Map<String, String> terrFRUMap = WSCH_CommonUtils.getTerritoryFRUMap(events);
        String startTime = WSCH_DateUtils.getCurrentTimeStamp();
        boolean anySuccess = false;
        try{
            //creates a map of Event and its related Technician Team's Connection Name
            getEventSpConn(events);
            Map<String, String> terrFRUMap = new Map<String, String>(mapTerrFruTemp);
            for (SVMXC__SVMX_Optimizer__c event : events) {
                WSCH_AuditLogger.info('Token :::::::'+event.SVMXC__Optimizer_Change_Token__c);
                if(WSCH_CommonUtils.isEventValid(event)) {
                    if(!canCallOut(event, fruChangesToGet, terrFRUMap)) {
                        if(event.SVMXC__Optimizer_Retry_Count__c == null ||  event.SVMXC__Optimizer_Retry_Count__c == 0) {
                            event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_BATCH;
                            batchList.add(event);
                        }else {
                            event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_RETRY_BATCH;
                            retryBatchList.add(event);
                        }
                        continue;
                    }
                    event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                    if(null == event.SVMXC__Optimizer_Retry_Count__c) {
                        event.SVMXC__Optimizer_Retry_Count__c = 1;
                    } else {
                        event.SVMXC__Optimizer_Retry_Count__c = event.SVMXC__Optimizer_Retry_Count__c + 1;
                    }
                    if (event.SVMXC__Optimizer_Change_Token__c.equalsIgnoreCase('CHANGE_CREATE')) {
                        standardActivityCreate(event);
                    } else if (event.SVMXC__Optimizer_Change_Token__c.equalsIgnoreCase('CHANGE_UPDATE')) {
                        standardActivityUpdate(event);
                    } else if (event.SVMXC__Optimizer_Change_Token__c.equalsIgnoreCase('CHANGE_DELETE')) {
                        stardardActivityDelete(event);
                    } else if (event.SVMXC__Optimizer_Change_Token__c.equalsIgnoreCase('CHANGE_UPDATE_TECH')) {
                        stardardActivityDelete(event);
                        standardActivityCreate(event);
                    }
                    
                    if(event.SVMXC__Optimizer_Status__c.equals(WSCH_Constants.STATUS_OPT_TENTATIVE)) {
                        SVMXC__Service_Group_Members__c technician = WSCH_CommonUtils.getNonWOEventTechnician (event);
                        if (technician != null) {
                            fruChangesToGet.add(terrFRUMap.get(technician.SVMXC__Service_Territory__r.Id));
                            anySuccess = true;
                        }
                    }
                    
                    response.getEvents().add(event);
                } else {
                    WSCH_AuditLogger.warn('Not a Valid Event : '+event);
                }
            }
            
            //Commented as Push notification will take care of this
            //Check if Push notification is enabled then skip the get changed workorders call.
            if('True' != WSCH_CommonUtils.getSettingValue('DCON004','SET010')){
                if(anySuccess) {
                    populateFruConNameMap(fruChangesToGet);
                    for(String fru: fruChangesToGet) {
                        WSCH_WorkOrderUpdateResponse woUpdateResponse = getChangedWorkOrders(fru, startTime);
                        List<WSCH_TechnicianEvent> techEvents = woUpdateResponse.getWoResponse().getLstTechEvent();
                        if(null != techEvents && techEvents.size() > 0) {
                            response.getTechEvents().addAll(techEvents);
                        }
                    }
                }
            }
        } catch (Exception ex) {
            String exceptionMsg = 'WSCH_Provider_SP_RealTimeOptimizer :: manageNonWorkOrderEvents() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            throw new WSCH_EXCEPTION(exceptionMsg+ex.getStackTraceString());
        } finally {
            if(batchList.size() > 0) {
                update batchList;
                WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.MANAGE_NON_WO_BATCH_CLASS_NAME, WSCH_Constants.BATCH_APEX_START_TIME);
            }
            if(retryBatchList.size() > 0) {
                update retryBatchList;
                WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.RETRY_FAILED_NON_WO_EVENT_BATCH, WSCH_Constants.BATCH_APEX_START_TIME);
            }
        }
        
        return response;
    }
    
    
    /**
Following method invokes cancel job SP API for deleted work orders.
This method is also used for processing the failed Workorders.Failed work orders are identified by SVMXC__Optimizer_Status__c having
OPT_FAIL or OPT_ERROR Value and having retry count less than equal to 3. As there is a probability of bulk objects can be requested for processing,
following method adds the remaining work orders(SVMXC__SVMX_Optimizer__c) to appropiate batch(WSCH_SP_CancelWorkOrderBatchApex or WSCH_SP_RetryCancelWOBatchApex)
based on retry count. If retry count is null or 0 , following methos considers it as a new request else a retry request.
**/
    public List<SVMXC__SVMX_Optimizer__c> cancelWorkOrders(List<SVMXC__SVMX_Optimizer__c> workOrders) {
        
        if(workOrders == null || workOrders.size() == 0){
            WSCH_AuditLogger.warn('Invalid input. There is no work order events to be deleted');
            throw new WSCH_EXCEPTION('Invalid input. There is no work order events to be deleted');
        }
        String logContext = '';
        Set<String> setWoNum = new Set<String>();
        List<SVMXC__SVMX_Optimizer__c> batchList = new List<SVMXC__SVMX_Optimizer__c>();
        List<SVMXC__SVMX_Optimizer__c> retryBatchList = new List<SVMXC__SVMX_Optimizer__c>();
        if(workOrders.size() > WSCH_Constants.WO_BATCH_SIZE + 1){       //workOrders.size() > 10
            for (Integer woIndex = workOrders.size() - 1; woIndex > WSCH_Constants.WO_BATCH_SIZE - 1; woIndex--){       //woIndex > 8
                SVMXC__SVMX_Optimizer__c workOrder = workOrders.get(woIndex);
                if(workOrder.SVMXC__Optimizer_Retry_Count__c == null ||  workOrder.SVMXC__Optimizer_Retry_Count__c == 0) {
                    workOrder.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_BATCH;
                    batchList.add(workOrder);
                }else {
                    workOrder.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_RETRY_BATCH;
                    retryBatchList.add(workOrder);
                }
                workOrders.remove(woIndex);
            }
        }
        
        try {
            //collect all the Work Order Numbers in a set.
            for (SVMXC__SVMX_Optimizer__c workOrder : workOrders) {
                if(workOrder.SVMXC__WhatId__c != null){
                    setWoNum.add(workOrder.SVMXC__WhatId__c);
                }
            }
            getCancelWorkOrders(setWoNum);
            for (SVMXC__SVMX_Optimizer__c workOrder : workOrders) {
                if(workOrder.SVMXC__WhatId__c != null) {
                    workOrder.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                    if(null == workOrder.SVMXC__Optimizer_Retry_count__c) {
                        workOrder.SVMXC__Optimizer_Retry_count__c = 1;
                    } else {
                        workOrder.SVMXC__Optimizer_Retry_count__c = workOrder.SVMXC__Optimizer_Retry_count__c + 1;
                    }
                    cancelJob(workOrder);
                    
                    //adding cancelled WO names to the logcontext
                    if((logContext.length() + 11) < 255) {
                        logContext = logContext + workOrder.Name + ', ';
                        WSCH_AuditLogger.setLogContext(logContext);
                    }
                }
            }
        } catch (Exception ex) {
            String exceptionMsg = 'WSCH_Provider_SP_RealTimeOptimizer:cancelWorkOrders()';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            throw new WSCH_EXCEPTION(exceptionMsg+ex.getStackTraceString());
        } finally {
            if(batchList.size() > 0) {
                update batchList;
                WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.CANCEL_WO_BATCH_APEX, WSCH_Constants.BATCH_APEX_START_TIME);
            }
            if(retryBatchList.size() > 0) {
                update retryBatchList;
                WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.RETRY_CANCEL_WO_BATCH_APEX, WSCH_Constants.BATCH_APEX_START_TIME);
            }
        }
        
        return workOrders;
    }
    
    /**
Following method performs EmpAddAct web service call to SP.
**/
    private void standardActivityCreate(SVMXC__SVMX_Optimizer__c event){
        
        //callOutsPending--;
        callOutsPending = callOutsPending - 3;      //callOutsPending - 2
        try {
            Long startTime = Datetime.now().getTime();
            WSCH_Status statusObj = new WSCH_Status();
            //get the Connection Name for Event, and set the corresponding Login Credentials in callout request.
            String strEventConnName = mapEventConn.get(event.SVMXC__WhatId__c);
            //map the requestObject and call the getActivityTypeForDesc() API to get the activity Type from SP
            WSCH_Provider_SP_StubsV91.ActTypeFindFromDescRequest actTypeFindRequest = WSCH_Provider_SP_DataMapper.mapActTypeFindFromDescRequest(event);
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            //set the login credentials as per the event's Connection Name
            if(String.isNotBlank(strEventConnName)){
                actTypeFindRequest.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strEventConnName);
                servicePowerWsdl.endpoint_x = getSpURL(strEventConnName);
            }
            
            String strActTypeSetting, strActTypeNum, strActTypeDesc;
            if(actTypeFindRequest != null && actTypeFindRequest.Desc_x != null && actTypeFindRequest.Desc_x != 'null') {
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityCreate(): actTypeFindRequest.Desc_x - ' + actTypeFindRequest.Desc_x);
                WSCH_Provider_SP_StubsV91.ActTypeFindFromDescResponse actTypeResponse = servicePowerWsdl.ActTypeFindFromDesc(actTypeFindRequest);
                strActTypeNum = WSCH_Provider_SP_DataMapper.getActTypeFindFromDescResponse(actTypeResponse);
                strActTypeDesc = actTypeFindRequest.Desc_x;
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityCreate(): strActTypeNum - ' + strActTypeNum);
            } else {
                //setting value format is 'Personal'
                strActTypeSetting = WSCH_CommonUtils.getSettingValue('DCON004','SET011');
                if(strActTypeSetting != null && String.isNotBlank(strActTypeSetting)) {
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityCreate():strActTypeSetting - ' + strActTypeSetting);
                    //map the requestObject and call the getActivityTypeForDesc() API to get the activity Type from SP
                    WSCH_Provider_SP_StubsV91.ActTypeFindFromDescRequest request_x = new WSCH_Provider_SP_StubsV91.ActTypeFindFromDescRequest();
                    //request_x.login = WSCH_Provider_SP_DataMapper.fetchLoginInfo();
                    //set the login credentials as per the event's Connection Name
                    if(String.isNotBlank(strEventConnName)){
                        request_x.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strEventConnName);
                    }
                    request_x.Desc_x = strActTypeSetting;
                    
                    //get the activityTypeId using ServicePower API call
                    WSCH_Provider_SP_StubsV91.ActTypeFindFromDescResponse actTypeResponse = servicePowerWsdl.ActTypeFindFromDesc(request_x);
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityCreate():actTypeResponse - ' + actTypeResponse);
                    strActTypeNum = WSCH_Provider_SP_DataMapper.getActTypeFindFromDescResponse(actTypeResponse);
                    strActTypeDesc = strActTypeSetting;
                }
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityCreate(): strActTypeNum - ' + strActTypeNum);
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityCreate(): strActTypeDesc - ' + strActTypeDesc);
            }
            
            //create standard activity only if the activity type is not null
            if(strActTypeNum != null) {
                WSCH_Provider_SP_StubsV91.EmpAddActRequest empAddActRequest = WSCH_Provider_SP_DataMapper.mapEmpAddActRequest(event);
                //set the login credentials as per the event's Connection Name
                if(String.isNotBlank(strEventConnName)){
                    empAddActRequest.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strEventConnName);
                }
                //assign the activityType to the activity request object.
                empAddActRequest.actType = strActTypeNum;
                WSCH_AuditLogger.debug('strActTypeNum - ' + strActTypeNum);
                //WSCH_Provider_SP_StubsV91.EmpAddActResponse response = WSCH_Provider_SP_CalloutUtils.stdActivityCreate(event, empAddActRequest, statusObj);
                WSCH_AuditLogger.setAPIName(WSCH_Constants.API_EMP_ADD_ACTIVITY);
                WSCH_Provider_SP_StubsV91.EmpAddActResponse response = servicePowerWsdl.EmpAddAct(empAddActRequest);
                if(response.result.code == WSCH_Constants.SP_WOULD_BREAK_ACCESS_HOURS){
                    callOutsPending--;
                    empAddActRequest.options.CheckJobsShuffle = false;
                    //response = WSCH_Provider_SP_CalloutUtils.stdActivityCreate(event, empAddActRequest, statusObj);
                    response = servicePowerWsdl.EmpAddAct(empAddActRequest);
                }
                WSCH_Provider_SP_DataMapper.mapEmpAddActResponse(response, event);
                
                //added the below code to update the SF event or Salesforce event with the activityType at ServiceMax side
                //to make it consistent with ServicePower
                if(WSCH_CommonUtils.isSVMXEvent(event)) {
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityCreate(): this is SVMXEvent');
                    WSCH_AuditLogger.debug('Activity type - ' + strActTypeDesc);
                    SVMXC__SVMX_Event__c SVMXEvent = WSCH_CommonUtils.fetchSVMXEventObjectById(event.SVMXC__WhatId__c);
                    SVMXEvent.SVMXC__Type__c = strActTypeDesc;
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    update SVMXEvent;
                    
                } else if (WSCH_CommonUtils.isSFEvent(event)) {
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityCreate(): this is SFEvent');
                    WSCH_AuditLogger.debug('Activity type - ' + strActTypeDesc);
                    Event SFEvent = WSCH_CommonUtils.fetchSFEventObjectById(event.SVMXC__WhatId__c);
                    SFEvent.Type = strActTypeDesc;
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    //update SFEvent;
                    WSCH_CRUD_Helper.upsertEvents(SFEvent);
                }
            } else {
                event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                event.SVMXC__Optimizer_Error_Text__c = 'Could not create a standard activity as the supplied activity type/default activity type is null or does not exist in ServicePower';
            }
            WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        } catch (Calloutexception callOutException) {
            event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            event.SVMXC__Optimizer_Error_Text__c = 'Failed to create the non work order event in SP';
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: standardActivityCreate :: ' + callOutException.getMessage());
        }catch(Exception ex){
            event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            event.SVMXC__Optimizer_Error_Text__c = 'Failed to create the non work order event in SP.' + ex.getMessage();
            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_RealTimeOptimizer:standardActivityCreate() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    /**
Following method performs ActDelete web service call to SP.
**/
    private void stardardActivityDelete(SVMXC__SVMX_Optimizer__c event){
        
        callOutsPending--;
        try {
            Long startTime = Datetime.now().getTime();
            WSCH_Status statusObj = new WSCH_Status();
            //get the Connection Name for Event, and set the corresponding Login Credentials in callout request.
            String strEventConnName = mapEventConn.get(event.SVMXC__WhatId__c);
            WSCH_Provider_SP_StubsV91.ActDeleteRequest empActDelRequest = WSCH_Provider_SP_DataMapper.mapActDeleteRequest(event);
            //set the login credentials as per the event's Connection Name
            if(String.isNotBlank(strEventConnName)){
                empActDelRequest.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strEventConnName);
            }
            WSCH_AuditLogger.setAPIName(WSCH_Constants.API_EMP_DELETE_ACTIVITY);
            WSCH_Provider_SP_StubsV91.StandardResponse response = WSCH_Provider_SP_CalloutUtils.stdActivityDelete(event, empActDelRequest, statusObj);
            WSCH_Provider_SP_DataMapper.mapActDeleteResponse(response, event);
            WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        } catch (Calloutexception callOutException) {
            event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            event.SVMXC__Optimizer_Error_Text__c = 'Failed to delete the non work order event in SP';
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: stardardActivityDelete :: ' + callOutException.getMessage());
        }catch(Exception ex){
            event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            event.SVMXC__Optimizer_Error_Text__c = 'Failed to delete the non work order event in SP.' + ex.getMessage();
            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_RealTimeOptimizer:stardardActivityDelete() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    /**
Following method performs ActUpdate web service call to SP.
**/
    private void standardActivityUpdate(SVMXC__SVMX_Optimizer__c event){
        
        if (event.SVMXC__Optimizer_External_ID__c == null || event.SVMXC__Optimizer_External_ID__c.equals('')) {
            event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            event.SVMXC__Optimizer_Error_Text__c = 'Failed to update the non work order event in SP as event id is not found';
            WSCH_AuditLogger.warn(event.SVMXC__Optimizer_Error_Text__c);
            return;
        }
        
        try {
            Long startTime = Datetime.now().getTime();
            //callOutsPending--;
            callOutsPending = callOutsPending - 3;      //callOutsPending - 2;
            WSCH_Status statusObj = new WSCH_Status();
            //get the Connection Name for Event, and set the corresponding Login Credentials in callout request.
            String strEventConnName = mapEventConn.get(event.SVMXC__WhatId__c);
            //map the requestObject and call the getActivityTypeForDesc() API to get the activity Type from SP
            WSCH_Provider_SP_StubsV91.ActTypeFindFromDescRequest actTypeFindRequest = WSCH_Provider_SP_DataMapper.mapActTypeFindFromDescRequest(event);
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            //set the login credentials as per the event's Connection Name
            if(String.isNotBlank(strEventConnName)){
                actTypeFindRequest.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strEventConnName);
                servicePowerWsdl.endpoint_x = getSpURL(strEventConnName);
            }
            
            String strActTypeSetting, strActTypeNum, strActTypeDesc;
            if(actTypeFindRequest != null && actTypeFindRequest.Desc_x != null && actTypeFindRequest.Desc_x != 'null') {
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityUpdate(): actTypeFindRequest.Desc_x - ' + actTypeFindRequest.Desc_x);
                WSCH_Provider_SP_StubsV91.ActTypeFindFromDescResponse actTypeResponse = servicePowerWsdl.ActTypeFindFromDesc(actTypeFindRequest);
                strActTypeNum = WSCH_Provider_SP_DataMapper.getActTypeFindFromDescResponse(actTypeResponse);
                strActTypeDesc = actTypeFindRequest.Desc_x;
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityUpdate(): strActTypeNum - ' + strActTypeNum);
            } else {
                //setting value format is 'Personal'
                strActTypeSetting = WSCH_CommonUtils.getSettingValue('DCON004','SET011');
                if(strActTypeSetting != null && String.isNotBlank(strActTypeSetting)) {
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityUpdate():strActTypeSetting - ' + strActTypeSetting);
                    //map the requestObject and call the getActivityTypeForDesc() API to get the activity Type from SP
                    WSCH_Provider_SP_StubsV91.ActTypeFindFromDescRequest request_x = new WSCH_Provider_SP_StubsV91.ActTypeFindFromDescRequest();
                    //request_x.login = WSCH_Provider_SP_DataMapper.fetchLoginInfo();
                    //set the login credentials as per the event's Connection Name
                    if(String.isNotBlank(strEventConnName)){
                        request_x.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strEventConnName);
                    }
                    request_x.Desc_x = strActTypeSetting;
                    
                    //get the activityTypeId using ServicePower API call
                    WSCH_Provider_SP_StubsV91.ActTypeFindFromDescResponse actTypeResponse = servicePowerWsdl.ActTypeFindFromDesc(request_x);
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityUpdate():actTypeResponse - ' + actTypeResponse);
                    strActTypeNum = WSCH_Provider_SP_DataMapper.getActTypeFindFromDescResponse(actTypeResponse);
                    strActTypeDesc = strActTypeSetting;
                }
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityUpdate(): strActTypeNum - ' + strActTypeNum);
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityUpdate(): strActTypeDesc - ' + strActTypeDesc);
            }
            
            //create standard activity only if the activity type is not null
            if(strActTypeNum != null) {
                WSCH_Provider_SP_StubsV91.ActUpdateRequest empActUpdateRequest = WSCH_Provider_SP_DataMapper.mapActUpdateRequest(event);
                //WSCH_Provider_SP_StubsV91.ReturnCode response = WSCH_Provider_SP_CalloutUtils.stdActivityUpdate(event, empActUpdateRequest, statusObj);
                //WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
                //set the login credentials as per the event's Connection Name
                if(String.isNotBlank(strEventConnName)){
                    empActUpdateRequest.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strEventConnName);
                }
                empActUpdateRequest.actType = strActTypeNum;
                WSCH_AuditLogger.debug('strActTypeNum - ' + strActTypeNum);
                WSCH_AuditLogger.setAPIName(WSCH_Constants.API_EMP_UPDATE_ACTIVITY);
                WSCH_Provider_SP_StubsV91.ReturnCode response = servicePowerWsdl.ActUpdate(empActUpdateRequest);
                if (response.code == WSCH_Constants.SP_WOULD_BREAK_ACCESS_HOURS) {
                    callOutsPending--;
                    empActUpdateRequest.options.CheckJobsShuffle = false;
                    //response = WSCH_Provider_SP_CalloutUtils.stdActivityUpdate(event, empActUpdateRequest, statusObj);
                    response = servicePowerWsdl.ActUpdate(empActUpdateRequest);
                }
                WSCH_Provider_SP_DataMapper.mapActUpdateResponse(response, event);
                
                //added the below code to update the SF event or Salesforce event with the activityType at ServiceMax side
                //to make it consistent with ServicePower
                if(WSCH_CommonUtils.isSVMXEvent(event)) {
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityUpdate(): this is SVMXEvent');
                    WSCH_AuditLogger.debug('Activity type - ' + strActTypeDesc);
                    SVMXC__SVMX_Event__c SVMXEvent = WSCH_CommonUtils.fetchSVMXEventObjectById(event.SVMXC__WhatId__c);
                    SVMXEvent.SVMXC__Type__c = strActTypeDesc;
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    //update SVMXEvent;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(SVMXEvent, COMM_SecurityUtils.Access.Updateable)){
                        update SVMXEvent;
                    }
                    
                } else if (WSCH_CommonUtils.isSFEvent(event)) {
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::standardActivityUpdate(): this is SFEvent');
                    WSCH_AuditLogger.debug('Activity type - ' + strActTypeDesc);
                    Event SFEvent = WSCH_CommonUtils.fetchSFEventObjectById(event.SVMXC__WhatId__c);
                    SFEvent.Type = strActTypeDesc;
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    //update SFEvent;
                    WSCH_CRUD_Helper.upsertEvents(SFEvent);
                }
            }else {
                event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                event.SVMXC__Optimizer_Error_Text__c = 'Could not update a standard activity as the supplied activity type/default activity type is null or does not exist in ServicePower';
            }
            WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
        } catch (Calloutexception callOutException) {
            event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            event.SVMXC__Optimizer_Error_Text__c = 'Failed to update the non work order event in SP';
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: standardActivityUpdate :: ' + callOutException.getMessage());
        }catch(Exception ex){
            event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            event.SVMXC__Optimizer_Error_Text__c = 'Failed to update the non work order event in SP.' + ex.getMessage();
            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_RealTimeOptimizer:standardActivityUpdate() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    
    
    /**
Overloaded canCallout method for non work order events SP call outs..
*/
    public boolean canCallOut(SVMXC__SVMX_Optimizer__c event, Set<String> frus, Map<String, String> territoryFRUMap) {
        
        Integer callOuts = 0;
        Set<String> cancelJobTokens =  new Set<String>{'CHANGE_DELETE','CHANGE_CANCEL_WO'};
            
            if (event.SVMXC__Optimizer_Change_Token__c.equalsIgnoreCase('CHANGE_CREATE') || event.SVMXC__Optimizer_Change_Token__c.equalsIgnoreCase('CHANGE_UPDATE')){
                callOuts = callOuts + 2;
            }
        
        if(cancelJobTokens.contains(event.SVMXC__Optimizer_Change_Token__c)) {
            callOuts++;
        }
        
        if(!cancelJobTokens.contains(event.SVMXC__Optimizer_Change_Token__c)) {
            SVMXC__Service_Group_Members__c technician = WSCH_CommonUtils.getNonWOEventTechnician (event);
            if(!frus.contains(territoryFRUMap.get(technician.SVMXC__Service_Territory__r.Id))) {
                callOuts++; // GetWorkItemChanges Call
            }
        }
        
        if(callOutsPending >= (callOuts + frus.size())) {
            return true;
        }
        
        return false;
    }
    
    /**
Overloaded canCallout method for work order related SP call outs..
*/
    public boolean canCallOut(SVMXC__Service_Order__c workOrder, Set<String> frus, Map<String, String> territoryFRUMap) {
        
        Integer callOuts = 0;
        Set<String> schedulingChangeTokensSet = new Set<String>{'CHANGE_CANCEL_WO','CHANGE_SCHEDULING_STATUS'};
            schedulingChangeTokensSet.addall(WSCH_Constants.BOOKJOB_SCHDL_CHANGE_TOKENS);
        schedulingChangeTokensSet.addall(WSCH_Constants.UPDATEJOB_SCHDL_CHANGE_TOKENS);
        if(schedulingChangeTokensSet.contains(workOrder.SVMXC__Scheduling_Change_Token__c)) {
            callOuts++;
        } else if('CHANGE_STATUS'.equals(workOrder.SVMXC__Scheduling_Change_Token__c)) {
            callOuts++; // GetWorkItemStatus Call
            if(workOrder.SVMXC__Work_Order_Scheduling_Status__c.equalsIgnoreCase(WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[0])) ||
               workOrder.SVMXC__Work_Order_Scheduling_Status__c.equalsIgnoreCase(WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[1]))) {
                   if(null != workOrder.SVMXC__Acknowledged_By_Technician_Date_Time__c) {
                       callOuts++; // ChangeWorkItemStatus Call - Contacted
                   }
                   if(null != workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c) {
                       callOuts++; // ChangeWorkItemStatus Call - Travelling
                   }
                   if(null != workOrder.SVMXC__Actual_Onsite_Response__c) {
                       callOuts++; // ChangeWorkItemStatus Call - LoggedOn
                   }
                   if(null != workOrder.SVMXC__Finished_Onsite_Date_Time__c) {
                       callOuts++; // ChangeWorkItemStatus Call - LoggedOff
                   }
               } else if (workOrder.SVMXC__Work_Order_Scheduling_Status__c.equalsIgnoreCase(WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[2]))) {
                   
                   if(null != workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c) {
                       callOuts++; // ChangeWorkItemStatus Call - Travelling
                   }
                   if(null != workOrder.SVMXC__Actual_Onsite_Response__c) {
                       callOuts++; // ChangeWorkItemStatus Call - LoggedOn
                   }
                   if(null != workOrder.SVMXC__Finished_Onsite_Date_Time__c) {
                       callOuts++; // ChangeWorkItemStatus Call - LoggedOff
                   }
               } else if (workOrder.SVMXC__Work_Order_Scheduling_Status__c.equalsIgnoreCase(WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[3]))) {
                   
                   if(null != workOrder.SVMXC__Actual_Onsite_Response__c) {
                       callOuts++; // ChangeWorkItemStatus Call - LoggedOn
                   }
                   if(null != workOrder.SVMXC__Finished_Onsite_Date_Time__c) {
                       callOuts++; // ChangeWorkItemStatus Call - LoggedOff
                   }
               }  else if (workOrder.SVMXC__Work_Order_Scheduling_Status__c.equalsIgnoreCase(WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[4]))) {
                   if(null != workOrder.SVMXC__Finished_Onsite_Date_Time__c) {
                       callOuts++; // ChangeWorkItemStatus Call - LoggedOff
                   }
               }
        } else if(WSCH_Constants.FORCEFIXJOB_SCHDL_CHANGE_TOKENS.contains(workOrder.SVMXC__Scheduling_Change_Token__c)) {
            callOuts++; // forcefixJob Call
        }
        
        if(workOrder.SVMXC__Service_Zone_ID__c !=null && !frus.contains(territoryFRUMap.get(workOrder.SVMXC__Service_Zone_ID__c))) {
            callOuts++; // for new territory GetChangedWorkItems call
        }else if(workOrder.SVMXC__Primary_Territory__c != null && !frus.contains(territoryFRUMap.get(workOrder.SVMXC__Primary_Territory__c))){
            callOuts++; // for new territory GetChangedWorkItems call
        }
        
        if(callOutsPending >= (callOuts + frus.size())) {
            return true;
        }
        
        return false;
    }
    
    public void updateStatus(SVMXC__Service_Order__c workOrder) {
        
        String currentStatus = getJobStatus(workOrder);
        boolean success = false;
        if(currentStatus == null){
            return;
        }
        WSCH_AuditLogger.debug('Inside Update ,Current Status :'+currentStatus);
        if(currentStatus.equalsIgnoreCase(WSCH_Constants.WO_SP_DISPATCH_STATUS[0]) || currentStatus.equalsIgnoreCase(WSCH_Constants.WO_SP_DISPATCH_STATUS[1]) || currentStatus.equalsIgnoreCase(WSCH_Constants.WO_SP_DISPATCH_STATUS[7])) {
            
            //Updating Job Status to contatcted.
            success = changeWorkItemStatus(workOrder, WSCH_Constants.WO_SP_DISPATCH_STATUS[2], workOrder.SVMXC__Acknowledged_By_Technician_Date_Time__c);
            
            //Updating Job Status to travelling.
            if(success) {
                //if success update the WO.scheduling status with the actual status
                workOrder.SVMXC__Work_Order_Scheduling_Status__c = WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[2]);
                success = changeWorkItemStatus(workOrder, WSCH_Constants.WO_SP_DISPATCH_STATUS[3], workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c);
            } else {
                if (workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c != null && workOrder.SVMXC__Acknowledged_By_Technician_Date_Time__c == null) {
                    updateWorkOrderEror(workOrder);
                    return;
                }
            }
            
            //Updating Job Status to logged on.
            if(success) {
                //if success update the WO.scheduling status with the actual status
                workOrder.SVMXC__Work_Order_Scheduling_Status__c = WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[3]);
                success = changeWorkItemStatus(workOrder, WSCH_Constants.WO_SP_DISPATCH_STATUS[4], workOrder.SVMXC__Actual_Onsite_Response__c);
            } else {
                if (workOrder.SVMXC__Actual_Onsite_Response__c != null && (workOrder.SVMXC__Acknowledged_By_Technician_Date_Time__c == null || workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c == null)) {
                    updateWorkOrderEror(workOrder);
                    return;
                }
            }
            
            //Updating Job Status to logged off.
            if(success){
                //if success update the WO.scheduling status with the actual status
                workOrder.SVMXC__Work_Order_Scheduling_Status__c = WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[4]);
                success = changeWorkItemStatus(workOrder,WSCH_Constants.WO_SP_DISPATCH_STATUS[5],workOrder.SVMXC__Finished_Onsite_Date_Time__c);
            } else {
                if (workOrder.SVMXC__Finished_Onsite_Date_Time__c != null && (workOrder.SVMXC__Acknowledged_By_Technician_Date_Time__c == null || workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c == null || workOrder.SVMXC__Actual_Onsite_Response__c == null)) {
                    updateWorkOrderEror(workOrder);
                    return;
                }
            }
            
            
            //Updating Job Status to cleared.
            if(success){
                //if success update the WO.scheduling status with the actual status
                workOrder.SVMXC__Work_Order_Scheduling_Status__c = WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[5]);
                success = changeWorkItemStatus(workOrder,WSCH_Constants.WO_SP_DISPATCH_STATUS[6],workOrder.SVMXC__Completed_Date_Time__c);
            } else {
                if (workOrder.SVMXC__Completed_Date_Time__c != null && (workOrder.SVMXC__Acknowledged_By_Technician_Date_Time__c == null || workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c == null || workOrder.SVMXC__Actual_Onsite_Response__c == null || workOrder.SVMXC__Finished_Onsite_Date_Time__c == null)) {
                    updateWorkOrderEror(workOrder);
                    return;
                }
            }
            
        } else if (currentStatus.equalsIgnoreCase(WSCH_Constants.WO_SP_DISPATCH_STATUS[2])) {
            
            //Updating Job Status to Travelling.
            success = changeWorkItemStatus(workOrder, WSCH_Constants.WO_SP_DISPATCH_STATUS[3], workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c);
            
            //Updating Job Status to logged on.
            if(success) {
                //if success update the WO.scheduling status with the actual status
                workOrder.SVMXC__Work_Order_Scheduling_Status__c = WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[3]);
                success = changeWorkItemStatus(workOrder, WSCH_Constants.WO_SP_DISPATCH_STATUS[4], workOrder.SVMXC__Actual_Onsite_Response__c);
            } else {
                if (workOrder.SVMXC__Actual_Onsite_Response__c != null && workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c == null) {
                    updateWorkOrderEror(workOrder);
                    return;
                }
            }
            
            //Updating Job Status to logged off.
            if(success){
                //if success update the WO.scheduling status with the actual status
                workOrder.SVMXC__Work_Order_Scheduling_Status__c = WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[4]);
                success = changeWorkItemStatus(workOrder,WSCH_Constants.WO_SP_DISPATCH_STATUS[5],workOrder.SVMXC__Finished_Onsite_Date_Time__c);
            } else {
                if (workOrder.SVMXC__Finished_Onsite_Date_Time__c != null && (workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c == null || workOrder.SVMXC__Actual_Onsite_Response__c == null)) {
                    updateWorkOrderEror(workOrder);
                    return;
                }
            }
            
            //Updating Job Status to cleared.
            if(success){
                //if success update the WO.scheduling status with the actual status
                workOrder.SVMXC__Work_Order_Scheduling_Status__c = WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[5]);
                success = changeWorkItemStatus(workOrder,WSCH_Constants.WO_SP_DISPATCH_STATUS[6],workOrder.SVMXC__Completed_Date_Time__c);
            } else {
                if (workOrder.SVMXC__Completed_Date_Time__c != null && (workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c == null || workOrder.SVMXC__Actual_Onsite_Response__c == null || workOrder.SVMXC__Finished_Onsite_Date_Time__c == null)) {
                    updateWorkOrderEror(workOrder);
                    return;
                }
            }
            
        } else if (currentStatus.equalsIgnoreCase(WSCH_Constants.WO_SP_DISPATCH_STATUS[3])) {
            
            //Updating Job Status to logged on.
            success = changeWorkItemStatus(workOrder, WSCH_Constants.WO_SP_DISPATCH_STATUS[4], workOrder.SVMXC__Actual_Onsite_Response__c);
            
            //Updating Job Status to logged off.
            if(success){
                //if success update the WO.scheduling status with the actual status
                workOrder.SVMXC__Work_Order_Scheduling_Status__c = WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[4]);
                success = changeWorkItemStatus(workOrder,WSCH_Constants.WO_SP_DISPATCH_STATUS[5],workOrder.SVMXC__Finished_Onsite_Date_Time__c);
            } else {
                if (workOrder.SVMXC__Finished_Onsite_Date_Time__c != null && workOrder.SVMXC__Actual_Onsite_Response__c == null) {
                    updateWorkOrderEror(workOrder);
                    return;
                }
            }
            
            //Updating Job Status to cleared.
            if(success){
                //if success update the WO.scheduling status with the actual status
                workOrder.SVMXC__Work_Order_Scheduling_Status__c = WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[5]);
                success = changeWorkItemStatus(workOrder,WSCH_Constants.WO_SP_DISPATCH_STATUS[6],workOrder.SVMXC__Completed_Date_Time__c);
            } else {
                if (workOrder.SVMXC__Completed_Date_Time__c != null && (workOrder.SVMXC__Actual_Onsite_Response__c == null || workOrder.SVMXC__Finished_Onsite_Date_Time__c == null)) {
                    updateWorkOrderEror(workOrder);
                    return;
                }
            }
            
            
        } else if (currentStatus.equalsIgnoreCase(WSCH_Constants.WO_SP_DISPATCH_STATUS[4])){
            
            //Updating Job Status to loggedOff.
            success = changeWorkItemStatus(workOrder,WSCH_Constants.WO_SP_DISPATCH_STATUS[5],workOrder.SVMXC__Finished_Onsite_Date_Time__c);
            
            //Updating Job Status to cleared.
            if(success){
                //if success update the WO.scheduling status with the actual status
                workOrder.SVMXC__Work_Order_Scheduling_Status__c = WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[5]);
                success = changeWorkItemStatus(workOrder,WSCH_Constants.WO_SP_DISPATCH_STATUS[6],workOrder.SVMXC__Completed_Date_Time__c);
            } else {
                if (workOrder.SVMXC__Completed_Date_Time__c != null && workOrder.SVMXC__Finished_Onsite_Date_Time__c == null) {
                    updateWorkOrderEror(workOrder);
                    return;
                }
            }
            
        } else if(currentStatus.equalsIgnoreCase(WSCH_Constants.WO_SP_DISPATCH_STATUS[5])) {
            
            //Updating Job Status to cleared.
            success = changeWorkItemStatus(workOrder,WSCH_Constants.WO_SP_DISPATCH_STATUS[6],workOrder.SVMXC__Completed_Date_Time__c);
            if(success) {
                //if success update the WO.scheduling status with the actual status
                workOrder.SVMXC__Work_Order_Scheduling_Status__c = WSCH_CommonUtils.getServiceMaxJobStatus(WSCH_Constants.WO_SP_DISPATCH_STATUS[6]);
            }
        }
    }
    
    /**
Following method calls the UpdateJob SP API for updating the job.
**/
    private void updateJob(SVMXC__Service_Order__c workOrder) {
        
        callOutsPending--;
        try{
            WSCH_Provider_SP_StubsV91.JobUpdateRequest updateJobRequest = null;
            //get the Connection Name for Work order, and set the corresponding Login Credentials in callout request.
            mapWoConName = new Map<Id, String>();
            getSpConnName(workOrder.SVMXC__Dispatch_Process__c, workOrder.SVMXC__Optimizer_Connection_Name__c, workOrder.Id);
            String strConName = mapWoConName.get(workOrder.Id);
            if('CHANGE_JOB_UNFIXED'.equalsIgnoreCase(workOrder.SVMXC__Scheduling_Change_Token__c)) {
                updateJobRequest = WSCH_Provider_SP_DataMapper.mapUnfixJobRequest(workOrder);
            } else {
                updateJobRequest = WSCH_Provider_SP_DataMapper.mapUpdateJobRequest(workOrder);
            }
            WSCH_Status statusObj = new WSCH_Status();
            //set the login credentials as per the Work Order's Connection Name
            if(String.isNotBlank(strConName)){
                updateJobRequest.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strConName);
            }
            WSCH_AuditLogger.setAPIName(WSCH_Constants.API_UPDATE_JOB);
            WSCH_Provider_SP_StubsV91.ReturnCode returnCode = WSCH_Provider_SP_CalloutUtils.updateJob(workOrder, updateJobRequest, statusObj);
            WSCH_Provider_SP_DataMapper.mapUpdateAPIReturnCode(workOrder, returnCode);
        }catch(CalloutException ex){
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            WSCH_CommonUtils.setOptimizerErrorText(workOrder, 'Failed to update the work order : ' + ex.getMessage());
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: updateJob :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }catch(Exception ex){
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            WSCH_CommonUtils.setOptimizerErrorText(workOrder, 'Failed to update the work order : ' + ex.getMessage());
            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_RealTimeOptimizer :: updateJob ::  ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    /**
Following method calls the CancelJob SP API when Work order field SVMXC__Order_Status__c updated to cancel.
**/
    private void cancelJob(SVMXC__Service_Order__c workOrder) {
        
        callOutsPending--;
        try{
            WSCH_Status statusObj = new WSCH_Status();
            //get the Connection Name for Work order, and set the corresponding Login Credentials in callout request.
            mapWoConName = new Map<Id, String>();
            getSpConnName(workOrder.SVMXC__Dispatch_Process__c, workOrder.SVMXC__Optimizer_Connection_Name__c, workOrder.Id);
            String strConName = mapWoConName.get(workOrder.Id);
            WSCH_Provider_SP_StubsV91.JobCancelRequest cancelJobRequest = WSCH_Provider_SP_DataMapper.mapCancelJobRequest(workOrder);
            //set the login credentials as per the Work Order's Connection Name
            if(String.isNotBlank(strConName)){
                cancelJobRequest.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strConName);
            }
            WSCH_Provider_SP_StubsV91.JobCancelResponse response = WSCH_Provider_SP_CalloutUtils.cancelJob(workOrder, cancelJobRequest, statusObj);
            WSCH_Provider_SP_DataMapper.mapCancelJobResponse(response, workOrder);
        }catch(CalloutException ex){
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            WSCH_CommonUtils.setOptimizerErrorText(workOrder,'Failed to cancel the work order : ' + ex.getMessage());
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: cancelJob(SVMXC__Service_Order__c) :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }catch(Exception ex){
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            WSCH_CommonUtils.setOptimizerErrorText(workOrder,'Failed to cancel the work order : ' + ex.getMessage());
            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_RealTimeOptimizer :: cancelJob(SVMXC__Service_Order__c) ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    /**
Following method calls the CancelJob SP API when work order gets deleted.
**/
    private void cancelJob(SVMXC__SVMX_Optimizer__c optimizerObj) {
        
        callOutsPending--;
        try{
            WSCH_Status statusObj = new WSCH_Status();
            WSCH_Provider_SP_StubsV91.JobCancelRequest cancelJobRequest = WSCH_Provider_SP_DataMapper.mapCancelJobRequest(optimizerObj);
            String strWoId = mapWoIDName.get(optimizerObj.SVMXC__WhatId__c);
            if(String.isNotBlank(strWoId)){
                String strConName = mapWoConName.get(Id.valueOf(strWoId));
                //set the login credentials as per the Work Order's Connection Name
                if(String.isNotBlank(strConName)){
                    cancelJobRequest.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strConName);
                }               
            }
            WSCH_Provider_SP_StubsV91.JobCancelResponse response = WSCH_Provider_SP_CalloutUtils.cancelJob(optimizerObj, cancelJobRequest, statusObj);
            WSCH_Provider_SP_DataMapper.mapCancelJobResponse(response, optimizerObj);
        }catch(CalloutException ex){
            optimizerObj.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            optimizerObj.SVMXC__Optimizer_Error_Text__c = 'Failed to cancel the work order : ' + ex.getMessage();
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: cancelJob(SVMXC__SVMX_Optimizer__c) :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }catch(Exception ex){
            optimizerObj.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            optimizerObj.SVMXC__Optimizer_Error_Text__c = 'Failed to cancel the work order : ' + ex.getMessage();
            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_RealTimeOptimizer:cancelJob(SVMXC__SVMX_Optimizer__c) ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    /**
Following method calls the ForceFixJob SP API when work order scheduling status updated as Fixed.
**/
    private void forceFixJob(SVMXC__Service_Order__c workOrder) {
        
        try{
            WSCH_Status statusObj = new WSCH_Status();
            //get the Connection Name for Work order, and set the corresponding Login Credentials in callout request.
            mapWoConName = new Map<Id, String>();
            getSpConnName(workOrder.SVMXC__Dispatch_Process__c, workOrder.SVMXC__Optimizer_Connection_Name__c, workOrder.Id);
            String strConName = mapWoConName.get(workOrder.Id);
            WSCH_Provider_SP_StubsV91.ForceFixJobRequest forceFixJobRequest = WSCH_Provider_SP_DataMapper.mapForceFixJobRequest(workOrder);
            //set the login credentials as per the Work Order's Connection Name
            if(String.isNotBlank(strConName)){
                forceFixJobRequest.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strConName);
            }
            WSCH_AuditLogger.setAPIName(WSCH_Constants.API_FORCE_FIX_JOB);
            WSCH_Provider_SP_StubsV91.ReturnCode returnCode = WSCH_Provider_SP_CalloutUtils.forceFixJob(workOrder,forceFixJobRequest, statusObj);
            //set the status code on the work order.
            if(workOrder != null && returnCode != null) {
                //based on the response code set the appropriate message on the WO Optimax status.
                if(WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)){
                    workOrder.SVMXC__OptiMax_Status__c = WSCH_CommonUtils.resolveOptimaxStatus(workOrder.SVMXC__OptiMax_Status__c, 'OPT_COMPLETED');
                } else {
                    workOrder.SVMXC__OptiMax_Status__c = WSCH_CommonUtils.resolveOptimaxStatus(workOrder.SVMXC__OptiMax_Status__c, 'OPT_ERROR');
                }
                String errorText = 'Return Code:' + returnCode.code + ' | Return Type:' + returnCode.type_x + ' | Return Note:' + returnCode.errNote + ' | Return Msg:' + WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(returnCode.code);
                WSCH_CommonUtils.setOptimizerErrorText(workOrder,errorText);
            }
        }catch(CalloutException ex){
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            WSCH_CommonUtils.setOptimizerErrorText(workOrder,'Failed to forcefix the work order : ' + ex.getMessage());
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: forceFixJob :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }catch(Exception ex){
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            WSCH_CommonUtils.setOptimizerErrorText(workOrder,'Failed to forcefix the work order : ' + ex.getMessage());
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: forceFixJob :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    public static boolean loginToSP(String dbUser, String dbPassword, String spUser) {
        
        boolean isLoginSuccess = false;
        try{
            WSCH_Provider_SP_StubsV91.spLogin spLoginRequest = WSCH_Provider_SP_DataMapper.mapSPLoginRequest(dbUser, dbPassword, spUser);
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            WSCH_Provider_SP_StubsV91.ReturnCode returnCode = servicePowerWsdl.Login(spLoginRequest);
            if(returnCode != null && WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)) {
                isLoginSuccess = true;
            }
        } catch(Exception ex) {
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: loginToSP :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return isLoginSuccess;
    }
    
    public static boolean loginToSP(String dbUser, String dbPassword, String spUser,String endPointUrl) {
        
        boolean isLoginSuccess = false;
        try{
            WSCH_Provider_SP_StubsV91.spLogin spLoginRequest = WSCH_Provider_SP_DataMapper.mapSPLoginRequest(dbUser, dbPassword, spUser);
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            WSCH_Provider_SP_StubsV91.ReturnCode returnCode = servicePowerWsdl.Login(spLoginRequest,endPointUrl);
            if(returnCode != null && WSCH_Provider_SP_ErrorCodesMapper.isSuccess(returnCode.code)) {
                isLoginSuccess = true;
            }
        } catch(Exception ex) {
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: loginToSP :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
            throw ex;
        }
        return isLoginSuccess;
    }
    
    public void forceBook(SVMXC__Service_Order__c workOrder) {
        
        try{
            String errorText=null;
            //fetch the Dispatching Tool setting value.
            String settingsGBL024 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL024');
            WSCH_AuditLogger.debug('settingsGBL024 :' + settingsGBL024);
            //if it is Internal, mark WO as OPT_ERROR
            if(settingsGBL024 != null && settingsGBL024.equalsIgnoreCase('INTERNAL')) {
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                errorText = 'Unable to schedule the work order as there are no technician slots available';
                WSCH_CommonUtils.setOptimizerErrorText(workOrder,errorText);
            } else if(settingsGBL024 != null && settingsGBL024.equalsIgnoreCase('EXTERNAL')) {
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                //get the Connection Name for Work order, and set the corresponding Login Credentials in callout request.
                mapWoConName = new Map<Id, String>();
                getSpConnName(workOrder.SVMXC__Dispatch_Process__c, workOrder.SVMXC__Optimizer_Connection_Name__c, workOrder.Id);
                String strConName = mapWoConName.get(workOrder.Id);
                WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
                WSCH_Provider_SP_StubsV91.JobBookRequest bookJobRequest = WSCH_Provider_SP_DataMapper.mapBookJobRequest(workOrder);
                //set the login credentials as per the Work Order's Connection Name
                if(String.isNotBlank(strConName)){
                    bookJobRequest.login = WSCH_Provider_SP_DataMapper.getSPCredentials(strConName);
                    servicePowerWsdl.endpoint_x = getSpURL(strConName);
                }
                WSCH_AuditLogger.setAPIName(WSCH_Constants.API_FORCE_BOOK);
                WSCH_Status statusObj = new WSCH_Status();
                WSCH_Provider_SP_StubsV91.JobBookForceOptions forceOptions = new WSCH_Provider_SP_StubsV91.JobBookForceOptions();
                forceOptions.InTray = true;
                bookJobRequest.forceOptions = forceOptions;
                //WSCH_Provider_SP_StubsV91.JobBookResponse forceBookResponse = servicePowerWsdl.BookJob(bookJobRequest);
                WSCH_Provider_SP_StubsV91.JobBookResponse forceBookResponse = WSCH_Provider_SP_CalloutUtils.BookJob(workOrder, bookJobRequest, statusObj);
                if(forceBookResponse != null && WSCH_Provider_SP_ErrorCodesMapper.isSuccess(forceBookResponse.result.code)) {
                    workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                    //clearing if any information on the slot as this WO is unscheduled for being send to unresourced tray.
                    if(workOrder.SVMXC__Appointment_Promised_Time_Slot__c != null && workOrder.SVMXC__Booked_Appointment_Slot__c != null) {
                        workOrder.SVMXC__Appointment_Promised_Time_Slot__c = null;
                        workOrder.SVMXC__Booked_Appointment_Slot__c = null;
                    }
                    String strFieldName;
                    //get the field name form the setting
                    strFieldName = WSCH_CommonUtils.getSettingValue('DCON003','SET00999');
                    if(String.isNotBlank(strFieldName)){
                        workOrder.put(strFieldName,'');
                    }
                    errorText = 'Work order is force scheduled. Use the external dispatching tool to schedule the work order';
                    WSCH_CommonUtils.setOptimizerErrorText(workOrder,errorText);
                } else {
                    workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                    if(forceBookResponse != null && forceBookResponse.result != null) {
                        errorText = WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(forceBookResponse.result.code);
                        WSCH_CommonUtils.setOptimizerErrorText(workOrder,errorText);
                    }
                }
            }
        }catch(CalloutException ex){
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            WSCH_CommonUtils.setOptimizerErrorText(workOrder,'Failed to force book the work order : ' + ex.getMessage());
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: forceBook(SVMXC__SVMX_Optimizer__c) :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }catch(Exception ex){
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            WSCH_CommonUtils.setOptimizerErrorText(workOrder,'Failed to force book the work order : ' + ex.getMessage());
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: forceBook(SVMXC__SVMX_Optimizer__c) :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    private static void updateWorkOrderEror(SVMXC__Service_Order__c workOrder) {
        
        workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
        WSCH_CommonUtils.setOptimizerErrorText(workOrder, 'Failed to change work item status : Required DateandTime to make changeWorkItemStatus API call not found.');
    }
    /*
* This method creates a Set of all the SLA Ids & ServiceContract Ids for the current list of Work Orders being processed.
* This Set will be used to optimize the SOQL transaction.
*/
    public static void populateWORelatedIds(List<SVMXC__Service_Order__c> lstWOSOQL){
        setWoIds = new Set<Id>();
        try{
            for (SVMXC__Service_Order__c workOrder : lstWOSOQL) {
                setWoIds.add(workOrder.Id);
                if(workOrder.SVMXC__SLA_Terms__c != null){
                    WSCH_Constants.setSLAIds.add(workOrder.SVMXC__SLA_Terms__c);
                }
                if(workOrder.SVMXC__Service_Contract__c != null){
                    WSCH_Constants.setServiceContractIds.add(workOrder.SVMXC__Service_Contract__c);
                }
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: populateWORelatedIds :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        
    }
    
     /*
* This method populates a static map with WorkOrder resource preference to used during JOB booking.
* This method collects the Ids of SLA Terms & ServiceContracts of WorkOrders to be processed in DataMapper.
*/
    public void populateWorkOrderResPrefMap(List<SVMXC__Service_Order__c> lstWO){
        
        List<Work_Order_Resource__c> lstWORes = new List<Work_Order_Resource__c>();
        try{
            lstWORes = WORD_Service_Order_Resources.getWorkOrderResources(lstWO);
            mapWrkOrdResPref = new Map<Id, List<String>>();
            ID woID;
            List<String> lstTechMpx;
            for(Work_Order_Resource__c woRes: lstWORes){
                if((woRes.SVMXC__Group_Member__r.SVMXC__Optimizer_External_ID__c != null) && ((woRes.SVMXC__Preference_Type__c != null))){
                    if(woID != woRes.SVMXC__Work_Order__c){
                        lstTechMpx = new List<String>();
                        woID = woRes.SVMXC__Work_Order__c;
                    }
                    lstTechMpx.add(String.valueOf(woRes.SVMXC__Group_Member__r.SVMXC__Optimizer_External_ID__c) + '=' + String.valueOf(woRes.SVMXC__Preference_Type__c));
                    if(woID !=null){
                        mapWrkOrdResPref.put(woID, lstTechMpx);
                    }
                    woID = woRes.SVMXC__Work_Order__c;
                }
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: populateWorkOrderResPrefMap :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    //Method to create map of DispatchProcess Id and Connection Name
    public void populateDispatchProcessSpURL(List<SVMXC__Service_Order__c> lstWO){
        mapDpIdSpUrl = new Map<Id, String>();
        String strQuery;
        try{
            //collect all the DispatchProcess Ids for the current Work-Orders being Processed
            for(SVMXC__Service_Order__c woDP: lstWO){
                if(woDP.SVMXC__Dispatch_Process__c != null){
                    setWoDispProcIds.add(woDP.SVMXC__Dispatch_Process__c);
                }
            }
            List<SVMXC__ServiceMax_Processes__c> lstWoDp = new List<SVMXC__ServiceMax_Processes__c>();
            strQuery = 'SELECT Id, SVMXC__Target_URL__c FROM SVMXC__ServiceMax_Processes__c WHERE Id =:setWoDispProcIds';
            //fecth all the Dispatch Process IDs in a Single SOQL query.
            lstWoDp = Database.query(strQuery);
            //create a map of DispatchProcess Id and Connection Name
            if(!lstWoDp.isEmpty()){
                for(SVMXC__ServiceMax_Processes__c dProc: lstWoDp){
                    mapDpIdSpUrl.put(dProc.Id, dProc.SVMXC__Target_URL__c);
                }
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: populateDispatchProcessSpURL :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    //Method to create map of WorkOrder Id, and Connection Name 
    public static void getSpConnName(Id idDP, String strConName, Id woId){
        String strSpInstName = '', strCon, strGBL23, strUrl = '';
        try{
            strGBL23 = WSCH_CommonUtils.getSettingValue('GLOB001','GBL023');
            //get connection name from the map, if its a Offer Appointment/Book Appointment
            strCon = mapWoConName.get(woId);
            strUrl = getSpURL(strSpInstName);
            //ifGBL023 is still active use it
            //if(String.isBlank(strGBL23)){
            // if the Optimizer Connection Name on WorkOrder is Not-Null, Use it.
            WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::getSpConnName:strSpInstName - ' + strSpInstName);
            if(String.isNotBlank(strConName)){
                strSpInstName = strConName;
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::getSpConnName from Work Order:strSpInstName - ' + strSpInstName);
            }//else assign the Connection Name from SFM, in case of AppointBooking.
            else if(String.isNotBlank(strCon)){
                strSpInstName = strCon;
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::getSpConnName from SFM in case of Appointment booking:strSpInstName - ' + strSpInstName);
            }//else use the Dispatch Process Id to fetch Connection Name.
            else if (String.isNotBlank(String.valueOf(idDP))){
                strSpInstName = WSCH_Provider_SP_RealTimeOptimizer.mapDpIdSpUrl.get(idDP);
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer::getSpConnName from dispatch process:strSpInstName - ' + strSpInstName);
                //if Dispatch Process Connection Name is NULL or --None-- then assign the Default Connection
                if((String.isBlank(strSpInstName)) || strSpInstName.equalsIgnoreCase(System.Label.DCON001_TAG280)){
                    strSpInstName = strDefaultConnection;
                    WSCH_AuditLogger.warn('WSCH_Provider_SP_RealTimeOptimizer::getSpConnName: This is the default connection as no other connection available - ' + strSpInstName);
                }
            }
            
            //if Connection Name of Work Order returns null, then throw exception.
            if(String.isBlank(strSpInstName)){
                //strSpInstName = strDefaultConnection;
                WSCH_AuditLogger.ERROR('WSCH_Provider_SP_RealTimeOptimizer :: getSpConnName: No Valid Connection Name for WorkOrder: ' + woId);
                throw new WSCH_EXCEPTION('WSCH_Provider_SP_RealTimeOptimizer :: getSpConnName: No Valid Connection Name for WorkOrder: ' + woId);
            }
            WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.put(woId, strSpInstName);
            //strUrl = WSCH_CommonUtils.getSettingValue('GLOB001','GBL023');
            //}else{
            //strUrl = strGBL23;
            //}
            WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer:mapWoConName : ' + mapWoConName);
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: getSpConnName :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    //This method returns the SP EndPoint URL for the passed Connection Name
    public static String getSpURL(String strSpInstName){
        SVMXC__ServiceMax_Properties__c instanceName = new SVMXC__ServiceMax_Properties__c();
        String strURL = '';
        WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer :: strSpInstName: ' + strSpInstName);
        try{//fetch all Custom Settings fro ServiceMax Properties.
            allSpSettings = SVMXC__ServiceMax_Properties__c.getAll();
            if((allSpSettings != null) && (!allSpSettings.isEmpty())){
                for(String strConNum: allSpSettings.keySet()){
                    instanceName = allSpSettings.get(strConNum);
                    //Check if the input Connection Name matches with an existing one and is Active
                    if ((String.isNotBlank(strSpInstName)) &&
                        ('ServicePower Connection Name'.equalsIgnoreCase(instanceName.SVMXC__Key__c)) &&
                        ('true'.equalsIgnoreCase(allSpSettings.get('SP_CON_01_' + (instanceName.Name).right(2)).SVMXC__Value__c))){
                            if((strSpInstName.equalsIgnoreCase(instanceName.SVMXC__Value__c))){
                                strUrl = allSpSettings.get('SP_CON_04_' + (instanceName.Name).right(2)).SVMXC__Value__c;
                                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer :: getSpURL: if strSPInstName is Not Blank, strUrl - ' + strUrl);
                            }
                        }//set the Default Connection Name, if it is Active.
                    if(('ServicePower Connection Default'.equalsIgnoreCase(instanceName.SVMXC__Key__c)) &&
                       ('true'.equalsIgnoreCase(allSpSettings.get('SP_CON_02_' + (instanceName.Name).right(2)).SVMXC__Value__c)) &&
                       ('true'.equalsIgnoreCase(allSpSettings.get('SP_CON_01_' + (instanceName.Name).right(2)).SVMXC__Value__c))){
                           strDefaultConnection = allSpSettings.get('SP_CON_00_' + (instanceName.Name).right(2)).SVMXC__Value__c;
                           WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer :: getSpURL: if Default Connection - ' + strDefaultConnection);
                       }
                }
                WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer :: getSpURL: ' + strUrl);
            }else{
                WSCH_AuditLogger.ERROR('WSCH_Provider_SP_RealTimeOptimizer :: getSpURL: No Valid Connection Name');
                throw new WSCH_EXCEPTION('WSCH_Provider_SP_RealTimeOptimizer :: getSpURL: No Valid Connection Name');
            }
            
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: getSpURL :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            strUrl ='';
        }
        return strUrl;
    }
    //This mehtod creates a map of Event and its related Technician Team's Connection Name
    public static void getEventSpConn(List<SVMXC__SVMX_Optimizer__c> events){
        List<SVMXC__Service_Group_Members__c> lstTech = new List<SVMXC__Service_Group_Members__c>();
        List<SVMXC__SVMX_Event__c> lstSvmxEvent = new List<SVMXC__SVMX_Event__c>();
        List<Event> lstSfEvent = new List<Event>();
        //Map<String,String> mapEventTech = new Map<String,String>();
        //Set<Id> setSvmxTech = new Set<Id>(), setSfOwner = new Set<Id>();
        mapEventConn = new Map<String, String>();
        setTechTerr = new Set<String>();
        List<SVMXC__Service_Group_Members__c> lstTechCon = new List<SVMXC__Service_Group_Members__c>();
        String strTechQuery = 'Select Id, '
            + 'SVMXC__Optimizer_External_ID__c,'
            + 'SVMXC__Service_Territory__r.Id, '
            + 'SVMXC__Salesforce_User__c, '
            + 'SVMXC__Working_Hours__c, '
            + 'SVMXC__Service_Group__c, '
            + 'SVMXC__Service_Group__r.SVMXC__Optimizer_Connection_Name__c ' 
            + 'From SVMXC__Service_Group_Members__c '
            + 'WHERE SVMXC__Salesforce_User__c IN :setSfOwner ' 
            + 'OR Id IN :setSvmxTech';
        Set<String> setSVMXEvent = new Set<String>(), setSFEvent = new Set<String>();
        try{
            //Seperate the ServiceMax Events and Salesforcce Events.
            for (SVMXC__SVMX_Optimizer__c event : events) {
                if(WSCH_CommonUtils.isSVMXEvent(event)){
                    setSVMXEvent.add(event.SVMXC__WhatId__c);
                }else if(WSCH_CommonUtils.isSFEvent(event)){
                    setSFEvent.add(event.SVMXC__WhatId__c);
                }
            }
            //get the Technicians for all SVMX Events
            if(!setSVMXEvent.isEmpty()){
                lstSvmxEvent = [Select Id, SVMXC__Technician__c, SVMXC__Type__c From SVMXC__SVMX_Event__c WHERE Id IN :setSVMXEvent];
            }
            //get the OwnerId for all the SF Events
            if(!setSFEvent.isEmpty()){
                lstSfEvent = WSCH_CRUD_Helper.fetchListSFEvent(setSFEvent);
            }
            //create a map of Technician Id and SVMX Event Id
            for(SVMXC__SVMX_Event__c svmxEv: lstSvmxEvent){
                setSvmxTech.add(svmxEv.SVMXC__Technician__c);
                mapEventTech.put(String.valueOf(svmxEv.SVMXC__Technician__c), String.valueOf(svmxEv.Id));
            }
            //create a map of Technician Id and SF Event Id
            for(Event sfEv: lstSfEvent){
                setSfOwner.add(sfEv.OwnerId);
                mapEventTech.put(String.valueOf(sfEv.OwnerId), String.valueOf(sfEv.Id));
            }
            //fetch all the technicians for SF Events and SVMX Events
            if((!setSvmxTech.isEmpty()) || (!setSfOwner.isEmpty())){
                lstTechCon = Database.query(strTechQuery);
            }
            mapTerrFruTemp = new Map<String, String>();
            //create a map of Event-WHAT_ID, and Technician Team's Connection Name
            if(!lstTechCon.isEmpty()){
                getSpURL('');
                String strCon = '';
                for(SVMXC__Service_Group_Members__c tech: lstTechCon){
                    //if ServiceTeam Connection Name is Null, assign the Default Connection Name
                    if(String.isBlank(tech.SVMXC__Service_Group__r.SVMXC__Optimizer_Connection_Name__c)){
                        //strCon = strDefaultConnection;
                    }//else assign the ServiceTeam Connection Name
                    else{
                        strCon = tech.SVMXC__Service_Group__r.SVMXC__Optimizer_Connection_Name__c;
                    }
                    //get the Event-What-Id for SVMX Event
                    if(mapEventTech.get(tech.SVMXC__Salesforce_User__c) != null){
                        mapEventConn.put(mapEventTech.get(tech.SVMXC__Salesforce_User__c),strCon);
                    }//get the Event-What-Id for SF Event
                    else{
                        mapEventConn.put(mapEventTech.get(tech.Id), strCon);
                    }
                    
                    if(tech.SVMXC__Service_Territory__r.Id != null){
                        setTechTerr.add(tech.SVMXC__Service_Territory__r.Id);
                    }
                }
                if(!setTechTerr.isEmpty()){
                    populateFruConNameMap(setTechTerr);
                }
            }
            WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer:mapEventConn : ' + mapEventConn);
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: getEventSpConn :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    //This method fetches the Connection Name from Territoty Object & creates a map of FRU & Connection Name
    public static void populateFruConNameMap(Set<String> setFruId){
        mapFruConn = new Map<String, String>();
        mapTerrFruTemp = new Map<String, String>();
        List<SVMXC__Territory__c> lstOfTerritory = new List<SVMXC__Territory__c>();
        String strTerrQuery ='';
        strTerrQuery = 'SELECT Id, '
            +'SVMXC__Optimizer_External_ID__c, '
            +'SVMXC__Optimizer_Connection_Name__c  '
            +'FROM SVMXC__Territory__c '
            +'WHERE SVMXC__Optimizer_External_ID__c != null '
            +'AND SVMXC__Optimizer_External_ID__c IN :setFruId';
        try{
            //fetch the territory details for all the FRUs in one SOQL
            lstOfTerritory = Database.query(strTerrQuery);
            if(!lstOfTerritory.isEmpty()){
                getSpURL('');
                for(SVMXC__Territory__c terr: lstOfTerritory){
                    if((terr.SVMXC__Optimizer_Connection_Name__c != null) && (String.isNotBlank(terr.SVMXC__Optimizer_Connection_Name__c))){
                        mapFruConn.put(terr.SVMXC__Optimizer_External_ID__c, terr.SVMXC__Optimizer_Connection_Name__c);
                    }else{
                        mapFruConn.put(terr.SVMXC__Optimizer_External_ID__c, strDefaultConnection);
                    }
                    mapTerrFruTemp.put(String.valueOf(terr.Id), String.valueOf(terr.SVMXC__Optimizer_External_ID__c));
                }
            }
            WSCH_AuditLogger.debug('WSCH_Provider_SP_RealTimeOptimizer:mapFruConn : ' + mapFruConn);
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: populateFruConNameMap :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        
    }
    public static void getCancelWorkOrders(Set<String> setWoNum){
        List<SVMXC__Service_Order__c> lstCancelWo = new List<SVMXC__Service_Order__c>();
        //fetch all the deleted Work Order deatils using one SOQL
        String strQuery = 'SELECT Id, '
                            +'Name, '
                            +'SVMXC__Dispatch_Process__c, '
                            +'SVMXC__Optimizer_Connection_Name__c '
                            +'FROM SVMXC__Service_Order__c '
                            +'WHERE Name IN :setWoNum '
                            +' ALL ROWS';
        try{
            if(!setWoNum.isEmpty()){
                lstCancelWo = Database.query(strQuery);
            }
            getSpURL('');
            mapWoIDName = new Map<String, String>();
            mapWoConName = new Map<Id, String>();
            //loop through the deleted Work Orders, create a map of Work Order Name and Work Order Id
            //also create the map of work Order and their connection names.
            for(SVMXC__Service_Order__c wrkOrdr: lstCancelWo){
                mapWoIDName.put(wrkOrdr.Name,wrkOrdr.Id);
                if((wrkOrdr.SVMXC__Dispatch_Process__c != null) || (wrkOrdr.SVMXC__Optimizer_Connection_Name__c != null)){
                    getSpConnName(wrkOrdr.SVMXC__Dispatch_Process__c, wrkOrdr.SVMXC__Optimizer_Connection_Name__c, wrkOrdr.Id);
                }
                /*else{
                    mapWoConName.put(wrkOrdr.Id, strDefaultConnection);
                }*/
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_RealTimeOptimizer :: getCancelWorkOrders :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        
    }
    
    /**
        This method has been introduced for managing results for OptiMax ECO
    **/
    public static Boolean manageSchedulingResults(String strJobInfo) {
        
        return null;
    }
        
    /*  Custom labels   */
    
    /*  Failed to book appointment as the request is invalid    */
    public static String getTAG035() {
        return system.label.DCON003_TAG035;
    }
    
    /*  Failed to book appointment  */
    public static String getTAG036() {
        return system.label.DCON003_TAG036;
    }
}