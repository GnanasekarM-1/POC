@RestResource(urlMapping='/scheduling/eco/technician/*')
global with sharing class WSCH_ECO_Client_TechnicianServices {
    public static final String RETURN_MESSAGE_FOR_TECH_UPDATE = 'Technician Horizon Updated';
    public static final String RETURN_MESSAGE_FOR_WO_UPDATE = 'WOs falling within the Horizon are sent';
    public static final String RETURN_MESSAGE_FOR_NON_WO_EVENT_UPDATE = 'Non WO Events falling within the Horizon are sent';
    public static final String NO_OP_ERROR_MESSAGE = 'Empty or Invalid operation type';

    @HttpPost
    global static String doPost() {
        RestRequest request = RestContext.request;
        String elementType = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPost::elementType: ' + elementType);
        Blob data = request.requestBody;
        String inputReq = data.toString();
        WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPost::Json Request: ' + inputReq);
        String res;
        try {
           if(String.isNotBlank(elementType)){
                if('technician'.equalsIgnoreCase(elementType)){
                    WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP req = (WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP)JSON.deserialize(inputReq, WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP.class);
                    if('RESUME_IDS'.equals(req.operation)) {
                         res = WSCH_ECO_Client_TechnicianServices.doPrepareResumeIds(req);
                    } else if('HORIZON_UPDATE'.equals(req.operation)){
                        res = updateTechHorizon(req);
                    } else if('WO_UPDATE'.equals(req.operation)){
                        res = WSCH_ECO_Client_TechnicianServices.scheduleWOsFallingInHorizon(req);
                    } else if('NON_WO_EVENT_UPDATE'.equals(req.operation)) {
                        res = WSCH_ECO_Client_TechnicianServices.scheduleEventsFallingInHorizon(req);
                    }
                }else{
                    WSCH_ECO_Client_Stubs.SchedulingInputRequest_WP req = (WSCH_ECO_Client_Stubs.SchedulingInputRequest_WP)JSON.deserialize(inputReq, WSCH_ECO_Client_Stubs.SchedulingInputRequest_WP.class);
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPost::afer parsing Json: ' + req.Ids);
                    if('workOrder'.equalsIgnoreCase(elementType) || 'skippedWorkOrder'.equalsIgnoreCase(elementType)){
                           res = WSCH_ECO_Client_TechnicianServices.doPrepareWorkOrderWP(req.Ids,req.jobInstanceGuid);
                    }else if('resource'.equalsIgnoreCase(elementType) || 'resourceUpdate'.equalsIgnoreCase(elementType)){
                           res = WSCH_ECO_Client_TechnicianServices.doPrepareTechnicianWP(req.Ids,req.jobInstanceGuid, elementType);
                    }else if('event'.equalsIgnoreCase(elementType)){
                           res = WSCH_ECO_Client_TechnicianServices.doPrepareTechnicianEventWP(req.Ids,req.jobInstanceGuid);
                    }else if('skippedEvent'.equalsIgnoreCase(elementType)){
                         res = WSCH_ECO_Client_TechnicianServices.doPrepareSkippedEventWP(req.Ids,req.jobInstanceGuid);
                    } else if('dependencyWorkOrder'.equalsIgnoreCase(elementType)) {
                            res = WSCH_ECO_Client_TechnicianServices.doPrepareSkippedDependencyWorkOrderWP(req.Ids,req.jobInstanceGuid);
                    }                   
                    //WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPost::response: ' + res);
                }    
           }
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPost::response: ' + res);    
            WSCH_AuditLogger.finish();  
        } catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_ECO_Client_TechnicianServices::doPost():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            res = ex.getMessage() + '\n' + ex.getStackTraceString();
            WSCH_AuditLogger.finish(); 
        } finally{
            WSCH_AuditLogger.finish();
        }
        return res;
    }    

    public static string doPrepareWorkOrderWP(List<String> woNames, string strDPIdTerritoryId){
        List<SVMXC__Service_Order__c> lstWorkOrder = WSCH_ECO_CommonUtils.fetchWorkOrdersByName(woNames);
        WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareWorkOrderWP::lstWorkOrder size:'+lstWorkOrder.size());
        String strTerritoryId;
        String strDPId;
        String requestJson;
        try{
            List<String> lstStr = strDPIdTerritoryId.split('-');
            strDPId = lstStr[1].trim();
            strTerritoryId = lstStr[2].trim();
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareWorkOrderWP::Dispatch Process | TerritoryId:-'+strDPId+' | '+strTerritoryId);
            
            SVMXC__Territory__c objTerritory = WSCH_ECO_CommonUtils.getTerritoryById(strTerritoryId);
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareWorkOrderWP::objTerritory:'+objTerritory);
      
            WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP request_x = WSCH_Provider_ECO_DataMapper.manageJobRequest(objTerritory,lstWorkOrder);
            //get the WOs which are already marked as OPT_ERROR and do the explicit update on them.
            List<SVMXC__Service_Order__c> lstErrorWOs = new List<SVMXC__Service_Order__c>();
            for(SVMXC__Service_Order__c eachWO: lstWorkOrder) {
                if(eachWO.SVMXC__OptiMax_Status__c.equalsIgnoreCase(WSCH_ECO_Constants.STATUS_OPT_ERROR)) {
                    lstErrorWOs.add(eachWO);
                }
            }
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareWorkOrderWP::error WOs size:' + lstErrorWOs.size());
            if(lstErrorWOs.size() > 0) {
                WSCH_OptimizedSchedulingService.triggerExecuted = true;
                WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                Database.upsert(lstErrorWOs);
            }
            requestJson=JSON.serialize(request_x);
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_ECO_Client_TechnicianServices::doPrepareWorkOrderWP:Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
            WSCH_AuditLogger.finish();
         }  
        return requestJson;
    }
    
    public static string doPrepareTechnicianWP(List<String> techIds, string strDPIdTerritoryId, string strElementType){
        List<SVMXC__Service_Group_Members__c> lstTechnicians = new List<SVMXC__Service_Group_Members__c>();
        Set<String> lstTechIds = new Set<String>();
        String strTerritoryId;
        String strDPId;
        String requestJson;
        List<SVMXC__SVMX_Optimizer__c> technicianOptimizers;
        Map<String,SVMXC__SVMX_Optimizer__c> mapTechIdOptTrnObj = new Map<String, SVMXC__SVMX_Optimizer__c>();
        try{
            for(String techNameId : techIds){
                list<String> lstTempId = techNameId.split('_');
                String techId = lstTempId[0].trim();
                lstTechIds.add(techId);
            }   
            lstTechnicians = WSCH_ECO_CommonUtils.getTechniciansByIds(lstTechIds);
            
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareTechnicianWP():lstTechnicians size'+lstTechnicians.size());
        
            List<String> lstStr = strDPIdTerritoryId.split('-');
            strDPId = lstStr[1].trim();
            strTerritoryId = lstStr[2].trim();
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareTechnicianWP::Dispatch Process | TerritoryId:-'+strDPId+' | '+strTerritoryId);
    
            SVMXC__Territory__c objTerritory = WSCH_ECO_CommonUtils.getTerritoryById(strTerritoryId);
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareTechnicianWP::objTerritory:'+objTerritory);
    
            //list<SVMXC__SVMX_Jobs__c> lstSVMXJob = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where SVMXC__Territory__c = :strTerritoryId and SVMXC__Type__c = 'ECO' and SVMXC__OptiMax_Message__c !='FAILED'];
            //WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareTechnicianWP()::lstSVMXJob : ' + lstSVMXJob);         
            String strDateTime;
            strDateTime = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm');
            if('resourceUpdate'.equalsIgnoreCase(strElementType)){
                String connectionId = strDPId + '_' + strTerritoryId;
                technicianOptimizers = WSCH_ECO_CommonUtils.getTechnicianOptimizarByWhatIds(techIds,connectionId);
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareTechnicianWP()::technicianOptimizers : ' + technicianOptimizers.size());         
                if(technicianOptimizers != null && technicianOptimizers.size() > 0){
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareTechnicianWP:technicianOptimizers size..' + technicianOptimizers.size());
                    for(SVMXC__SVMX_Optimizer__c optimizerObj : technicianOptimizers){
                        //TODO: need to check the previous optimizer status. Sometimes create tech might failed.
                        if('CHANGE_CREATE_TECH'.equalsIgnoreCase(optimizerObj.SVMXC__Optimizer_Change_Token__c) && 'OPT_ERROR'.equalsIgnoreCase(optimizerObj.SVMXC__Optimizer_Status__c)){
                            optimizerObj.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_TECH';
                        }else{
                            optimizerObj.SVMXC__Optimizer_Change_Token__c = 'CHANGE_UPDATE_TECH';
                            optimizerObj.SVMXC__Optimizer_Error_Text__c = strDateTime+': Technician data updated during resume job.';
                        }
                        mapTechIdOptTrnObj.put(optimizerObj.SVMXC__WhatId__c,optimizerObj);
                    }
                    // if( COMM_SecurityUtils.getInstance().verifyFieldAccess( technicianOptimizers, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    //  update technicianOptimizers; 
                    // }else {
                    //  throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    // }
                }
            }else if('resource'.equalsIgnoreCase(strElementType)){
                technicianOptimizers= createTechOptimizer(strTerritoryId, strDPId,lstTechnicians);
                for(SVMXC__SVMX_Optimizer__c optimizerObj : technicianOptimizers){
                    mapTechIdOptTrnObj.put(optimizerObj.SVMXC__WhatId__c,optimizerObj);
                }           
            }
    
            WSCH_Provider_ECO_Stubs.ManageTechnicianRequest_WP request_x = WSCH_Provider_ECO_DataMapper.manageTechnicianRequest(objTerritory,lstTechnicians,mapTechIdOptTrnObj,strDPId);
            List<WSCH_Provider_ECO_Stubs.Technician_WP> newResources = new List<WSCH_Provider_ECO_Stubs.Technician_WP>();
            for(WSCH_Provider_ECO_Stubs.Technician_WP techWP :request_x.resources){
                if(techWP.workingHours == null){
                    SVMXC__SVMX_Optimizer__c optimizer = mapTechIdOptTrnObj.get(techWP.resourceId);
                    optimizer.SVMXC__Optimizer_Status__c = 'OPT_ERROR';
                    optimizer.SVMXC__Optimizer_Error_Text__c = strDateTime+' : Technician availability is empty. So technician data not synced. ';
                }else{
                    newResources.add(techWP);   
                }
            }
            request_x.resources = newResources;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( technicianOptimizers, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update technicianOptimizers; 
            }else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
    
            requestJson=JSON.serialize(request_x);
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_ECO_Client_TechnicianServices::doPrepareTechnicianWP:Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
            WSCH_AuditLogger.finish();
        }   
    
        return requestJson;
    }
    
    public static string doPrepareTechnicianEventWP(List<String> techIds, string strDPIdTerritoryId){
        WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP requestWP = new WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP();
        Map<String, BusinessHours> mapBusinessHours = new Map<String, BusinessHours>();
        String requestJson;
        List<SVMXC__SVMX_Optimizer__c> optimizers = new List<SVMXC__SVMX_Optimizer__c>();
        List<SVMXC__Service_Group_Members__c> lstTechnicians;
        Set<String> lstTechIds = new Set<String>();
        String strTerritoryId;
        String strDPId;
        String strOrgId;
        try{
            List<String> lstStr = strDPIdTerritoryId.split('-');
            strOrgId = lstStr[0].trim();
            strDPId = lstStr[1].trim();
            strTerritoryId = lstStr[2].trim();
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareTechnicianEventWP::Dispatch Process | TerritoryId:-'+strDPId+' | '+strTerritoryId);
    
            SVMXC__Territory__c objTerritory = WSCH_ECO_CommonUtils.getTerritoryById(strTerritoryId);
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareTechnicianEventWP::objTerritory:'+objTerritory);
            
            WSCH_Provider_ECO_DataMapper.initializeBussHr(objTerritory);
    
            WSCH_Provider_ECO_DataMapper.setHorizonDates(objTerritory,strDPId);
    
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareTechnicianEventWP::WSCH_Provider_ECO_DataMapper.intNoOfDays:'+WSCH_Provider_ECO_DataMapper.intNoOfDays);
    
            for(String techNameId : techIds){
                list<String> lstTempId = techNameId.split('_');
                String techId = lstTempId[0].trim();
                lstTechIds.add(techId);
            }
    
            lstTechnicians = WSCH_ECO_CommonUtils.getTechniciansByIds(lstTechIds);      
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareTechnicianEventWP():lstTechnicians size'+lstTechnicians.size());
    
            //get non WO event details
            List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP> resourcesEvent = WSCH_Provider_ECO_DataMapper.doBuildResourceEventWrapper(WSCH_Provider_ECO_DataMapper.intNoOfDays,WSCH_Provider_ECO_DataMapper.mapBusinessHours, lstTechnicians,WSCH_Provider_ECO_DataMapper.objDefTerritoryBH, strDPId);
            requestWP.dispatchProcessId = strDPId;
            requestWP.territoryId = strTerritoryId;
            requestWP.technicianEvents = resourcesEvent;
            requestWP.orgId = strOrgId;
            requestWP.geoCodingEnabled = true;
    
            requestJson=JSON.serialize(requestWP);
        
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_ECO_Client_TechnicianServices::doPrepareTechnicianEventWP:Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
            WSCH_AuditLogger.finish();
        }
        return requestJson;
    }
    public static string doPrepareSkippedEventWP(List<String> techEventIds, string strDPIdTerritoryId){
        String requestJson;
        List<SVMXC__SVMX_Optimizer__c> lstEventOptimizers = new List<SVMXC__SVMX_Optimizer__c>();
        String strTerritoryId;
        String strDPId;
        List<String> lstWhatId = new List<String>();
    
        try{
            List<String> lstStr = strDPIdTerritoryId.split('-');
            strDPId = lstStr[1].trim();
            strTerritoryId = lstStr[2].trim();
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareSkippedEventWP::Dispatch Process | TerritoryId:-'+strDPId+' | '+strTerritoryId);
            for(String strFullEventId : techEventIds){
                String strEventId = strFullEventId.split('_')[1].trim();
                String strTechName = strFullEventId.split('_')[2].trim();
                String strWhatId = strEventId+'_'+strTechName;
                WSCH_AuditLogger.debug('strWhatId....'+strWhatId);
                lstWhatId.add(strWhatId);
            }
            lstEventOptimizers = WSCH_ECO_CommonUtils.getEventOptimizerByWhatIds(lstWhatId);
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareSkippedEventWP()::lstEventOptimizers : ' + lstEventOptimizers.size());         
    
            Map<String,WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP> requestMap = WSCH_Provider_ECO_DataMapper.createManageTechnicianEventRequest(lstEventOptimizers);
            WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP manageEventRequest;
            manageEventRequest = requestMap.get(strTerritoryId);
            requestJson=JSON.serialize(manageEventRequest);
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_ECO_Client_TechnicianServices::doPrepareSkippedEventWP:Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
            WSCH_AuditLogger.finish();
        }
        return requestJson;
    }
    
    public static string doPrepareSkippedDependencyWorkOrderWP(List<String> dependencyGroupIds, string strDPIdTerritoryId) {
        String strTerritoryId;
        String strDPId;
        String requestJson;
        WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareSkippedDependencyWorkOrderWP::dependencyGroupIds : ' + dependencyGroupIds);
        try {
            List<String> lstStr = strDPIdTerritoryId.split('-');
            strDPId = lstStr[1].trim();
            strTerritoryId = lstStr[2].trim();
            
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareSkippedDependencyWorkOrderWP::Dispatch Process | TerritoryId:-'+strDPId+' | '+strTerritoryId);
            //fetching all the related dependencyObjects for a the group Ids fetched above
            List<SVMXC__Service_Order_Dependency__c> dependencyGroupList = new List<SVMXC__Service_Order_Dependency__c>();

            //fetch all the dependency objects for all the groupIds received above
            if(dependencyGroupIds.size() > 0){
                for(Id depGroupId : dependencyGroupIds){
                    dependencyGroupList.addAll(WSCH_CommonUtils.fetchGroupDependency(depGroupId));
                }
            }
            //fetch all the WO Ids from the dependency objects
            Set<String> WO_Ids = new Set<String>();
            if(dependencyGroupList.size() > 0) {
                for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: dependencyGroupList){
                    WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Primary_Work_Order__c));
                    WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Secondary_Work_Order__c));
                }
            }
            //fetch all the WOs from the primary and secondary WO Ids fetched above
            List<String> lstOfWOIds = new List<String>(WO_Ids);
            List<SVMXC__Service_Order__c> lstWorkOrder = WSCH_CommonUtils.fetchWorkOrders(lstOfWOIds);
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices: doPrepareSkippedDependencyWorkOrderWP(): dependencyGroupList.size() - ' + dependencyGroupList.size());
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices: doPrepareSkippedDependencyWorkOrderWP(): lstWorkOrder.size() - ' + lstWorkOrder.size());
            
            SVMXC__Territory__c objTerritory = WSCH_ECO_CommonUtils.getTerritoryById(strTerritoryId);
            WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP request_x;
            if(dependencyGroupList.size() > 0 && dependencyGroupList.size() > 0) {
                request_x = WSCH_Provider_ECO_DataMapper.manageJobDependencyRequest(objTerritory,dependencyGroupList,lstWorkOrder);
            }

            //get the WOs which are already marked as OPT_ERROR and do the explicit update on them.
            List<SVMXC__Service_Order__c> lstErrorWOs = new List<SVMXC__Service_Order__c>();
            for(SVMXC__Service_Order__c eachWO: lstWorkOrder) {
                if(eachWO.SVMXC__OptiMax_Status__c.equalsIgnoreCase(WSCH_ECO_Constants.STATUS_OPT_ERROR)) {
                    lstErrorWOs.add(eachWO);
                }
            }
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareSkippedDependencyWorkOrderWP::error WOs size:' + lstErrorWOs.size());
            if(lstErrorWOs.size() > 0) {
                WSCH_OptimizedSchedulingService.triggerExecuted = true;
                WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                Database.upsert(lstErrorWOs);
            }
            requestJson=JSON.serialize(request_x);
        } catch(Exception ex) {
            WSCH_AuditLogger.error('WSCH_ECO_Client_TechnicianServices::doPrepareSkippedDependencyWorkOrderWP:Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
            WSCH_AuditLogger.finish();
        }
        return requestJson;
    }
    
    private static List<SVMXC__SVMX_Optimizer__c> createTechOptimizer(String territoryId, String dpId,List<SVMXC__Service_Group_Members__c> lstTech) {
        List<SVMXC__SVMX_Optimizer__c> lstOptimizer = new List<SVMXC__SVMX_Optimizer__c>();
        String strDateTime;
        strDateTime = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm');
        try {
            for(SVMXC__Service_Group_Members__c techObj : lstTech){
                SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
                optimizer.SVMXC__WhatType__c = 'TECHNICIAN';
                optimizer.SVMXC__WhatId__c = techObj.Id + '_' + techObj.Name;
                optimizer.SVMXC__Optimizer_Connection_ID__c = dpId + '_' + territoryId;
                optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_TECH';
                optimizer.SVMXC__Optimizer_Status__c = 'OPT_COMPLETED';
                optimizer.SVMXC__Optimizer_Error_Text__c = strDateTime+' : Technician added through initJob call';
                lstOptimizer.add(optimizer);
            }               
            //Database.upsert(lstOptimizer);
            
            if(lstOptimizer.size() > 0) {
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstOptimizer, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert lstOptimizer; 
                }else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
        } catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_Client_JobServices:createTechOptimizer() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return lstOptimizer;
    }
    
    public static string doPrepareResumeIds(WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP req) {
        String dispatchProcessGuid = req.dispatchProcessGuid;
        String territoryGuid = req.territoryGuid;
        String operation = req.operation;
        String jobInstanceGuid;
        WSCH_ECO_Client_Stubs.ExecuteJobRequest_WP executeJobRequest = new WSCH_ECO_Client_Stubs.ExecuteJobRequest_WP();
    
        try {
            List<String> workOrderIds = new List<String>();
            Set<String> setDependencyGrpIds = new Set<String>();
            List<String> lstOfDependencyGrpIds = new List<String>();
            List<SVMXC__Service_Order__c> lstWOs = fetchWorkOrdersForResume(dispatchProcessGuid, territoryGuid);
            
            //below code seggregates the normal WO Ids and the dependency WO Group Ids
            if(lstWOs != null && lstWOs.size() > 0) {
                for(SVMXC__Service_Order__c eachWO: lstWOs) {
                    if(eachWO.SVMXC__Scheduling_Change_Token__c.equalsIgnoreCase('CREATE_DEPENDENCY_WO') ||
                        eachWO.SVMXC__Scheduling_Change_Token__c.equalsIgnoreCase('CHANGE_DEPENDENCY_WO')) {
                        setDependencyGrpIds.add(eachWO.SVMXC__Dependency_Group__c);
                    } else {
                        workOrderIds.add(eachWO.Name);
                    }
                }
            }
            //Setting the dependency GroupIds in the wrapper
            if(setDependencyGrpIds.size() > 0) {
                lstOfDependencyGrpIds.addAll(setDependencyGrpIds);
                executeJobRequest.dependencyGrpIds = lstOfDependencyGrpIds;
            }
            
            //set the WOids to the wrapper
            executeJobRequest.workOrderIds = workOrderIds;
    
            List<String> lstOfEventIds = fetchEventIdsForResume(dispatchProcessGuid, territoryGuid);
            //set the Eventids to the wrapper
            executeJobRequest.eventIds = lstOfEventIds;
            
            //Fetch the technicians for the given territory ID and set the techIds to the wrapper
            List<SVMXC__Service_Group_Members__c> lstTechnicians = [Select Id, Name  from SVMXC__Service_Group_Members__c 
                    where SVMXC__Active__c = TRUE AND SVMXC__Service_Territory__c = :territoryGuid AND ((SVMXC__Enable_Scheduling__c = TRUE AND SVMXC__Salesforce_User__c = NULL) OR (SVMXC__Salesforce_User__c != NULL AND SVMXC__Salesforce_User__r.IsActive = true) )];
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPrepareResumeIds():lstTechnicians size ..'+lstTechnicians.size());
    
            List<String> resourceIds = new List<String>();
            if(lstTechnicians.size() > 0) {
                for(SVMXC__Service_Group_Members__c eachTech: lstTechnicians) {
                    resourceIds.add(eachTech.Id + '_' + eachTech.Name);
                }
            }
            //set the Techids to the wrapper
            executeJobRequest.resourceIds = resourceIds;
            executeJobRequest.jobInstanceGuid = Userinfo.getOrganizationId().substring(0,15) + '-' + dispatchProcessGuid + '-' + territoryGuid;  //OrgId-DPId-TerritoryId
            executeJobRequest.jobInstanceId = null;
        } catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_Client_JobServices:doPrepareResumeIds() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
        return JSON.serialize(executeJobRequest);
    }
     
    private static List<SVMXC__Service_Order__c> fetchWorkOrdersForResume(String dispatchProcessGuid, String territoryGuid) {
        List<SVMXC__Service_Order__c> lstofWOsWithinHorizon = new List<SVMXC__Service_Order__c>();
        try {
            List<SVMXC__ServiceMax_Processes__c> lstOfDPProcessObj = [SELECT Id, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Dispatch_Method__c, SVMXC__Frequency__c, SVMXC__Full_Run_Unit__c, SVMXC__Child_Object_Criteria__c from SVMXC__ServiceMax_Processes__c 
                                                                where RecordType.Name = 'Dispatch Process' AND Id =:dispatchProcessGuid];
            
            SVMXC__Territory__c territoryObj = [Select SVMXC__Territory_s_Business_Hours__r.Id from SVMXC__Territory__c where Id =:territoryGuid]; 
                
            BusinessHours bh = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
                                WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, 
                                SaturdayEndTime, SundayStartTime, SundayEndTime from BusinessHours where IsActive = TRUE AND 
                                Id =: territoryObj.SVMXC__Territory_s_Business_Hours__r.Id ];
    
            if(lstOfDPProcessObj != null && lstOfDPProcessObj.size() > 0) {
                List<DateTime> lstHorizonStartAndEndDateTime = WSCH_CommonUtils.getDPHorizonStartAndEndDates(lstOfDPProcessObj[0], bh);
                if(lstHorizonStartAndEndDateTime != null && lstHorizonStartAndEndDateTime.size() == 2) {
                    DateTime horizonStartDateTime = lstHorizonStartAndEndDateTime[0];
                    DateTime horizonEndDateTime = lstHorizonStartAndEndDateTime[1];
                    
                    //converting the horizon datetimes in GMT from territory timezone before comparing against the PST and PET whose values are in GMT.
                    DateTime horizonStartDateTimeInGMT = WSCH_DateUtils.doTZConversion(horizonStartDateTime, bh.timeZoneSidKey, 'GMT');
                    DateTime horizonEndDateTimeInGMT = WSCH_DateUtils.doTZConversion(horizonEndDateTime, bh.timeZoneSidKey, 'GMT');
                    
                    if(String.isEmpty(lstOfDPProcessObj[0].SVMXC__Child_Object_Criteria__c)) {
                        lstofWOsWithinHorizon = [Select Name, Id, SVMXC__Scheduling_Change_Token__c, SVMXC__Dependency_Group__c from SVMXC__Service_Order__c where (SVMXC__Dispatch_Process__c =: dispatchProcessGuid) AND SVMXC__Dispatch_Status__c = 'New' AND ((SVMXC__OptiMax_Status__c IN ('OPT_SKIPPED') AND ((SVMXC__Preferred_Start_Time__c >=: horizonStartDateTimeInGMT AND SVMXC__Preferred_Start_Time__c <=: horizonEndDateTimeInGMT) OR (SVMXC__Preferred_End_Time__c >= :horizonStartDateTimeInGMT AND SVMXC__Preferred_End_Time__c <= :horizonEndDateTimeInGMT))) OR SVMXC__OptiMax_Status__c IN ('OPT_UNASSIGNED'))];
                    } else {
                        lstofWOsWithinHorizon = database.query('Select Name, Id, SVMXC__Scheduling_Change_Token__c, SVMXC__Dependency_Group__c from SVMXC__Service_Order__c where (SVMXC__Dispatch_Process__c =: dispatchProcessGuid) AND ((SVMXC__Dispatch_Status__c = \'New\' AND ((SVMXC__OptiMax_Status__c IN (\'OPT_SKIPPED\') AND ((SVMXC__Preferred_Start_Time__c >=: horizonStartDateTimeInGMT AND SVMXC__Preferred_Start_Time__c <=: horizonEndDateTimeInGMT) OR (SVMXC__Preferred_End_Time__c >= :horizonStartDateTimeInGMT AND SVMXC__Preferred_End_Time__c <= :horizonEndDateTimeInGMT))) OR SVMXC__OptiMax_Status__c IN (\'OPT_UNASSIGNED\'))) OR (SVMXC__Dispatch_Status__c = \'Assigned\' AND SVMXC__OptiMax_Status__c = \'Processing Complete\' AND ((SVMXC__Preferred_Start_Time__c >=: horizonStartDateTimeInGMT AND SVMXC__Preferred_Start_Time__c <=: horizonEndDateTimeInGMT) OR (SVMXC__Preferred_End_Time__c >= :horizonStartDateTimeInGMT AND SVMXC__Preferred_End_Time__c <= :horizonEndDateTimeInGMT)) AND (' + lstOfDPProcessObj[0].SVMXC__Child_Object_Criteria__c + ')))');
                    }
                }
            }
        } catch (Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_Client_JobServices:fetchWorkOrdersForResume() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
        return lstofWOsWithinHorizon;
    }
    
    private static List<String> fetchEventIdsForResume(String dispatchProcessGuid, String territoryGuid) {
        List<String> lstOfEventsIds = new List<String>();
        try {
            List<SVMXC__ServiceMax_Processes__c> lstOfDPProcessObj = [SELECT Id, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Dispatch_Method__c, SVMXC__Frequency__c from SVMXC__ServiceMax_Processes__c 
                                                           where RecordType.Name = 'Dispatch Process' AND Id =:dispatchProcessGuid];
       
            SVMXC__Territory__c territoryObj = [Select SVMXC__Territory_s_Business_Hours__r.Id from SVMXC__Territory__c where Id =:territoryGuid]; 
        
            BusinessHours bh = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
                                WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, 
                                SaturdayEndTime, SundayStartTime, SundayEndTime from BusinessHours where IsActive = TRUE AND 
                                Id =: territoryObj.SVMXC__Territory_s_Business_Hours__r.Id ];
    
            if(lstOfDPProcessObj != null && lstOfDPProcessObj.size() > 0) {
                List<DateTime> lstHorizonStartAndEndDateTime = WSCH_CommonUtils.getDPHorizonStartAndEndDates(lstOfDPProcessObj[0], bh);
                if(lstHorizonStartAndEndDateTime != null && lstHorizonStartAndEndDateTime.size() == 2) {
                    DateTime horizonStartDateTime = lstHorizonStartAndEndDateTime[0];
                    DateTime horizonEndDateTime = lstHorizonStartAndEndDateTime[1];
                    
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::fetchEventIdsForResume:horizonStartDateTime - ' + horizonStartDateTime);
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::fetchEventIdsForResume:horizonEndDateTime - ' + horizonEndDateTime);
                    
                    DateTime horizonStartDateTimeGMT = WSCH_DateUtils.doTZConversion(horizonStartDateTime, bh.TimeZoneSidKey, 'GMT');
                    DateTime horizonEndDateTimeGMT = WSCH_DateUtils.doTZConversion(horizonEndDateTime, bh.TimeZoneSidKey, 'GMT');
                            
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::fetchEventIdsForResume:horizonStartDateTimeGMT - ' + horizonStartDateTimeGMT);
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::fetchEventIdsForResume:horizonEndDateTimeGMT - ' + horizonEndDateTimeGMT);
                    
                    List<Event> lstOfEvents = new List<Event>();
                    List<SVMXC__SVMX_Event__c> lstOfSmaxEvents = new List<SVMXC__SVMX_Event__c>();
                    List<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = new List<SVMXC__SVMX_Optimizer__c>();
                    set<String> setAvailTechAsSFUserList = new set<String>();
                    set<String> setAvailTechAsSVMXUserList = new set<String>();
                    Map<Id,SVMXC__Service_Group_Members__c> mapOwnerIDTechId = new Map<Id,SVMXC__Service_Group_Members__c>();
                    
                    Map<Id, SVMXC__Service_Group_Members__c> mapOfAllTechnicians = new Map<Id, SVMXC__Service_Group_Members__c>([Select Id, Name, SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive, SVMXC__Active__c, SVMXC__Service_Territory__c, SVMXC__Enable_Scheduling__c from SVMXC__Service_Group_Members__c 
                        where SVMXC__Active__c = TRUE AND SVMXC__Service_Territory__c = :territoryGuid AND ((SVMXC__Enable_Scheduling__c = TRUE AND SVMXC__Salesforce_User__c = NULL) OR (SVMXC__Salesforce_User__c != NULL AND SVMXC__Salesforce_User__r.IsActive = true) )]);  
                    
                    for(SVMXC__Service_Group_Members__c tech : mapOfAllTechnicians.values()) {
                        if(tech.SVMXC__Salesforce_User__c != NULL) {
                            setAvailTechAsSFUserList.add(tech.SVMXC__Salesforce_User__c);
                            mapOwnerIDTechId.put(tech.SVMXC__Salesforce_User__c, tech);
                        }
                        else {
                            setAvailTechAsSVMXUserList.add(tech.Id);
                        }
                    }
                    String strOptConnIdWithNoTechId = dispatchProcessGuid+'_'+territoryGuid;
                    
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::fetchEventIdsForResume: mapOfAllTechnicians.size() :' + mapOfAllTechnicians.size());                
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::fetchEventIdsForResume: strOptConnIdWithNoTechId :' + strOptConnIdWithNoTechId);
                    
                    //fetch all the OptimizerTransRecords for all the SFEvents and SmaxEvents whose status is OPT_COMPLETED, OPT_ERROR, OPT_FAIL
                    lstSVMXOptimizer = [SELECT ID , SVMXC__WhatId__c, SVMXC__WhatType__c, SVMXC__Optimizer_External_Id__c, SVMXC__Optimizer_Status__c, SVMXC__Optimizer_Error_Text__c, SVMXC__Optimizer_Change_Token__c, 
                                            SVMXC__Optimizer_Retry_count__c,SVMXC__Optimizer_Connection_ID__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatType__c = 'NON_WO_EVENT' AND SVMXC__Optimizer_Status__c IN ('OPT_COMPLETED','OPT_ERROR','OPT_FAIL') AND SVMXC__Optimizer_Connection_ID__c LIKE: '%' + strOptConnIdWithNoTechId + '%'];
                                            
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::fetchEventIdsForResume:list of opt_trans records within Horizon to filter:lstSVMXOptimizer.size() - ' + lstSVMXOptimizer.size());
                    
                    String sfEventKeyPrefix = Schema.SObjectType.Event.getKeyPrefix();
                    String smaxEventKeyPrefix = Schema.SObjectType.SVMXC__SVMX_Event__c.getKeyPrefix();
                    List<String> lstOfsfEventIds = new List<String>();
                    List<String> lstOfSmaxEventIds = new List<String>();
                    
                    //seggregate the SFEvents and SmaxEvents Ids from the optimizers.
                    for(SVMXC__SVMX_Optimizer__c eachOptTrans : lstSVMXOptimizer) {
                        String[] strSplitWhatID = (String.valueOf(eachOptTrans.SVMXC__WhatId__c)).split('_',-1); //fetch the object Prefix from a0v2I00000aiyGGQAY_Aaron
                        String strPrefix = (strSplitWhatID[0].trim()).substring(0,3);
                        if(sfEventKeyPrefix.equals(strPrefix)) {
                            lstOfsfEventIds.add(strSplitWhatID[0].trim());
                        } else if(smaxEventKeyPrefix.equals(strPrefix)) {
                            lstOfSmaxEventIds.add(strSplitWhatID[0].trim());
                        }
                    }
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::fetchEventIdsForResume:setAvailTechAsSVMXUserList.size():'+ setAvailTechAsSVMXUserList.size());
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::fetchEventIdsForResume:lstOfSmaxEventIds.size():'+ lstOfSmaxEventIds.size());
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::fetchEventIdsForResume:lstOfsfEventIds.size():'+ lstOfsfEventIds.size());
                    
                    //getting the date component from the horizonStartDateTime, used below to get the events starting from this date
                    Date horizonStartDateGMT = horizonStartDateTimeGMT.dateGmt();
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::fetchEventIdsForResume:horizonStartDateGMT:'+ horizonStartDateGMT);
                    DateTime horizonStartDateZeroHr = DateTime.newInstanceGmt(horizonStartDateGMT, Time.newInstance(0,0,0,0));
                    //query all the SFEvents excluding the above Ids within the Horizon dates
                    /**  Added another condition to check if eventEndDateTime > currentDateTime to ensure past event is not sent   **/
                    // Fetch all SF events
                    lstOfEvents = [Select Id,WhatId,StartDateTime,EndDateTime,SVMXC__Driving_Time__c,SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, Location,OwnerId from EVENT WHERE Id NOT IN:lstOfsfEventIds AND WhatId = null AND IsAllDayEvent= false AND OwnerId in:setAvailTechAsSFUserList AND ((StartDateTime <=: horizonEndDateTimeGMT AND StartDateTime >=: horizonStartDateZeroHr AND EndDateTime >=: system.now()) OR (EndDateTime >= :horizonStartDateTimeGMT AND EndDateTime <= :horizonEndDateTimeGMT AND EndDateTime >=: system.now()))];
                    
                    // Fetch all SVMX events
                    lstOfSmaxEvents = [Select Id,SVMXC__WhatId__c,SVMXC__StartDateTime__c,SVMXC__EndDateTime__c,SVMXC__Technician__c,SVMXC__Driving_Time__c,SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__Location__c from SVMXC__SVMX_Event__c WHERE Id NOT IN:lstOfSmaxEventIds AND SVMXC__WhatId__c = null AND SVMXC__IsAllDayEvent__c = false AND SVMXC__Technician__c in:setAvailTechAsSVMXUserList AND ((SVMXC__StartDateTime__c <=: horizonEndDateTimeGMT AND SVMXC__StartDateTime__c >=: horizonStartDateZeroHr AND SVMXC__EndDateTime__c >=: system.now()) OR (SVMXC__EndDateTime__c >= :horizonStartDateTimeGMT AND SVMXC__EndDateTime__c <= :horizonEndDateTimeGMT AND SVMXC__EndDateTime__c >=: system.now()))];
                    
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::fetchEventIdsForResume:SmaxEvents within Horizon:lstOfSmaxEvents.size() - ' + lstOfSmaxEvents.size());
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::fetchEventIdsForResume:SFEvents within Horizon:lstOfEvents.size() - ' + lstOfEvents.size());
                    List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();             
                    SVMXC__Service_Group_Members__c technician;
                    if(null != lstOfEvents){
                        for(Event objEvent : lstOfEvents){
                            DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(objEvent.StartDateTime, 'GMT', bh.TimeZoneSidKey);
                            DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(objEvent.EndDateTime, 'GMT', bh.TimeZoneSidKey);        
                            integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                            if(intDays > 0){
                                continue;
                            }
                            technician = mapOwnerIDTechId.get(objEvent.OwnerId);
                            if(null != technician){
                                lstOfEventsIds.add('Event_' + objEvent.id+'_'+technician.name);
                                SVMXC__SVMX_Optimizer__c optimizer = createEventOptimizer(objEvent.id,WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE,WSCH_ECO_Constants.OPT_NON_WORK_ORDER_EVENT_TYPE,dispatchProcessGuid,territoryGuid,technician);
                                optimizerObjects.add(optimizer);
                            }
                        }
                    }
                
                    if (null != lstOfSmaxEvents){
                        for(SVMXC__SVMX_Event__c objEvent : lstOfSmaxEvents){
                            technician = mapOfAllTechnicians.get(objEvent.SVMXC__Technician__c);
                            DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(objEvent.SVMXC__StartDateTime__c, 'GMT', bh.TimeZoneSidKey);
                            DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(objEvent.SVMXC__EndDateTime__c, 'GMT', bh.TimeZoneSidKey);        
                            integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                            if(intDays > 0){
                                continue;
                            }          
                            if(null != technician){
                                lstOfEventsIds.add('Event_' + objEvent.id+'_'+technician.name); 
                                SVMXC__SVMX_Optimizer__c optimizer = createEventOptimizer(objEvent.id,WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE,WSCH_ECO_Constants.OPT_NON_WORK_ORDER_EVENT_TYPE,dispatchProcessGuid,territoryGuid,technician);
                                optimizerObjects.add(optimizer);
                            }
                        }
                    }
                    if(optimizerObjects.size() > 0) {
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( optimizerObjects, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            upsert optimizerObjects; 
                        }else {
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }
                    } 
                }
            }
        } catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_Client_JobServices:fetchEventIdsForResume() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
        return lstOfEventsIds;
    }
    
    public static SVMXC__SVMX_Optimizer__c createEventOptimizer(String eventid, String changeToken,String eventType,String dProcess,String teritory,SVMXC__Service_Group_Members__c technician) {
        SVMXC__SVMX_Optimizer__c obj = new SVMXC__SVMX_Optimizer__c();
        obj.SVMXC__WhatType__c = eventType;
        obj.SVMXC__WhatId__c = eventid+'_'+technician.name;
        obj.SVMXC__Optimizer_Change_Token__c = changeToken;
        obj.SVMXC__Optimizer_Connection_ID__c = dProcess+'_'+teritory+'_'+technician.id;
        obj.SVMXC__Optimizer_Status__c = 'OPT_COMPLETED';
        return obj;
    }

