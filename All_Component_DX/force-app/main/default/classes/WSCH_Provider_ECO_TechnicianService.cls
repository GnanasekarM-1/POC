/**
A concrete OptiMaxECO related implementation class for the ITechnicianService.
This class encapsulates all the logic of invoking ECO webservices related to real time optimization such as Manage Technicians. 
In addition to invoking the webservices, it is the responsibility of this class to perform
the data transformations from input to webservice request and webservice response to required output format using
data mappers.
*/


public with sharing class WSCH_Provider_ECO_TechnicianService implements WSCH_ITechnicianService {
    
    public WSCH_TechnicianResponse manageTechnicians(List<SVMXC__SVMX_Optimizer__c> technicians){
        WSCH_TechnicianResponse response = new WSCH_TechnicianResponse();
        WSCH_AuditLogger.warn('WSCH_Provider_ECO_TechnicianService::manageTechnicians()::technicians '+technicians.size());
        if(technicians == null || technicians.size() == 0){
            //WSCH_AuditLogger.rca('WSCH_Provider_ECO_TechnicianService::manageTechnicians()::Invalid input.There are no technicians to be managed');
            throw new WSCH_EXCEPTION('Invalid input. There is no technicians to be managed');
        }
        set<Id> setTechIds = new set<Id>();
        List<SVMXC__Service_Group_Members__c> lstValidTechs = new List<SVMXC__Service_Group_Members__c>();
        List<SVMXC__Service_Group_Members__c> lstErrorTechs = new List<SVMXC__Service_Group_Members__c>();
        Map<Id,List<SVMXC__Service_Group_Members__c>> mapTerritoryIdTechs= new Map<Id,List<SVMXC__Service_Group_Members__c>>();
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryJobs = new Map<Id, SVMXC__SVMX_Jobs__c>();
        Map<String,SVMXC__SVMX_Optimizer__c> mapTechIdOptTrnObj = new Map<String, SVMXC__SVMX_Optimizer__c>();
        Map<String,SVMXC__SVMX_Optimizer__c> mapDelTechIdOptTrnObj = new Map<String, SVMXC__SVMX_Optimizer__c>();
        Map<String,List<String>> mapTerritoryIdTechId= new Map<String,List<String>>();
        try{
            for(SVMXC__SVMX_Optimizer__c optimizerTrn : technicians){
                if('CHANGE_REMOVE_TECH'.equalsIgnoreCase(optimizerTrn.SVMXC__Optimizer_Change_Token__c)){
                    String[] lstIds = optimizerTrn.SVMXC__Optimizer_Connection_ID__c.split('_');
                    if(!mapTerritoryIdTechId.containsKey(lstIds[1]))
                        mapTerritoryIdTechId.put(lstIds[1], new List<String>());
                    
                    mapTerritoryIdTechId.get(lstIds[1]).add(optimizerTrn.SVMXC__WhatId__c+'_'+lstIds[0]+'_'+lstIds[1]);
                    mapDelTechIdOptTrnObj.put(optimizerTrn.SVMXC__WhatId__c,optimizerTrn);
                }else{
                    String[] lstTechIds = optimizerTrn.SVMXC__WhatId__c.split('_');
                    setTechIds.add(lstTechIds[0]);
                    mapTechIdOptTrnObj.put(optimizerTrn.SVMXC__WhatId__c,optimizerTrn);
                }
            }
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_TechnicianService::manageTechnicians():size of technicians removed from Job..'+mapDelTechIdOptTrnObj.size());  
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_TechnicianService::manageTechnicians():size of technicians changed into existing Job..'+mapTechIdOptTrnObj.size());            
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_TechnicianService::manageTechnicians():setTechIds '+setTechIds);
            List<SVMXC__Service_Group_Members__c> lstTechnicians;
            if(setTechIds != null && setTechIds.size() >0){
                lstTechnicians = [Select Id, Name, SVMXC__Active__c, SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c,SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey,SVMXC__Service_Territory__r.SVMXC__Per_Mile_Cost__c,
                SVMXC__Service_Territory__r.SVMXC__Per_Hour_Cost__c, SVMXC__Service_Territory__r.SVMXC__Fixed_Cost__c, SVMXC__Service_Territory__r.SVMXC__Max_Hours__c,
                SVMXC__Service_Territory__r.SVMXC__Average_Speed__c, SVMXC__Service_Territory__r.SVMXC__Max_Daily_Hours__c, SVMXC__Max_Hours__c,
                SVMXC__Service_Territory__r.SVMXC__Max_Distance__c, 
                SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive, SVMXC__Fixed_Cost__c, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c, SVMXC__Per_hour_Cost__c,
                SVMXC__Per_Mile_Cost__c, SVMXC__Average_Speed__c, SVMXC__Max_Daily_Hours__c, SVMXC__Max_Distance__c,
                SVMXC__Working_Hours__c ,SVMXC__Working_Hours__r.TimeZoneSidKey,
                SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c , SVMXC__Break_Hours__c, SVMXC__Enable_Scheduling__c
                from SVMXC__Service_Group_Members__c WHERE Id in:setTechIds and SVMXC__Active__c = true];
                
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_TechnicianService::manageTechnicians():lstTechnicians size'+lstTechnicians.size());
            
                //validate work orders service duration,zip
                //remove the invalid work orders for callout and update the error details on the work orders
                for(SVMXC__Service_Group_Members__c tech : lstTechnicians){
                    if(isTechnicianValid(tech)){
                        lstValidTechs.add(tech);
                        if(!mapTerritoryIdTechs.containsKey(tech.SVMXC__Service_Territory__c))
                            mapTerritoryIdTechs.put(tech.SVMXC__Service_Territory__c, new List<SVMXC__Service_Group_Members__c>());
                            
                        mapTerritoryIdTechs.get(tech.SVMXC__Service_Territory__c).add(tech);
                    }else{
                        lstErrorTechs.add(tech);
                    }
                }
            
                //create territory object map for data preparation
                Map<Id, SVMXC__Territory__c> mapAllTeritories = getTerritoriesMap(lstValidTechs);
                
                Set<Id> setTerritoryId = mapTerritoryIdTechs.keyset();
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_TechnicianService::manageTechnicians()::setTerritoryId : ' + setTerritoryId);
                
                //query the svmx jobs records for territoryId
                list<SVMXC__SVMX_Jobs__c> lstSVMXJob = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where SVMXC__Territory__c In :setTerritoryId and SVMXC__Type__c = 'ECO' and SVMXC__OptiMax_Message__c !='FAILED']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_TechnicianService::manageTechnicians()::lstSVMXJob : ' + lstSVMXJob);         
                
                for(SVMXC__SVMX_Jobs__c objJob : lstSVMXJob){
                    mapTeritoryJobs.put(objJob.SVMXC__Territory__c, objJob);
                }
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_TechnicianService::manageTechnicians()::mapTeritoryJobs : ' + mapTeritoryJobs);
                                
                //need to make the decision whether we need to make call or not.        
                for(Id territoryId : mapTerritoryIdTechs.keyset()){
                    if(mapTeritoryJobs.containsKey(territoryId)){
                        manageTechnicians(mapAllTeritories.get(territoryId),mapTerritoryIdTechs.get(territoryId),mapTechIdOptTrnObj,mapTeritoryJobs.get(territoryId));
                    }
                }
            
                //update the optimizer transaction status and error text 
                response.getTechOptimizer().addAll(mapTechIdOptTrnObj.values());                
            }else{
                for(Id territoryId : mapTerritoryIdTechId.keySet()){
                    cancelTechnicians(mapTerritoryIdTechId.get(territoryId),mapDelTechIdOptTrnObj);
                }
                //response.getTechOptimizer().addAll(mapDelTechIdOptTrnObj.values()); 
            }
                    
        } catch (Exception ex) {
            String exceptionMsg = 'WSCH_Provider_ECO_TechnicianService :: manageTechnicians() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
            throw new WSCH_EXCEPTION(exceptionMsg+ex.getStackTraceString());
        }       
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_TechnicianService::manageTechnicians()::start, No of Queries used in this transaction so far: ' + Limits.getQueries());       
        return response;    
    }
    
    private void manageTechnicians(SVMXC__Territory__c objTerritory, List<SVMXC__Service_Group_Members__c> lstTech, Map<String,SVMXC__SVMX_Optimizer__c> mapTechIdOptTrn,SVMXC__SVMX_Jobs__c svmxJob){
        //Invoking ManageTechnician api call  
        String strDateTime;
        strDateTime = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm');
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_TechnicianService::manageTechnicians():territory -'+objTerritory.Name +'-'+objTerritory.Id);
        WSCH_Provider_ECO_Stubs.ManageTechnicianRequest_WP request_x = WSCH_Provider_ECO_DataMapper.manageTechnicianRequest(objTerritory,lstTech,mapTechIdOptTrn,svmxJob.SVMXC__SVMX_Process__c);
        List<WSCH_Provider_ECO_Stubs.Technician_WP> newResources = new List<WSCH_Provider_ECO_Stubs.Technician_WP>();
        for(WSCH_Provider_ECO_Stubs.Technician_WP techWP :request_x.resources){
            if(techWP.workingHours == null){
                SVMXC__SVMX_Optimizer__c optimizer = mapTechIdOptTrn.get(techWP.resourceId);
                optimizer.SVMXC__Optimizer_Status__c = 'OPT_SYNC_ERROR';
                optimizer.SVMXC__Optimizer_Error_Text__c = strDateTime+': Technician availability is empty. So technician data not synced. ';
            }else{
                newResources.add(techWP);   
            }
        }
        request_x.resources = newResources;
        WSCH_Provider_ECO_Stubs.Response_WP response_x = new WSCH_Provider_ECO_Stubs.Response_WP();
        if(request_x.resources != null && !request_x.resources.isEmpty()){
            String requestJson=JSON.serialize(request_x); 
            String serviceName = WSCH_Provider_ECO_Callout_Helper.ECO_ASSIGNMENTENTITY_SERVICE_PATH;
            String methodName = WSCH_Provider_ECO_Callout_Helper.ECO_MANAGE_TECH_METHOD;
            response_x = WSCH_Provider_ECO_Callout_Helper.callOut(requestJson,serviceName,methodName);    
        }
        
        //WSCH_Provider_ECO_Stubs.Response_WP response_x = WSCH_Provider_ECO_Service.manageTechnicians(request_x);
        if(response_x.status == '200'){
            
            setOptimizerStatus(mapTechIdOptTrn,WSCH_ECO_Constants.STATUS_OPT_COMPLETED,response_x);
        }else{
            setOptimizerStatus(mapTechIdOptTrn,WSCH_ECO_Constants.STATUS_OPT_ERROR,response_x);
        }
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_TechnicianService::manageJob():response_x..'+response_x);
    }   
    
    private void cancelTechnicians(List<String> lstTechId, Map<String,SVMXC__SVMX_Optimizer__c> mapDelTechIdOptiObj){
        //Invoking cancelTechnicians api call  
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_TechnicianService::cancelTechnicians():lstTechId size -'+lstTechId.size());
        WSCH_Provider_ECO_Stubs.ManageTechnicianRequest_WP request_x = WSCH_Provider_ECO_DataMapper.cancelTechnicianRequest(lstTechId); 
        String requestJson=JSON.serialize(request_x); 
        String serviceName = WSCH_Provider_ECO_Callout_Helper.ECO_ASSIGNMENTENTITY_SERVICE_PATH;
        String methodName = WSCH_Provider_ECO_Callout_Helper.ECO_MANAGE_TECH_METHOD;
        WSCH_Provider_ECO_Stubs.Response_WP response_x = WSCH_Provider_ECO_Callout_Helper.callOut(requestJson,serviceName,methodName);
        
        //WSCH_Provider_ECO_Stubs.Response_WP response_x = WSCH_Provider_ECO_Service.manageResources(request_x);
        if(response_x.status == '200'){
            //setOptimizerStatus(mapDelTechIdOptiObj,WSCH_ECO_Constants.STATUS_OPT_COMPLETED,response_x);
            //Optimizer record not required for this technician.
            delete mapDelTechIdOptiObj.values();
        }else{
            setOptimizerStatus(mapDelTechIdOptiObj,WSCH_ECO_Constants.STATUS_OPT_ERROR,response_x);
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_TechnicianService::manageJob():response_x..'+response_x);
    }   
    
    public void setOptimizerStatus(Map<String,SVMXC__SVMX_Optimizer__c> mapTechIdOptTrnObj, String status,WSCH_Provider_ECO_Stubs.Response_WP returnCode){
        for(SVMXC__SVMX_Optimizer__c optTrnObj : mapTechIdOptTrnObj.values()){

            if('OPT_SYNC_ERROR'.equalsIgnoreCase(optTrnObj.SVMXC__Optimizer_Status__c)){
                optTrnObj.SVMXC__Optimizer_Status__c = 'OPT_ERROR';
            }else{
                optTrnObj.SVMXC__Optimizer_Status__c = status;
                optTrnObj.SVMXC__Optimizer_Error_Text__c = 'Return Code:' + returnCode.status + ' | Return Msg:' + returnCode.message;    
            }            
            // Update retry count
            // if(null == optTrnObj.SVMXC__Optimizer_Retry_Count__c) {
            //     optTrnObj.SVMXC__Optimizer_Retry_Count__c = 1;
            // } else {
            //     optTrnObj.SVMXC__Optimizer_Retry_Count__c = optTrnObj.SVMXC__Optimizer_Retry_Count__c + 1;
            // }
        }       
        /*for(SVMXC__Service_Group_Members__c techObj :lstTech){
            SVMXC__SVMX_Optimizer__c optTrnObj = mapTechIdOptTrnObj.get(techObj.Id);
            optTrnObj.SVMXC__Optimizer_Status__c = status;
            optTrnObj.SVMXC__Optimizer_Error_Text__c = 'Return Code:' + returnCode.status + ' | Return Msg:' + returnCode.message;
        }*/
    }
    
    public boolean isTechnicianValid(SVMXC__Service_Group_Members__c technician) {
        boolean isValid=true;
        //TODO: need to implement validation logics for technician data
        return isValid;
    } 
    
    
    public Map<Id, SVMXC__Territory__c> getTerritoriesMap(List<SVMXC__Service_Group_Members__c> lstTech){
        set<Id> setTerritoryIds = new set<Id>();
        for(SVMXC__Service_Group_Members__c tech : lstTech){
            setTerritoryIds.add(tech.SVMXC__Service_Territory__c);
        }
        Map<Id, SVMXC__Territory__c> mapTerritory = new Map<Id, SVMXC__Territory__c>([Select Id, Name,SVMXC__Territory_s_Business_Hours__c, SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey, SVMXC__Break_Hours__c, SVMXC__Average_Driving_Time__c, SVMXC__Per_Mile_Cost__c,
                                SVMXC__Max_Distance__c, SVMXC__Average_Speed__c, SVMXC__Fixed_Cost__c, SVMXC__Per_hour_Cost__c, SVMXC__Mode_Of_Travel__c
                                from SVMXC__Territory__c
                                where Id in :setTerritoryIds]);  
        return mapTerritory;
    }    
}