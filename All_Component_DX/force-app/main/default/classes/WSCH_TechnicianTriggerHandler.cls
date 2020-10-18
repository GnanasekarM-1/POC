/**
@ Name: WSCH_TechnicianTriggerHandler
@ Author: Anantha Kumar
@ Description: Define future call to Synchronize Technician Data. Invokes the SP API call based on the type of change in Technician.
 **/
public with sharing class WSCH_TechnicianTriggerHandler {
    public static Boolean isSmaxQEnabled = false;
    static {
        String setVal = WSCH_CommonUtils.getSettingValue('OMAX004','SET004');
        if(String.isNotBlank(setVal)){
            isSmaxQEnabled = Boolean.valueOf(setVal);
        }
        WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::static(): isSmaxQEnabled ' + isSmaxQEnabled);        
    }   

    //Method to create optimizer object related to Technician INSERT. 
    public static void handleTechnicianInsert(List<SVMXC__Service_Group_Members__c> techInsert)
    {
        List<SVMXC__SVMX_Optimizer__c> optimizerObjects = new List<SVMXC__SVMX_Optimizer__c>();
        Set<ID> setTerritory = new Set<ID>();
        for(SVMXC__Service_Group_Members__c lstTech: techInsert){
            //check if territory is null and add to set
            if(lstTech.SVMXC__Service_Territory__c <> null)
            //add territory ID to set;
            setTerritory.add(lstTech.SVMXC__Service_Territory__c);
        }
        //WSCH_AuditLogger.rca('Tehnician Insert for the Teritories '+setTerritory);
        //query the svmx jobs records for territoryId
        //list<SVMXC__SVMX_Jobs__c> lstSVMXJob = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where SVMXC__Territory__c In :setTerritory and SVMXC__Type__c = 'ECO' and SVMXC__OptiMax_Message__c != 'IDLE'];
        list<SVMXC__SVMX_Jobs__c> lstSVMXJob = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where SVMXC__Territory__c In :setTerritory];
        WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::handleTechnicianInsert()::lstSVMXJob : ' + lstSVMXJob.size());           
        
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryJobs = new Map<Id, SVMXC__SVMX_Jobs__c>();
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryBatchJobs = new Map<Id, SVMXC__SVMX_Jobs__c>();
        for(SVMXC__SVMX_Jobs__c objJob : lstSVMXJob){
            if(objJob.SVMXC__Type__c == 'ECO' && objJob.SVMXC__OptiMax_Message__c != 'IDLE'){
                mapTeritoryJobs.put(objJob.SVMXC__Territory__c, objJob);    
            }else if(objJob.SVMXC__Type__c == 'Full'){
                mapTeritoryBatchJobs.put(objJob.SVMXC__Territory__c, objJob);
            }
        }
        WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::handleTechnicianInsert()::mapTeritoryJobs : ' + mapTeritoryJobs);
        WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::handleTechnicianInsert()::mapTeritoryBatchJobs size : ' + mapTeritoryBatchJobs.size());
             
        if(mapTeritoryJobs !=null && mapTeritoryJobs.size() > 0){
            // retrive only technicians under territoty which has already initiated.
            // other technicians fitered out here.
            //WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::handleTechnicianInsert:: setTerritory: '+setTerritory);
            List<SVMXC__Service_Group_Members__c> technicianList = getTerritory(mapTeritoryJobs.keySet(), techInsert);
            WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::handleTechnicianInsert:: technicianList size: '+technicianList.size());
                //Adding Technician IDs to Optimizer List.
            for(SVMXC__Service_Group_Members__c objTech: technicianList) 
            {
                WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::handleTechnicianInsert:: Insert Technician: '+objTech);
                Id territoryId = objTech.SVMXC__Service_Territory__c;
                if(mapTeritoryJobs.get(territoryId) != null){
                    String strDPId = mapTeritoryJobs.get(territoryId).SVMXC__SVMX_Process__c;
                    String strECOId = strDPId+'_'+territoryId;
                    String strTechId = objTech.id+'_'+objTech.Name;
                    optimizerObjects.add(getOptimizerObject(strTechId,'CHANGE_CREATE_TECH',strECOId));
                }
            }
            //Creating SVMX Optimizer      
            if(optimizerObjects.size() > 0) 
            {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(optimizerObjects, COMM_SecurityUtils.Access.Createable)){     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    insert optimizerObjects;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
                List<ID> optimizerIds = new List<ID>();
                map<String, String> mapOptimizerIdToken = new Map<String, String>();  
                for(SVMXC__SVMX_Optimizer__c optimizer : optimizerObjects){
                    optimizerIds.add(optimizer.ID);
                    if(isSmaxQEnabled)                
                    mapOptimizerIdToken.put(optimizer.ID,'CHANGE_CREATE_TECH');
                }
                if(isSmaxQEnabled){
                    //create optmimizer transaction record for the map of optimizerId & respective scheduling token
                    createMaxQTrans(mapOptimizerIdToken);                  
                }else{
                    //invoking future call to Delete Technician.
                    manageTechnicians(optimizerIds);
                }
            }
        }
        //TODO:Create/update optimizer transaction for Batch technician for run the job without new work order.
        List<SVMXC__SVMX_Optimizer__c> lstBatchSVMXOptimizer = new List<SVMXC__SVMX_Optimizer__c>();
        if(mapTeritoryBatchJobs != null && mapTeritoryBatchJobs.size() > 0){
            lstBatchSVMXOptimizer = [Select id, SVMXC__WhatType__c, SVMXC__Optimizer_Change_Token__c,SVMXC__WhatId__c,SVMXC__Optimizer_Connection_ID__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatType__c = 'BATCH_TECHNICIAN' AND SVMXC__Optimizer_Connection_ID__c in: mapTeritoryBatchJobs.keySet()];
            WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::handleTechnicianInsert:: lstBatchSVMXOptimizer: '+lstBatchSVMXOptimizer);
            List<SVMXC__SVMX_Optimizer__c> lstBatchSVMXOptimizerUpdate = new List<SVMXC__SVMX_Optimizer__c>();
            Map<Id,SVMXC__SVMX_Optimizer__c> mapTerritoryIdOptimizer = new Map<Id,SVMXC__SVMX_Optimizer__c>();
            for(SVMXC__SVMX_Optimizer__c optimizerBatch :lstBatchSVMXOptimizer){
                mapTerritoryIdOptimizer.put(optimizerBatch.SVMXC__Optimizer_Connection_ID__c,optimizerBatch);
            }
            SVMXC__SVMX_Optimizer__c optimizerBatch;
            for(Id territoryId :mapTeritoryBatchJobs.keyset()){
                if(mapTerritoryIdOptimizer != null && mapTerritoryIdOptimizer.size() > 0){
                    optimizerBatch = mapTerritoryIdOptimizer.get(territoryId);
                }
                if(optimizerBatch != null && mapTerritoryIdOptimizer.containsKey(territoryId)){
                    optimizerBatch.SVMXC__Optimizer_Change_Token__c = 'TRUE';
                    lstBatchSVMXOptimizerUpdate.add(optimizerBatch);
                    continue;
                }else{
                SVMXC__SVMX_Optimizer__c obj = new SVMXC__SVMX_Optimizer__c();
                obj.SVMXC__WhatType__c = 'BATCH_TECHNICIAN';
                obj.SVMXC__WhatId__c = territoryId;
                obj.SVMXC__Optimizer_Connection_ID__c=territoryId;
                obj.SVMXC__Optimizer_Change_Token__c = 'TRUE';
            lstBatchSVMXOptimizerUpdate.add(obj);
                }
            }
            WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::handleTechnicianInsert:: lstBatchSVMXOptimizerUpdate: '+lstBatchSVMXOptimizerUpdate);
            if(lstBatchSVMXOptimizerUpdate.size() > 0 ){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstBatchSVMXOptimizerUpdate, COMM_SecurityUtils.Access.Createable)){      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert lstBatchSVMXOptimizerUpdate;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
        }
        WSCH_AuditLogger.finish();
    }

    //Method to return technicians associated with Territories.
    private static List<SVMXC__Service_Group_Members__c> getTerritory(Set<ID> setTerritory, List<SVMXC__Service_Group_Members__c> lstTech) {
    //Retriving territory associated with dispatch process method 'OptiMax ECO'
    List<SVMXC__Service_Group_Members__c> returnTechList = new List<SVMXC__Service_Group_Members__c> ();
    //Retrieving all Territory associated with Technician other then linx SP.
    List<SVMXC__Territory__c> territoryList = new List<SVMXC__Territory__c>([SELECT Id, Name,SVMXC__Active__c   FROM SVMXC__Territory__c WHERE Id in: setTerritory]);
    WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::getTerritory:: territoryList size: '+territoryList.size());
                                                                                        
    for(SVMXC__Territory__c lstTerr: territoryList){
        for(SVMXC__Service_Group_Members__c objTech: lstTech){
            //WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::getTerritory:: Territory name : '+lstTerr.Name+' Tech Territory name '+objTech.SVMXC__Service_Territory__r.Name);
            //WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::getTerritory:: Territory Id : '+lstTerr.Id+' Tech Territory Id '+objTech.SVMXC__Service_Territory__c);
            if(lstTerr.Id==objTech.SVMXC__Service_Territory__c){
                if(objTech.SVMXC__Active__c == true && (objTech.SVMXC__Enable_Scheduling__c == true && objTech.SVMXC__Salesforce_User__c == NULL) || (objTech.SVMXC__Salesforce_User__c != NULL))
                {
                    returnTechList.add(objTech);
                }
            }
        }
    }
    return returnTechList;
    }
    
    //Method returns Optimizer object
    private static SVMXC__SVMX_Optimizer__c getOptimizerObject(string techId, string changeToken,string strJobId) 
    {
        SVMXC__SVMX_Optimizer__c obj = new SVMXC__SVMX_Optimizer__c();
        obj.SVMXC__WhatType__c = 'TECHNICIAN';
        obj.SVMXC__WhatId__c = techId;
        obj.SVMXC__Optimizer_Connection_ID__c=strJobId;
        obj.SVMXC__Optimizer_Change_Token__c = changeToken;
        obj.SVMXC__Optimizer_Status__c = WSCH_ECO_Constants.STATUS_OPT_PENDING;
        return obj;
    }
         //Method to update optimizer object related to Technician is UPDATED. 
    public static void handleTechnicianUpdate(List<SVMXC__Service_Group_Members__c> newTech, List<SVMXC__Service_Group_Members__c> oldTech)
    {
        List<SVMXC__SVMX_Optimizer__c> updateTech = new List<SVMXC__SVMX_Optimizer__c> ();
        List<SVMXC__SVMX_Optimizer__c> updateTechBatch = new List<SVMXC__SVMX_Optimizer__c> ();
        List<SVMXC__Service_Group_Members__c> insertTech = new List<SVMXC__Service_Group_Members__c>();
        
             //Retrieving existing optimizer object associated with the Technician.
        Map<String,SVMXC__SVMX_Optimizer__c> mapIdOptimizer = getTechOptimizers(oldTech);
        WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::handleTechnicianUpdate::mapIdOptimizer size..: '+mapIdOptimizer.size());
    
        //Retrieving existing optimizer object associated with the batch technician
        Map<String,SVMXC__SVMX_Optimizer__c> mapIdOptimizerBatch = getTechOptimizersBatch(newTech);
        
        integer index = 0;
        //for(SVMXC__Service_Group_Members__c objTech : newTech)
        set<String> setTerritoryId = new set<String>();
        String schedulingChangeToken = '';
        Boolean isQualifyAndMark = false;
        String strErrorText = '';
        String strDateTime = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm');
        for(Integer i = 0; i < newTech.size(); i++)
        {
        SVMXC__Service_Group_Members__c oldTechRecord = oldTech.get(i);
        SVMXC__Service_Group_Members__c newTechRecord = newTech.get(i);
        WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::handleTechnicianUpdate::Old Technician SF user: '+oldTechRecord.SVMXC__Salesforce_User__c+'| oldTechRecord.EnableScheduling :'+oldTechRecord.SVMXC__Enable_Scheduling__c+'| oldTechRecord.IsActive :'+oldTechRecord.SVMXC__Active__c);
        WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::handleTechnicianUpdate::New Technician SF user: '+newTechRecord.SVMXC__Salesforce_User__c+'| newTechRecord.EnableScheduling :'+newTechRecord.SVMXC__Enable_Scheduling__c+'| newTechRecord.IsActive :'+newTechRecord.SVMXC__Active__c);
        //checking whether optimizer object already exist, then update
        String strTechId = oldTechRecord.id+'_'+oldTechRecord.Name;
        if(!mapIdOptimizer.isEmpty() && mapIdOptimizer.containsKey(strTechId))
        {
            SVMXC__SVMX_Optimizer__c optimizerObj = mapIdOptimizer.get(strTechId);
            if(newTechRecord.SVMXC__Service_Territory__c != oldTechRecord.SVMXC__Service_Territory__c && newTechRecord.SVMXC__Service_Territory__c != null){
                //inject technician in the new territory job.
                insertTech.add(newTechRecord);
                //Remove the technician from the old territory job.
                schedulingChangeToken = 'CHANGE_REMOVE_TECH';
                isQualifyAndMark = true;
            }else if(oldTechRecord.Name != newTechRecord.Name && newTechRecord.Name != null){
                //Insert new technician with new name                        
                insertTech.add(newTechRecord);
                //remove the existing technician with old name
                schedulingChangeToken = 'CHANGE_REMOVE_TECH';
                isQualifyAndMark = true;
            } else if(oldTechRecord.SVMXC__Active__c != newTechRecord.SVMXC__Active__c && newTechRecord.SVMXC__Active__c == false) {
                schedulingChangeToken = 'CHANGE_REMOVE_TECH';
                isQualifyAndMark = true;
            } else if('OPT_ERROR'.equalsIgnoreCase(optimizerObj.SVMXC__Optimizer_Status__c) && 'CHANGE_CREATE_TECH'.equalsIgnoreCase(optimizerObj.SVMXC__Optimizer_Change_Token__c)){
                schedulingChangeToken = 'CHANGE_CREATE_TECH';
                isQualifyAndMark = true;
            } else if(oldTechRecord.SVMXC__Active__c != newTechRecord.SVMXC__Active__c && newTechRecord.SVMXC__Active__c == true){
                schedulingChangeToken = 'CHANGE_CREATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__Zip__c != oldTechRecord.SVMXC__Zip__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__Working_Hours__c != oldTechRecord.SVMXC__Working_Hours__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__Latitude_Home__c != oldTechRecord.SVMXC__Latitude_Home__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__Longitude_Home__c != oldTechRecord.SVMXC__Longitude_Home__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__City__c != oldTechRecord.SVMXC__City__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__Street__c != oldTechRecord.SVMXC__Street__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__Country__c != oldTechRecord.SVMXC__Country__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__Fixed_Cost__c != oldTechRecord.SVMXC__Fixed_Cost__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__Per_Hour_Cost__c != oldTechRecord.SVMXC__Per_Hour_Cost__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__Per_Mile_Cost__c != oldTechRecord.SVMXC__Per_Mile_Cost__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__Average_Speed__c != oldTechRecord.SVMXC__Average_Speed__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__Max_Hours__c != oldTechRecord.SVMXC__Max_Hours__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__Max_Distance__c != oldTechRecord.SVMXC__Max_Distance__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } else if(newTechRecord.SVMXC__State__c != oldTechRecord.SVMXC__State__c){
                schedulingChangeToken = 'CHANGE_UPDATE_TECH';
                isQualifyAndMark = true;
            } 
            if(isQualifyAndMark){
                WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::handleTechnicianUpdate::schedulingChangeToken: '+schedulingChangeToken);
                strErrorText = strDateTime+' : Syncing the technican changes.';
                updateTech.add(updateOptimizerObject(mapIdOptimizer.get(strTechId), schedulingChangeToken, WSCH_ECO_Constants.STATUS_OPT_PENDING,strErrorText));
            }                    
        } else if(!mapIdOptimizerBatch.isEmpty() && mapIdOptimizerBatch.containsKey(newTechRecord.SVMXC__Service_Territory__c)){
            SVMXC__SVMX_Optimizer__c optimizerBatch = mapIdOptimizerBatch.get(newTechRecord.SVMXC__Service_Territory__c);
            if(setTerritoryId != null && setTerritoryId.contains(optimizerBatch.SVMXC__WhatId__c)){
                continue;
            }
            optimizerBatch.SVMXC__Optimizer_Change_Token__c = 'TRUE';
            updateTechBatch.add(optimizerBatch);
            setTerritoryId.add(optimizerBatch.SVMXC__WhatId__c);
        } 
        else
        {
            // If optimizer object doesn't  exist, then create a new Technician.
            insertTech.add(newTechRecord);
        }
        }
    
        //Updating optimizer object
        if(!updateTech.isEmpty()) {     
            Database.update( updateTech); 
            List<String> lstSVMXOptimizerID = new List<String> ();
            map<String, String> mapOptimizerIdToken = new Map<String, String>();                   
             for(SVMXC__SVMX_Optimizer__c objSVMXOpt : updateTech){
           lstSVMXOptimizerID.add(objSVMXOpt.id);
           if(isSmaxQEnabled)
            mapOptimizerIdToken.put(objSVMXOpt.ID, 'CHANGE_UPDATE_TECH');
        }
        if(isSmaxQEnabled){
           //create optmimizer transaction record for the map of optimizerId & respective scheduling token
           createMaxQTrans(mapOptimizerIdToken);                  
        }else{
           //invoking future call to Delete Technician.
           manageTechnicians(lstSVMXOptimizerID);
        }
        }
    
        if(!insertTech.isEmpty()) {     
            System.debug(logginglevel.warn,'List of SVMX Optimizer object to be created '+insertTech);
        //invoking Insert method to Insert Technician.
            handleTechnicianInsert(insertTech);
        }
        
        if(!updateTechBatch.isEmpty()){
        Database.update(updateTechBatch); 
        }

        WSCH_AuditLogger.finish();
    }
        
    //Method to update Optimizer object when Technicians are deleted.
    public static void handleTechnicianDelete(List<SVMXC__Service_Group_Members__c> lstTechDel)
    {
        List<SVMXC__SVMX_Optimizer__c> deleteTech = new List<SVMXC__SVMX_Optimizer__c> ();
        //Retrieving existing optimizer object associated with the Technicians.
        Map<String,SVMXC__SVMX_Optimizer__c> mapIdOptimizer = getTechOptimizers(lstTechDel);
    
        for(SVMXC__Service_Group_Members__c objTech : lstTechDel)
        {
            WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::handleTechnicianDelete::Delete Technician: '+objTech); 
            String strTechId = objTech.id+'_'+objTech.Name;   
            if(mapIdOptimizer.size() > 0 && mapIdOptimizer.containskey(strTechId)) {
           deleteTech.add(updateOptimizerObject(mapIdOptimizer.get(strTechId), 'CHANGE_REMOVE_TECH',WSCH_ECO_Constants.STATUS_OPT_PENDING,null));
            }
        }
        
        //Updating optimizer object
        if(!deleteTech.isEmpty()) {     
            Database.update( deleteTech); 
            List<String> lstSVMXOptimizerID = new List<String> ();
            map<String, String> mapOptimizerIdToken = new Map<String, String>();                  
            for(SVMXC__SVMX_Optimizer__c objSVMXOpt : deleteTech){
            lstSVMXOptimizerID.add(objSVMXOpt.id);
             if(isSmaxQEnabled)
                mapOptimizerIdToken.put(objSVMXOpt.ID, 'CHANGE_REMOVE_TECH');
        }
            if(isSmaxQEnabled){
            //create optmimizer transaction record for the map of optimizerId & respective scheduling token
             createMaxQTrans(mapOptimizerIdToken);                  
            }else{
                    //invoking future call to Delete Technician.
                    manageTechnicians(lstSVMXOptimizerID);
            }
        }
        WSCH_AuditLogger.finish();
    }
         
    //Get optimizer objects related to Technician.
    private static map<String,SVMXC__SVMX_Optimizer__c> getTechOptimizers(list<SVMXC__Service_Group_Members__c> lstTech)
    { 
        list<String> lstTechID= new list<String> ();           
        list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizerToExisting = new list<SVMXC__SVMX_Optimizer__c> ();
        
        for(SVMXC__Service_Group_Members__c objTech : lstTech){
            lstTechID.add(objTech.id+'_'+objTech.Name);
        }
            lstSVMXOptimizerToExisting = [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__WhatId__c,SVMXC__Optimizer_Connection_ID__c,SVMXC__Optimizer_Status__c,SVMXC__Optimizer_Error_Text__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatId__c in: lstTechID];
        map<String,SVMXC__SVMX_Optimizer__c> mapIdOptimizer = new map<String,SVMXC__SVMX_Optimizer__c>();   
        
        for(SVMXC__SVMX_Optimizer__c objOptimizer : lstSVMXOptimizerToExisting){
                    mapIdOptimizer.put(objOptimizer.SVMXC__WhatId__c,objOptimizer);
        }
        return mapIdOptimizer;
    }
     
    //Get optimizer objects related to Batch Technician.
    private static map<String,SVMXC__SVMX_Optimizer__c> getTechOptimizersBatch(list<SVMXC__Service_Group_Members__c> lstTech)
    { 
        list<String> lstTerritoryID= new list<String> ();           
        list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizerToExisting = new list<SVMXC__SVMX_Optimizer__c> ();
        
        for(SVMXC__Service_Group_Members__c objTech : lstTech){
            if(objTech.SVMXC__Service_Territory__c <> null)
                lstTerritoryID.add(objTech.SVMXC__Service_Territory__c);
        }
        lstSVMXOptimizerToExisting = [Select id, SVMXC__WhatType__c, SVMXC__Optimizer_Change_Token__c,SVMXC__WhatId__c,SVMXC__Optimizer_Connection_ID__c,SVMXC__Optimizer_Status__c,SVMXC__Optimizer_Error_Text__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatType__c = 'BATCH_TECHNICIAN' AND SVMXC__WhatId__c in: lstTerritoryID];
        map<String,SVMXC__SVMX_Optimizer__c> mapIdOptimizerBatch = new map<String,SVMXC__SVMX_Optimizer__c>();   
        for(SVMXC__SVMX_Optimizer__c objOptimizer : lstSVMXOptimizerToExisting){
                    mapIdOptimizerBatch.put(objOptimizer.SVMXC__WhatId__c,objOptimizer);
        }
        return mapIdOptimizerBatch;
    }
    //Update optimizer objects
    private static SVMXC__SVMX_Optimizer__c updateOptimizerObject(SVMXC__SVMX_Optimizer__c objSVMXOptimizer, String changeToken, String status, String strErrorTxt) {
        objSVMXOptimizer.SVMXC__Optimizer_Change_Token__c = changeToken;
        objSVMXOptimizer.SVMXC__Optimizer_Status__c = status; //WSCH_ECO_Constants.STATUS_OPT_PENDING;
        objSVMXOptimizer.SVMXC__Optimizer_Error_Text__c = strErrorTxt;
        return objSVMXOptimizer;
    }
    @future(callout=true)
    public static void manageTechnicians(List<String> objSVMX_OtimizerIds)
    {
          /*Calling Abstract services method */
        try
        {
            WSCH_AuditLogger.debug('WSCH_TechnicianTriggerHandler::manageTechnician():Size of SVMX Optimizer : '+ objSVMX_OtimizerIds);
            list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = WSCH_CommonUtils.fetchSVMXOptimizerById(objSVMX_OtimizerIds);
        WSCH_OptimizedSchedulingService.manageTechnicians(lstSVMXOptimizer);
        }catch(Exception ex)
        {
           WSCH_AuditLogger.error('Exception caught:WSCH_TechnicianTriggerHandler:manageTechnician() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

    public static void createMaxQTrans(Map<String,String> mapOptimizerIdToken){
        list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = new list<SVMXC__SVMX_Optimizer__c>();
        try{
            for (String optimizerId : mapOptimizerIdToken.keySet()) {
            SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
            optimizer.SVMXC__WhatId__c = optimizerId;                   
            optimizer.SVMXC__WhatType__c = 'ECO_TECHNICIAN';
            optimizer.SVMXC__Optimizer_Change_Token__c = mapOptimizerIdToken.get(optimizerId);
            optimizer.SVMXC__Optimizer_Status__c = 'BATCH_QUEUED';
            optimizer.SVMXC__Optimizer_Retry_Count__c = 0;
            lstSVMXOptimizer.add(optimizer);
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSVMXOptimizer, COMM_SecurityUtils.Access.Upsertable)){
            Database.upsert(lstSVMXOptimizer);
            }
        }catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_TechnicianTriggerHandler:createMaxQTrans() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
        
    }   
}