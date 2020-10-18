/**
@ Name WSCH_CommonUtils
@ Author Anantha Kumar
@ Description Utility methods to support scheduling business object.
*/
global with sharing class WSCH_CommonUtils {
    
    public static List<Holiday> listOfAllHolidays;
    /** strSetOfUpdateableFields contains only the updateable fields of a Work Order **/
    public static Set<String> strSetOfUpdateableFields = new Set<String>();
    
    public static Map<String,String> globalUtilValMap;
    
    global static String getGlobalUtilValMap(String strKey){
        String returnVal = '';
        try{
            if((globalUtilValMap != null) && (!globalUtilValMap.isEmpty())){
                returnVal = globalUtilValMap.get(strKey);
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_CommonUtils::getGlobalUtilValMap::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return returnVal;
    }
    
    public static void putGlobalUtilValMap(String strKey, String strVal){
        try{
            if(globalUtilValMap == null){
                globalUtilValMap = new Map<String,String>();
            }
            globalUtilValMap.put(strKey,strVal);
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_CommonUtils::putGlobalUtilValMap::Exception caught:'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    static {
        //listOfAllHolidays = [SELECT ActivityDate,IsRecurrence,CreatedDate,EndTimeInMinutes,Id,IsAllDay,Name,StartTimeInMinutes,RecurrenceEndDateOnly,RecurrenceStartDate FROM Holiday];
    }
    
    /* Time Dependency values - client to server mapping */
    public static String getServerTimeDepVal(String strClientTimeDepVal){ 
        
        Map<String, String> mapOfClientToServerTimeDepValues = new Map<String, String>();
        mapOfClientToServerTimeDepValues.put('Start to Finish', 'STARTFINISH'); //changed the map values from startFinish to all CAPS
        mapOfClientToServerTimeDepValues.put('Start to Start', 'STARTSTART');
        mapOfClientToServerTimeDepValues.put('Finish to Finish', 'FINISHFINISH');
        mapOfClientToServerTimeDepValues.put('Finish to Start', 'FINISHSTART');
        mapOfClientToServerTimeDepValues.put('Finish in Unison', 'FINISHUNISON');
        mapOfClientToServerTimeDepValues.put('Start in Unison', 'STARTUNISON');
        
        mapOfClientToServerTimeDepValues.put('Set End Time of Secondary relative to the Arrival Time of Primary', 'STARTFINISH');
        mapOfClientToServerTimeDepValues.put('Set Arrival Time of Secondary relative to the Arrival Time of Primary', 'STARTSTART');
        mapOfClientToServerTimeDepValues.put('Set End Time of Secondary relative to the End Time of Primary', 'FINISHFINISH');
        mapOfClientToServerTimeDepValues.put('Set Arrival Time of Secondary relative to the End Time of Primary', 'FINISHSTART');
        
        return mapOfClientToServerTimeDepValues.get(strClientTimeDepVal);
    }

   global static String getServiceMaxJobStatus(String spDispatchStatus){
        Map<String, String> dispatchStatus = new Map<String, String>();
        dispatchStatus.put('Tentative', 'Tentative');
        dispatchStatus.put('Fixed', 'Fixed');
        dispatchStatus.put('Earmarked', 'Dispatched');
        dispatchStatus.put('Contacted', 'Received');
        dispatchStatus.put('Travelling', 'En Route');
        dispatchStatus.put('LoggedOn', 'Onsite');
        dispatchStatus.put('LoggedOff', 'Finished Onsite');
        dispatchStatus.put('Cleared', 'Completed');
        
        //Service Power new action        
        dispatchStatus.put('planned', 'Tentative');
        dispatchStatus.put('notified', 'Dispatched');
        dispatchStatus.put('acknowledged', 'Received');
        dispatchStatus.put('en_route', 'En Route');
        dispatchStatus.put('on_site', 'Onsite');
        dispatchStatus.put('off_site', 'Finished Onsite');
        dispatchStatus.put('complete', 'Completed');
        
        return dispatchStatus.get(spDispatchStatus);
    }

    global static String getServicePowerJobStatus(String svmxDispatchStatus){
        Map<String, String> dispatchStatus = new Map<String, String>();
        dispatchStatus.put('Tentative', 'Tentative');
        dispatchStatus.put('Fixed', 'Fixed');
        dispatchStatus.put('Dispatched', 'Earmarked'); 
        dispatchStatus.put('Received', 'Contacted');
        dispatchStatus.put('En Route', 'Travelling');
        dispatchStatus.put('Onsite', 'LoggedOn');
        dispatchStatus.put('Finished Onsite', 'LoggedOff');
        dispatchStatus.put('Completed', 'Cleared');
        dispatchStatus.put('Cancelled', 'Canceled');
        
        return dispatchStatus.get(svmxDispatchStatus);
    }
    
    global static String workOrderFields;
    
    public static Map<String, SVMXC__Service_Order__c> getMapOfWorkOrders(Set<String> setOfWOFields, List<SVMXC__Service_Order__c> lstOfWorkOrders) {
        
        Map<String, SVMXC__Service_Order__c> mapOfWorkOrders = new Map<String, SVMXC__Service_Order__c>();
        try{
            for(SVMXC__Service_Order__c eachWO:lstOfWorkOrders) {
                SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
                //Trying to copy the ID first
                workOrder.Id = eachWO.Id;
                for(String eachField:strSetOfUpdateableFields) {
                    //if the field is ID, do not copy the value as it has already been copied above
                    if(!eachField.equalsIgnoreCase('Id')){
                        workOrder.put(eachField, eachWO.get(eachField));
                    } 
                }
                mapOfWorkOrders.put(eachWO.Id, workOrder);
            }
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_CommonUtils :: getMapOfWorkOrders() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            //WSCH_AuditLogger.finish();
        }
        return mapOfWorkOrders;
    }

    global static String getWorkorderFields() {
        if(workOrderFields != null) {
            return workOrderFields;
        }
        String strFlds = 'Id, Name, lastModifiedDate, CreatedDate, SVMXC__Company__c, SVMXC__Apply_Business_Hours_For_OptiMax__c, SVMXC__SM_Appointment_Type__c, SVMXC__Booked_Appointment_Slot__c, SVMXC__Canceled_Date_Time__c, SVMXC__SM_Capacity_Rule_Name__c, SVMXC__Case__c, SVMXC__City__c, SVMXC__Component__c, SVMXC__Contact__c, SVMXC__Country__c, SVMXC__Dependency_Group__c, SVMXC__Dispatch_Priority__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Status__c, SVMXC__Drip__c, SVMXC__Driving_Time__c, SVMXC__First_Assigned_DateTime__c, SVMXC__FirstScheduledDateTime__c, SVMXC__Idle_Time__c, SVMXC__SM_In_Jeopardy__c, SVMXC__Is_PM_Work_Order__c, SVMXC__Latitude__c, SVMXC__SM_Lock_Appointment_Schedule__c, SVMXC__Locked_By_DC__c, SVMXC__Longitude__c, SVMXC__OptiMax_Error_Occurred__c, SVMXC__OptiMax_Error_Text__c, SVMXC__OptiMax_Status__c, SVMXC__SM_Optimizer_Message_Creation_Date_Time__c  , SVMXC__Order_Status__c, SVMXC__Order_Type__c, SVMXC__Partner_Account__c, SVMXC__Partner_Contact__c, SVMXC__Preferred_Business_Hours__c, SVMXC__Preferred_End_Time__c, SVMXC__Preferred_Resource_Priority__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_Technician__c, SVMXC__Primary_Territory__c, SVMXC__Related_Work_Order__c, SVMXC__Priority__c, SVMXC__Product__c, SVMXC__Appointment_Promised_Time_Slot__c, SVMXC__Purpose_of_Visit__c, SVMXC__QTL_Status__c, SVMXC__Qualified_Technicians__c, SVMXC__Schedule_As_A_Dependent_Work_Order__c, SVMXC__Scheduled_Date__c, SVMXC__Scheduled_Date_Time__c, SVMXC__SM_Schedule_Violation_Penalty__c, SVMXC__Scheduling_Change_Token__c, SVMXC__SM_Scheduling_Options__c, SVMXC__Scheduling_Retry_Count__c, SVMXC__Work_Order_Scheduling_Status__c, SVMXC__Service_Contract__c, SVMXC__Service_Duration__c, SVMXC__Service_Group__c, SVMXC__Site__c, SVMXC__Skill__c, SVMXC__Skill_Set__c, SVMXC__SLA_Terms__c, SVMXC__State__c, SVMXC__Street__c, SVMXC__Group_Member__c, SVMXC__Violation_Message__c, SVMXC__Violation_Status2__c, SVMXC__Zip__c';
        

        /*try {
            // Global setting to enable/disable security check. GBL031.
            //String strSecurityChk = WSCH_CommonUtils.getSettingValue('GLOB001','GBL031');
            
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> mapOfFields = gd.get('SVMXC__Service_Order__c').getDescribe().fields.getMap();
            List<String> lstOfKeys = new List<String>(mapOfFields.keySet());
            lstOfKeys.sort();
            for(String key : lstOfKeys)  
            {  
                Schema.DescribeFieldResult fieldResult = mapOfFields.get(key).getDescribe();  
                if(fieldResult.isAccessible())
                //if((fieldResult.isCustom() && fieldResult.isUpdateable()) || ((!fieldResult.isCustom()) && (fieldResult.isAccessible())))
                {  
                    if(strFlds.length() > 0)
                        strFlds += ',';
                    strFlds += fieldResult.getName();
                }
                
                if(fieldResult.isUpdateable()) {
                    strSetOfUpdateableFields.add(fieldResult.getName());
                }
                
            }
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_CommonUtils::getWorkorderFields(): ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n  Stack Trace:: ' + ex.getStackTraceString());
            //WSCH_AuditLogger.finish();
        }*/       
        workOrderFields = strFlds;
        //WSCH_AuditLogger.debug('WSCH_CommonUtils:getWorkorderFields::Work Order fields returned: '+strFlds);
        return strFlds;
    }

    global static List<SVMXC__Service_Order__c> getUpdateableWo(List<SVMXC__Service_Order__c> WoList){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> mapOfFields = gd.get('SVMXC__Service_Order__c').getDescribe().fields.getMap();
        List<String> lstOfKeys = new List<String>(mapOfFields.keySet());
        lstOfKeys.sort();
        List<SVMXC__Service_Order__c> updateableWoList = new List<SVMXC__Service_Order__c>();
        for(SVMXC__Service_Order__c wo: WoList){
            SVMXC__Service_Order__c newWo = new SVMXC__Service_Order__c();
            for(String key : lstOfKeys){
                Schema.DescribeFieldResult fieldResult = mapOfFields.get(key).getDescribe();
                if(fieldResult.isUpdateable()) {
                    newWo.put(key,wo.get(key));
                }
            }
            updateableWoList.add(newWo);
        }  
        return updateableWoList;
    }
    
    
    global static SVMXC__Service_Order__c fetchWorkOrderById(String strWoId){
        String strfld = getWorkorderFields();
        if(String.isNotBlank(strfld)){
            String strRelationFields = ', SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone, SVMXC__Site__r.Name, SVMXC__Preferred_Technician__r.SVMXC__Optimizer_External_ID__c, SVMXC__Dispatch_Process__r.SVMXC__Target_URL__c, SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id, SVMXC__Group_Member__r.Id,SVMXC__Group_Member__r.Name,SVMXC__Product__r.Name,SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Group_Member__r.SVMXC__Service_Territory__c';
            return database.query('Select ' + strfld + strRelationFields + ' From SVMXC__Service_Order__c ' + '  where Id =: strWoId');
        }else {
            return [Select Name, Id, SVMXC__Work_Order_Scheduling_Status__c, SVMXC__Service_Group__c, SVMXC__Group_Member__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c, SVMXC__Zip__c, SVMXC__Service_Duration__c, SVMXC__Skill_Set__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Purpose_of_Visit__c, SVMXC__Preferred_Technician__c,SVMXC__Primary_Territory__c,SVMXC__Dispatch_Priority__c,SVMXC__Preferred_Business_Hours__c,SVMXC__Scheduling_Change_Token__c,SVMXC__Acknowledged_By_Technician_Date_Time__c,SVMXC__Started_Driving_To_Location_Date_Time__c,SVMXC__Actual_Onsite_Response__c,SVMXC__Finished_Onsite_Date_Time__c,SVMXC__Completed_Date_Time__c,SVMXC__Scheduling_Retry_Count__c,SVMXC__Dispatch_Process__c,SVMXC__Driving_Time__c,SVMXC__Locked_By_DC__c,SVMXC__OptiMax_Error_Occurred__c,SVMXC__Priority__c,SVMXC__Contact__c,SVMXC__Contact__r.Name,SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone,SVMXC__FirstScheduledDateTime__c,SVMXC__OptiMax_Error_Text__c,SVMXC__OptiMax_Status__c,SVMXC__Service_Contract__c,SVMXC__Product__c,SVMXC__Partner_Account__c,SVMXC__Appointment_Promised_Time_Slot__c,SVMXC__Service_Zone_ID__c, SVMXC__Company__c, SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Site__c, SVMXC__SM_Optimizer_Message_Creation_Date_Time__c,SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id, SVMXC__Dispatch_Status__c, SVMXC__SM_Schedule_Violation_Penalty__c,SVMXC__Group_Member__r.SVMXC__Service_Territory__c from SVMXC__Service_Order__c where Id = :strWoId];
        }
    }

    global static List<SVMXC__Service_Order__c> fetchWorkOrders(List<String> woIdList){
        String strfld = getWorkorderFields();
        //WSCH_AuditLogger.debug('Inside commonUtils, fetchWorkOrders(), strfld - ' + strfld);
        if(String.isNotBlank(strfld)){
            String strRelationFields = ', SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone, SVMXC__Site__r.Name, SVMXC__Preferred_Technician__r.SVMXC__Optimizer_External_ID__c, SVMXC__Dispatch_Process__r.SVMXC__Target_URL__c, SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id,SVMXC__Group_Member__r.Id,SVMXC__Group_Member__r.Name, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c, SVMXC__Product__r.Name, SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c,SVMXC__Group_Member__r.SVMXC__Service_Territory__c';
            return database.query('Select ' + strfld + strRelationFields + ' From SVMXC__Service_Order__c ' + '  where Id =: woIdList');
        }else {
            return [Select Name, Id, SVMXC__Work_Order_Scheduling_Status__c, SVMXC__Service_Group__c, SVMXC__Group_Member__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Group_Member__r.Id,SVMXC__Group_Member__r.Name, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c, SVMXC__Zip__c, SVMXC__Service_Duration__c, SVMXC__Skill_Set__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Purpose_of_Visit__c, SVMXC__Preferred_Technician__c,SVMXC__Primary_Territory__c, SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Dispatch_Priority__c,SVMXC__Preferred_Business_Hours__c,SVMXC__Scheduling_Change_Token__c,SVMXC__Acknowledged_By_Technician_Date_Time__c,SVMXC__Started_Driving_To_Location_Date_Time__c,SVMXC__Actual_Onsite_Response__c,SVMXC__Finished_Onsite_Date_Time__c,SVMXC__Completed_Date_Time__c,SVMXC__Scheduling_Retry_Count__c,SVMXC__Dispatch_Process__c,SVMXC__Driving_Time__c,SVMXC__Locked_By_DC__c,SVMXC__OptiMax_Error_Occurred__c,SVMXC__Priority__c,SVMXC__Contact__c,SVMXC__Contact__r.Name,SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone,SVMXC__FirstScheduledDateTime__c,SVMXC__OptiMax_Error_Text__c,SVMXC__OptiMax_Status__c,SVMXC__Service_Contract__c,SVMXC__Product__c,SVMXC__Partner_Account__c,SVMXC__Appointment_Promised_Time_Slot__c,SVMXC__Service_Zone_ID__c, SVMXC__Company__c, SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Site__c, SVMXC__SM_Optimizer_Message_Creation_Date_Time__c,SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id, SVMXC__Dispatch_Status__c, SVMXC__SM_Schedule_Violation_Penalty__c,SVMXC__Group_Member__r.SVMXC__Service_Territory__c from SVMXC__Service_Order__c where Id in : woIdList];
        }       
    }
    
    //Added this method to get the WO's by name in order to retry the failed push notifications based on last modified date
    public static List<SVMXC__Service_Order__c> fetchWorkOrdersByName(List<String> woNameList){
        try {
            String strfld = getWorkorderFields();
            //WSCH_AuditLogger.debug('Inside commonUtils, fetchWorkOrders(), strfld - ' + strfld);
            if(String.isNotBlank(strfld)){
                String strRelationFields = ', SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone, SVMXC__Site__r.Name, SVMXC__Preferred_Technician__r.SVMXC__Optimizer_External_ID__c, SVMXC__Dispatch_Process__r.SVMXC__Target_URL__c,SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id, SVMXC__Group_Member__r.Id,SVMXC__Group_Member__r.Name,SVMXC__Product__r.Name,SVMXC__Group_Member__r.SVMXC__Service_Territory__c';
                return database.query('Select ' + strfld + strRelationFields + ' From SVMXC__Service_Order__c ' + '  where Name =: woNameList');
            }else {
                return [Select Name, Id, SVMXC__Work_Order_Scheduling_Status__c, SVMXC__Service_Group__c, SVMXC__Group_Member__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c, SVMXC__Zip__c, SVMXC__Service_Duration__c, SVMXC__Skill_Set__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Purpose_of_Visit__c, SVMXC__Preferred_Technician__c,SVMXC__Primary_Territory__c,SVMXC__Dispatch_Priority__c,SVMXC__Preferred_Business_Hours__c,SVMXC__Scheduling_Change_Token__c,SVMXC__Acknowledged_By_Technician_Date_Time__c,SVMXC__Started_Driving_To_Location_Date_Time__c,SVMXC__Actual_Onsite_Response__c,SVMXC__Finished_Onsite_Date_Time__c,SVMXC__Completed_Date_Time__c,SVMXC__Scheduling_Retry_Count__c,SVMXC__Dispatch_Process__c,SVMXC__Driving_Time__c,SVMXC__Locked_By_DC__c,SVMXC__OptiMax_Error_Occurred__c,SVMXC__Priority__c,SVMXC__Contact__c,SVMXC__Contact__r.Name,SVMXC__Contact__r.FirstName, SVMXC__Contact__r.LastName, SVMXC__Contact__r.Phone, SVMXC__Contact__r.MobilePhone,SVMXC__FirstScheduledDateTime__c,SVMXC__OptiMax_Error_Text__c,SVMXC__OptiMax_Status__c,SVMXC__Service_Contract__c,SVMXC__Product__c,SVMXC__Partner_Account__c,SVMXC__Appointment_Promised_Time_Slot__c,SVMXC__Service_Zone_ID__c, SVMXC__Company__c, SVMXC__Company__r.Id, SVMXC__Company__r.Name, SVMXC__Company__r.AccountNumber, SVMXC__Site__c, SVMXC__SM_Optimizer_Message_Creation_Date_Time__c, LastModifiedDate, SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Preferred_Business_Hours__r.Id, SVMXC__Dispatch_Status__c, SVMXC__SM_Schedule_Violation_Penalty__c, SVMXC__Group_Member__r.SVMXC__Service_Territory__c from SVMXC__Service_Order__c where Name in : woNameList];
            }
        } catch(Exception ex) {
            String exceptionMsg = 'WSCH_CommonUtils::fetchWorkOrdersByName(): ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n  Stack Trace:: ' + ex.getStackTraceString());
            return null;
        }
    }

    global static List<SVMXC__Service_Order__c> fetchRequiredField(List<String> woIdList, String strQuery){
        return database.query('Select ' + strQuery + ' ,Id From SVMXC__Service_Order__c ' + '  where Id =: woIdList');
    }

    global static SVMXC__Service_Order__c fetchRequiredFieldById(String strWoId, String strQuery){
        return database.query('Select ' + strQuery + ' ,Id From SVMXC__Service_Order__c ' + '  where Id =: strWoId');
    }
    
    global static SVMXC__Service_Order__c fetchWorkOrderByName(String strWoName){
        String strfld = getWorkorderFields();
        WSCH_AuditLogger.debug('inside fetchWorkOrderByName() strfld - ' + strfld);
        if(String.isNotBlank(strfld)){
            return database.query('Select ' + strfld + ' From SVMXC__Service_Order__c ' + '  where Name =:strWoName');
        }else {
            return [Select Name, Id, SVMXC__Work_Order_Scheduling_Status__c, SVMXC__Service_Group__c, SVMXC__Group_Member__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c, SVMXC__Zip__c, SVMXC__Service_Duration__c, SVMXC__Skill_Set__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Purpose_of_Visit__c, SVMXC__Preferred_Technician__c,SVMXC__Primary_Territory__c,SVMXC__Dispatch_Priority__c,SVMXC__Preferred_Business_Hours__c,SVMXC__Scheduling_Change_Token__c,SVMXC__Acknowledged_By_Technician_Date_Time__c,SVMXC__Started_Driving_To_Location_Date_Time__c,SVMXC__Actual_Onsite_Response__c,SVMXC__Finished_Onsite_Date_Time__c,SVMXC__Completed_Date_Time__c,SVMXC__Scheduling_Retry_Count__c,SVMXC__Dispatch_Process__c,SVMXC__Driving_Time__c,SVMXC__Locked_By_DC__c,SVMXC__OptiMax_Error_Occurred__c,SVMXC__Priority__c,SVMXC__Contact__c,SVMXC__Contact__r.Name,SVMXC__FirstScheduledDateTime__c,SVMXC__OptiMax_Error_Text__c,SVMXC__OptiMax_Status__c,SVMXC__Service_Contract__c,SVMXC__Product__c,SVMXC__Partner_Account__c,SVMXC__Appointment_Promised_Time_Slot__c,SVMXC__Service_Zone_ID__c, SVMXC__Company__c, SVMXC__Site__c, SVMXC__Dispatch_Status__c, SVMXC__SM_Schedule_Violation_Penalty__c from SVMXC__Service_Order__c where Name =:strWoName];
        }       
    }

    /**
     Following method does the following.

       1. Checks for the configurable setting to identify the field to get the job id.
         2. defaults to the field provided as the parameter if the setting is not found.
           3. Return the value from the fieldName.
    **/
    public static String getWorkItemId(String fieldName,SVMXC__Service_Order__c workOrder) {
    //String configuredFieldName = getSettingValue('DCON004', 'SET00996');
    //Not using settings now, hence to keep the changes one place , hard coded default fieldName to Name.
    String configuredFieldName = 'Name';
        if(String.isNotBlank(configuredFieldName)) {
          return String.valueOf(workOrder.get(configuredFieldName));
        } else {
          return String.valueOf(workOrder.get(fieldName));
        }
    }

    /**
     Following method does the following.

       1. get the configured field name setting. if not available default it to the fieldName parameter.
      2. Query the sObject using the fieldName and fieldValue.
      3. Create a map of the fieldValue to workorder id and return the Map.
    **/
    public static Map<String,String> getWorkItemIds(String fieldName,List<String> fieldValues) {
    //String configuredFieldName = getSettingValue('DCON004', 'SET00996');
    //Not using settings now, hence to keep the changes one place , hard coded default fieldName to Name.
    String configuredFieldName = 'Name';
        if(String.isNotBlank(configuredFieldName)) {
          fieldName = configuredFieldName;
        }
    Map<String,String> fieldNameToId = new Map<String,String>();
    String query = 'SELECT ID,' + fieldName + ' FROM SVMXC__Service_Order__c WHERE ' + fieldName + ' IN :fieldValues';
        if(fieldName.equalsIgnoreCase('ID')) {
          query = 'SELECT ID FROM SVMXC__Service_Order__c WHERE ' + fieldName + ' IN :fieldValues';
        }
    List<SVMXC__Service_Order__c> workOrders = DataBase.query(query);
        for (SVMXC__Service_Order__c workOrder : workOrders){
          fieldNameToId.put(String.valueOf(workOrder.get(fieldName)),workOrder.Id);
        }
    return fieldNameToId;
    }

    global static List<SVMXC__SVMX_Optimizer__c> fetchSVMXOptimizerById(List<String> eventIdList)  {
        return [SELECT ID , SVMXC__WhatId__c, SVMXC__WhatType__c, SVMXC__Optimizer_External_Id__c, SVMXC__Optimizer_Status__c, SVMXC__Optimizer_Error_Text__c, SVMXC__Optimizer_Change_Token__c, SVMXC__Optimizer_Retry_count__c,SVMXC__Optimizer_Connection_ID__c FROM SVMXC__SVMX_Optimizer__c WHERE Id in : eventIdList];
    }

    global static List<SVMXC__SVMX_Optimizer__c> fetchSVMXOptimizerByWhatId (List<String> whatIdList)  {
        return [SELECT ID , SVMXC__WhatId__c, SVMXC__WhatType__c, SVMXC__Optimizer_External_Id__c, SVMXC__Optimizer_Status__c, SVMXC__Optimizer_Error_Text__c, SVMXC__Optimizer_Change_Token__c, SVMXC__Optimizer_Retry_count__c,SVMXC__Optimizer_Connection_ID__c FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__WhatId__c in : whatIdList];
    }

    // need to change global after verify the fix.
    public static SVMXC__SVMX_Optimizer__c fetchSVMXOptimizerByWhatId (String eventId)  {
        return [SELECT ID , SVMXC__WhatId__c, SVMXC__WhatType__c, SVMXC__Optimizer_External_Id__c, SVMXC__Optimizer_Status__c, SVMXC__Optimizer_Error_Text__c, SVMXC__Optimizer_Change_Token__c, SVMXC__Optimizer_Retry_count__c,SVMXC__Optimizer_Connection_ID__c FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__WhatId__c =: eventId];
    }

    global static SVMXC__SVMX_Event__c fetchSVMXEventObjectById(String eventId) {
        //return [Select Name, Id, SVMXC__Technician__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__DurationInMinutes__c, SVMXC__Type__c From SVMXC__SVMX_Event__c WHERE Id = :eventId];
        List<SVMXC__SVMX_Event__c> lstSvmxEvent = [Select Name, Id, SVMXC__Technician__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__DurationInMinutes__c, SVMXC__Type__c,SVMXC__Service_Duration__c, SVMXC__SM_Optimizer_Message_Creation_Date_Time__c From SVMXC__SVMX_Event__c WHERE Id = :eventId];
        if(!lstSvmxEvent.isEmpty()){
            return lstSvmxEvent[0];
        }
        else{
            return null;
        }
    }

    global static SVMXC__SVMX_Event__c fetchSVMXEventObjectById(String eventId, String smaxEventCustomField) {
        List<SVMXC__SVMX_Event__c> lstSvmxEvent = new List<SVMXC__SVMX_Event__c>();
        String sanitizedSmaxEventField = String.escapeSingleQuotes(smaxEventCustomField);
        String strQuery = 'Select Name, Id, SVMXC__Technician__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__DurationInMinutes__c, SVMXC__Type__c,SVMXC__Service_Duration__c ' + sanitizedSmaxEventField + ' From SVMXC__SVMX_Event__c WHERE Id = :eventId';
        lstSvmxEvent = Database.query(strQuery);
        if(!lstSvmxEvent.isEmpty()){
            return lstSvmxEvent[0];
        }
        else{
            return null;
        }
    }

    global static Event fetchSFEventObjectById(String eventId) {
        WSCH_AuditLogger.debug('WSCH_CommonUtils::fetchSFEventObjectById:eventId- '+eventId);
        return WSCH_CRUD_Helper.fetchSFEventObjectById(eventId);
    }

    //TODO: need to remove below 2 methods once Push implemented and dispatch client not required.
    global static List<Event> fetchSFEventByWhatId (Set<String> whatIds) {
        return [Select Id, WhatId, StartDateTime, EndDateTime, OwnerId,SVMXC__Service_Duration__c,SVMXC__Driving_Time__c,SVMXC__SM_Idle_Time__c,SVMXC__SM_Status__c from Event where WhatId In : whatIds];
    }

    global static List<SVMXC__SVMX_Event__c> fetchSVMXEventByWhatId (Set<String> whatIds) {
        return [Select Id, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c,SVMXC__Technician__c,SVMXC__Service_Duration__c,SVMXC__Driving_Time__c,SVMXC__SM_Idle_Time__c,SVMXC__SM_Status__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c In : whatIds];
    }

 
    global static SVMXC__SVMX_Optimizer__c fetchOptimizerByExtId(String extId) {
        List<SVMXC__SVMX_Optimizer__c> lstObj = [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__Optimizer_Status__c, SVMXC__WhatType__c, SVMXC__WhatId__c from SVMXC__SVMX_Optimizer__c  where SVMXC__Optimizer_External_ID__c =: extId];
        if(lstObj != null && lstObj.size() > 0){
            return lstObj[0];
        }
        return null;
    }

    global static SVMXC__Service_Group_Members__c fetchTechnicianById(String techId) {
        return [Select Name, Id,SVMXC__Optimizer_External_ID__c,SVMXC__Service_Territory__r.Id, SVMXC__Salesforce_User__c, SVMXC__Working_Hours__c From SVMXC__Service_Group_Members__c WHERE Id = :techId];
        //return [Select Name, Id,SVMXC__Optimizer_External_ID__c,SVMXC__Service_Territory__r.Id, SVMXC__Salesforce_User__c, SVMXC__Working_Hours__c, SVMXC__Service_Group__c, SVMXC__Service_Group__r.SVMXC__Optimizer_Connection_Name__c From SVMXC__Service_Group_Members__c WHERE Id = :techId];
    }

    global static SVMXC__Service_Group_Members__c fetchSFUserTechnicianId(String ownerId) {
        List<SVMXC__Service_Group_Members__c> lstObj = [Select Name, Id,SVMXC__Optimizer_External_ID__c,SVMXC__Service_Territory__r.Id, SVMXC__Salesforce_User__c, SVMXC__Working_Hours__c  From SVMXC__Service_Group_Members__c WHERE SVMXC__Salesforce_User__c = :ownerId];
        //List<SVMXC__Service_Group_Members__c> lstObj = [Select Name, Id,SVMXC__Optimizer_External_ID__c,SVMXC__Service_Territory__r.Id, SVMXC__Salesforce_User__c, SVMXC__Working_Hours__c, SVMXC__Service_Group__c, SVMXC__Service_Group__r.SVMXC__Optimizer_Connection_Name__c From SVMXC__Service_Group_Members__c WHERE SVMXC__Salesforce_User__c = :ownerId];
        if(lstObj !=null && lstObj.size() > 0){
            return lstObj[0];
        }
        return null;
    }
    
    // 03/07/2017 -Sadiya - Method added to fetch the tehcnician ids bu owner id in a list to avoid multiple queries
    global static List<SVMXC__Service_Group_Members__c> fetchSFUsersTechnicianIds(List<String> ownerIds) {
        List<SVMXC__Service_Group_Members__c> lstObj = [Select Name, Id,SVMXC__Optimizer_External_ID__c,SVMXC__Service_Territory__r.Id, SVMXC__Salesforce_User__c, SVMXC__Working_Hours__c  From SVMXC__Service_Group_Members__c WHERE SVMXC__Salesforce_User__c IN :ownerIds];
        return lstObj;
    }

    /**
        Following method finds territory fru map for work orders..
    */
    global static Map<String, String> getTerritoryFRUMap(List<SVMXC__Service_Order__c> workOrders) {
        Set<String> territories = new Set<String>();
        for(SVMXC__Service_Order__c workOrder:workOrders) {
            territories.add(workOrder.SVMXC__Primary_Territory__c);
        }
        return getTerritoryFRUMap(territories);
    }

    /**
        Following method finds territory fru map for non work orders..
    */
    global static Map<String, String> getTerritoryFRUMap(List<SVMXC__SVMX_Optimizer__c> events) {

        Set<String> territories = new Set<String>();
        for(SVMXC__SVMX_Optimizer__c event : events) {
            if(!event.SVMXC__Optimizer_Change_Token__c.equalsIgnoreCase('CHANGE_DELETE')) {
                SVMXC__Service_Group_Members__c technician = getNonWOEventTechnician (event);
                if(technician != null && technician.SVMXC__Service_Territory__r != null) {
                    territories.add(technician.SVMXC__Service_Territory__r.Id);
                }
            }
        }
        return getTerritoryFRUMap(territories);
    }

    /*
        Retrieves the technician associated with a non wo order event else returns null.
    */
    global static SVMXC__Service_Group_Members__c getNonWOEventTechnician (SVMXC__SVMX_Optimizer__c event) {
        SVMXC__Service_Group_Members__c technician = null;
        if (event != null) {
           if(isSVMXEvent(event)) {
              SVMXC__SVMX_Event__c SVMXEvent = fetchSVMXEventObjectById(event.SVMXC__WhatId__c);
              technician = fetchTechnicianById(SVMXEvent.SVMXC__Technician__c);
            } else if (isSFEvent(event)) {
              Event SFEvent = fetchSFEventObjectById(event.SVMXC__WhatId__c);
              technician = fetchSFUserTechnicianId(SFEvent.OwnerId);
            }
        }
        return technician;
    }

    /**
        Following method finds territory fru map for territories..
    */
    private static Map<String, String> getTerritoryFRUMap(Set<String> territories) {
        Map<String, String> territoryFRUMap = new Map<String, String>();
        List<SVMXC__Territory__c> lstOfTerritory = [SELECT ID, SVMXC__Optimizer_External_ID__c FROM SVMXC__Territory__c WHERE SVMXC__Optimizer_External_ID__c != null AND ID IN :territories];
        for(SVMXC__Territory__c territory:lstOfTerritory) {
            territoryFRUMap.put(territory.ID, territory.SVMXC__Optimizer_External_ID__c);
        }
        return territoryFRUMap;
    }

   /*
        Checks whether a non work order event is a SVMXEvent ?
    */
    global static boolean isSVMXEvent(SVMXC__SVMX_Optimizer__c event) {
        if(Schema.Sobjecttype.SVMXC__SVMX_Event__c.getKeyPrefix() == event.SVMXC__WhatId__c.substring(0,3)){
            return true;
        }
        return false;
    }

    /*
        Checks whether a non work order event is a SFEvent ?
    */
    global static boolean isSFEvent(SVMXC__SVMX_Optimizer__c event) {
        if(Schema.Sobjecttype.Event.getKeyPrefix() == event.SVMXC__WhatId__c.substring(0,3)){
            return true;
        }
        return false;
    }

         /*
      Following method checks whether the syncSchedulers are running ? If any one of them is not running, it starts them.
      There are four schedules to make the scheduler run every 15 mins.
    */
    global static void startSyncScheduler(){
      WSCH_Provider_SP_Scheduler scheduler = new WSCH_Provider_SP_Scheduler();

      //To schedule job at every XX:00 hrs
      if (!isCronJobRunning(WSCH_Constants.WSCH_SYNCSCHEDULER_CRONJOB+'_00')){
        System.schedule(WSCH_Constants.WSCH_SYNCSCHEDULER_CRONJOB+'_00', '0 0 * * * ?', scheduler);
      }

      //To schedule job at every XX:15 hrs
      if (!isCronJobRunning(WSCH_Constants.WSCH_SYNCSCHEDULER_CRONJOB+'_15')){
        System.schedule(WSCH_Constants.WSCH_SYNCSCHEDULER_CRONJOB+'_15', '0 15 * * * ?', scheduler);
      }

      //To schedule job at every XX:30 hrs
      if (!isCronJobRunning(WSCH_Constants.WSCH_SYNCSCHEDULER_CRONJOB+'_30')){
        System.schedule(WSCH_Constants.WSCH_SYNCSCHEDULER_CRONJOB+'_30', '0 30 * * * ?', scheduler);
      }

      //To schedule job at every XX:45 hrs
      if (!isCronJobRunning(WSCH_Constants.WSCH_SYNCSCHEDULER_CRONJOB+'_45')){
        System.schedule(WSCH_Constants.WSCH_SYNCSCHEDULER_CRONJOB+'_45', '0 45 * * * ?', scheduler);
      }
    }

     /*
        Following method checks if the cronjob is running, If yes returns true , else returns false.
    */
    global static boolean isCronJobRunning (String cronJobName) {
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime FROM CronTrigger where CronJobDetail.Name= :cronJobName];
        if(jobs.size() > 0 && jobs[0].state != WSCH_Constants.CRON_JOB_STATE.COMPLETED.name() && jobs[0].state != WSCH_Constants.CRON_JOB_STATE.ERROR.name() && jobs[0].state != WSCH_Constants.CRON_JOB_STATE.DELETED.name()) {
             return true;    // Job already running.
        }
        return false;
    }

    global static String getSettingValue(String subModuleId, String setttingId) {
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::getSettingValue()::started fetching submodule_settingId: ' + subModuleId + '_' + setttingId);
        String settingValue;
        String sanitisedSubModuleId = String.escapeSingleQuotes(subModuleId);
        String sanitisedSetttingId = String.escapeSingleQuotes(setttingId);
        try{
            system.debug('SVMX_Constants.AllsvmxSettingList.keySet() - ' + SVMX_Constants.AllsvmxSettingList.keySet());
            //Check if the setting is already in Trigger Cache
            if(SVMX_Constants.AllsvmxSettingList != NULL || SVMX_Constants.AllsvmxSettingList.size() != 0){
                if(SVMX_Constants.AllsvmxSettingList.containsKey(sanitisedSubModuleId) && SVMX_Constants.AllsvmxSettingList.get(sanitisedSubModuleId) != null) {
                    return SVMX_Constants.AllsvmxSettingList.get(sanitisedSubModuleId).get(sanitisedSetttingId);
                }
            }
            system.debug('Settings not in the Trigger Cache...So look into the RealTime Optimization Cache...');
            //Check if the setting is already in RealTime Optimization Cache
            if(WSCH_Constants.allDMSettings != NULL || WSCH_Constants.allDMSettings.size() != 0){
                if(WSCH_Constants.allDMSettings.containsKey(sanitisedSubModuleId) && WSCH_Constants.allDMSettings.get(sanitisedSubModuleId) != null) {
                    return WSCH_Constants.allDMSettings.get(sanitisedSubModuleId).get(sanitisedSetttingId);
                }
            }
            system.debug('Settings not in the RealTime Optimization Cache...So started Caching for further use..');
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            //throw exception here when submoduleId not add in the Set.
            if(!WSCH_Constants.subModules.contains(sanitisedSubModuleId)){
                WSCH_Constants.subModules.add(sanitisedSubModuleId);
            }

            List<string> subModules = new List<string>(WSCH_Constants.subModules);
            WSCH_Constants.allDMSettings = commSettings.SVMX_getSettingList(subModules);

            if(WSCH_Constants.allDMSettings.containsKey(sanitisedSubModuleId) && WSCH_Constants.allDMSettings.get(sanitisedSubModuleId) != null) {
                settingValue=WSCH_Constants.allDMSettings.get(sanitisedSubModuleId).get(sanitisedSetttingId);
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_CommonUtils:getSettingValue() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            //WSCH_AuditLogger.finish();
        }
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::getSettingValue()::ended fetching submodule_settingId: ' + sanitisedSubModuleId + '_' + sanitisedSetttingId + ' No of Queries used in this transaction so far: ' + Limits.getQueries());
        return settingValue;
    }

    global static String getDispatchProcessIdByName(String dispatchProcessName) {
        String dispatchProcessId;
        try{
            List<SVMXC__ServiceMax_Processes__c> svmxProcessObj = [SELECT Id,Name,SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c =: dispatchProcessName limit 1];
            if(!svmxProcessObj.isEmpty())
                dispatchProcessId=svmxProcessObj[0].Id;
        }catch(Exception ex){
           WSCH_AuditLogger.error('Exception caught:WSCH_CommonUtils:getDispatchProcessIdByName() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            //WSCH_AuditLogger.finish();
        }
        return dispatchProcessId;
    }

    global static String fetchTerritoryIdByExternalId(String ExternalId){
        String territoryId;
        try{
            SVMXC__Territory__c territoryObj = [SELECT ID, SVMXC__Optimizer_External_ID__c FROM SVMXC__Territory__c WHERE SVMXC__Optimizer_External_ID__c =:ExternalId limit 1];
            territoryId=territoryObj.Id;
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_CommonUtils:fetchTerritoryIdByExternalId() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            //WSCH_AuditLogger.finish();
        }
        return territoryId;
    }

    global static String fetchExternalIdByTerritoryId(String TerritoryId){
        String externalId;
        try{
            SVMXC__Territory__c territoryObj = [SELECT ID, SVMXC__Optimizer_External_ID__c FROM SVMXC__Territory__c WHERE ID =:TerritoryId limit 1];
            externalId=territoryObj.SVMXC__Optimizer_External_ID__c;
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_CommonUtils:fetchExternalIdByTerritoryId() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            //WSCH_AuditLogger.finish();
        }
        return externalId;
    }
        /**
        Following method validate if the event is valid or not.
    **/
    global static boolean isEventValid(SVMXC__SVMX_Optimizer__c event){
        if(event.SVMXC__Optimizer_Change_Token__c.equalsIgnoreCase('CHANGE_DELETE')) {
            return true;
        }
        boolean isEventValid = false;
        if(event.SVMXC__WhatId__c != null && Schema.SObjectType.Service_Order__c.getKeyPrefix() != event.SVMXC__WhatId__c.substring(0,3)){

            SVMXC__Service_Group_Members__c technician = WSCH_CommonUtils.getNonWOEventTechnician(event);
            if(technician != null && technician.SVMXC__Optimizer_External_ID__c != null){
                isEventValid = true;
            }
        }
        return isEventValid;
    }

    /**
        Following method decides , whether the new status should be updated or not and acorrdingly resolves it.
        ? A work order status will be updated to OPT_COMPLETED, if and only if the WO status is in ?OPT_PENDING? or ?OPT_TENTATIVE?.
        ? A work order status will be updated to OPT_ERROR, if and only if the WO status is in ?OPT_PENDING? or ?OPT_TENTATIVE?.
    **/
    global static String resolveOptimaxStatus(String oldStatus, String newStatus) {
        String resolvedStatus = newStatus;
        if (newStatus.equalsIgnoreCase(WSCH_Constants.STATUS_OPT_COMPLETED) || newStatus.equalsIgnoreCase(WSCH_Constants.STATUS_OPT_ERROR)){

            if (!(oldStatus.equalsIgnoreCase(WSCH_Constants.STATUS_OPT_TENTATIVE) || oldStatus.equalsIgnoreCase(WSCH_Constants.STATUS_OPT_PENDING))) {
                return oldStatus;
            }
        }
        return resolvedStatus;
    }

    /** Method to create map containing dispatch processes whose dispatch method is Linx for ServicePower **/
    global static Map<Id,SVMXC__ServiceMax_Processes__c> getContinuousDP() {
        Map<Id,SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new Map<Id,SVMXC__ServiceMax_Processes__c>();
         mapSVMXProcess.putAll([SELECT Id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Dispatch Process' and SVMXC__Dispatch_Process_Status__c = 'Complete'
        and SVMXC__Dispatch_Method__c ='Linx for ServicePower' order by SVMXC__Sequence__c]);
        return mapSVMXProcess;
    }

    /** Method to create map containing dispatch processes whose dispatch method is Linx for ServicePower **/
    global static Map<Id,SVMXC__ServiceMax_Processes__c> getEcoDP() {
        Map<Id,SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new Map<Id,SVMXC__ServiceMax_Processes__c>();
        mapSVMXProcess.putAll([SELECT Id, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Dispatch_Method__c, SVMXC__Frequency__c, SVMXC__Full_Run_Unit__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Dispatch Process' and SVMXC__Dispatch_Process_Status__c = 'Complete'
        and SVMXC__Dispatch_Method__c ='Real Time Optimization' order by SVMXC__Sequence__c]);
        return mapSVMXProcess;
    }
    
    /** Method to create map containing dispatch processes whose dispatch method is Optimized Batch **/
    global static Map<Id,SVMXC__ServiceMax_Processes__c> getOptimizedBatchDP() {
        Map<Id,SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new Map<Id,SVMXC__ServiceMax_Processes__c>();
        mapSVMXProcess.putAll([SELECT Id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Dispatch Process' and SVMXC__Dispatch_Process_Status__c = 'Complete'
        and SVMXC__Dispatch_Method__c ='Optimized Batch' order by SVMXC__Sequence__c]);
        return mapSVMXProcess;
    }

   /** Method to check the Optimization is enabled and Optimizer is ServicePower **/
    global static boolean isOptimizerEnabled() {
        Boolean spEnabled=false;
        String settingsGBL007 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL007');
        String settingsGBL022 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL022');
        if(settingsGBL007 != null && settingsGBL007.touppercase() == 'TRUE') {
            Set<String> providersSet = new Set<String>();
            if(settingsGBL022 != null ) {
                for(String StrProvider : settingsGBL022.split(',')){
                    providersSet.add(StrProvider.touppercase());
                }
                if((providersSet.contains('SERVICEPOWER') || providersSet.contains('SERVICE POWER'))) {
                    spEnabled= true;
                }
            }
        }
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::isOptimizerEnabled():: ServicePower Enabled : ' +spEnabled);
        return spEnabled;
    }

    global static void setOptimizerErrorText(SVMXC__Service_Order__c workOrder, String errorText){
        //to get the maximum length of the field
        Integer maxLength = SObjectType.SVMXC__Service_Order__c.Fields.SVMXC__OptiMax_Error_Text__c.Length;
        String errorTextAppend=null;
        if(workOrder.SVMXC__OptiMax_Error_Text__c != null) {
            errorTextAppend = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm') + ' - ' + errorText + '\n' + workOrder.SVMXC__OptiMax_Error_Text__c;
        } else {
            errorTextAppend = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm') + ' - ' + errorText + '\n';
        }
        if(errorTextAppend.length() > maxLength){
            errorTextAppend = errorTextAppend.substring(0, maxLength);
        }
        workOrder.SVMXC__OptiMax_Error_Text__c = errorTextAppend;
    }
    
    global static void setOptimizerErrorText(SVMXC__Service_Order_Dependency__c serviceOrder, String errorText){
        //to get the maximum length of the field
        /* [BVL]
        Integer maxLength = SObjectType.SVMXC__Service_Order_Dependency__c.Fields.SVMXC__OptiMax_Error_Text__c.Length;
        String errorTextAppend=null;
        
        if(serviceOrder.SVMXC__OptiMax_Error_Text__c != null) {
            errorTextAppend = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm') + ' - ' + errorText + '\n' + serviceOrder.SVMXC__OptiMax_Error_Text__c;
        } else {
            errorTextAppend = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm') + ' - ' + errorText + '\n';
        }
        if(errorTextAppend.length() > maxLength){
            errorTextAppend = errorTextAppend.substring(0, maxLength);
        }
        serviceOrder.SVMXC__OptiMax_Error_Text__c = errorTextAppend;
        */
    }

    global static void setOptimizerErrorText(SVMXC__Dependency_Management__c depManagement, String errorText){
        //to get the maximum length of the field
            Integer maxLength = SObjectType.SVMXC__Dependency_Management__c.Fields.SVMXC__Error_Text__c.Length;
            String errorTextAppend=null;
            if(depManagement.SVMXC__Error_Text__c != null) {
                errorTextAppend = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm') + ' - ' + errorText + '\n' + depManagement.SVMXC__Error_Text__c;
             } else {
                errorTextAppend = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm') + ' - ' + errorText + '\n';
            }
            if(errorTextAppend.length() > maxLength){
                errorTextAppend = errorTextAppend.substring(0, maxLength);
            }
            depManagement.SVMXC__Error_Text__c = errorTextAppend;
    }
    global static List<Service_Order_Dependency__c> fetchGroupDependency(String groupDependencyId){
        List<Service_Order_Dependency__c> serviceOrderList = new List<Service_Order_Dependency__c>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Service_Order_Dependency__c.fields.getMap();
        String serviceOrderFields;
        for(String s : fieldMap.keySet()) {
            if(serviceOrderFields == null){
                serviceOrderFields = s + ',';
            }
            else{
                serviceOrderFields += s + ',';
            }
        }
        serviceOrderFields =serviceOrderFields + ' SVMXC__Primary_Work_Order__r.Name, SVMXC__Secondary_Work_Order__r.Name';
        String queryString;
        queryString = 'SELECT '+serviceOrderFields+' From Service_Order_Dependency__c where SVMXC__Dependency_Group__c =: '+ 'groupDependencyId';
        serviceOrderList = Database.query(queryString);
        return serviceOrderList;
    }


    global static map<Id, SVMXC__ServiceMax_Processes__c> fetchRules(String ruleType, String srcName){
        map<Id, SVMXC__ServiceMax_Processes__c> rulesMap = new map<Id, SVMXC__ServiceMax_Processes__c>();
        rulesMap.putAll([SELECT Name, SVMXC__ProcessID__c, SVMXC__Sequence__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Advance_Expression__c, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Primary_Consolidation_Rule__c, SVMXC__Field_Name__c, SVMXC__Child_Object_Criteria__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Active__c, Id, RecordType.Name from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c =:ruleType and SVMXC__Source_Object_Name__c=:srcName and SVMXC__Active__c=:true order by SVMXC__Sequence__c]);
        WSCH_AuditLogger.debug('WSCH_CommonUtils::fetchRules()::Count of ServiceMax Process records for all the valid rules "'+ruleType+'": ' + rulesMap.size()); //+ '; Records: ' + rulesMap);
        return rulesMap;
    }

    /*
        Following method will delete the WO Events , when a work order will be canceled.
     */
    global static void deleteWORelatedEventsOnCancel (Set<SVMXC__Service_Order__c> workOrders) {

        List<String> cancelWoList = new List<String>();
        List<SVMXC__Service_Order__c> cancelAndUpdateOldDependencyWOs = new List<SVMXC__Service_Order__c>();
        for(SVMXC__Service_Order__c workOrder : workOrders) {
            if(workOrder.SVMXC__Scheduling_Change_Token__c != NULL && workOrder.SVMXC__Scheduling_Change_Token__c.equalsIgnoreCase('CHANGE_CANCEL_WO')) {
                if(workOrder.SVMXC__Group_Member__c != NULL){
                    workOrder.SVMXC__Last_Dispatch_Event__c = 'UnAssigned';
                }
                if(workOrder.SVMXC__Group_Member__c == NULL && workOrder.SVMXC__Service_Group__c != NULL){
                    workOrder.SVMXC__Last_Dispatch_Event__c = 'UnQueued';
                }
                workOrder.SVMXC__Service_Group__c = NULL;
                workOrder.SVMXC__Group_Member__c = NULL;
                workOrder.SVMXC__Scheduled_Date_Time__c = NULL;
                workOrder.SVMXC__Scheduled_Date__c = NULL;
                workOrder.SVMXC__Work_Order_Scheduling_Status__c = 'Cancelled';
                workOrder.SVMXC__Appointment_Promised_Time_Slot__c = null;
                cancelWoList.add(workOrder.Id);
                cancelAndUpdateOldDependencyWOs.add(workOrder);
            }
        }
        WSCH_AuditLogger.debug('WSCH_CommonUtils:deleteWORelatedEventsOnCancel:cancelWoList ' + cancelWoList);
        if (cancelWoList.size() > 0){
            List<Event> SalesforceEventList = new List<Event>();
            SalesforceEventList = [SELECT Id from Event where WhatId IN :cancelWoList];
            WSCH_AuditLogger.debug('WSCH_CommonUtils:deleteWORelatedEventsOnCancel:SalesforceEventList ' + SalesforceEventList);
            List<SVMXC__SVMX_Event__c> ServiceMaxEventList = new List<SVMXC__SVMX_Event__c>();
            ServiceMaxEventList = [SELECT Id from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :cancelWoList];
            WSCH_AuditLogger.debug('WSCH_CommonUtils:deleteWORelatedEventsOnCancel:ServiceMaxEventList ' + ServiceMaxEventList);
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
            //if(SalesforceEventList.size()>0)delete SalesforceEventList;
            //if(ServiceMaxEventList.size()>0)delete ServiceMaxEventList;
            if(SalesforceEventList.size()>0)WSCH_CRUD_Helper.deleteListEvents(SalesforceEventList);
            if(ServiceMaxEventList.size()>0)WSCH_CRUD_Helper.deleteListEvents(ServiceMaxEventList);
        }
    }
    
    
    /*
        This method takes a Full Day Holiday Date and returns the start and end date range for closedAccHrs overrides      
    */
    public static WSCH_Provider_SP_StubsV91.DateAndTimeRange getDateTimeRangeForAllDayHoliday(Date holidayDate, BusinessHours businessHr, Integer tzOffSetinMinutes) {
        
        WSCH_AuditLogger.debug('WSCH_CommonUtils:: getDateTimeRangeForAllDayHoliday() - start');
        
        String strSPDateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm';
        
        WSCH_Provider_SP_StubsV91.DateAndTimeRange dateAndTimeRange = new WSCH_Provider_SP_StubsV91.DateAndTimeRange();
        
        DateTime holidayStartDateTime = DateTime.newInstanceGmt(holidayDate, Time.newInstance(0,0,0,0));
        DateTime holidayEndDateTime = DateTime.newInstanceGmt(holidayDate, Time.newInstance(23,59,0,0));
        
        WSCH_AuditLogger.debug('holidayStartDateTime - ' + holidayStartDateTime);
        WSCH_AuditLogger.debug('holidayEndDateTime - ' + holidayEndDateTime);
        
        String strSPStartDateTime,strSPEndDateTime;
        
        if(tzOffsetinMinutes == null || tzOffSetinMinutes == -1 || tzOffSetinMinutes == 1) {
            
            DateTime startDateTime = WSCH_DateUtils.doTZConversion(holidayStartDateTime, businessHr.TimeZoneSidKey, 'GMT');
            strSPStartDateTime = startDateTime.formatGmt(strSPDateTimeFormat);
            
            DateTime endDateTime = WSCH_DateUtils.doTZConversion(holidayEndDateTime, businessHr.TimeZoneSidKey, 'GMT');
            strSPEndDateTime = endDateTime.formatGmt(strSPDateTimeFormat);
            
        } else {
            
            DateTime startDateTime = WSCH_DateUtils.doTZConversion(holidayStartDateTime, businessHr.TimeZoneSidKey, 'GMT', tzOffSetinMinutes);
            strSPStartDateTime = startDateTime.formatGmt(strSPDateTimeFormat);
            
            DateTime endDateTime = WSCH_DateUtils.doTZConversion(holidayEndDateTime, businessHr.TimeZoneSidKey, 'GMT', tzOffSetinMinutes);
            strSPEndDateTime = endDateTime.formatGmt(strSPDateTimeFormat);
        }
        
        WSCH_AuditLogger.debug('strSPStartDateTime - ' + strSPStartDateTime);
        WSCH_AuditLogger.debug('strSPEndDateTime - ' + strSPEndDateTime);
        
        dateAndTimeRange.start = strSPStartDateTime;
        dateAndTimeRange.end_x = strSPEndDateTime;
        
        WSCH_AuditLogger.debug('WSCH_CommonUtils:: getDateTimeRangeForAllDayHoliday() - end');
        
        return dateAndTimeRange;
    }
    
    /*
        This method takes a Part Day Holiday Date and returns the start and end date range for closedAccHrs overrides      
    */
    public static WSCH_Provider_SP_StubsV91.DateAndTimeRange getDateTimeRangeForPartDayHoliday(Date holidayDate, Integer startTimeMins, Integer endTimeMins, BusinessHours businessHr, Integer tzOffSetinMinutes) {
        
        WSCH_AuditLogger.debug('WSCH_CommonUtils:: getDateTimeRangeForPartDayHoliday() - start');
        
        String strSPDateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm';
        
        WSCH_Provider_SP_StubsV91.DateAndTimeRange dateAndTimeRange = new WSCH_Provider_SP_StubsV91.DateAndTimeRange();
        
        Double startTimeMinDouble = (Double)startTimeMins/60;
        //WSCH_AuditLogger.debug('startTimeMinDouble - ' + startTimeMinDouble);
        String[] strStartTime = String.valueOf(startTimeMinDouble).split('\\.',2);
        Integer intStartHour = Integer.valueOf(strStartTime[0]);
        Integer intStartMin = Math.mod(startTimeMins, 60);
        /*if(strStartTime[1].length() == 1) {
            intStartMin = Integer.valueOf(Integer.valueOf(strStartTime[1])*0.1*60); //to handle 10th, 20th 30th and so on mins
        } else if(strStartTime[1].length() == 2) {
            intStartMin = Integer.valueOf(Integer.valueOf(strStartTime[1])*0.01*60); //to handle 15th, 45th and so on mins
        }*/
        //WSCH_AuditLogger.debug('strStartTime-' + strStartTime);
        //WSCH_AuditLogger.debug('intStartHour-' + intStartHour);
        //WSCH_AuditLogger.debug('intStartMin-' + intStartMin);
        
        DateTime holidayStartDateTime = DateTime.newInstanceGmt(holidayDate, Time.newInstance(intStartHour,intStartMin,0,0));
        //WSCH_AuditLogger.debug('holidayStartDateTime - ' + holidayStartDateTime);
        
        String strSPStartDateTime, strSPEndDateTime;
        if(tzOffsetinMinutes == null || tzOffSetinMinutes == -1 || tzOffSetinMinutes == 1) {
            //strSPStartDateTime = WSCH_DateUtils.formatDateTime(holidayStartDateTime, businessHr.TimeZoneSidKey, strSPDateTimeFormat);
            
            DateTime startDateTime = WSCH_DateUtils.doTZConversion(holidayStartDateTime, businessHr.TimeZoneSidKey, 'GMT');
            strSPStartDateTime = startDateTime.formatGmt(strSPDateTimeFormat);
        } else {
            //strSPStartDateTime = holidayStartDateTime.addMinutes(tzOffSetinMinutes).formatGmt(strSPDateTimeFormat);
            
            DateTime startDateTime = WSCH_DateUtils.doTZConversion(holidayStartDateTime, businessHr.TimeZoneSidKey, 'GMT', tzOffSetinMinutes);
            strSPStartDateTime = startDateTime.formatGmt(strSPDateTimeFormat);
        }
        
        WSCH_AuditLogger.debug('strSPStartDateTime - ' + strSPStartDateTime);
            
        Double endTimeMinDouble = (Double)endTimeMins/60;
        //WSCH_AuditLogger.debug('endTimeMinDouble - ' + endTimeMinDouble);
        String[] strEndTime = String.valueOf(endTimeMinDouble).split('\\.',2);              
        Integer intEndHour = Integer.valueOf(strEndTime[0]);
        Integer intEndMin = Math.mod(endTimeMins, 60);
        /*if(strEndTime[1].length() == 1) {
            intEndMin = Integer.valueOf(Integer.valueOf(strEndTime[1])*0.1*60);
        } else if(strEndTime[1].length() == 2) {
            intEndMin = Integer.valueOf(Integer.valueOf(strEndTime[1])*0.01*60);
        }*/
        //WSCH_AuditLogger.debug('strEndTime-' + strEndTime);
        //WSCH_AuditLogger.debug('intEndHour-' + intEndHour);
        //WSCH_AuditLogger.debug('intEndMin-' + intEndMin);
        
        DateTime holidayEndDateTime = DateTime.newInstanceGmt(holidayDate, Time.newInstance(intEndHour,intEndMin,0,0));
        //WSCH_AuditLogger.debug('holidayEndDateTime - ' + holidayEndDateTime);
        
        if(tzOffsetinMinutes == null || tzOffSetinMinutes == -1 || tzOffSetinMinutes == 1) {
            //strSPEndDateTime = WSCH_DateUtils.formatDateTime(holidayEndDateTime, businessHr.TimeZoneSidKey, strSPDateTimeFormat);
            
            DateTime endDateTime = WSCH_DateUtils.doTZConversion(holidayEndDateTime, businessHr.TimeZoneSidKey, 'GMT');
            strSPEndDateTime = endDateTime.formatGmt(strSPDateTimeFormat);
        } else {
            //strSPEndDateTime = holidayEndDateTime.addMinutes(tzOffSetinMinutes).formatGmt(strSPDateTimeFormat);
            
            DateTime endDateTime = WSCH_DateUtils.doTZConversion(holidayEndDateTime, businessHr.TimeZoneSidKey, 'GMT', tzOffSetinMinutes);
            strSPEndDateTime = endDateTime.formatGmt(strSPDateTimeFormat);
        }
        
        WSCH_AuditLogger.debug('strSPEndDateTime - ' + strSPEndDateTime);
        
        dateAndTimeRange.start = strSPStartDateTime;
        dateAndTimeRange.end_x = strSPEndDateTime;
        
        WSCH_AuditLogger.debug('WSCH_CommonUtils:: getDateTimeRangeForPartDayHoliday() - end');
        
        return dateAndTimeRange;
    }
    
    
    /*
    *   This method returns all the ClosedHours for a list of Holidays belonging to a particular 
    *   BusinessHours within a given start and end date range
    */
    global static List<WSCH_Provider_SP_StubsV91.DateAndTimeRange> getClosedHoursForHolidays(Date startDate, Date endDate, BusinessHours businessHr, Integer tzOffsetinMinutes, List<Holiday> lstHoliday) {
        return null;
    }
    
    /**
    *   Below logic is constructing the start and end dates using the business hour start time and end time for that day
    *   and returns the List containing businessHour startDateTime and endDateTime
    **/
    public static List<DateTime> getBHStartEndDateTime(Date dateObj, BusinessHours bussHour) {
        
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::getBHStartEndDateTime() - start');
        DateTime eachDateTime = DateTime.newInstanceGmt(dateObj,Time.newInstance(0,0,0,0));
        //DateTime eachDateTime = DateTime.newInstance(dateObj,Time.newInstance(0,0,0,0));
        //WSCH_AuditLogger.debug(' eachDateTime - ' + eachDateTime);
        String strDay = eachDateTime.formatGmt('EEEE');
        
        //WSCH_AuditLogger.debug(' day - ' + strDay);
        
        Map<String, String> dayTimesMap = new Map<String, String>();
        dayTimesMap.put('Monday',bussHour.MondayStartTime +'-'+bussHour.MondayEndTime);
        dayTimesMap.put('Tuesday',bussHour.TuesdayStartTime+'-'+bussHour.TuesdayEndTime);
        dayTimesMap.put('Wednesday',bussHour.WednesdayStartTime+'-'+bussHour.WednesdayEndTime);
        dayTimesMap.put('Thursday',bussHour.ThursdayStartTime+'-'+bussHour.ThursdayEndTime);
        dayTimesMap.put('Friday',bussHour.FridayStartTime+'-'+bussHour.FridayEndTime);
        dayTimesMap.put('Saturday',bussHour.SaturdayStartTime+'-'+bussHour.SaturdayEndTime);
        dayTimesMap.put('Sunday',bussHour.SundayStartTime+'-'+bussHour.SundayEndTime);
        
        //WSCH_AuditLogger.debug('dayTimesMap - ' + dayTimesMap);
        
        String[] startTimeSplit, endTimeSplit;
        String strStartTime, strEndTime;
        DateTime bhStartDateTime, bhEndDateTime;
        List<DateTime> lstOfBhDateTime = new List<DateTime>();
        
        //form the datetime object using start and end times for that particular day
        if(dayTimesMap != null && dayTimesMap.containsKey(strDay.trim())) {
            startTimeSplit = dayTimesMap.get(strDay.trim()).split('-')[0].split(':');
            //WSCH_AuditLogger.debug('startTimeSplit-' + startTimeSplit);
            if(startTimeSplit != null && startTimeSplit.size() >= 2) {
                strStartTime = startTimeSplit[0] + ':' + startTimeSplit[1];
                //WSCH_AuditLogger.debug('strStartTime-' + strStartTime);
                
                bhStartDateTime = DateTime.newInstanceGmt(dateObj, Time.newInstance(Integer.valueOf(startTimeSplit[0]), Integer.valueOf(startTimeSplit[1]), 0, 0));
                lstOfBhDateTime.add(bhStartDateTime);
            }
            
            endTimeSplit = dayTimesMap.get(strDay.trim()).split('-')[1].split(':');
            //WSCH_AuditLogger.debug('endTimeSplit-' + endTimeSplit);
            if(endTimeSplit != null && endTimeSplit.size() >= 2) {
                strEndTime = endTimeSplit[0] + ':' + endTimeSplit[1];
                //WSCH_AuditLogger.debug('strEndTime-' + strEndTime);
                
                bhEndDateTime = DateTime.newInstanceGmt(dateObj, Time.newInstance(Integer.valueOf(endTimeSplit[0]), Integer.valueOf(endTimeSplit[1])-1, 0, 0));
                lstOfBhDateTime.add(bhEndDateTime);
            }
        }
        //WSCH_AuditLogger.debug('lstOfBhDateTime - ' + lstOfBhDateTime);
        return lstOfBhDateTime;
    }
    
    public static List<Date> getLstOfDatesBetween(Date startDate, Date endDate) {
        
        //WSCH_AuditLogger.debug('WSCH_CommonUtils:: getLstOfDatesBetween() - start');
        
        List<Date> lstDate = new List<Date>();
        for(Date dt = startDate; dt <= endDate; dt = dt.addDays(1)) { 
            lstDate.add(dt);
        }
        WSCH_AuditLogger.debug(' lstDate - ' + lstDate);
        return lstDate;
    }
    
    public static List<WSCH_Provider_SP_StubsV91.DateAndTimeRange> getClosedHours(Date startDate, Date endDate, BusinessHours bh, Integer tzOffsetInMinutes) {
        
        //system.debug('Inside WSCH_CommonUtils.getClosedHours()');
        //in a lstOfStartAndEndRange, for each date,check if it is a working day for that BH.
        //If not, add it as a Holiday
        List<WSCH_Provider_SP_StubsV91.DateAndTimeRange> lstDateAndTimeRange = new List<WSCH_Provider_SP_StubsV91.DateAndTimeRange>();
        WSCH_Provider_SP_StubsV91.DateAndTimeRange dateAndTimeRange = new WSCH_Provider_SP_StubsV91.DateAndTimeRange();
        SMAX_OptiMax_Engine_Ext optExt = new SMAX_OptiMax_Engine_Ext();
        List<Holiday> lstOfAllHolidays = WSCH_CommonUtils.listOfAllHolidays;
        List<Holiday> lstOfPartialHolidays = new List<Holiday>();
        
        if(lstOfAllHolidays != null && lstOfAllHolidays.size() > 0) {
            for(Holiday eachHoliday : lstOfAllHolidays) {
                if(!eachHoliday.isAllDay) {
                    lstOfPartialHolidays.add(eachHoliday);
                }
            }
        }

        //system.debug('lstOfPartialHolidays - ' + lstOfPartialHolidays);
        //to reduce heap size
        if(lstOfAllHolidays != null && lstOfAllHolidays.size() > 0) {
            lstOfAllHolidays.clear();
        }
        
        List<Date> lstOfDatesBetweenStartAndEnd = getLstOfDatesBetween(startDate, endDate);
        //Checking if eachDate between the dateRange is a holiday or not. If yes, add it as a closed hours
        if(lstOfDatesBetweenStartAndEnd != null && lstOfDatesBetweenStartAndEnd.size() > 0) {
            for( Date eachDate : lstOfDatesBetweenStartAndEnd) {
                //if each date, between start and end date range is a full day holiday create holiday hours for that date
                if(!optExt.isWorkingDay(bh, eachDate)) {
                    dateAndTimeRange = getDateTimeRangeForAllDayHoliday(eachDate, bh, tzOffsetinMinutes);
                    lstDateAndTimeRange.add(dateAndTimeRange);
                    continue;
                }
                
                for(Holiday eachPartialHoliday : lstOfPartialHolidays) {
                    
                    //check if the eachPartialHoliday start and endtime within the lstPartialBhr then continue
                    
                    Double startTimeMinDouble = (Double)eachPartialHoliday.StartTimeInMinutes/60;
                    WSCH_AuditLogger.debug('startTimeMinDouble - ' + startTimeMinDouble);
                    String[] strStartTime = String.valueOf(startTimeMinDouble).split('\\.',2);
                    Integer intStartHour = Integer.valueOf(strStartTime[0]);
                    Integer intStartMin = Math.mod(eachPartialHoliday.StartTimeInMinutes, 60);
                    //system.debug('strStartTime-' + strStartTime);
                    //system.debug('intStartHour-' + intStartHour);
                    //system.debug('intStartMin-' + intStartMin);
                    
                    Double endTimeMinDouble = (Double)eachPartialHoliday.EndTimeInMinutes/60;
                    WSCH_AuditLogger.debug('endTimeMinDouble - ' + endTimeMinDouble);
                    String[] strEndTime = String.valueOf(endTimeMinDouble).split('\\.',2);              
                    Integer intEndHour = Integer.valueOf(strEndTime[0]);
                    Integer intEndMin = Math.mod(eachPartialHoliday.EndTimeInMinutes, 60);
                    //system.debug('strEndTime-' + strEndTime);
                    //system.debug('intEndHour-' + intEndHour);
                    //system.debug('intEndMin-' + intEndMin);
                    
                    //create dateTime object as DateTime.newInstance(eachHolidayObj.ActivityDate, Time.newInstance(hour, minute, 0, 0))
                    DateTime startDateTimeUsr = DateTime.newInstanceGmt(eachDate, Time.newInstance(intStartHour, intStartMin, 0, 0));               
                    DateTime startDateTimeGmt = WSCH_DateUtils.doTZConversion(startDateTimeUsr, bh.timeZoneSidKey, 'GMT', tzOffsetinMinutes);
                    //system.debug('startDateTimeUsr - ' + startDateTimeUsr);
                    //system.debug('startDateTimeGmt - ' + startDateTimeGmt);
                    
                    //similarly do it for endTime
                    DateTime endDateTimeUsr = DateTime.newInstanceGmt(eachDate, Time.newInstance(intEndHour, intEndMin-1, 0, 0));
                    DateTime endDateTimeGmt = WSCH_DateUtils.doTZConversion(endDateTimeUsr, bh.timeZoneSidKey, 'GMT', tzOffsetinMinutes);
                    //system.debug('endDateTimeUsr - ' + endDateTimeUsr);
                    //system.debug('endDateTimeGmt - ' + endDateTimeGmt);
                    
                    List<DateTime> lstOfBHDateTime = getBHStartEndDateTime(eachDate, bh);
                            
                    if(lstOfBHDateTime != null && lstOfBHDateTime.size() == 2) {
                        DateTime bhStartDateTime = lstOfBHDateTime.get(0);
                        //convert the bhDateTime to GMT timezone
                        DateTime bhStartDateTimeGMT = WSCH_DateUtils.doTZConversion(bhStartDateTime, bh.timeZoneSidKey, 'GMT', tzOffsetinMinutes);
                        //system.debug('bhStartDateTime - ' + bhStartDateTime);
                        //system.debug('bhStartDateTimeGMT - ' + bhStartDateTimeGMT);
                        
                        DateTime bhEndDateTime = lstOfBHDateTime.get(1);
                        //convert the bhDateTime to GMT timezone
                        DateTime bhEndDateTimeGMT = WSCH_DateUtils.doTZConversion(bhEndDateTime, bh.timeZoneSidKey, 'GMT', tzOffsetinMinutes);
                        //system.debug('bhEndDateTime - ' + bhEndDateTime);
                        //system.debug('bhEndDateTimeGMT - ' + bhEndDateTimeGMT);
                        
                        //if partDaySlot startTime is before the business hours startTime then set the business hour
                        // startTime as the slotStartTime 
                        if(startDateTimeGmt < bhStartDateTimeGMT) {
                            startDateTimeGmt = bhStartDateTimeGMT;
                        }
                        
                        //if partDaySlot endTime is after the business hours endTime then set the business hour
                        // endTime as the slotEndTime
                        if(endDateTimeGmt > bhEndDateTimeGMT) {
                            endDateTimeGmt = bhEndDateTimeGMT;
                        }
                        
                        //system.debug('final startDateTimeGmt - ' + startDateTimeGmt);
                        //system.debug('final endDateTimeGmt - ' + endDateTimeGmt);
                            
                        //if each date, between start and end date range is a partial day holiday create partial holiday hours for that date
                        //using the above slot information
                        if(!Businesshours.isWithin(bh.Id, startDateTimeGmt) && !Businesshours.isWithin(bh.Id, endDateTimeGmt)) {
                            dateAndTimeRange = getDateTimeRangeForPartDayHoliday(eachDate, eachPartialHoliday.StartTimeInMinutes, eachPartialHoliday.EndTimeInMinutes, bh, tzOffsetinMinutes);
                            lstDateAndTimeRange.add(dateAndTimeRange);
                            //adding qualify partial holiday to list lstPartialBhr. Here add the partial holiday object in this list to check the start
                            //time and end time later above before proceeding with the next partial holiday object.
                            //system.debug('WSCH_CommonUtils:: getClosedHours() - IsPartDay - recurrence: ' + dateAndTimeRange);
                        }
                    }
                    //to reduce the heap size
                    lstOfBHDateTime.clear();
                }
            }
        }
        //to reduce the heap size
        lstOfPartialHolidays.clear();
        return lstDateAndTimeRange;
    }
    
    //This method returns the list containing the startdatetime (as first element of list) and 
    // end datetime(as second element of the list) of the horizon of a DP and a Territory
       
    public static String getActiveRealTimeOptimizationEngine() {
        String rtoEngine = null;
        String settingsGBL007 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL007');
        String settingsGBL022 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL022');
        //String isOptiMaxEcoEnabled = WSCH_CommonUtils.getSettingValue('OMAX001', 'SET00999'); 
        if(settingsGBL007 != null && settingsGBL007.touppercase() == 'TRUE'){
            Set<String> providersSet = new Set<String>();
            if(settingsGBL022 != null ) {
                for(String StrProvider : settingsGBL022.split(',')){
                    providersSet.add(StrProvider.touppercase());
                }
                //WSCH_AuditLogger.debug('Provider Set: ' + providersSet);
                //if((providersSet.contains('OPTIMAX') || providersSet.contains('OPTIMAXECO')) && String.isNotBlank(isOptiMaxEcoEnabled) && (Boolean.valueOf(isOptiMaxEcoEnabled))) {
                if(providersSet.contains('OPTIMAX') || providersSet.contains('OPTIMAXECO')) {
                    rtoEngine = 'OPTIMAXECO';
                }else if((providersSet.contains('SERVICEPOWER') || providersSet.contains('SERVICE POWER'))) {
                    rtoEngine = 'SERVICEPOWER';
                }
            }
        }
        WSCH_AuditLogger.debug('WSCH_CommonUtils::getActiveRealTimeOptimizationEngine():: Active RTO Engine is : ' +rtoEngine);
        return rtoEngine;
    }    
    
    public static List<DateTime> getDPHorizonStartAndEndDates(SVMXC__ServiceMax_Processes__c objDispatchProcess, BusinessHours bh) {
        
        List<DateTime> lstHorizonStartAndEndDateTime = new List<DateTime>();
        
        DateTime startDateTime;
        DateTime endDateTime;
        Datetime tempStDt;
        DateTime horizonStartDateTime;
        DateTime horizonEndDateTime;
        Datetime lastProcessedDateTime;
        Integer calStartDays;
        Integer calEndDays;
        
        DateTime dtmNow = system.now();
        
        if(objDispatchProcess.SVMXC__Calendar_Start_Days__c != null) {
            calStartDays = Integer.valueOf(objDispatchProcess.SVMXC__Calendar_Start_Days__c);
            //beow loop determines the nextWorkingDay to start the scheduling from, based on the startAfterDays mentioned in the Dispatch Process
            //WSCH_AuditLogger.debug('dtmNow - ' + dtmNow);
            //getting the next working datetime to start the loop from
            //in Batch if the BusinessHour is already started, consider the next working day.So below method getNextWorkingHour() is very important for Batch
            tempStDt = WSCH_Provider_ECO_DataMapper.getNextWorkingHour(bh, dtmNow);
            //WSCH_AuditLogger.debug('tempStDt - ' + tempStDt);
            for (integer i = 0; i < calStartDays; i++)
            {
                // We add 1 minute to the tempStDt every time through the loop to force getNextWorkingHour
                // function to return the next working day. Else, it will keep returning the same date time
                tempStDt = WSCH_Provider_ECO_DataMapper.getNextWorkingHour(bh, tempStDt.addMinutes(1));
            }
            //WSCH_AuditLogger.debug('WSCH_CommonUtils::getDPHorizonStartAndEndDates():start after date in case of Batch Dispatch Process - ' + tempStDt);
        }
        
        if(objDispatchProcess.SVMXC__Calendar_End_Days__c != null) {
            calEndDays = Integer.valueOf(objDispatchProcess.SVMXC__Calendar_End_Days__c);
        }
        
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::getDPHorizonStartAndEndDates():calStartDays - ' + calStartDays);
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::getDPHorizonStartAndEndDates():calEndDays - ' + calEndDays);
        
        //If it is a RTO Dispatch Process consider current day as the start date of the Horizon
        //If it is a Batch dispatch process, consider the SVMXC__Calendar_Start_Days__c field to determine the horizon start date.
        if(objDispatchProcess.SVMXC__Dispatch_Method__c.equalsIgnoreCase('Real Time Optimization')) {
            //horizonStartDateTime = dtmNow;
            horizonStartDateTime = BusinessHours.addGmt(bh.id, dtmNow, 1L);
        } else if(objDispatchProcess.SVMXC__Dispatch_Method__c.equalsIgnoreCase('Optimized Batch')) {
            if((objDispatchProcess.SVMXC__Full_Run_Unit__c).toUpperCase() == 'DAYS') {
                horizonStartDateTime = tempStDt;
            } else {
                horizonStartDateTime = BusinessHours.addGmt(bh.id, dtmNow.addhours(objDispatchProcess.SVMXC__Frequency__c.intValue()), 1L);
            }
        }
        
        if(calEndDays < 1) {
            calEndDays = 1;
        }
        
        // copy the horizonStartDateTime which is in GMT to a temp variable 
        startDateTime = horizonStartDateTime;
        
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::getDPHorizonStartAndEndDates()::BH.Id - ' + bh.Id);
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::getDPHorizonStartAndEndDates()::sytem.now(): in GMT - ' + dtmNow);
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::getDPHorizonStartAndEndDates()::First Day Start Time in GMT::after BusinessHours.addGmt - ' +horizonStartDateTime);
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::getDPHorizonStartAndEndDates()::Start Date in GMT time zone: ' + startDateTime);
        
        //horizonStartDateTime is in GMT. So get the corresponding dateTime in territory time zone with Business Hour startTime and endTime
        List<DateTime> lstStAndEndDateTime = WSCH_CommonUtils.getBHStartEndDateTime(horizonStartDateTime.date(), bh);
        if(lstStAndEndDateTime != null && lstStAndEndDateTime.size() == 2) {
            horizonStartDateTime = lstStAndEndDateTime.get(0);
            WSCH_AuditLogger.debug('WSCH_CommonUtils::getDPHorizonStartAndEndDates()::lstStAndEndDateTime[0] - '+ lstStAndEndDateTime[0] + 
                            ' lstStAndEndDateTime[1] - '+ lstStAndEndDateTime[1]);
        }
        
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::getDPHorizonStartAndEndDates()::horizonStartDateTime as per Territory BH start Time - ' + horizonStartDateTime);
        //get the first Working Hour datetime from the above horizonStartDateTime, before adding it to the Horizon
        //lastProcessedDateTime = WSCH_Provider_ECO_DataMapper.getNextWorkingHour(bh, horizonStartDateTime);
        
        //Add the first date of the Horizon. This is as per the Territory BH
        lstHorizonStartAndEndDateTime.add(horizonStartDateTime);
        
        // Starting from the first day, get all the dates in the scheduling horizon
        lastProcessedDateTime = startDateTime;        
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::getDPHorizonStartAndEndDates()::lastProcessedDateTime:: ' +lastProcessedDateTime);
        
        /*!!!Below comment is very important for Horizon calculation*/
        //below loop starts processing from the next subsequent workingDay in the BusinessHour as the method 
        //getNextWorkingHour gives the next working date in that BusinessHour. Starting the loop from index 1 instead of 0 
        //as the first date in the horizon is already considered above.
        for(integer i = 1; i < calEndDays; i++)     //changed from calEndDays - 1 to calEndDays
        {
            lastProcessedDateTime = WSCH_Provider_ECO_DataMapper.getNextWorkingHour(bh, lastProcessedDateTime.addMinutes(5)); //changed it from 1 to 5 in addMinutes()
            endDateTime = lastProcessedDateTime;
            //WSCH_AuditLogger.debug('Inside calEndDays loop i - ' + i);
            //WSCH_AuditLogger.debug('Inside calEndDays loop lastProcessedDateTime - ' + lastProcessedDateTime);
        }
        
        //WSCH_AuditLogger.debug('Inside calEndDays loop lastProcessedDateTime or endDateTime - ' + endDateTime);
        //added the below code to fix the NBN issue where null pointer exception was seen when endDate is null.
        //if schedule for no. of days is 1 in dispatch process, set the startDate as the endDate
        if(calEndDays == 1) {
            endDateTime = startDateTime;
        }
        
        //now we have the enddatetime. But the time component has to be taken from the businesshour for that particular day and form a new datetime
        Date horizonEndDate = Date.valueOf(endDateTime.format('yyyy-MM-dd', bh.timeZoneSidKey));
        lstStAndEndDateTime.clear();
        lstStAndEndDateTime = WSCH_CommonUtils.getBHStartEndDateTime(horizonEndDate, bh);
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::getDPHorizonStartAndEndDates()::lstStAndEndDateTime:: ' +lstStAndEndDateTime);
        if(lstStAndEndDateTime != null && lstStAndEndDateTime.size() == 2) {
            horizonEndDateTime = lstStAndEndDateTime.get(1);
            WSCH_AuditLogger.debug('WSCH_CommonUtils::getDPHorizonStartAndEndDates()::lstStAndEndDateTime[0] - '+ lstStAndEndDateTime[0] + 
                            ' lstStAndEndDateTime[1] - '+ lstStAndEndDateTime[1]);
        }
        
        lstHorizonStartAndEndDateTime.add(horizonEndDateTime);
        
        //WSCH_AuditLogger.debug('WSCH_CommonUtils::getDPHorizonStartAndEndDates - horizon end date ' + horizonEndDateTime);
        //WSCH_AuditLogger.finish();    //do not uncomment this line. It will cause 'You have uncommitted work pending'
        return lstHorizonStartAndEndDateTime;
    }

    public static List<DateTime> getDPHorizonStartAndEndDatesForLTP(SVMXC__ServiceMax_Processes__c objDispatchProcess, BusinessHours bh) {
        SMAX_OptiMax_Engine_Ext clsOMaxExtension = new SMAX_OptiMax_Engine_Ext();
        Integer intNoOfDays = 0;
        Date datStartDate;
        Date datEndDate;
        Datetime dtmNow = system.now();
        DateTime dtmSchedulingHorizonStartDateTime;
        Datetime dtmLastProcessedDateTime;
        set<Date> setSchedHorizDates = new set<Date>();
        List<DateTime> lstHorizonStartAndEndDateTime = new List<DateTime>();
        String strHorizonStartEndDT;
        Map<String, List<Date>> mapHorizonDetails = new Map<String, List<Date>>();
        if(objDispatchProcess.SVMXC__Calendar_End_Days__c != null)
            intNoOfDays = (objDispatchProcess.SVMXC__Calendar_End_Days__c).intValue();

        if(intNoOfDays < 1)
            intNoOfDays = 1;

        Integer intStartAfterDays;
        if(objDispatchProcess.SVMXC__Window_Height__c != null)
            intStartAfterDays = objDispatchProcess.SVMXC__Window_Height__c.intValue();

        if(intStartAfterDays < 0)
        intStartAfterDays = 0;

        Datetime tempStDt = clsOMaxExtension.getNextWorkingHour(bh, dtmNow);
        for (integer i = 1; i < intStartAfterDays; i++)
        {
            // We add 1 minute to the tempStDt every time through the loop to force getNextWorkingHour
            // function to return the next working day. Else, it will keep returning the same date time
            tempStDt = clsOMaxExtension.getNextWorkingHour(bh, tempStDt.addMinutes(5));
        }
        dtmSchedulingHorizonStartDateTime = tempStDt;
        // Get the date of the first day in the scheduling horizon in Business Hour time zone
        datStartDate = Date.valueOf(dtmSchedulingHorizonStartDateTime.format('yyyy-MM-dd', bh.timeZoneSidKey));
        lstHorizonStartAndEndDateTime.add(dtmSchedulingHorizonStartDateTime);
        // Starting from the first day, get all the dates in the scheduling horizon
        dtmlastProcessedDateTime = dtmSchedulingHorizonStartDateTime;
        strHorizonStartEndDT = String.ValueOfGMT(dtmlastProcessedDateTime);
        //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getDPHorizonStartAndEndDatesForLTP::LTP Job horizon startdatetime:'+strHorizonStartEndDT);

        // Starting from the primary job horizon end date, get all the dates till the LTP dispatch process definition end date.
        //SVMXC__Max_Hours_Per_Day__c - This is the field used to store the horizon end date for LTP
        integer intNoOfDaysLTP = 1;

        if(objDispatchProcess.SVMXC__Window_Width__c != null)
            intNoOfDaysLTP = objDispatchProcess.SVMXC__Window_Width__c.intValue();

        Date ltpTempDate = datStartDate;
        setSchedHorizDates.add(ltpTempDate);
        for(integer i = 0; i < intNoOfDaysLTP - 1; i++)
        {
            dtmlastProcessedDateTime = clsOMaxExtension.getNextWorkingHour(bh, dtmlastProcessedDateTime.addMinutes(1));
            ltpTempDate = Date.valueOf(dtmlastProcessedDateTime.format('yyyy-MM-dd', bh.timeZoneSidKey));
            setSchedHorizDates.add(ltpTempDate);
            datEndDate = ltpTempDate;
        }
        strHorizonStartEndDT = strHorizonStartEndDT+','+dtmlastProcessedDateTime;
        lstHorizonStartAndEndDateTime.add(dtmlastProcessedDateTime);

        WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getDPHorizonStartAndEndDatesForLTP::LTP Job horizon start and end datetime:'+strHorizonStartEndDT + ' , lstHorizonStartAndEndDateTime : '+lstHorizonStartAndEndDateTime);

        return lstHorizonStartAndEndDateTime;
    }

    public static WSCH_Provider_ECO_Stubs.ExecutionTime_WP getWorkOrderArrivalWindow(SVMXC__Service_Order__c workOrder, BusinessHours objDefTerritoryBH){
        WSCH_Provider_ECO_Stubs.ExecutionTime_WP wrpExecTime;
        //get the Arrival Windows for the Appointment Type mentioned on the WO
        List<SVMXC__SM_Appointment_Window__c> lstOfApptWindowDefinition = [Select SVMXC__SM_Appointment_Type__r.SVMXC__SM_Appointment_Type_Name__c, SVMXC__SM_Time_Window__r.SVMXC__SM_Time_Window_Name__c, 
                                        SVMXC__SM_Time_Window__r.SVMXC__SM_Window_Start_Time__c, SVMXC__SM_Time_Window__r.SVMXC__SM_Window_End_Time__c 
                                        From SVMXC__SM_Appointment_Window__c WHERE RecordType.Name = 'Appointment Type Definition' 
                                        AND SVMXC__SM_Appointment_Type__c = :workOrder.SVMXC__SM_Appointment_Type__c];
                                        
        WSCH_AuditLogger.debug('WSCH_CommonUtils::getWorkOrderArrivalWindow()::lstOfApptWindowDefinition: ' + lstOfApptWindowDefinition.size());
        List<WSCH_Provider_ECO_Stubs.ArrivalWindow_WP> arrivalWindows = new List<WSCH_Provider_ECO_Stubs.ArrivalWindow_WP>();
        WSCH_Provider_ECO_Stubs.ArrivalWindow_WP arrivalWindow;
        
        WSCH_Provider_ECO_Stubs.ApptOfferType_WP appOfferType = new WSCH_Provider_ECO_Stubs.ApptOfferType_WP();
        
        if(lstOfApptWindowDefinition != null && lstOfApptWindowDefinition.size() > 0) {
            /*Anush added time Formatting - START*/
            String StartTimeString,EndTimeString;
            Date currentDateterritory = workOrder.SVMXC__Scheduled_Date_Time__c.DateGMT();
            DateTime terrStartDateTime, terrEndDateTime, gmtStartDateTime, gmtEndDateTime;
            /*Anush added time Formatting - END*/
            for(SVMXC__SM_Appointment_Window__c eachApptWindowDef : lstOfApptWindowDefinition) {
                StartTimeString = eachApptWindowDef.SVMXC__SM_Time_Window__r.SVMXC__SM_Window_Start_Time__c;
                EndTimeString = eachApptWindowDef.SVMXC__SM_Time_Window__r.SVMXC__SM_Window_End_Time__c;
                
                if(!StartTimeString.contains(':')) {
                    StartTimeString = StartTimeString + ':00';
                }
                
                if(!EndTimeString.contains(':')) {
                    EndTimeString = EndTimeString + ':00';
                }
                
                WSCH_AuditLogger.debug('WSCH_CommonUtils::getWorkOrderArrivalWindow()::starttime: '+StartTimeString);
                WSCH_AuditLogger.debug('WSCH_CommonUtils::getWorkOrderArrivalWindow()::endtime: '+EndTimeString);
                terrStartDateTime = Datetime.newInstanceGMT(currentDateterritory.year(),currentDateterritory.month(),currentDateterritory.day(),Integer.valueOf(StartTimeString.split(':')[0]),Integer.valueOf(StartTimeString.split(':')[1]),00);
                terrEndDateTime = Datetime.newInstanceGMT(currentDateterritory.year(),currentDateterritory.month(),currentDateterritory.day(),Integer.valueOf(EndTimeString.split(':')[0]),Integer.valueOf(EndTimeString.split(':')[1]),00);
                
                gmtStartDateTime = WSCH_DateUtils.doTZConversion(terrStartDateTime, objDefTerritoryBH.TimeZoneSidKey, 'GMT');
                gmtEndDateTime = WSCH_DateUtils.doTZConversion(terrEndDateTime, objDefTerritoryBH.TimeZoneSidKey, 'GMT');

                WSCH_AuditLogger.debug('WSCH_CommonUtils::getWorkOrderArrivalWindow()::gmtStartDateTime - ' + gmtStartDateTime);
                WSCH_AuditLogger.debug('WSCH_CommonUtils::getWorkOrderArrivalWindow()::gmtEndDateTime - ' + gmtEndDateTime);
                WSCH_AuditLogger.debug('WSCH_CommonUtils::getWorkOrderArrivalWindow()::WO Scheduled datetime - ' + workOrder.SVMXC__Scheduled_Date_Time__c);
                
                if(gmtStartDateTime <= workOrder.SVMXC__Scheduled_Date_Time__c && gmtEndDateTime >= workOrder.SVMXC__Scheduled_Date_Time__c){
                    WSCH_AuditLogger.debug('WSCH_CommonUtils::getWorkOrderArrivalWindow()::current schedule date time falls within this arrival window.....');
                    wrpExecTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(gmtStartDateTime, gmtEndDateTime);
                    WSCH_AuditLogger.debug('WSCH_CommonUtils::getWorkOrderArrivalWindow()::wrpExecTime..'+wrpExecTime);
                    break;
                }
            }
        
        }
        return wrpExecTime;        
    }    
}