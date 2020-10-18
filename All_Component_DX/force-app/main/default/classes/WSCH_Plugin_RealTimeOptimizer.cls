/**
    The Plugin to handle only RealTimeOptimization related functionalities such as scheduleWorkOrder, getWorkOrderUpdates.
    Plugins are simple Named API?s to provide a cleaner interface to handle various functionalities.
    RealTimeOptimizerPlugin would invoke the ServiceProviderAdaptor to get a handle to the configured service providers Real Time Optimization service. Once the handle is obtained, it invokes the corresponding methods on the handle.
    It would also handle general exceptions thrown by ServiceProviderAdaptor such as NoServiceFoundException.
*/
public class WSCH_Plugin_RealTimeOptimizer{


    /**
        Invokes the manageWorkOrders API method of SPAdaptor.
        Gets the response object (WSCH_WorkOrderResponse) with the list of work orders and technician events.
        Invoke the Common APIs to update work orders and events. Batch Apex is invoked if the work orders are more than 9.
    */
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
    
    public static void manageWorkOrders(List<SVMXC__Service_Order__c> workOrders){

        try{ 
            WSCH_IRealTimeOptimizer realTimeOptimizer = WSCH_Provider_OptimizationFactory.getRealTimeOptimizer();
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders()::start, heap size before manageWorkOrders() call - ' + Limits.getHeapSize());
            WSCH_WorkOrderResponse woResponse = realTimeOptimizer.manageWorkOrders(workOrders);
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders()::start, No of Queries used in this transaction so far: ' + Limits.getQueries());
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders()::start, heap size after manageWorkOrders() call- ' + Limits.getHeapSize());
            
            String strActiveProvider = WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO')){
                WSCH_ECO_WorkOrderEventHelper.processWorkOrderResponse(woResponse);
            }else if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('SERVICEPOWER')){
                WSCH_WorkOrderEventHelper.processWorkOrderResponse(woResponse);
            }
            
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders()::end, No of Queries used in this transaction so far: ' + Limits.getQueries());
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders()::end, heap size after processWorkOrderResponse() - ' + Limits.getHeapSize());
        } catch(WSCH_ServiceNotFoundException ex){
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders():Service not found for this organization. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        } catch (Exception ex){
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders(): Exception raised while scheduling work orders. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    
    public static void manageDependencyGroup(String multiJobId, List<Service_Order_Dependency__c> serviceOrderList){

        try{ 
            WSCH_IRealTimeOptimizer realTimeOptimizer = WSCH_Provider_OptimizationFactory.getRealTimeOptimizer();
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders()::start, heap size before manageWorkOrders() call - ' + Limits.getHeapSize());
            WSCH_Provider_SP_StubsV91.BookDependencyGroupResponse gdResponse = realTimeOptimizer.manageDependencyGroup(multiJobId, serviceOrderList);
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders()::start, No of Queries used in this transaction so far: ' + Limits.getQueries());
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders()::start, heap size after manageWorkOrders() call- ' + Limits.getHeapSize());
            //WSCH_WorkOrderEventHelper.processWorkOrderResponse(woResponse);
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders()::end, No of Queries used in this transaction so far: ' + Limits.getQueries());
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders()::end, heap size after processWorkOrderResponse() - ' + Limits.getHeapSize());
        } catch(WSCH_ServiceNotFoundException ex){
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders():Service not found for this organization. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        } catch (Exception ex){
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::manageWorkOrders(): Exception raised while scheduling work orders. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    public static void manageDependencyBooking(List<SVMXC__Service_Order_Dependency__c>  lstOfServiceOrderGroupDependency, List<SVMXC__Service_Order__c> lstDependencyWOs) {
        try{ 
            WSCH_IRealTimeOptimizer realTimeOptimizer = WSCH_Provider_OptimizationFactory.getRealTimeOptimizer();
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageDependencyBooking()::start, heap size before manageWorkOrders() call - ' + Limits.getHeapSize());

            
            WSCH_WorkOrderResponse woResponse = realTimeOptimizer.manageDependencyBooking(lstOfServiceOrderGroupDependency, lstDependencyWOs);
            
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageDependencyBooking()::start, No of Queries used in this transaction so far: ' + Limits.getQueries());
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageDependencyBooking()::start, heap size after manageWorkOrders() call- ' + Limits.getHeapSize());

            String strActiveProvider = WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO')){
                WSCH_ECO_WorkOrderEventHelper.processWorkOrderResponse(woResponse);
            }else if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('SERVICEPOWER')){
                WSCH_WorkOrderEventHelper.processWorkOrderResponse(woResponse);
            }
            
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageDependencyBooking()::end, No of Queries used in this transaction so far: ' + Limits.getQueries());
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::manageDependencyBooking()::end, heap size after processWorkOrderResponse() - ' + Limits.getHeapSize());
        } catch(WSCH_ServiceNotFoundException ex){
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::manageDependencyBooking():Service not found for this organization. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        } catch (Exception ex){
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::manageDependencyBooking(): Exception raised while scheduling work orders. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
     /*@kundan- Commented this code as this functionality is not required for the current release.
    public static void cancelDependencyGroup(List<String> multiJobId, List<String> WorkOrderIds) {

        try{
            WSCH_IRealTimeOptimizer realTimeOptimizer = WSCH_Provider_OptimizationFactory.getRealTimeOptimizer();
            realTimeOptimizer.cancelDependencyGroup(multiJobId, WorkOrderIds);
        } catch (WSCH_ServiceNotFoundException ex){
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::cancelWorkOrders(): ' +'Service not found for this organization. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        } catch (Exception ex) {
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::cancelWorkOrders(): ' +'Exception raised while scheduling work orders. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }*/

    /**
        Invokes the getAvailableAppointments API method of SPAdaptor.
    */
    public static WSCH_AppointmentsResponse getAvailableAppointments(String woNumber, WSCH_ApptParam apptParamObj, Integer apptBatchSize, Integer apptBatchNumber){
        try{
            WSCH_IRealTimeOptimizer realTimeOptimizer = WSCH_Provider_OptimizationFactory.getRealTimeOptimizer();
            SVMXC__Service_Order__c woObj = WSCH_CommonUtils.fetchWorkOrderById(woNumber);
            return realTimeOptimizer.getAvailableAppointments(woObj,apptParamObj,apptBatchSize,apptBatchNumber);
        }catch(WSCH_ServiceNotFoundException ex){
            String expMessage = 'Required service is not found for this organization to get available appointment.';
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::getAvailableAppointments(): ' + expMessage + '\n Stack Trace:: ' + ex.getStackTraceString());
            throw new WSCH_Exception(expMessage);
        }catch(WSCH_Exception ex) {
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::getAvailableAppointments(): ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            throw ex;
        }catch (Exception ex){
            String expMessage = 'Exception is raised while getting available appointment.';
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::getAvailableAppointments(): ' + expMessage + ' :: ' +ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            throw new WSCH_Exception(expMessage);
        }
        return null;
    }
    
 
    /**
        Invokes the bookAppointment API method of SPAdaptor.
        Gets a TechnicianSlotReponse object, which contains the status of the API call (status code & status message)
        along with the list of WSCH_Appointment objects.
    */
    public static WSCH_AppointmentsResponse bookAppointment(SVMXC__Service_Order__c workOrder, WSCH_Appointment apptSlot){

        WSCH_AppointmentsResponse apptResponse = null;
        try{
            String startTime = WSCH_DateUtils.getCurrentTimeStamp();
            WSCH_IRealTimeOptimizer realTimeOptimizer = WSCH_Provider_OptimizationFactory.getRealTimeOptimizer();
            apptResponse = realTimeOptimizer.bookAppointment(workOrder, apptSlot);
            WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::bookAppointment(): apptResponse - ' + apptResponse);
            
            String strActiveProvider = WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO')){
                //Creating this List of WO object and adding a single WO only for passing this list to the securityUtils method
                WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer::bookAppointment():workOrder ' + workOrder);
                List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
                SVMXC__Service_Order__c newWO = new SVMXC__Service_Order__c();
                newWO.Id = workOrder.Id;
                if(!'OPT_TENTATIVE'.equalsIgnoreCase(workOrder.SVMXC__OptiMax_Status__c)){
                    newWO.SVMXC__OptiMax_Status__c = workOrder.SVMXC__OptiMax_Status__c;
                }
                newWO.SVMXC__OptiMax_Error_Text__c = workOrder.SVMXC__OptiMax_Error_Text__c;
                newWO.SVMXC__Appointment_Promised_Time_Slot__c = workOrder.SVMXC__Appointment_Promised_Time_Slot__c;
                newWO.SVMXC__Scheduling_Change_Token__c = workOrder.SVMXC__Scheduling_Change_Token__c;
                newWO.SVMXC__Locked_By_DC__c = workOrder.SVMXC__Locked_By_DC__c;
                newWO.SVMXC__SM_Lock_Appointment_Schedule__c = workOrder.SVMXC__SM_Lock_Appointment_Schedule__c;
                lstWO.add(newWO);
                if(!lstWO.isEmpty()){
                    if (!securityUtils.verifyFieldAccess(lstWO, COMM_SecurityUtils.Access.Updateable, false))
                    {
                        WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }           
                    else
                    {
                        WSCH_OptimizedSchedulingService.triggerExecuted = true;
                        WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                        update lstWO[0];   
                    }
                }
                
            }else if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('SERVICEPOWER')){
                // Commented by Kamal: Push notifications to update the schedule details and also updating WorkOrder
                //Check if Push notification is enabled then skip the get changed workorders call.
                if('True' != WSCH_CommonUtils.getSettingValue('DCON004','SET010')){
                    if(apptResponse != null) {
                        if(WSCH_Provider_SP_ErrorCodesMapper.successCodes.contains(apptResponse.statusCode)) {
                            SVMXC__Territory__c[] territories = [SELECT ID,SVMXC__Optimizer_External_ID__c FROM SVMXC__Territory__c WHERE SVMXC__Optimizer_External_ID__c = :apptSlot.getFRU()];
                            for(SVMXC__Territory__c territory : territories) {
                                territory.SVMXC__Optimizer_Last_Timestamp__c = startTime;
                            }
                            getChangedWorkOrders(territories[0], workorder);
                            if(territories != null && territories.size() > 0) 
                                {
                                    if (!securityUtils.verifyFieldAccess(territories, COMM_SecurityUtils.Access.Updateable, false))     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                    {
                                        WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                                    }           
                                    else
                                    {
                                        update territories; 
                                    }
                                }
                            
                        }
                    }
                }else{
                    //if push is not enabled we manually updating the wo.
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                    
                    //Creating this List of WO object and adding a single WO only for passing this list to the securityUtils method
                    List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
                    lstWO.add(workOrder);
                    
                    WSCH_CommonUtils.getWorkorderFields();
                    if((WSCH_CommonUtils.strSetOfUpdateableFields != null) && (!WSCH_CommonUtils.strSetOfUpdateableFields.isEmpty())){
                        List<SVMXC__Service_Order__c> lstUpdateWos = new List<SVMXC__Service_Order__c>();
                        lstUpdateWos.addAll(lstWO);
                        lstWO = new List<SVMXC__Service_Order__c>();
                        lstWO.addAll(WSCH_CommonUtils.getMapOfWorkOrders(WSCH_CommonUtils.strSetOfUpdateableFields, lstUpdateWos).values());
                    }else{
                        WSCH_AuditLogger.debug('WSCH_Plugin_RealTimeOptimizer:lstWO:strSetOfUpdateableFields: ' + WSCH_CommonUtils.strSetOfUpdateableFields);
                    }
                    if(!lstWO.isEmpty()){
                        if (!securityUtils.verifyFieldAccess(lstWO, COMM_SecurityUtils.Access.Updateable, false))       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        {
                            WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }           
                        else
                        {
                            update lstWO[0];   
                        }
                    }
                }
            }
        }catch(WSCH_ServiceNotFoundException ex){
            String expMessage = 'Required service is not found for this organization to book appointment.';
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::bookAppointment(): ' + expMessage + '\n Stack Trace:: ' + ex.getStackTraceString());
            throw new WSCH_Exception(expMessage);
        }catch(WSCH_Exception ex) {
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::bookAppointment(): ' +ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            throw ex;
        }catch (Exception ex){
            String expMessage = 'Exception raised while booking appointment for work orders.';
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::bookAppointment(): ' +expMessage + ' :: ' +ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            throw new WSCH_Exception(expMessage);
        }

        return apptResponse;
    }

    /**
        Invokes the getChangedWorkOrders API method of SPAdaptor.
        Gets a List of technician events object, which contains updates of techinician.
    */
    public static void getWorkOrderUpdates(SVMXC__Territory__c territory) {

        try{
            WSCH_WorkOrderUpdateResponse woUpdateResponse = getChangedWorkOrders(territory, null);

            if(territory.SVMXC__Optimizer_Last_Timestamp__c != null){
                WSCH_AuditLogger.debug('TIMESTAMP BEFORE Update: ' + territory.SVMXC__Optimizer_Last_Timestamp__c);
            }
            else{
                WSCH_AuditLogger.debug('TIMESTAMP BEFORE Update: TIMESTAMP IS NULL');
            }
            //This is fix to avoid update territory optimizer timestamp as 0
            //if(woUpdateResponse.getTimeStampOut() !=null && !woUpdateResponse.getTimeStampOut().equals('0')){
            if(checkTimeStamp(woUpdateResponse.getTimeStampOut())){
                WSCH_AuditLogger.debug('woUpdateResponse.getTimeStampOut(): ' + woUpdateResponse.getTimeStampOut());
                territory.SVMXC__Optimizer_Last_Timestamp__c = woUpdateResponse.getTimeStampOut();
            }else{
                territory.SVMXC__Optimizer_Last_Timestamp__c = WSCH_DateUtils.getCurrentTimeStamp();
            }
            if(territory.SVMXC__Optimizer_Last_Timestamp__c !=null){
                WSCH_AuditLogger.debug('TIMESTAMP AFTER Update: ' + territory.SVMXC__Optimizer_Last_Timestamp__c + '\n WSCH_DateUtils.getCurrentTimeStamp()' + WSCH_DateUtils.getCurrentTimeStamp());
            }
            else{
                WSCH_AuditLogger.debug('TIMESTAMP AFTER Update: TIMESTAMP IS NULL');
            }
            
            List<SVMXC__Territory__c> lstOfTerritory = new List<SVMXC__Territory__c>();
            lstOfTerritory.add(territory);
            
            if (!securityUtils.verifyFieldAccess(lstOfTerritory, COMM_SecurityUtils.Access.Updateable, false))      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                {
                    WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }           
                else
                {
                    update territory;   
                }
            
        }catch(WSCH_ServiceNotFoundException ex){
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::getWorkOrderUpdates(): ' +'Service not found for this organization. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }catch (Exception ex){
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::getWorkOrderUpdates(): ' +'Exception raised while getting updates for work orders. : '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

    /**
        Invokes the manageNonWorkOrderEvents API method of SPAdaptor.
    */
    public static void manageNonWorkOrderEvents(List<SVMXC__SVMX_Optimizer__c> events) {

        try{
            WSCH_IRealTimeOptimizer realTimeOptimizer = WSCH_Provider_OptimizationFactory.getRealTimeOptimizer();
            WSCH_NonWOEventResponse response= realTimeOptimizer.manageNonWorkOrderEvents(events);
            if(response !=null && response.getEvents().size() > 0) {
              WSCH_WorkOrderEventHelper.updateNonWoEvents(response.getEvents());
            }
            WSCH_WorkOrderResponse woResponse = new WSCH_WorkOrderResponse();
            if(response!= null){
                woResponse.getLstTechEvent().addAll(response.getTechEvents());
                WSCH_WorkOrderEventHelper.processWorkOrderResponse(woResponse);
            }
        } catch (WSCH_ServiceNotFoundException ex){
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::manageNonWorkOrderEvents(): ' +'Service not found for this organization. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        } catch (Exception ex) {
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::manageNonWorkOrderEvents(): ' +'Exception raised while scheduling work orders. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

    /**
        Invokes the cancelWorkOrders API method of SPAdaptor.
    */
    public static void cancelWorkOrders(List<SVMXC__SVMX_Optimizer__c> workOrders) {

        try{
            WSCH_IRealTimeOptimizer realTimeOptimizer = WSCH_Provider_OptimizationFactory.getRealTimeOptimizer();
            List<SVMXC__SVMX_Optimizer__c> responseWorkOrders = realTimeOptimizer.cancelWorkOrders(workOrders);
            if (!securityUtils.verifyFieldAccess(responseWorkOrders, COMM_SecurityUtils.Access.Updateable, false))      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            {
                WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }           
            else
            {
                update responseWorkOrders;  
            }
            
        } catch (WSCH_ServiceNotFoundException ex){
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::cancelWorkOrders(): ' +'Service not found for this organization. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        } catch (Exception ex) {
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::cancelWorkOrders(): ' +'Exception raised while scheduling work orders. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

    /**
        Invokes the getChangedWorkOrders API method of SPAdaptor.
        Gets a List of technician events object, which contains updates of techinician.
    */
    public static WSCH_WorkOrderUpdateResponse getChangedWorkOrders(SVMXC__Territory__c territory, SVMXC__Service_Order__c workOrder){

       WSCH_IRealTimeOptimizer realTimeOptimizer = WSCH_Provider_OptimizationFactory.getRealTimeOptimizer();
       WSCH_WorkOrderUpdateResponse woUpdateResponse = realTimeOptimizer.getWorkOrderUpdates(territory);
       WSCH_OptimizedSchedulingService.triggerExecuted = true;
       WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
       if(null != workOrder) {
            //check if the WO is fixed by checking LockedByDC is true, then remove the flag to rebook an appointment.
            WSCH_AuditLogger.debug('LockedByDC flag :-'+workOrder.SVMXC__Locked_By_DC__c);
            if(workOrder.SVMXC__Locked_By_DC__c) {
                WSCH_AuditLogger.debug('LockedByDC flag set back to false, when rebook appointment for this job.');
                workOrder.SVMXC__Locked_By_DC__c = false;
            }
            woUpdateResponse.getWoResponse().getLstWorkOrder().add(workOrder);
       }
       WSCH_WorkOrderEventHelper.processWorkOrderResponse(woUpdateResponse.getWoResponse());
       return woUpdateResponse;
    }
    /*
        Validate if the TimeStamp format is suitable for conversion
    */
    private static Boolean checkTimeStamp(String timeStamp){
        Boolean retTimeCheck = true;
        //check if TimeStamp is NULL, WhiteSpace or ''
        if(String.isBlank(timeStamp)){
            retTimeCheck = false;
            WSCH_AuditLogger.debug('TIMESTAMP IS NULL');
        }//check if TimeStamp is ZERO
        else if(timeStamp.equalsIgnoreCase('0')){
            WSCH_AuditLogger.debug('TIMESTAMP IS 0. Value = ' + timeStamp);
            retTimeCheck = false;
        }//verify TimeStamp is NUMERIC before converting to LONG
        else if(timeStamp.isNumeric()){
            //check if TimeStamp is Greater than TWO Days from NOW.
            if(long.valueOf(timeStamp) > (DateTime.now().addDays(2).getTime()/1000)){
                WSCH_AuditLogger.debug('TIMESTAMP IS GREATER THAN 2 DAYS FROM NOW. Value = ' + timeStamp);
                retTimeCheck = false;
            }
        }//check if TimeStamp is Non-Numeric
        else if(!timeStamp.isNumeric()){
            WSCH_AuditLogger.debug('TIMESTAMP IS NON-Numeric. Value = ' + timeStamp);
            retTimeCheck = false;
        } 
        return retTimeCheck;
    }
    
    public static Boolean manageSchedulingResults(String strJobInfo) {
        Boolean isCallSuccess = false;
        try{
            WSCH_IRealTimeOptimizer realTimeOptimizer = WSCH_Provider_OptimizationFactory.getRealTimeOptimizer();
            isCallSuccess = realTimeOptimizer.manageSchedulingResults(strJobInfo);
        } catch (WSCH_ServiceNotFoundException ex){
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::cancelWorkOrders(): ' +'Service not found for this organization. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        } catch (Exception ex) {
            WSCH_AuditLogger.error('WSCH_Plugin_RealTimeOptimizer::cancelWorkOrders(): ' +'Exception raised while retrieving Work Orders results. '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return isCallSuccess;
    }
    
    public static void testcheckTimeStamp(String timeStamp){
        checkTimeStamp(timeStamp);
    }
}