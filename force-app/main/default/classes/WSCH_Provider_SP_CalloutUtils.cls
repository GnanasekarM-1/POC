/**
@ Name WSCH_Provider_SP_CalloutUtils
@ Author Anantha Kumar
@ Description All the API callout are routed through this utils class and it does the appropriate hooks invocation lifecycle.
*/
public with sharing class WSCH_Provider_SP_CalloutUtils{
    
    public static WSCH_Provider_SP_StubsV91.JobBookResponse bookJob(SVMXC__Service_Order__c workOrder, WSCH_IRequest request, WSCH_Status statusObj) {
        WSCH_Provider_SP_StubsV91.JobBookResponse response = null;
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        workOrders.add(workOrder);
        WSCH_ICalloutHook hook=null;
        try{
            //hook implementation
            hook = WSCH_Provider_SP_HookUtils.getCalloutHook('bookJob');
            if(!beforeCall(hook, request, workOrders, statusObj)){
                return null;
            }
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            servicePowerWsdl.timeout_x= WSCH_Constants.customTimeout;
            //Fetch & Set EndPoint URL corresponding to the WorkOrder
            //if((workOrder.SVMXC__Dispatch_Process__c != null) || (workOrder.SVMXC__Optimizer_Connection_Name__c != null)){
                String strConName = WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id);
                if(String.isNotBlank(strConName)){
                    servicePowerWsdl.endpoint_x = WSCH_Provider_SP_RealTimeOptimizer.getSpURL(strConName);
                }
            //}
            response = servicePowerWsdl.BookJob((WSCH_Provider_SP_StubsV91.JobBookRequest) request);
        }catch(Exception ex){
            handleException(ex,workOrder,'bookJob', ex.getStackTraceString());
        }
        afterCall(hook, response, workOrders, statusObj);
        return response;
    }
    
    
    public static WSCH_Provider_SP_StubsV91.BookDependencyGroupResponse bookDependencyGroup(SVMXC__Dependency_Management__c dependencyManagement, List<SVMXC__Service_Order_Dependency__c> serviceOrderList, WSCH_Provider_SP_StubsV91.BookDependencyGroupRequest request, WSCH_Status statusObj){
        WSCH_Provider_SP_StubsV91.BookDependencyGroupResponse response = null;
        //hook implementation
        WSCH_ICalloutHook hook=null;
        try{
            hook = WSCH_Provider_SP_HookUtils.getCalloutHook('BookDependencyGroup');
            if(!beforeCall(hook, request, serviceOrderList, statusObj,dependencyManagement)){
                return null;
            }
        
            WSCH_Provider_SP_ServiceV91.sp serviceWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            serviceWsdl.timeout_x= WSCH_Constants.customTimeout;
            //Multiple Instance Begin
            String strConName = '';
            if(!WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.isEmpty()){
                for(Service_Order_Dependency__c serviceOrder : serviceOrderList){
                    if(WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(serviceOrder.SVMXC__Primary_Work_Order__c)!=null){
                        strConName = WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(serviceOrder.SVMXC__Primary_Work_Order__c);
                    }
                    if(WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(serviceOrder.SVMXC__Secondary_Work_Order__c)!=null){
                        strConName = WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(serviceOrder.SVMXC__Secondary_Work_Order__c);
                    }
                }
            }
            if(String.isNotBlank(strConName)){
                serviceWsdl.endpoint_x = WSCH_Provider_SP_RealTimeOptimizer.getSpURL(strConName);
            }
            //Multiple Instance End
             if(!Test.isRunningTest()){
            response= serviceWsdl.BookDependencyGroup((WSCH_Provider_SP_StubsV91.BookDependencyGroupRequest) request);
            }
            System.debug('response_x-->'+response);
        }
        catch(Exception ex){
            handleException(ex,serviceOrderList,'bookJob', ex.getStackTraceString());
        }
        afterCall(hook, response, serviceOrderList, statusObj,dependencyManagement);
        return response;
    }
    
    private static boolean beforeCall(WSCH_ICalloutHook hook, WSCH_IRequest request, List<Service_Order_Dependency__c> dependencyGroups, WSCH_Status statusObj, SVMXC__Dependency_Management__c dependencyManagement) {
        try {
            hook.beforeCall(request, dependencyGroups, statusObj);
        } catch(DMLException ex) {
            dependencyManagement.SVMXC__Status__c=WSCH_Constants.STATUS_OPT_FAIL;
            dependencyManagement.SVMXC__Error_Text__c='WSCH_Provider_SP_CalloutUtils :: beforeCall :: DMLException :' + ex.getMessage();
            statusObj.exceptionObj=ex;
            WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: beforeCall :: DMLException :' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;                       
        } catch(Exception ex) {
            dependencyManagement.SVMXC__Status__c=WSCH_Constants.STATUS_OPT_FAIL;
            dependencyManagement.SVMXC__Error_Text__c='WSCH_Provider_SP_CalloutUtils :: beforeCall :: ' + ex.getMessage();
            statusObj.exceptionObj=ex;
            WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: beforeCall :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;                       
        }
        return true;
    }
    private static boolean afterCall(WSCH_ICalloutHook hook, WSCH_IResponse response, List<Service_Order_Dependency__c> dependencyGroups, WSCH_Status statusObj, SVMXC__Dependency_Management__c dependencyManagement) {
        try {
            hook.afterCall(response, dependencyGroups, statusObj);
        } catch(DMLException ex) {
            dependencyManagement.SVMXC__Status__c=WSCH_Constants.STATUS_OPT_FAIL;
            dependencyManagement.SVMXC__Error_Text__c='WSCH_Provider_SP_CalloutUtils :: afterCall :: DMLException :' + ex.getMessage();          
            statusObj.exceptionObj=ex;
            WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: afterCall :: DMLException :' + ex.getMessage());
            return false;                       
        } catch(Exception ex) {
            dependencyManagement.SVMXC__Status__c=WSCH_Constants.STATUS_OPT_FAIL;
            dependencyManagement.SVMXC__Error_Text__c='WSCH_Provider_SP_CalloutUtils :: afterCall :: ' + ex.getMessage();            
            statusObj.exceptionObj=ex;
            WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: afterCall :: ' + ex.getMessage());
            return false;                       
        }
        return true;
    }
    private static void handleException(Exception ex, List<SVMXC__Service_Order_Dependency__c> svcOrderList,String methodName, String stackTrace) {
        for (SVMXC__Service_Order_Dependency__c serviceOrder : svcOrderList){
            //[BVL] serviceOrder.SVMXC__Status__c = WSCH_Constants.STATUS_OPT_FAIL;
            String errorText = 'WSCH_Provider_SP_CalloutUtils :: '+methodName+' :: '+ex.getMessage();
            //[BVL] WSCH_CommonUtils.setOptimizerErrorText(serviceOrder, errorText);
            WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: '+methodName+' :: '+ex.getMessage()+ '\n' + stackTrace);        
        }   
    }
    
    public static WSCH_Provider_SP_StubsV91.ApptOfferResponse getAppointments(SVMXC__Service_Order__c workOrder, WSCH_IRequest request, WSCH_Status statusObj) {
        WSCH_Provider_SP_StubsV91.ApptOfferResponse response=null;
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        workOrders.add(workOrder);
        WSCH_ICalloutHook hook=null;
        try{
            //hook implementation
            hook = WSCH_Provider_SP_HookUtils.getCalloutHook('OfferAppts');
            if(!beforeCall(hook, request, workOrders, statusObj)){
                return null;
            }
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            servicePowerWsdl.timeout_x= WSCH_Constants.customTimeout;
            //Fetch & Set EndPoint URL corresponding to the WorkOrder
            //if((workOrder.SVMXC__Dispatch_Process__c != null) || (workOrder.SVMXC__Optimizer_Connection_Name__c != null) || (String.isNotBlank(strConName))){
                String strConName = WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id);
                if(String.isNotBlank(strConName)){
                    servicePowerWsdl.endpoint_x = WSCH_Provider_SP_RealTimeOptimizer.getSpURL(strConName);
                }
            //}
            response = servicePowerWsdl.OfferAppts((WSCH_Provider_SP_StubsV91.ApptOfferRequest)request);
        }catch(Exception ex){
            handleException(ex,workOrder,'getAppointments',ex.getStackTraceString());
        }
        afterCall(hook, response, workOrders, statusObj);
        return response;
    }   

    public static WSCH_Provider_SP_StubsV91.ApptBookResponse bookAppointment(SVMXC__Service_Order__c workOrder, WSCH_IRequest request, WSCH_Status statusObj) {
        WSCH_Provider_SP_StubsV91.ApptBookResponse response=null;
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        workOrders.add(workOrder);
        WSCH_ICalloutHook hook=null;
        try{
            //hook implementation
            hook = WSCH_Provider_SP_HookUtils.getCalloutHook('BookAppt');
            if(!beforeCall(hook, request, workOrders, statusObj)){
                return null;
            }
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            servicePowerWsdl.timeout_x= WSCH_Constants.customTimeout;
            //Fetch & Set EndPoint URL corresponding to the WorkOrder
            //if((workOrder.SVMXC__Dispatch_Process__c != null) || (workOrder.SVMXC__Optimizer_Connection_Name__c != null)){
                String strConName = WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id);
                if(String.isNotBlank(strConName)){
                    servicePowerWsdl.endpoint_x = WSCH_Provider_SP_RealTimeOptimizer.getSpURL(strConName);
                }
            //}
            response = servicePowerWsdl.BookAppt((WSCH_Provider_SP_StubsV91.ApptBookRequest) request);
        }catch(Exception ex){
            handleException(ex,workOrder,'bookAppointment',ex.getStackTraceString());
        }
        afterCall(hook, response, workOrders, statusObj);
        return response;
    }
    
    public static WSCH_Provider_SP_StubsV91.ReturnCode changeWorkItemStatus(SVMXC__Service_Order__c workOrder, WSCH_IRequest request, WSCH_Status statusObj) {
        WSCH_Provider_SP_StubsV91.ReturnCode response=null;
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        workOrders.add(workOrder);
        WSCH_ICalloutHook hook=null;        
        try{
            //hook implementation
            hook = WSCH_Provider_SP_HookUtils.getCalloutHook('ChangeWorkItemStatus');
            if(!beforeCall(hook, request, workOrders, statusObj)){
                return null;
            }
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            servicePowerWsdl.timeout_x= WSCH_Constants.customTimeout;
            //Fetch & Set EndPoint URL corresponding to the WorkOrder
            String strConName = WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id);
            if(String.isNotBlank(strConName)){
                servicePowerWsdl.endpoint_x = WSCH_Provider_SP_RealTimeOptimizer.getSpURL(strConName);
            }
            response = servicePowerWsdl.ChangeWorkItemStatus((WSCH_Provider_SP_StubsV91.ChangeWorkItemStatusRequest)request);

        }catch(Exception ex){
            handleException(ex,workOrder,'changeWorkItemStatus',ex.getStackTraceString());
        }
        afterCall(hook, response, workOrders, statusObj);       
        return response;
    }
    
    public static WSCH_Provider_SP_StubsV91.GetJobStatusResponse getJobStatus(SVMXC__Service_Order__c workOrder, WSCH_IRequest request, WSCH_Status statusObj) {
        WSCH_Provider_SP_StubsV91.GetJobStatusResponse response=null;
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        workOrders.add(workOrder);
        WSCH_ICalloutHook hook=null;            
        try{
            //hook implementation
            hook = WSCH_Provider_SP_HookUtils.getCalloutHook('GetJobStatus');
            if(!beforeCall(hook, request, workOrders, statusObj)){
                return null;
            }
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            servicePowerWsdl.timeout_x= WSCH_Constants.customTimeout;
            //Fetch & Set EndPoint URL corresponding to the WorkOrder
            String strConName = WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id);
            if(String.isNotBlank(strConName)){
                servicePowerWsdl.endpoint_x = WSCH_Provider_SP_RealTimeOptimizer.getSpURL(strConName);
            }
            response = servicePowerWsdl.GetJobStatus((WSCH_Provider_SP_StubsV91.GetJobStatusRequest) request);
        }catch(Exception ex){
            handleException(ex,workOrder,'getJobStatus',ex.getStackTraceString());
        }
        afterCall(hook,response, workOrders, statusObj);        
        return response;
    }       
    
    public static WSCH_Provider_SP_StubsV91.EmpAddActResponse stdActivityCreate(SVMXC__SVMX_Optimizer__c event, WSCH_IRequest request, WSCH_Status statusObj) {
        WSCH_Provider_SP_StubsV91.EmpAddActResponse response=null;
        List<SVMXC__SVMX_Optimizer__c> events = new List<SVMXC__SVMX_Optimizer__c>();
        events.add(event);
        WSCH_ICalloutHook hook=null;            
        try{
            //hook implementation
            hook = WSCH_Provider_SP_HookUtils.getCalloutHook('EmpAddAct');
            if(!beforeCall(hook, request, events, statusObj)){
                return null;
            }
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            servicePowerWsdl.timeout_x= WSCH_Constants.customTimeout;
            //Fetch & Set EndPoint URL corresponding to the Event
            String strConName = WSCH_Provider_SP_RealTimeOptimizer.mapEventConn.get(event.SVMXC__WhatId__c);
            if(String.isNotBlank(strConName)){
                servicePowerWsdl.endpoint_x = WSCH_Provider_SP_RealTimeOptimizer.getSpURL(strConName);
            }
            response = servicePowerWsdl.EmpAddAct((WSCH_Provider_SP_StubsV91.EmpAddActRequest) request);
        }catch(Exception ex){
            handleException(ex,event,'stdActivityCreate',ex.getStackTraceString());
        }
        afterCall(hook, response, events, statusObj);       
        return response;
    }

    public static WSCH_Provider_SP_StubsV91.StandardResponse stdActivityDelete(SVMXC__SVMX_Optimizer__c event, WSCH_IRequest request, WSCH_Status statusObj) {
        WSCH_Provider_SP_StubsV91.StandardResponse response=null;
        List<SVMXC__SVMX_Optimizer__c> events = new List<SVMXC__SVMX_Optimizer__c>();
        events.add(event);
        WSCH_ICalloutHook hook=null;                
        try{
            //hook implementation
            hook = WSCH_Provider_SP_HookUtils.getCalloutHook('ActDelete');
            if(!beforeCall(hook, request, events, statusObj)){
                return null;
            }
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            servicePowerWsdl.timeout_x= WSCH_Constants.customTimeout;
            //Fetch & Set EndPoint URL corresponding to the Event
            String strConName = WSCH_Provider_SP_RealTimeOptimizer.mapEventConn.get(event.SVMXC__WhatId__c);
            if(String.isNotBlank(strConName)){
                servicePowerWsdl.endpoint_x = WSCH_Provider_SP_RealTimeOptimizer.getSpURL(strConName);
            }
            response = servicePowerWsdl.ActDelete((WSCH_Provider_SP_StubsV91.ActDeleteRequest)request);
        }catch(Exception ex){
            handleException(ex,event,'stdActivityDelete',ex.getStackTraceString());
        }
        afterCall(hook, response, events, statusObj);       
        return response;
    }
    
    public static WSCH_Provider_SP_StubsV91.ReturnCode stdActivityUpdate(SVMXC__SVMX_Optimizer__c event, WSCH_IRequest request, WSCH_Status statusObj) {
        WSCH_Provider_SP_StubsV91.ReturnCode response=null;
        List<SVMXC__SVMX_Optimizer__c> events = new List<SVMXC__SVMX_Optimizer__c>();
        events.add(event);
        WSCH_ICalloutHook hook=null;            
        try{
            //hook implementation
            hook = WSCH_Provider_SP_HookUtils.getCalloutHook('ActUpdate');
            if(beforeCall(hook, request, events, statusObj)){
                return null;
            }
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            servicePowerWsdl.timeout_x= WSCH_Constants.customTimeout;
            //Fetch & Set EndPoint URL corresponding to the Event
            String strConName = WSCH_Provider_SP_RealTimeOptimizer.mapEventConn.get(event.SVMXC__WhatId__c);
            if(String.isNotBlank(strConName)){
                servicePowerWsdl.endpoint_x = WSCH_Provider_SP_RealTimeOptimizer.getSpURL(strConName);
            }
            response = servicePowerWsdl.ActUpdate((WSCH_Provider_SP_StubsV91.ActUpdateRequest) request);
        }catch(Exception ex){
            handleException(ex,event,'stdActivityUpdate',ex.getStackTraceString()); 
        }
        afterCall(hook, response, events, statusObj);       
        return response;
    }   
    
    public static WSCH_Provider_SP_StubsV91.ReturnCode updateJob(SVMXC__Service_Order__c workOrder, WSCH_IRequest request, WSCH_Status statusObj) {
        WSCH_Provider_SP_StubsV91.ReturnCode response=null;
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        workOrders.add(workOrder);
        WSCH_ICalloutHook hook=null;                
        try{
            //hook implementation
            hook = WSCH_Provider_SP_HookUtils.getCalloutHook('UpdateJob');
            if(!beforeCall(hook, request, workOrders, statusObj)){
                return null;
            }
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            servicePowerWsdl.timeout_x= WSCH_Constants.customTimeout;
            //Fetch & Set EndPoint URL corresponding to the WorkOrder
            String strConName = WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id);
            if(String.isNotBlank(strConName)){
                servicePowerWsdl.endpoint_x = WSCH_Provider_SP_RealTimeOptimizer.getSpURL(strConName);
            }
            response = servicePowerWsdl.UpdateJob((WSCH_Provider_SP_StubsV91.JobUpdateRequest) request);
        }catch(Exception ex){
            handleException(ex,workOrder,'updateJob',ex.getStackTraceString());
        }
        afterCall(hook, response, workOrders, statusObj);
        return response;
    }

    public static WSCH_Provider_SP_StubsV91.JobCancelResponse cancelJob(SVMXC__Service_Order__c workOrder, WSCH_IRequest request, WSCH_Status statusObj) {
        WSCH_Provider_SP_StubsV91.JobCancelResponse response=null;
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        workOrders.add(workOrder);
        WSCH_ICalloutHook hook=null;            
        try{
            //hook implementation
            hook = WSCH_Provider_SP_HookUtils.getCalloutHook('CancelJob');
            if(!beforeCall(hook, request, workOrders, statusObj)){
                return null;
            }
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            servicePowerWsdl.timeout_x= WSCH_Constants.customTimeout;
            //Fetch & Set EndPoint URL corresponding to the WorkOrder
            String strConName = WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id);
            if(String.isNotBlank(strConName)){
                servicePowerWsdl.endpoint_x = WSCH_Provider_SP_RealTimeOptimizer.getSpURL(strConName);
            }
            response = servicePowerWsdl.CancelJob((WSCH_Provider_SP_StubsV91.JobCancelRequest) request);
        }catch(Exception ex){
            handleException(ex,workOrder,'cancelJob',ex.getStackTraceString()); 
        }
        afterCall(hook, response, workOrders, statusObj);
        return response;
    }
        
    public static WSCH_Provider_SP_StubsV91.JobCancelResponse cancelJob(SVMXC__SVMX_Optimizer__c event, WSCH_IRequest request, WSCH_Status statusObj) {
        WSCH_Provider_SP_StubsV91.JobCancelResponse response=null;
        List<SVMXC__SVMX_Optimizer__c> events = new List<SVMXC__SVMX_Optimizer__c>();
        events.add(event);
        WSCH_ICalloutHook hook=null;            
        try{
            //hook implementation
            hook = WSCH_Provider_SP_HookUtils.getCalloutHook('CancelJob');
            if(!beforeCall(hook, request, events, statusObj)){
                return null;
            }
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            servicePowerWsdl.timeout_x= WSCH_Constants.customTimeout;
            //Fetch & Set EndPoint URL corresponding to the WorkOrder
            String strWoId = WSCH_Provider_SP_RealTimeOptimizer.mapWoIDName.get(event.SVMXC__WhatId__c);
            if(String.isNotBlank(strWoId)){
                String strConName = WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(Id.valueOf(strWoId));
                if(String.isNotBlank(strConName)){
                    servicePowerWsdl.endpoint_x = WSCH_Provider_SP_RealTimeOptimizer.getSpURL(strConName);
                }
            }
            response = servicePowerWsdl.CancelJob((WSCH_Provider_SP_StubsV91.JobCancelRequest) request);
        }catch(Exception ex){
            handleException(ex,event,'cancelJob',ex.getStackTraceString());
        }
        afterCall(hook, response, events, statusObj);       
        return response;
    }
    
    public static WSCH_Provider_SP_StubsV91.ReturnCode forceFixJob(SVMXC__Service_Order__c workOrder, WSCH_IRequest request, WSCH_Status statusObj) {
        WSCH_Provider_SP_StubsV91.ReturnCode response=null;
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        workOrders.add(workOrder);
        WSCH_ICalloutHook hook=null;                
        try{
            //hook implementation
            hook = WSCH_Provider_SP_HookUtils.getCalloutHook('ForceFixJob');
            if(!beforeCall(hook, request, workOrders, statusObj)){
                return null;
            }
            WSCH_Provider_SP_ServiceV91.sp servicePowerWsdl = new WSCH_Provider_SP_ServiceV91.sp();
            servicePowerWsdl.timeout_x= WSCH_Constants.customTimeout;
            //Fetch & Set EndPoint URL corresponding to the WorkOrder
            String strConName = WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.get(workOrder.Id);
            if(String.isNotBlank(strConName)){
                servicePowerWsdl.endpoint_x = WSCH_Provider_SP_RealTimeOptimizer.getSpURL(strConName);
            }
            response = servicePowerWsdl.ForceFixJob((WSCH_Provider_SP_StubsV91.ForceFixJobRequest) request);
        }catch(Exception ex){
            handleException(ex,workOrder,'forceFixJob',ex.getStackTraceString());
        }
        afterCall(hook, response, workOrders, statusObj);
        return response;
    }
    
    
    /* Handling exception in this common method for all the callout */
    private static void handleException(Exception ex, SVMXC__Service_Order__c wo,String methodName, String stackTrace) {
        wo.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
        String errorText = 'WSCH_Provider_SP_CalloutUtils :: '+methodName+' :: '+ex.getMessage();
        WSCH_CommonUtils.setOptimizerErrorText(wo, errorText);
        WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: '+methodName+' :: '+ex.getMessage()+ '\n' + stackTrace);           
    }
    
    /* Actual hook before call for workorder object */  
    private static boolean beforeCall(WSCH_ICalloutHook hook, WSCH_IRequest request, List<SVMXC__Service_Order__c> workOrders, WSCH_Status statusObj) {
        try {
            hook.beforeCall(request, workOrders, statusObj);
        } catch(DMLException ex) {
            workOrders[0].SVMXC__OptiMax_Status__c=WSCH_Constants.STATUS_OPT_FAIL;
            workOrders[0].SVMXC__OptiMax_Error_Text__c='WSCH_Provider_SP_CalloutUtils :: beforeCall :: DMLException :' + ex.getMessage();
            statusObj.exceptionObj=ex;
            WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: beforeCall :: DMLException :' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;                       
        } catch(Exception ex) {
            workOrders[0].SVMXC__OptiMax_Status__c=WSCH_Constants.STATUS_OPT_FAIL;
            workOrders[0].SVMXC__OptiMax_Error_Text__c='WSCH_Provider_SP_CalloutUtils :: beforeCall :: ' + ex.getMessage();
            statusObj.exceptionObj=ex;
            WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: beforeCall :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;                       
        }
        return true;
    }

    /* Actual hook after call for workorder object */
    private static boolean afterCall(WSCH_ICalloutHook hook, WSCH_IResponse response, List<SVMXC__Service_Order__c> workOrders, WSCH_Status statusObj) {
        try {
            hook.afterCall(response, workOrders, statusObj);
        } catch(DMLException ex) {
            workOrders[0].SVMXC__OptiMax_Status__c=WSCH_Constants.STATUS_OPT_FAIL;
            workOrders[0].SVMXC__OptiMax_Error_Text__c='WSCH_Provider_SP_CalloutUtils :: afterCall :: DMLException :' + ex.getMessage();         
            statusObj.exceptionObj=ex;
            WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: afterCall :: DMLException :' + ex.getMessage());
            return false;                       
        } catch(Exception ex) {
            workOrders[0].SVMXC__OptiMax_Status__c=WSCH_Constants.STATUS_OPT_FAIL;
            workOrders[0].SVMXC__OptiMax_Error_Text__c='WSCH_Provider_SP_CalloutUtils :: afterCall :: ' + ex.getMessage();            
            statusObj.exceptionObj=ex;
            WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: afterCall :: ' + ex.getMessage());
            return false;                       
        }
        return true;
    }
    
    /* Handling exception in this common method for all the standard activity callout */
    private static void handleException(Exception ex, SVMXC__SVMX_Optimizer__c event,String methodName, String stackTrace) {
        event.SVMXC__Optimizer_Status__c = WSCH_Constants.STATUS_OPT_FAIL;
        event.SVMXC__Optimizer_Error_Text__c = 'WSCH_Provider_SP_CalloutUtils :: '+methodName+' :: '+ex.getMessage();
        WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: '+methodName+' :: '+ex.getMessage()+ '\n' + stackTrace);           
    }
    
    /* Actual hook before call for event object */  
    private static boolean beforeCall(WSCH_ICalloutHook hook, WSCH_IRequest request, List<SVMXC__SVMX_Optimizer__c> events, WSCH_Status statusObj) {
        try {
            hook.beforeCall(request, events, statusObj);
        } catch(DMLException ex) {
            events[0].SVMXC__Optimizer_Status__c=WSCH_Constants.STATUS_OPT_FAIL;
            events[0].SVMXC__Optimizer_Error_Text__c='WSCH_Provider_SP_CalloutUtils :: beforeCall :: DMLException :' + ex.getMessage();
            statusObj.exceptionObj=ex;
            WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: beforeCall :: DMLException :' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;                       
        } catch(Exception ex) {
            events[0].SVMXC__Optimizer_Status__c=WSCH_Constants.STATUS_OPT_FAIL;
            events[0].SVMXC__Optimizer_Error_Text__c='WSCH_Provider_SP_CalloutUtils :: beforeCall :: ' + ex.getMessage();         
            statusObj.exceptionObj=ex;
            WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: beforeCall :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;                       
        }
        return true;
    }

    /* Actual hook after call for event object */
    private static boolean afterCall(WSCH_ICalloutHook hook, WSCH_IResponse response, List<SVMXC__SVMX_Optimizer__c> events, WSCH_Status statusObj) {
        try {
            hook.afterCall(response, events, statusObj);
        } catch(DMLException ex) {
            events[0].SVMXC__Optimizer_Status__c=WSCH_Constants.STATUS_OPT_FAIL;
            events[0].SVMXC__Optimizer_Error_Text__c='WSCH_Provider_SP_CalloutUtils :: afterCall :: DMLException :' + ex.getMessage();
            statusObj.exceptionObj=ex;
            WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: afterCall :: DMLException :' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;                       
        } catch(Exception ex) {
            events[0].SVMXC__Optimizer_Status__c=WSCH_Constants.STATUS_OPT_FAIL;
            events[0].SVMXC__Optimizer_Error_Text__c='WSCH_Provider_SP_CalloutUtils :: afterCall :: ' + ex.getMessage();          
            statusObj.exceptionObj=ex;
            WSCH_AuditLogger.error('WSCH_Provider_SP_CalloutUtils :: afterCall :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return false;                       
        }
        return true;
    }
    
}