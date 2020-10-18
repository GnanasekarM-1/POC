/*
    Author : Sadiya
    Date : 9/11/2016
    WSCH_ECO_CommonUtils contains generic manupulation methods by fetching data through SOQL Queries
*/
public with sharing class WSCH_ECO_CommonUtils {
    
    public static List<SVMXC__Service_Order__c> fetchWorkOrders(List<String> woIdList){
        String strfld = WSCH_CommonUtils.getWorkorderFields();
        WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils::fetchWorkOrders(), strfld - ' + strfld);
        //String strStatus = WSCH_ECO_Constants.STATUS_OPT_INITIATED;
        if(String.isNotBlank(strfld)){
            String strRelationFields = ', SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone, SVMXC__Site__r.Name, SVMXC__Preferred_Technician__r.SVMXC__Optimizer_External_ID__c, SVMXC__Dispatch_Process__r.SVMXC__Target_URL__c, SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id,SVMXC__Group_Member__r.Id,SVMXC__Group_Member__r.Name,SVMXC__Group_Member__r.SVMXC__Service_Territory__c';
            //return database.query('Select ' + strfld + strRelationFields + ' From SVMXC__Service_Order__c ' + '  where Id =: woIdList OR SVMXC__OptiMax_Status__c=: strStatus');
            return database.query('Select ' + strfld + strRelationFields + ' From SVMXC__Service_Order__c ' + '  where Id =: woIdList');
        }else {
            return [Select Name, Id, SVMXC__Work_Order_Scheduling_Status__c, SVMXC__Service_Group__c, SVMXC__Group_Member__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c, SVMXC__Zip__c, SVMXC__Service_Duration__c, SVMXC__Skill_Set__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Purpose_of_Visit__c, SVMXC__Preferred_Technician__c,SVMXC__Primary_Territory__c,SVMXC__Dispatch_Priority__c,SVMXC__Preferred_Business_Hours__c,SVMXC__Scheduling_Change_Token__c,SVMXC__Acknowledged_By_Technician_Date_Time__c,SVMXC__Started_Driving_To_Location_Date_Time__c,SVMXC__Actual_Onsite_Response__c,SVMXC__Finished_Onsite_Date_Time__c,SVMXC__Completed_Date_Time__c,SVMXC__Scheduling_Retry_Count__c,SVMXC__Dispatch_Process__c,SVMXC__Driving_Time__c,SVMXC__Locked_By_DC__c,SVMXC__OptiMax_Error_Occurred__c,SVMXC__Priority__c,SVMXC__Contact__c,SVMXC__Contact__r.Name,SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone,SVMXC__FirstScheduledDateTime__c,SVMXC__OptiMax_Error_Text__c,SVMXC__OptiMax_Status__c,SVMXC__Service_Contract__c,SVMXC__Product__c,SVMXC__Partner_Account__c,SVMXC__Appointment_Promised_Time_Slot__c,SVMXC__Service_Zone_ID__c, SVMXC__Company__c, SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Site__c, SVMXC__SM_Optimizer_Message_Creation_Date_Time__c,SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id from SVMXC__Service_Order__c where Id in : woIdList];
        }       
    }   

    public static List<SVMXC__Service_Order__c> fetchWorkOrdersByName(List<String> woNameList){
        String strfld = WSCH_CommonUtils.getWorkorderFields();
        WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils::fetchWorkOrdersByName(), strfld - ' + strfld);
        if(String.isNotBlank(strfld)){
            String strRelationFields = ', SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone, SVMXC__Site__r.Name, SVMXC__Preferred_Technician__r.SVMXC__Optimizer_External_ID__c, SVMXC__Dispatch_Process__r.SVMXC__Target_URL__c, SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id,SVMXC__Group_Member__r.Id,SVMXC__Group_Member__r.Name,SVMXC__Group_Member__r.SVMXC__Service_Territory__c';
            return database.query('Select ' + strfld + strRelationFields + ' From SVMXC__Service_Order__c ' + '  where Name =: woNameList');
        }else {
            return [Select Name, Id, SVMXC__Work_Order_Scheduling_Status__c, SVMXC__Service_Group__c, SVMXC__Group_Member__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c, SVMXC__Zip__c, SVMXC__Service_Duration__c, SVMXC__Skill_Set__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Purpose_of_Visit__c, SVMXC__Preferred_Technician__c,SVMXC__Primary_Territory__c,SVMXC__Dispatch_Priority__c,SVMXC__Preferred_Business_Hours__c,SVMXC__Scheduling_Change_Token__c,SVMXC__Acknowledged_By_Technician_Date_Time__c,SVMXC__Started_Driving_To_Location_Date_Time__c,SVMXC__Actual_Onsite_Response__c,SVMXC__Finished_Onsite_Date_Time__c,SVMXC__Completed_Date_Time__c,SVMXC__Scheduling_Retry_Count__c,SVMXC__Dispatch_Process__c,SVMXC__Driving_Time__c,SVMXC__Locked_By_DC__c,SVMXC__OptiMax_Error_Occurred__c,SVMXC__Priority__c,SVMXC__Contact__c,SVMXC__Contact__r.Name,SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone,SVMXC__FirstScheduledDateTime__c,SVMXC__OptiMax_Error_Text__c,SVMXC__OptiMax_Status__c,SVMXC__Service_Contract__c,SVMXC__Product__c,SVMXC__Partner_Account__c,SVMXC__Appointment_Promised_Time_Slot__c,SVMXC__Service_Zone_ID__c, SVMXC__Company__c, SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Site__c, SVMXC__SM_Optimizer_Message_Creation_Date_Time__c,SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id from SVMXC__Service_Order__c where Name in : woNameList];
        }       
    }   
    
    /*
     getOptimizerWhatIds  : Queries and constructs a list of whatIds of the SVMXC__SVMX_Optimizer__c Objects
    */
     public static List<String> getOptimizerWhatIds(List<SVMXC__SVMX_Optimizer__c> optimizers){
         List<String> whatIds = new  List<String>();
        for(SVMXC__SVMX_Optimizer__c opt : optimizers){
            whatIds.add(opt.SVMXC__WhatId__c);
        }
        return whatIds;
    }
    
    /*
     fetchOptimizerWhatTypes  : Queries and constructs a list of whatIds of the SVMXC__SVMX_Optimizer__c Objects
    */
    public static List<String> fetchOptimizerWhatTypes(List<SVMXC__SVMX_Optimizer__c> optimizers){
          WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils : fetchOptimizerWhatTypes :- '+optimizers);
         List<String> WhatTypes = new List<String>();
         List<String> optimizerIDs = new List<String>();
         for(SVMXC__SVMX_Optimizer__c opt :optimizers){optimizerIDs.add(opt.id);}
         List<SVMXC__SVMX_Optimizer__c> opts =[Select Id,SVMXC__WhatType__c from SVMXC__SVMX_Optimizer__c where Id in : optimizerIDs];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
         for(SVMXC__SVMX_Optimizer__c opt : opts ){
             WhatTypes.add(opt.SVMXC__WhatType__c);
         }
         WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils fetchOptimizerWhatTypes :- '+WhatTypes);
         return WhatTypes;
    }
    
        /*
     fetchOptimizerWhatTypes  : Queries and constructs a list of whatIds of the SVMXC__SVMX_Optimizer__c Objects
    */
    public static  Map<String,SVMXC__SVMX_Optimizer__c> getEventIdAndOptimizers(List<SVMXC__SVMX_Optimizer__c> optimizers){
         Map<String,SVMXC__SVMX_Optimizer__c> optimizerMap = new Map<String,SVMXC__SVMX_Optimizer__c>();
         String splitWhatId;
         for(SVMXC__SVMX_Optimizer__c opt :optimizers){
            if(null!= opt.SVMXC__WhatId__c && opt.SVMXC__WhatId__c.contains('_')){
              optimizerMap.put(opt.SVMXC__WhatId__c,opt);
            }/*else{
               optimizerMap.put(opt.SVMXC__WhatId__c,opt);
            }*/
         }
         WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils getEventIdAndOptimizers :- '+optimizerMap);
         return optimizerMap;
    }
    
    /*
     getSFEventWhatIds  : Queries and constructs a list of whatIds of the Event Objects
    */
    public static  List<String> getSFEventWhatIds(List<Event> sfEvents){
         List<String> whatIds = new  List<String>();
        for(Event sfEvent : sfEvents){
            whatIds.add(sfEvent.WhatId);
        }
        WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils getSFEventWhatIds :- '+whatIds);
        return whatIds;
    }
    
    /*
     getSVMXEventWhatIDs  : Queries and constructs a list of whatIds of the SVMXC__SVMX_Event__c Objects
    */
    public static List<String> getSVMXEventWhatIDs(List<SVMXC__SVMX_Event__c> svmxEvents){
         List<String> whatIds = new  List<String>();
        for(SVMXC__SVMX_Event__c sfEvent : svmxEvents){
            whatIds.add(sfEvent.SVMXC__Technician__c);
        }
        WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils getSVMXEventWhatIDs :- '+whatIds);
        return whatIds;
        
    }
    
    
    /*
     getTechnicians  : Queries and constructs a map of Technician Id and Technician Object
    */
    public  static Map<Id,SVMXC__Service_Group_Members__c> getTechnicians(List<String> technicianIds){
        return  new Map<Id,SVMXC__Service_Group_Members__c>(
                    [Select Id,SVMXC__Salesforce_User__c,SVMXC__Service_Territory__c,name, SVMXC__Working_Hours__c, SVMXC__Service_Territory__r.Id, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c From SVMXC__Service_Group_Members__c where Id in : technicianIds]);
    }
    
    
    /*
     getTerritoriesByTechnicians  : Creates a Map of Teritory Id and Territory Object from the technician
    */
    public static Map<Id,SVMXC__Territory__c> getTerritoriesByTechnicians(Map<Id,SVMXC__Service_Group_Members__c> technicians){
        List<String> idsList = new List<String>();
        for(SVMXC__Service_Group_Members__c tech : technicians.values()){
            idsList.add(tech.SVMXC__Service_Territory__c);    
        }
        return new Map<Id,SVMXC__Territory__c>([Select Id,SVMXC__Territory_Code__c From SVMXC__Territory__c where Id in : idsList]);
    }
 
     /*
     getDispatchProcessesByTeritories  : Creates a Map of Teritory Id and Dispatch Process Object from the technician
    */
   public static Map<String,SVMXC__ServiceMax_Processes__c> getDispatchProcessesByTeritories(Map<Id,SVMXC__Territory__c> teritories){
        //Fetch the Dispatch Processes
        List<Id> idList =  new List<Id>(teritories.keySet());
        
        List<SVMXC__ServiceMax_Processes__c> dispatchProcesses = [SELECT Id, SVMXC__Dispatch_Method__c,SVMXC__Territory__c FROM SVMXC__ServiceMax_Processes__c   where  SVMXC__Record_Type_Name__c='Dispatch Process' and SVMXC__Territory__c in : idList]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
         
        //Map the Dispatch Process and teritory
        Map<String,SVMXC__ServiceMax_Processes__c> teritoryAndProcessMap = new  Map<String,SVMXC__ServiceMax_Processes__c>();
        for(SVMXC__ServiceMax_Processes__c dProcess : dispatchProcesses){
            teritoryAndProcessMap.put(dProcess.SVMXC__Territory__c,dProcess);
        }
        
        WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils: teritoryAndProcessMap '+teritoryAndProcessMap);
         
        return teritoryAndProcessMap;
    }   
    
    
     // 03/07/2017 -Sadiya - Method added to fetch the tehcnician ids bu owner id in a list to avoid multiple queries
    public static List<String> fetchSFUsersTechnicianIds(List<String> ownerIds) {
        Map<Id, SVMXC__Service_Group_Members__c> lstObjMap = new Map<Id,SVMXC__Service_Group_Members__c>([Select Name, Id,SVMXC__Optimizer_External_ID__c,SVMXC__Service_Territory__r.Id, SVMXC__Salesforce_User__c, SVMXC__Working_Hours__c  From SVMXC__Service_Group_Members__c WHERE SVMXC__Salesforce_User__c IN :ownerIds]);
        List<String> lstObj = new List<String>();
        if(null!=lstObjMap && lstObjMap.size()>0){
            lstObj = new List<String>((Set<String>)JSON.deserialize(JSON.serialize(lstObjMap.keyset()), Set<String>.class));
        }
        return lstObj;
    }
    
    // method to get the list of ECO technicians ids from SF events 
    public static List<String> getNonWOTechniciansFromSFEvents(List<Event> sfEvents){
    
     List<String> ownerIds = new List<String>();
       for(Event sfevent : sfEvents ){
              WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils getNonWOTechniciansFromSFEvents sfevent' +sfevent);
              ownerIds.add(sfevent.ownerId);  
        }
        
        List<String> technicianIds  = fetchSFUsersTechnicianIds(ownerIds);
        WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils getNonWOTechniciansFromSFEvents technicianIds' +technicianIds);
        return technicianIds;
    }
    
    
    
    //method to get the list of ECO technicians ids from SF events a
    public static List<String> getNonWOTechniciansFromSVMXEvents(List<SVMXC__SVMX_Event__c> svmxEvents){
         //WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils getNonWOTechniciansFromSVMXEvents' +svmxEvents);
         List<String> technicianIds = new List<String>();
         String  woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
         String  techKeyPrefix = Schema.SObjectType.SVMXC__Service_Group_Members__c.getKeyPrefix();
          
        //WSCH_AuditLogger.debug(' WSCH_ECO_CommonUtils woKeyPrefix    ' +woKeyPrefix+'  techKeyPrefix    '+techKeyPrefix);
        
        for(SVMXC__SVMX_Event__c svmxEvent : svmxEvents ){
              //WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils getNonWOTechniciansFromSVMXEvents svmxEvent' +svmxEvent);
              //Multi-resource and Multi-appointment
              //Allow both workorder and non workorder events
              //if(sfevent.SVMXC__WhatId__c == null || !(woKeyPrefix.equals(sfevent.SVMXC__WhatId__c.substring(0,3)))){
              if(svmxEvent.SVMXC__WhatId__c == null || (woKeyPrefix.equals(svmxEvent.SVMXC__WhatId__c.substring(0,3)))){    
                  //WSCH_AuditLogger.debug('This event does not have a work order');
                   if(svmxEvent.SVMXC__Technician__c != null){
                        technicianIds.add(svmxEvent.SVMXC__Technician__c);
                    }   
             }
            
        }
        WSCH_AuditLogger.debug(' WSCH_ECO_CommonUtils getNonWOTechniciansFromSVMXEvents technicianIds' +technicianIds);
         return technicianIds;
    }
    
  
    //method to fetch the jobs for the territories and create a map of territory id  and job
    public static Map<String,SVMXC__SVMX_Jobs__c> getSVMXJobsByTerritories(List<String> territoryIds){
     WSCH_AuditLogger.debug(' WSCH_ECO_CommonUtils getSVMXJobsByTerritories' +territoryIds);
      Map<String,SVMXC__SVMX_Jobs__c> terIdsAndJobsMap = new Map<String,SVMXC__SVMX_Jobs__c>();
      
      list<SVMXC__SVMX_Jobs__c> lstSVMXJobs = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where SVMXC__Territory__c In :territoryIds and SVMXC__Type__c = 'ECO' and SVMXC__OptiMax_Message__c != 'IDLE']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
      
      for(SVMXC__SVMX_Jobs__c svmxJob : lstSVMXJobs){
        if(!terIdsAndJobsMap.containsKey(svmxJob.SVMXC__Territory__c)){
            terIdsAndJobsMap.put(svmxJob.SVMXC__Territory__c,svmxJob);
        }
      }
       WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils getSVMXJobsByTerritories : The Territory Ids and Jobs : - ' +terIdsAndJobsMap);
      return terIdsAndJobsMap;
    }

    public static SVMXC__Territory__c getTerritoryById(String strTerritoryId){
        List<SVMXC__Territory__c> lstObjTerritory = [Select Id, Name,SVMXC__Territory_s_Business_Hours__c, SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey, SVMXC__Break_Hours__c, SVMXC__Average_Driving_Time__c, SVMXC__Per_Mile_Cost__c,
        SVMXC__Max_Distance__c, SVMXC__Average_Speed__c, SVMXC__Fixed_Cost__c, SVMXC__Per_hour_Cost__c, SVMXC__Mode_Of_Travel__c
        from SVMXC__Territory__c where Id = :strTerritoryId];
        if(lstObjTerritory != null && lstObjTerritory.size() > 0){
            return lstObjTerritory[0];
        }
        return null;
    }
    
    public static List<SVMXC__Service_Group_Members__c> getTechniciansByIds(Set<String> lstTechIds){
        List<SVMXC__Service_Group_Members__c> lstTechnicians = [Select Id, Name, SVMXC__Active__c, SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey, SVMXC__Service_Territory__r.SVMXC__Per_Mile_Cost__c,
        SVMXC__Service_Territory__r.SVMXC__Per_Hour_Cost__c, SVMXC__Service_Territory__r.SVMXC__Fixed_Cost__c, SVMXC__Service_Territory__r.SVMXC__Max_Hours__c,
        SVMXC__Service_Territory__r.SVMXC__Average_Speed__c, SVMXC__Service_Territory__r.SVMXC__Max_Daily_Hours__c, SVMXC__Max_Hours__c,
        SVMXC__Service_Territory__r.SVMXC__Max_Distance__c, 
        SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive, SVMXC__Fixed_Cost__c, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c, SVMXC__Per_hour_Cost__c,
        SVMXC__Per_Mile_Cost__c, SVMXC__Average_Speed__c, SVMXC__Max_Daily_Hours__c, SVMXC__Max_Distance__c,
        SVMXC__Working_Hours__c ,SVMXC__Working_Hours__r.TimeZoneSidKey,
        SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c , SVMXC__Break_Hours__c, SVMXC__Enable_Scheduling__c
        from SVMXC__Service_Group_Members__c WHERE Id in:lstTechIds and SVMXC__Active__c = true];
        return lstTechnicians;

    }

    public static List<SVMXC__SVMX_Optimizer__c> getTechnicianOptimizarByWhatIds(List<String> lstWhatId, String strConnectionId){
        List<SVMXC__SVMX_Optimizer__c> technicianOptimizers = [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__WhatId__c,SVMXC__Optimizer_Connection_ID__c,SVMXC__WhatType__c,SVMXC__Optimizer_Status__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatId__c in : lstWhatId AND SVMXC__Optimizer_Connection_ID__c =: strConnectionId AND SVMXC__WhatType__c ='TECHNICIAN' AND SVMXC__Optimizer_Change_Token__c != 'CHANGE_REMOVE_TECH'];
        return technicianOptimizers;
    }

    public static List<SVMXC__SVMX_Optimizer__c> getEventOptimizerByWhatIds(List<String> lstWhatId){
        List<SVMXC__SVMX_Optimizer__c> lstEventOptimizers = [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__WhatId__c,SVMXC__Optimizer_Connection_ID__c,SVMXC__WhatType__c,SVMXC__Optimizer_Status__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatId__c in : lstWhatId AND SVMXC__WhatType__c ='NON_WO_EVENT' AND SVMXC__Optimizer_Change_Token__c != 'CHANGE_DELETE_EVENT'];
        return lstEventOptimizers;
    }

    public static Boolean getIsRTOBatched(){
        String setVal = '';
        Boolean isRTOBatched =false;
        try{
            setVal = WSCH_CommonUtils.getSettingValue('OMAX004','SET008');

            if(String.isNotBlank(setVal)){
                isRTOBatched = Boolean.valueOf(setVal);
            }
            WSCH_AuditLogger.debug('WSCH_ECO_CommonUtils: getIsRTOBatched() ' + isRTOBatched);
        }catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_CommonUtils:WSCH_ECO_CommonUtils() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return isRTOBatched;
    }    
}