//     @HttpPost
//     global static String doPost() {
//         String returnMsg = NO_OP_ERROR_MESSAGE;
//         RestRequest request = RestContext.request;
//         Blob data = request.requestBody;
//         String changeReq = data.toString();
//         try {
//          WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::doPost::Json Request: ' + changeReq);
//          WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP req = (WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP)JSON.deserialize(changeReq, WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP.class);
//          if('HORIZON_UPDATE'.equals(req.operation)) {
//              returnMsg = updateTechHorizon(req);
//          } else if('WO_UPDATE'.equals(req.operation)){
//              returnMsg = WSCH_ECO_Client_TechnicianServices.scheduleWOsFallingInHorizon(req);
//          } else if('NON_WO_EVENT_UPDATE'.equals(req.operation)) {
//              returnMsg = WSCH_ECO_Client_TechnicianServices.scheduleEventsFallingInHorizon(req);
//          }
//         } catch(Exception ex){
//             WSCH_AuditLogger.error('WSCH_ECO_Client_TechnicianServices::doPost():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
//         } finally{
//             WSCH_AuditLogger.finish();
//         }
//         return returnMsg;
//     }
    
    private static String updateTechHorizon(WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP req) {
        String dispatchProcessGuid = req.dispatchProcessGuid;
        String territoryGuid = req.territoryGuid;
        String connectionId = dispatchProcessGuid + '_' + territoryGuid;
        
        //Fetch the Optimizer Object from the technician id 
        //list<SVMXC__SVMX_Optimizer__c> technicianOptimizers = [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__Optimizer_External_ID__c,SVMXC__WhatId__c,SVMXC__Optimizer_Connection_ID__c,SVMXC__WhatType__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatId__c in : connectionIds];
        list<SVMXC__SVMX_Optimizer__c> technicianOptimizers = [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__WhatId__c,SVMXC__Optimizer_Connection_ID__c,SVMXC__WhatType__c,SVMXC__Optimizer_Status__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__Optimizer_Connection_ID__c =: connectionId AND SVMXC__WhatType__c ='TECHNICIAN' AND SVMXC__Optimizer_Change_Token__c != 'CHANGE_REMOVE_TECH'];
        WSCH_AuditLogger.debug('technicianOptimizers size..' + technicianOptimizers.size());
        for(SVMXC__SVMX_Optimizer__c optimizerObj : technicianOptimizers) {
            if('CHANGE_CREATE_TECH'.equalsIgnoreCase(optimizerObj.SVMXC__Optimizer_Change_Token__c) && 'OPT_ERROR'.equalsIgnoreCase(optimizerObj.SVMXC__Optimizer_Status__c)) {
                optimizerObj.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_TECH';
            } else {
                optimizerObj.SVMXC__Optimizer_Change_Token__c = 'CHANGE_UPDATE_TECH';
            }            
        }
        //invoking manage technicians callout
        WSCH_OptimizedSchedulingService.manageTechnicians(technicianOptimizers);
        //WSCH_ECO_Client_TechnicianServices.scheduleWOsFallingInHorizon(req);
        //WSCH_ECO_Client_TechnicianServices.scheduleEventsFallingInHorizon(req);
        return RETURN_MESSAGE_FOR_TECH_UPDATE;
    }
    
    //Below method schedules all the Unscheduled WOs that were skipped earlier due to not falling within the DP horizon as they were at a later date.
    public static String scheduleWOsFallingInHorizon(WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP req) {
        String dispatchProcessGuid = req.dispatchProcessGuid;
        String territoryGuid = req.territoryGuid;
        
        List<SVMXC__ServiceMax_Processes__c> lstOfDPProcessObj = [SELECT Id, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Dispatch_Method__c, SVMXC__Frequency__c, SVMXC__Full_Run_Unit__c, SVMXC__Child_Object_Criteria__c from SVMXC__ServiceMax_Processes__c 
                                                                where RecordType.Name = 'Dispatch Process' AND Id =:dispatchProcessGuid];
            
        SVMXC__Territory__c territoryObj = [Select SVMXC__Territory_s_Business_Hours__r.Id from SVMXC__Territory__c where Id =:territoryGuid]; 
            
        BusinessHours bh = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
                            WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, 
                            SaturdayEndTime, SundayStartTime, SundayEndTime from BusinessHours where IsActive = TRUE AND 
                            Id =: territoryObj.SVMXC__Territory_s_Business_Hours__r.Id ];
        
        if(lstOfDPProcessObj != null && lstOfDPProcessObj.size() > 0) {
            List<DateTime> lstHorizonStartAndEndDateTime = WSCH_CommonUtils.getDPHorizonStartAndEndDates(lstOfDPProcessObj[0], bh);
            if(lstHorizonStartAndEndDateTime != null && lstHorizonStartAndEndDateTime.size() == 2) {
                DateTime horizonStartDateTime = lstHorizonStartAndEndDateTime[0];
                DateTime horizonEndDateTime = lstHorizonStartAndEndDateTime[1];
                
                //converting the horizon datetimes in GMT from territory timezone before comparing against the PST and PET whose values are in GMT.
                DateTime horizonStartDateTimeInGMT = WSCH_DateUtils.doTZConversion(horizonStartDateTime, bh.timeZoneSidKey, 'GMT');
                DateTime horizonEndDateTimeInGMT = WSCH_DateUtils.doTZConversion(horizonEndDateTime, bh.timeZoneSidKey, 'GMT');
                
                //Fetch all the WOs which are within the above horizon dates
                List<SVMXC__Service_Order__c> lstofWOsWithinHorizon = new List<SVMXC__Service_Order__c>();
                String strfld = WSCH_CommonUtils.getWorkorderFields();
        //         /*if(String.isNotBlank(strfld)){
        //             String strRelationFields = ', SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone, SVMXC__Site__r.Name, SVMXC__Preferred_Technician__r.SVMXC__Optimizer_External_ID__c, SVMXC__Dispatch_Process__r.SVMXC__Target_URL__c, SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id, SVMXC__Group_Member__r.Id,SVMXC__Group_Member__r.Name,SVMXC__Product__r.Name';
        //             lstofWOsWithinHorizon =  database.query('Select ' + strfld + strRelationFields + ' From SVMXC__Service_Order__c ' + '  where (SVMXC__Dispatch_Process__c =: dispatchProcessGuid) AND SVMXC__Dispatch_Status__c = \'New\' AND SVMXC__OptiMax_Status__c IN (\'OPT_SKIPPED\',\'OPT_UNASSIGNED\') AND ((SVMXC__Preferred_Start_Time__c >=: horizonStartDateTimeInGMT AND SVMXC__Preferred_Start_Time__c <=: horizonEndDateTimeInGMT) OR (SVMXC__Preferred_End_Time__c >= :horizonStartDateTimeInGMT AND SVMXC__Preferred_End_Time__c <= :horizonEndDateTimeInGMT))');
        //         }else {
        //             lstofWOsWithinHorizon = [Select Name, Id, SVMXC__Work_Order_Scheduling_Status__c, SVMXC__Service_Group__c, SVMXC__Group_Member__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c, SVMXC__Zip__c, SVMXC__Service_Duration__c, SVMXC__Skill_Set__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Purpose_of_Visit__c, SVMXC__Preferred_Technician__c,SVMXC__Primary_Territory__c,SVMXC__Dispatch_Priority__c,SVMXC__Preferred_Business_Hours__c,SVMXC__Scheduling_Change_Token__c,SVMXC__Acknowledged_By_Technician_Date_Time__c,SVMXC__Started_Driving_To_Location_Date_Time__c,SVMXC__Actual_Onsite_Response__c,SVMXC__Finished_Onsite_Date_Time__c,SVMXC__Completed_Date_Time__c,SVMXC__Scheduling_Retry_Count__c,SVMXC__Dispatch_Process__c,SVMXC__Driving_Time__c,SVMXC__Locked_By_DC__c,SVMXC__OptiMax_Error_Occurred__c,SVMXC__Priority__c,SVMXC__Contact__c,SVMXC__Contact__r.Name,SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone,SVMXC__FirstScheduledDateTime__c,SVMXC__OptiMax_Error_Text__c,SVMXC__OptiMax_Status__c,SVMXC__Service_Contract__c,SVMXC__Product__c,SVMXC__Partner_Account__c,SVMXC__Appointment_Promised_Time_Slot__c,SVMXC__Service_Zone_ID__c, SVMXC__Company__c, SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Site__c, SVMXC__SM_Optimizer_Message_Creation_Date_Time__c,SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id, SVMXC__Dispatch_Status__c, SVMXC__SM_Schedule_Violation_Penalty__c from SVMXC__Service_Order__c where (SVMXC__Dispatch_Process__c =: dispatchProcessGuid) AND SVMXC__Dispatch_Status__c = 'New' AND SVMXC__OptiMax_Status__c IN ('OPT_SKIPPED','OPT_UNASSIGNED') AND ((SVMXC__Preferred_Start_Time__c >=: horizonStartDateTimeInGMT AND SVMXC__Preferred_Start_Time__c <=: horizonEndDateTimeInGMT) OR (SVMXC__Preferred_End_Time__c >= :horizonStartDateTimeInGMT AND SVMXC__Preferred_End_Time__c <= :horizonEndDateTimeInGMT))];
        //         }
                
                //commented the above logic. Introduced the below one to handle both OPT_UNASSIGNED and OPT_SKIPPED WOs
                if(String.isNotBlank(strfld)){
                    String strRelationFields = ', SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone, SVMXC__Site__r.Name, SVMXC__Preferred_Technician__r.SVMXC__Optimizer_External_ID__c, SVMXC__Dispatch_Process__r.SVMXC__Target_URL__c, SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id, SVMXC__Group_Member__r.Id,SVMXC__Group_Member__r.Name,SVMXC__Product__r.Name';
                    if(String.isEmpty(lstOfDPProcessObj[0].SVMXC__Child_Object_Criteria__c)) {
                        lstofWOsWithinHorizon =  database.query('Select ' + strfld + strRelationFields + ' From SVMXC__Service_Order__c ' + '  where (SVMXC__Dispatch_Process__c =: dispatchProcessGuid) AND SVMXC__Dispatch_Status__c = \'New\' AND ((SVMXC__OptiMax_Status__c IN (\'OPT_SKIPPED\') AND ((SVMXC__Preferred_Start_Time__c >=: horizonStartDateTimeInGMT AND SVMXC__Preferred_Start_Time__c <=: horizonEndDateTimeInGMT) OR (SVMXC__Preferred_End_Time__c >= :horizonStartDateTimeInGMT AND SVMXC__Preferred_End_Time__c <= :horizonEndDateTimeInGMT))) OR SVMXC__OptiMax_Status__c IN (\'OPT_UNASSIGNED\'))');
                    } else {
                        lstofWOsWithinHorizon =  database.query('Select ' + strfld + strRelationFields + ' From SVMXC__Service_Order__c ' + '  where (SVMXC__Dispatch_Process__c =: dispatchProcessGuid) AND ((SVMXC__Dispatch_Status__c = \'New\' AND ((SVMXC__OptiMax_Status__c IN (\'OPT_SKIPPED\') AND ((SVMXC__Preferred_Start_Time__c >=: horizonStartDateTimeInGMT AND SVMXC__Preferred_Start_Time__c <=: horizonEndDateTimeInGMT) OR (SVMXC__Preferred_End_Time__c >= :horizonStartDateTimeInGMT AND SVMXC__Preferred_End_Time__c <= :horizonEndDateTimeInGMT))) OR SVMXC__OptiMax_Status__c IN (\'OPT_UNASSIGNED\'))) OR (SVMXC__Dispatch_Status__c = \'Assigned\' AND SVMXC__OptiMax_Status__c = \'Processing Complete\' AND ((SVMXC__Preferred_Start_Time__c >=: horizonStartDateTimeInGMT AND SVMXC__Preferred_Start_Time__c <=: horizonEndDateTimeInGMT) OR (SVMXC__Preferred_End_Time__c >= :horizonStartDateTimeInGMT AND SVMXC__Preferred_End_Time__c <= :horizonEndDateTimeInGMT)) AND (' + lstOfDPProcessObj[0].SVMXC__Child_Object_Criteria__c + ')))');
                    }
                    
                }else {
                    //if LTP criteria is NOT defined for this DP use the below query
                    if(String.isEmpty(lstOfDPProcessObj[0].SVMXC__Child_Object_Criteria__c)) {
                        lstofWOsWithinHorizon = [Select Name, Id, SVMXC__Work_Order_Scheduling_Status__c, SVMXC__Service_Group__c, SVMXC__Group_Member__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c, SVMXC__Zip__c, SVMXC__Service_Duration__c, SVMXC__Skill_Set__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Purpose_of_Visit__c, SVMXC__Preferred_Technician__c,SVMXC__Primary_Territory__c,SVMXC__Dispatch_Priority__c,SVMXC__Preferred_Business_Hours__c,SVMXC__Scheduling_Change_Token__c,SVMXC__Acknowledged_By_Technician_Date_Time__c,SVMXC__Started_Driving_To_Location_Date_Time__c,SVMXC__Actual_Onsite_Response__c,SVMXC__Finished_Onsite_Date_Time__c,SVMXC__Completed_Date_Time__c,SVMXC__Scheduling_Retry_Count__c,SVMXC__Dispatch_Process__c,SVMXC__Driving_Time__c,SVMXC__Locked_By_DC__c,SVMXC__OptiMax_Error_Occurred__c,SVMXC__Priority__c,SVMXC__Contact__c,SVMXC__Contact__r.Name,SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone,SVMXC__FirstScheduledDateTime__c,SVMXC__OptiMax_Error_Text__c,SVMXC__OptiMax_Status__c,SVMXC__Service_Contract__c,SVMXC__Product__c,SVMXC__Partner_Account__c,SVMXC__Appointment_Promised_Time_Slot__c,SVMXC__Service_Zone_ID__c, SVMXC__Company__c, SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Site__c, SVMXC__SM_Optimizer_Message_Creation_Date_Time__c,SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id, SVMXC__Dispatch_Status__c, SVMXC__SM_Schedule_Violation_Penalty__c from SVMXC__Service_Order__c where (SVMXC__Dispatch_Process__c =: dispatchProcessGuid) AND SVMXC__Dispatch_Status__c = 'New' AND ((SVMXC__OptiMax_Status__c IN ('OPT_SKIPPED') AND ((SVMXC__Preferred_Start_Time__c >=: horizonStartDateTimeInGMT AND SVMXC__Preferred_Start_Time__c <=: horizonEndDateTimeInGMT) OR (SVMXC__Preferred_End_Time__c >= :horizonStartDateTimeInGMT AND SVMXC__Preferred_End_Time__c <= :horizonEndDateTimeInGMT))) OR SVMXC__OptiMax_Status__c IN ('OPT_UNASSIGNED'))];
                    } else {
                        lstofWOsWithinHorizon = database.query('Select Name, Id, SVMXC__Work_Order_Scheduling_Status__c, SVMXC__Service_Group__c, SVMXC__Group_Member__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c, SVMXC__Zip__c, SVMXC__Service_Duration__c, SVMXC__Skill_Set__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Purpose_of_Visit__c, SVMXC__Preferred_Technician__c,SVMXC__Primary_Territory__c,SVMXC__Dispatch_Priority__c,SVMXC__Preferred_Business_Hours__c,SVMXC__Scheduling_Change_Token__c,SVMXC__Acknowledged_By_Technician_Date_Time__c,SVMXC__Started_Driving_To_Location_Date_Time__c,SVMXC__Actual_Onsite_Response__c,SVMXC__Finished_Onsite_Date_Time__c,SVMXC__Completed_Date_Time__c,SVMXC__Scheduling_Retry_Count__c,SVMXC__Dispatch_Process__c,SVMXC__Driving_Time__c,SVMXC__Locked_By_DC__c,SVMXC__OptiMax_Error_Occurred__c,SVMXC__Priority__c,SVMXC__Contact__c,SVMXC__Contact__r.Name,SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone,SVMXC__FirstScheduledDateTime__c,SVMXC__OptiMax_Error_Text__c,SVMXC__OptiMax_Status__c,SVMXC__Service_Contract__c,SVMXC__Product__c,SVMXC__Partner_Account__c,SVMXC__Appointment_Promised_Time_Slot__c,SVMXC__Service_Zone_ID__c, SVMXC__Company__c, SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Site__c, SVMXC__SM_Optimizer_Message_Creation_Date_Time__c,SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id, SVMXC__Dispatch_Status__c, SVMXC__SM_Schedule_Violation_Penalty__c from SVMXC__Service_Order__c where (SVMXC__Dispatch_Process__c =: dispatchProcessGuid) AND ((SVMXC__Dispatch_Status__c = \'New\' AND ((SVMXC__OptiMax_Status__c IN (\'OPT_SKIPPED\') AND ((SVMXC__Preferred_Start_Time__c >=: horizonStartDateTimeInGMT AND SVMXC__Preferred_Start_Time__c <=: horizonEndDateTimeInGMT) OR (SVMXC__Preferred_End_Time__c >= :horizonStartDateTimeInGMT AND SVMXC__Preferred_End_Time__c <= :horizonEndDateTimeInGMT))) OR SVMXC__OptiMax_Status__c IN (\'OPT_UNASSIGNED\'))) OR (SVMXC__Dispatch_Status__c = \'Assigned\' AND SVMXC__OptiMax_Status__c = \'Processing Complete\' AND ((SVMXC__Preferred_Start_Time__c >=: horizonStartDateTimeInGMT AND SVMXC__Preferred_Start_Time__c <=: horizonEndDateTimeInGMT) OR (SVMXC__Preferred_End_Time__c >= :horizonStartDateTimeInGMT AND SVMXC__Preferred_End_Time__c <= :horizonEndDateTimeInGMT)) AND (' + lstOfDPProcessObj[0].SVMXC__Child_Object_Criteria__c + ')))');
                    }
                }
                
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleWOsFallingInHorizon:lstofWOsWithinHorizon.size() - ' + lstofWOsWithinHorizon.size());
                
                /*if(lstofWOsWithinHorizon.size() > 0) {
                    List<String> lstWOIds = new List<String>();
                    for(SVMXC__Service_Order__c eachWO : lstofWOsWithinHorizon) {
                        lstWOIds.add(eachWO.Id);
                    }
                    WSCH_ECO_Client_TechnicianServices.scheduleWOsInHorizon(lstWOIds);
                }*/
                
                List<String> listOfDependencyWOIds = new List<String>();
                List<String> lstWOIds = new List<String>();
                if(lstofWOsWithinHorizon.size() > 0) {
                    for(SVMXC__Service_Order__c eachWO : lstofWOsWithinHorizon) {
                        if(eachWO.SVMXC__Scheduling_Change_Token__c == 'CREATE_DEPENDENCY_WO' || eachWO.SVMXC__Scheduling_Change_Token__c == 'CHANGE_DEPENDENCY_WO'){
                            listOfDependencyWOIds.add(eachWO.Id);
                        }else{  
                            lstWOIds.add(eachWO.Id);
                        }
                    }
                }
                //callout for regular WOs
                if(lstWOIds.size() > 0) {
                    WSCH_ECO_Client_TechnicianServices.scheduleWOsInHorizon(lstWOIds);
                }
                //callout for Dependency WOs
                if(listOfDependencyWOIds.size() > 0) {
                    WSCH_ECO_Client_TechnicianServices.scheduleDependencyWOsInHorizon(listOfDependencyWOIds);
                }
            }
        }
        return RETURN_MESSAGE_FOR_WO_UPDATE;
    }
    
    @future(callout=true)
    public static void scheduleDependencyWOsInHorizon(List<String> listOfDependencyWOIds) {
        try {
            List<SVMXC__Service_Order__c> manageDependencyWorkOrderList = WSCH_ECO_CommonUtils.fetchWorkOrders(listOfDependencyWOIds);
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleDependencyWOsInHorizon:: WOs qualified for dependency Group:'+manageDependencyWorkOrderList);
            if(manageDependencyWorkOrderList != null && manageDependencyWorkOrderList.size() > 0) {
                Set<Id> dependencyManagementId = new Set<Id>();
                List<SVMXC__Service_Order_Dependency__c> dependencyGroupList = new List<SVMXC__Service_Order_Dependency__c>();
                for(SVMXC__Service_Order__c dependencyWO: manageDependencyWorkOrderList) {
                    dependencyManagementId.add(dependencyWO.SVMXC__Dependency_Group__c);
                }
                
                //fetch all the dependency objects for all the groupIds received above
                Map<Id, SVMXC__Service_Order__c> mapOfWOIdWorkOrder = new Map<Id, SVMXC__Service_Order__c>();
                List<SVMXC__Service_Order_Dependency__c> lstOfFilteredDependencyObj = new List<SVMXC__Service_Order_Dependency__c>();
                List<SVMXC__Service_Order__c> lstOfFilteredDependencyWOs = new List<SVMXC__Service_Order__c>();
                
                if(dependencyManagementId.size() > 0) {
                    for(Id depGroupId : dependencyManagementId){
                        dependencyGroupList.addAll(WSCH_CommonUtils.fetchGroupDependency(depGroupId));
                    }
                }
                //fetch all the WO Ids from the dependency objects
                Set<String> WO_Ids = new Set<String>();
                if(dependencyGroupList.size() > 0) {
                    for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: dependencyGroupList){
                        WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Primary_Work_Order__c));
                        WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Secondary_Work_Order__c));
                    }
                }
                //fetch all the WOs from the primary and secondary WO Ids fetched above
                List<String> lstOfWOIds = new List<String>(WO_Ids);
                List<SVMXC__Service_Order__c> woList = WSCH_CommonUtils.fetchWorkOrders(lstOfWOIds);
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices: scheduleDependencyWOsInHorizon(): dependencyGroupList.size() - ' + dependencyGroupList.size());
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices: scheduleDependencyWOsInHorizon(): woList.size() - ' + woList.size());
                //create a map of WOid and WO which is used below to create a filtered list of DependencyObj and DependencyWOs
                for(SVMXC__Service_Order__c eachWO: woList) {
                    mapOfWOIdWorkOrder.put(eachWO.Id, eachWO);
                }

                Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap = WSCH_CommonUtils.getEcoDP();
                //Create a filtered list of dependencyObj and dependencyWOs if they have RTO DP only.
                if(dependencyGroupList.size() > 0) {
                    for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: dependencyGroupList){
                        SVMXC__Service_Order__c primaryWO = mapOfWOIdWorkOrder.get(groupDependencyRecords.SVMXC__Primary_Work_Order__c);
                        SVMXC__Service_Order__c secondaryWO = mapOfWOIdWorkOrder.get(groupDependencyRecords.SVMXC__Secondary_Work_Order__c);
                        //if both primary and secondary WOs has a valid RTO DP only then add this DependencyObject to the filtered list
                        if(svmxProcessMap.ContainsKey(primaryWO.SVMXC__Dispatch_Process__c) &&
                                svmxProcessMap.ContainsKey(secondaryWO.SVMXC__Dispatch_Process__c)) {
                            lstOfFilteredDependencyObj.add(groupDependencyRecords);
                            //also add the primary and secondary WOs to the new filtered listOfDepWOs
                            lstOfFilteredDependencyWOs.add(primaryWO);
                            lstOfFilteredDependencyWOs.add(secondaryWO);
                        }
                    }
                }
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices: scheduleDependencyWOsInHorizon(): lstOfFilteredDependencyObj.size() - ' + lstOfFilteredDependencyObj.size());
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices: scheduleDependencyWOsInHorizon(): lstOfFilteredDependencyWOs.size() - ' + lstOfFilteredDependencyWOs.size());
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices: scheduleDependencyWOsInHorizon(): Before making manageDependencyBooking() call');
                
                if(lstOfFilteredDependencyObj.size() > 0 && lstOfFilteredDependencyWOs.size() > 0) {
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                    WSCH_OptimizedSchedulingService.manageDependencyBooking(lstOfFilteredDependencyObj, lstOfFilteredDependencyWOs);
                }
            }
        } catch(Exception ex) {
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleDependencyWOsInHorizon: Exception caught: ' + ex.getMessage());
            WSCH_AuditLogger.finish();
        }
    }
    
    @future(callout=true)
    public static void scheduleWOsInHorizon(List<String> lstWOIds) {
        try{
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
            List<SVMXC__Service_Order__c> lstOfWOs = WSCH_ECO_CommonUtils.fetchWorkOrders(lstWOIds);
            WSCH_OptimizedSchedulingService.manageWorkOrders(lstOfWOs);

            //commented the above code to implement the apex batching as below
            /*WSCH_Provider_ECO_WorkOrderBatchApex woBatchApex = new WSCH_Provider_ECO_WorkOrderBatchApex(lstWOIds);
            Id batchProcessId;
            Integer intBatchSize = Integer.valueOf(WSCH_CommonUtils.getSettingValue('OMAX003', 'SET029'));
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleWOsInHorizon:Batch size : ' + intBatchSize);
            
            if(intBatchSize > 0) {
                batchProcessId = Database.executeBatch(woBatchApex, intBatchSize);
            } else {
                batchProcessId = Database.executeBatch(woBatchApex, 50);
            }*/
            //batchProcessId = Database.executeBatch(woBatchApex, 2);
            //WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleWOsInHorizon:Batch started to process workorders. Batch Id is : ' + batchProcessId);
        } catch(Exception ex) {
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleWOsInHorizon: Exception caught: ' + ex.getMessage());
        }
    }
    
    public static String scheduleEventsFallingInHorizon(WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP req) {
        
        String dispatchProcessGuid = req.dispatchProcessGuid;
        String territoryGuid = req.territoryGuid;
        
        List<SVMXC__ServiceMax_Processes__c> lstOfDPProcessObj = [SELECT Id, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Dispatch_Method__c, SVMXC__Frequency__c from SVMXC__ServiceMax_Processes__c 
                                                                where RecordType.Name = 'Dispatch Process' AND Id =:dispatchProcessGuid];
            
        SVMXC__Territory__c territoryObj = [Select SVMXC__Territory_s_Business_Hours__r.Id from SVMXC__Territory__c where Id =:territoryGuid]; 
            
        BusinessHours bh = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
                            WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, 
                            SaturdayEndTime, SundayStartTime, SundayEndTime from BusinessHours where IsActive = TRUE AND 
                            Id =: territoryObj.SVMXC__Territory_s_Business_Hours__r.Id ];
                            
        if(lstOfDPProcessObj != null && lstOfDPProcessObj.size() > 0) {
            List<DateTime> lstHorizonStartAndEndDateTime = WSCH_CommonUtils.getDPHorizonStartAndEndDates(lstOfDPProcessObj[0], bh);
            if(lstHorizonStartAndEndDateTime != null && lstHorizonStartAndEndDateTime.size() == 2) {
                DateTime horizonStartDateTime = lstHorizonStartAndEndDateTime[0];
                DateTime horizonEndDateTime = lstHorizonStartAndEndDateTime[1];
                
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:horizonStartDateTime - ' + horizonStartDateTime);
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:horizonEndDateTime - ' + horizonEndDateTime);
                
                DateTime horizonStartDateTimeGMT = WSCH_DateUtils.doTZConversion(horizonStartDateTime, bh.TimeZoneSidKey, 'GMT');
                DateTime horizonEndDateTimeGMT = WSCH_DateUtils.doTZConversion(horizonEndDateTime, bh.TimeZoneSidKey, 'GMT');
                
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:horizonStartDateTimeGMT - ' + horizonStartDateTimeGMT);
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:horizonEndDateTimeGMT - ' + horizonEndDateTimeGMT);
                
                List<Event> lstOfEvents = new List<Event>();
                List<SVMXC__SVMX_Event__c> lstOfSmaxEvents = new List<SVMXC__SVMX_Event__c>();
                List<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = new List<SVMXC__SVMX_Optimizer__c>();
                set<String> setAvailTechAsSFUserList = new set<String>();
                set<String> setAvailTechAsSVMXUserList = new set<String>();
                Map<Id,SVMXC__Service_Group_Members__c> mapOwnerIDTechId = new Map<Id,SVMXC__Service_Group_Members__c>();
                
                Map<Id, SVMXC__Service_Group_Members__c> mapOfAllTechnicians = new Map<Id, SVMXC__Service_Group_Members__c>([Select Id, Name, SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey, SVMXC__Service_Territory__r.SVMXC__Per_Mile_Cost__c,
                            SVMXC__Service_Territory__r.SVMXC__Per_Hour_Cost__c, SVMXC__Service_Territory__r.SVMXC__Fixed_Cost__c, SVMXC__Service_Territory__r.SVMXC__Max_Hours__c,
                            SVMXC__Service_Territory__r.SVMXC__Average_Speed__c, SVMXC__Service_Territory__r.SVMXC__Max_Daily_Hours__c, SVMXC__Max_Hours__c,
                            SVMXC__Service_Territory__r.SVMXC__Max_Distance__c, 
                            SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive, SVMXC__Fixed_Cost__c, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c, SVMXC__Per_hour_Cost__c,
                            SVMXC__Per_Mile_Cost__c, SVMXC__Average_Speed__c, SVMXC__Max_Daily_Hours__c, SVMXC__Max_Distance__c,
                            SVMXC__Working_Hours__c ,SVMXC__Working_Hours__r.IsActive,
                            SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c , SVMXC__Break_Hours__c, SVMXC__Enable_Scheduling__c,SVMXC__SM_Overnight_Stay_Policy__c,SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.IsActive
                            from SVMXC__Service_Group_Members__c 
                            where SVMXC__Active__c = TRUE AND SVMXC__Service_Territory__c = :territoryGuid AND ((SVMXC__Enable_Scheduling__c = TRUE AND SVMXC__Salesforce_User__c = NULL) OR (SVMXC__Salesforce_User__c != NULL AND SVMXC__Salesforce_User__r.IsActive = true) )]);  
                
                for(SVMXC__Service_Group_Members__c tech : mapOfAllTechnicians.values()) {
                    if(tech.SVMXC__Salesforce_User__c != NULL) {
                        setAvailTechAsSFUserList.add(tech.SVMXC__Salesforce_User__c);
                        mapOwnerIDTechId.put(tech.SVMXC__Salesforce_User__c, tech);
                    }
                    else {
                        setAvailTechAsSVMXUserList.add(tech.Id);
                    }
                }
                
                String strOptConnIdWithNoTechId = dispatchProcessGuid+'_'+territoryGuid;
                
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon: mapOfAllTechnicians.size() :' + mapOfAllTechnicians.size());
                //WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon: mapOfAllTechnicians :' + mapOfAllTechnicians);
                
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon: strOptConnIdWithNoTechId :' + strOptConnIdWithNoTechId);
                
                //fetch all the OptimizerTransRecords for all the SFEvents and SmaxEvents whose status is OPT_COMPLETED, OPT_ERROR, OPT_FAIL
                lstSVMXOptimizer = [SELECT ID , SVMXC__WhatId__c, SVMXC__WhatType__c, SVMXC__Optimizer_External_Id__c, SVMXC__Optimizer_Status__c, SVMXC__Optimizer_Error_Text__c, SVMXC__Optimizer_Change_Token__c, 
                                        SVMXC__Optimizer_Retry_count__c,SVMXC__Optimizer_Connection_ID__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatType__c = 'NON_WO_EVENT' AND SVMXC__Optimizer_Status__c IN ('OPT_COMPLETED','OPT_ERROR','OPT_FAIL') AND SVMXC__Optimizer_Connection_ID__c LIKE: '%' + strOptConnIdWithNoTechId + '%'];
                                        
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:list of opt_trans records within Horizon to filter:lstSVMXOptimizer.size() - ' + lstSVMXOptimizer.size());
                
                String sfEventKeyPrefix = Schema.SObjectType.Event.getKeyPrefix();
                String smaxEventKeyPrefix = Schema.SObjectType.SVMXC__SVMX_Event__c.getKeyPrefix();
                List<String> lstOfsfEventIds = new List<String>();
                List<String> lstOfSmaxEventIds = new List<String>();
                
                //seggregate the SFEvents and SmaxEvents Ids from the optimizers.
                for(SVMXC__SVMX_Optimizer__c eachOptTrans : lstSVMXOptimizer) {
                    String[] strSplitWhatID = (String.valueOf(eachOptTrans.SVMXC__WhatId__c)).split('_',-1); //fetch the object Prefix from a0v2I00000aiyGGQAY_Aaron
                    String strPrefix = (strSplitWhatID[0].trim()).substring(0,3);
                    if(sfEventKeyPrefix.equals(strPrefix)) {
                        lstOfsfEventIds.add(strSplitWhatID[0].trim());
                    } else if(smaxEventKeyPrefix.equals(strPrefix)) {
                        lstOfSmaxEventIds.add(strSplitWhatID[0].trim());
                    }
                }
                
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:setAvailTechAsSVMXUserList.size():'+ setAvailTechAsSVMXUserList.size());
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:lstOfSmaxEventIds.size():'+ lstOfSmaxEventIds.size());
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:lstOfsfEventIds.size():'+ lstOfsfEventIds.size());
                
                //getting the date component from the horizonStartDateTime, used below to get the events starting from this date
                Date horizonStartDateGMT = horizonStartDateTimeGMT.dateGmt();
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:horizonStartDateGMT:'+ horizonStartDateGMT);
                DateTime horizonStartDateZeroHr = DateTime.newInstanceGmt(horizonStartDateGMT, Time.newInstance(0,0,0,0));
                /**  Added another condition to check if eventEndDateTime > currentDateTime to ensure past event is not sent   **/
                //query all the SFEvents excluding the above Ids within the Horizon dates
                //String strSmaxEventfld = WSCH_ECO_Client_TechnicianServices.getSmaxEventFields();
                //if(String.isNotBlank(strSmaxEventfld)){
                    //lstOfSmaxEvents =  database.query('Select ' + strSmaxEventfld + ' From SVMXC__SVMX_Event__c ' + ' WHERE Id NOT IN:lstOfSmaxEventIds AND SVMXC__WhatId__c = null AND SVMXC__Technician__c in:setAvailTechAsSVMXUserList AND ((SVMXC__StartDateTime__c >=: horizonStartDateTimeGMT AND SVMXC__StartDateTime__c <=: horizonEndDateTimeGMT) OR (SVMXC__EndDateTime__c >= :horizonStartDateTimeGMT AND SVMXC__EndDateTime__c <= :horizonEndDateTimeGMT))');
                    lstOfSmaxEvents =  [Select Id,SVMXC__WhatId__c,SVMXC__StartDateTime__c,SVMXC__EndDateTime__c,SVMXC__Technician__c,SVMXC__Driving_Time__c,SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__Location__c, SVMXC__IsAllDayEvent__c From SVMXC__SVMX_Event__c WHERE Id NOT IN:lstOfSmaxEventIds AND SVMXC__WhatId__c = null AND SVMXC__Technician__c in:setAvailTechAsSVMXUserList AND ((SVMXC__StartDateTime__c <=: horizonEndDateTimeGMT AND SVMXC__StartDateTime__c >=: horizonStartDateZeroHr AND SVMXC__EndDateTime__c >=: system.now()) OR (SVMXC__EndDateTime__c >= :horizonStartDateTimeGMT AND SVMXC__EndDateTime__c <= :horizonEndDateTimeGMT AND SVMXC__EndDateTime__c >=: system.now()))];
                //}
                
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:SmaxEvents within Horizon:lstOfSmaxEvents.size() - ' + lstOfSmaxEvents.size());
                
                List<String> technicianIds = WSCH_ECO_CommonUtils.getNonWOTechniciansFromSVMXEvents(lstOfSmaxEvents);               
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:technicianIds from SmaxEvents technicianIds.size() - ' + technicianIds.size());
                /**  Added another condition to check if eventEndDateTime > currentDateTime to ensure past event is not sent   **/
                //query all the SmaxEvents excluding the above Ids within the Horizon dates
                //String strEventfld = WSCH_ECO_Client_TechnicianServices.getSFEventFields();
                //if(String.isNotBlank(strEventfld)){
                    //lstOfEvents =  database.query('Select ' + strEventfld + ' From Event ' + '  WHERE Id NOT IN:lstOfsfEventIds AND WhatId = null AND OwnerId in:setAvailTechAsSFUserList AND ((StartDateTime >=: horizonStartDateTimeGMT AND StartDateTime <=: horizonEndDateTimeGMT) OR (EndDateTime >= :horizonStartDateTimeGMT AND EndDateTime <= :horizonEndDateTimeGMT))');
                    lstOfEvents =  [Select Id,WhatId,StartDateTime,EndDateTime,SVMXC__Driving_Time__c,SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, Location,OwnerId, IsAllDayEvent From Event WHERE Id NOT IN:lstOfsfEventIds AND WhatId = null AND OwnerId in:setAvailTechAsSFUserList AND ((StartDateTime <=: horizonEndDateTimeGMT AND StartDateTime >=: horizonStartDateZeroHr AND EndDateTime >=: system.now()) OR (EndDateTime >= :horizonStartDateTimeGMT AND EndDateTime <= :horizonEndDateTimeGMT AND EndDateTime >=: system.now()))];
                //}
                
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:SFEvents within Horizon:lstOfEvents.size() - ' + lstOfEvents.size());
                
                technicianIds.addAll(WSCH_ECO_CommonUtils.getNonWOTechniciansFromSFEvents(lstOfEvents));                
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:technicianIds from SmaxEvents and SFEvents technicianIds.size() - ' + technicianIds.size());
                
                List<SVMXC__SVMX_Optimizer__c> lstOfSVMXOptimizer = getLstOfOptimizers(lstOfEvents, lstOfSmaxEvents, mapOfAllTechnicians);
                
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:list of existing opt_trans within Horizon which are not OPT_COMPLETED or OPT_ERROR or OPT_FAIL:lstOfSVMXOptimizer.size() - ' + lstOfSVMXOptimizer.size());
                
                Map<String, SVMXC__SVMX_Optimizer__c> mapOfeventIdOptTransaction = new Map<String, SVMXC__SVMX_Optimizer__c>();
                SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
                List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();
                List<SVMXC__SVMX_Optimizer__c> lstOfQualifiedSVMXOptimizer = new List<SVMXC__SVMX_Optimizer__c>();
                List<String> lstOfEventIds = new List<String>();
                
                //Below logic logs all the optimizer transaction records that were created for the events and those events were not sent to server
                //and not marked OPT_ERROR or OPT_FAIL or empty by any chance.
                for(SVMXC__SVMX_Optimizer__c eachOptTransRecord : lstOfSVMXOptimizer) {
                    String[] strWhatIdSplit = (eachOptTransRecord.SVMXC__WhatId__c).split('_', -1);  //'eventid_techid'
                    WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices:: Delete the following optimizer transaction record to avoid inconsistency: ' + strWhatIdSplit[0].trim());
                }
                
                //create the optimizer transaction records for the above smax events
                for(SVMXC__SVMX_Event__c eachSmaxEvent : lstOfSmaxEvents) {
                    DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(eachSmaxEvent.SVMXC__StartDateTime__c, 'GMT', bh.TimeZoneSidKey);
                    DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(eachSmaxEvent.SVMXC__EndDateTime__c, 'GMT', bh.TimeZoneSidKey);        
                    integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                    if(intDays > 0 || eachSmaxEvent.SVMXC__IsAllDayEvent__c == true){
                        continue;
                    }
                    optimizer = WSCH_ECO_Client_TechnicianServices.createOptimizerObject(String.valueOf(eachSmaxEvent.id),WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE,WSCH_ECO_Constants.OPT_NON_WORK_ORDER_EVENT_TYPE,dispatchProcessGuid,territoryGuid,mapOfAllTechnicians.get(eachSmaxEvent.SVMXC__Technician__c));
                    optimizerObjects.add(optimizer);
                }
                
                //create the optimizer transaction records for the above SFevents
                for(Event eachSFEvent : lstOfEvents) {
                    DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(eachSFEvent.StartDateTime, 'GMT', bh.TimeZoneSidKey);
                    DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(eachSFEvent.EndDateTime, 'GMT', bh.TimeZoneSidKey);        
                    integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                    if(intDays > 0 || eachSFEvent.IsAllDayEvent == true){
                        continue;
                    }                   
                    optimizer = WSCH_ECO_Client_TechnicianServices.createOptimizerObject(String.valueOf(eachSFEvent.id),WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE,WSCH_ECO_Constants.OPT_NON_WORK_ORDER_EVENT_TYPE,dispatchProcessGuid,territoryGuid,mapOwnerIDTechId.get(eachSFEvent.OwnerId));
                    optimizerObjects.add(optimizer);
                }
                
                insert optimizerObjects;
                
                //add the newly created optimizer transaction records to the qualified list
                lstOfQualifiedSVMXOptimizer.addAll(optimizerObjects);
                
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:no. of optimizer Transactions newly created - ' + optimizerObjects.size());
                WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsFallingInHorizon:no. of optimizer Transactions to be synced to server - ' + lstOfQualifiedSVMXOptimizer.size());
                
                if(lstOfQualifiedSVMXOptimizer != null && lstOfQualifiedSVMXOptimizer.size() != 0){
                    List<String> lstOptTransIds = new List<String>();
                    for(SVMXC__SVMX_Optimizer__c eachOptTransObj : lstOfQualifiedSVMXOptimizer) {
                        lstOptTransIds.add(eachOptTransObj.Id);
                    }
                    WSCH_ECO_Client_TechnicianServices.scheduleEventsInHorizon(lstOptTransIds);
                }
            }
        }
        return RETURN_MESSAGE_FOR_NON_WO_EVENT_UPDATE;
    }
    
    public static SVMXC__SVMX_Optimizer__c createOptimizerObject(String eventid, String changeToken,String eventType,String dProcess,String teritory,SVMXC__Service_Group_Members__c technician) {
        SVMXC__SVMX_Optimizer__c obj = new SVMXC__SVMX_Optimizer__c();
        obj.SVMXC__WhatType__c = eventType;
        obj.SVMXC__WhatId__c = eventid+'_'+technician.name;
        obj.SVMXC__Optimizer_Change_Token__c = changeToken;
        obj.SVMXC__Optimizer_Connection_ID__c = dProcess+'_'+teritory+'_'+technician.id;
        return obj;
    }
    
    @future(callout=true)
    public static void scheduleEventsInHorizon(List<String> lstOfOptimizerIds) {
        try {
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
            List<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = WSCH_CommonUtils.fetchSVMXOptimizerById(lstOfOptimizerIds);
            //Call manageNonWOEvents for all the OptimizerTransRecords
            WSCH_OptimizedSchedulingService.manageNonWorkOrderEvents(lstSVMXOptimizer);
        } catch(Exception ex) {
            WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices::scheduleEventsInHorizon: Exception caught: ' + ex.getMessage());
        }
    }
    
    public static list<SVMXC__SVMX_Optimizer__c> getLstOfOptimizers(list<Event> sfEvents, List<SVMXC__SVMX_Event__c> svmxEvents, Map<Id,SVMXC__Service_Group_Members__c> mapOfTechnicians)
    { 
        WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices : getEventIdAndOptimizers ');
        map<String,SVMXC__SVMX_Optimizer__c> mapIdOptimizer = new map<String,SVMXC__SVMX_Optimizer__c>();   
        list<String> lstEventID= new list<String> ();           
        list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = new list<SVMXC__SVMX_Optimizer__c> ();

        //Map<Id,SVMXC__Service_Group_Members__c> techniciansMap= WSCH_ECO_CommonUtils.getTechnicians(technicianIds);
        
        Map<Id,SVMXC__Service_Group_Members__c> mapOwnerIDTechId = new Map<Id,SVMXC__Service_Group_Members__c>();
        //create ownerId map
        for(SVMXC__Service_Group_Members__c tech : mapOfTechnicians.values()){
                if(tech.SVMXC__Salesforce_User__c != null)
                    mapOwnerIDTechId.put(tech.SVMXC__Salesforce_User__c, tech);   
        }        

        SVMXC__Service_Group_Members__c technician;
        if(null != sfEvents){
            for(Event objEvent : sfEvents){
                technician = mapOwnerIDTechId.get(objEvent.OwnerId);
                if(null != technician){
                    lstEventID.add(objEvent.id+'_'+technician.name);
                }
            }
        }
            
        if (null != svmxEvents){
            for(SVMXC__SVMX_Event__c objEvent : svmxEvents){
                technician = mapOfTechnicians.get(objEvent.SVMXC__Technician__c);
                if(null != technician){
                   lstEventID.add(objEvent.id+'_'+technician.name); 
                }
            }
        }
            
                                    
        lstSVMXOptimizer = [SELECT ID , SVMXC__WhatId__c, SVMXC__WhatType__c, SVMXC__Optimizer_External_Id__c, SVMXC__Optimizer_Status__c, SVMXC__Optimizer_Error_Text__c, SVMXC__Optimizer_Change_Token__c, 
                                        SVMXC__Optimizer_Retry_count__c,SVMXC__Optimizer_Connection_ID__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatId__c in: lstEventID AND SVMXC__WhatType__c = 'NON_WO_EVENT' AND SVMXC__Optimizer_Status__c NOT IN ('OPT_COMPLETED','OPT_ERROR','OPT_FAIL')];
          
        WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices : Optimizer Objects size  - '+lstSVMXOptimizer.size());
       
        return lstSVMXOptimizer;
    }
    
    /*public static String getSmaxEventFields() {
        String strFlds = '';
        try {
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> mapOfFields = gd.get('SVMXC__SVMX_Event__c').getDescribe().fields.getMap();
            List<String> lstOfKeys = new List<String>(mapOfFields.keySet());
            lstOfKeys.sort();
            for(String key : lstOfKeys)  
            {  
                Schema.DescribeFieldResult fieldResult = mapOfFields.get(key).getDescribe();  
                if(fieldResult.isAccessible())
                {  
                    if(strFlds.length() > 0)
                        strFlds += ',';
                    strFlds += fieldResult.getName();
                }
                
            }
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_ECO_Client_TechnicianServices::getSmaxEventFields(): ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n  Stack Trace:: ' + ex.getStackTraceString());
        }       
        //WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices:getSmaxEventFields::SMAX_Event fields returned: '+strFlds);
        return strFlds;
    }
    
    public static String getSFEventFields() {
        String strFlds = '';
        try {
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> mapOfFields = gd.get('Event').getDescribe().fields.getMap();
            List<String> lstOfKeys = new List<String>(mapOfFields.keySet());
            lstOfKeys.sort();
            for(String key : lstOfKeys)  
            {  
                Schema.DescribeFieldResult fieldResult = mapOfFields.get(key).getDescribe();  
                if(fieldResult.isAccessible())
                {  
                    if(strFlds.length() > 0)
                        strFlds += ',';
                    strFlds += fieldResult.getName();
                }
            }
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_ECO_Client_TechnicianServices::getSFEventFields(): ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n  Stack Trace:: ' + ex.getStackTraceString());
        }       
        //WSCH_AuditLogger.debug('WSCH_ECO_Client_TechnicianServices:getSFEventFields::SFEvent fields returned: '+strFlds);
        return strFlds;
    }*/
}