public with sharing class PREV_EngineUtils
{
    public static Map<String, Schema.SObjectType> allObjmap  = new Map<String, Schema.SObjectType>();
    public SVMXC.INTF_ApplyMapping objApplyMapping = new SVMXC.INTF_ApplyMapping();
    public DCON_Utils dcUtils = new DCON_Utils();
    public Map<String,String> mapIBTechnician = new Map<String,String>();
    public Map<String,String> mapLocationTechnician = new Map<String,String>();
    public PREV_Engine_Batch objEnginBatch = new PREV_Engine_Batch();
    public SVMXC__ServiceMax_Processes__c objPMProcess;
    public SVMXC__PM_Schedule__c objPMSchedule;
    public SVMXC__PM_Plan__c objPMPlan;
    public String strWOCreationBasedOn = NULL;
    public String typeOfPMPlan = 'PRODUCT';
    public static String strProdServicedRType = null;
    Id ScheduleDefWOMapId;
    
    //Method to create work orders for the Preventive Maintenance plan at regular interval to perform Preventive Maintenance commitments
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse createWorkOrders(SVMXC.INTF_WebServicesDef.INTF_SFMRequest objEngineRequest)
    {
        system.debug(LoggingLevel.WARN, 'Engine Request contains: ' + objEngineRequest);
        
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse objEngineResp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        objEngineResp.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        objEngineResp.values = new List<String>();
        List<SVMXC__PM_Coverage__c> lstPMCoverage = new List<SVMXC__PM_Coverage__c>();
        List<SVMXC__Required_Part__c> lstPartsUsed = new List<SVMXC__Required_Part__c>();
        List<SVMXC__Service_Order_Line__c> lstWorkOrdLine = new List<SVMXC__Service_Order_Line__c>();
        List<SVMXC__PM_History__c> lstPMHistory = new List<SVMXC__PM_History__c>();
        Map<String, sObject> mapSourceIBIdTargetWorkOrdObj = new Map<String, sObject>();
        Map<String, sObject> mapSourceLocIdTargetWorkOrdObj = new Map<String, sObject>();
        Map<String, sObject> mapSourceIdTargetWorkOrdObj = new Map<String, sObject>();
        Map<String, sObject> mapSourceRecIdWorkOrderObj = new Map<String, sObject>();
        Map<String,Sobject> mapReqPartsWorkDetail = new Map<String,Sobject>();
        Map<String,Sobject> mapTaskTemplateIdTask = new Map<String,Sobject>();
        Map<Id, SVMXC__Service_Group_Members__c> mapSFTechnician = new Map<Id, SVMXC__Service_Group_Members__c>();
        Map<String, SVMXC__Service_Order__c> mapScheduleIdWorkOrder = new Map<String, SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c objPMWorkOrd = new SVMXC__Service_Order__c();
        List<Sobject> lstSFTask = new List<Sobject>();
        Set<Id> setTechnicianIds = new Set<Id>();
        String strMappingObjName, strTaskObjName;
        Id WorkOrdMapId, CaseMapId, TaskObjMapId, ReqPartsMapId, WorkTemplateId;
        String strLogger = '\n';
        String PMScheduleDefId = NULL;
        Boolean isNoPMCoverage = false;
        Boolean IsCreateTask = false;
        boolean IsLocBasedPMEnabled = false;
        String TaskPriority = NULL;
        String strPMScheduleId = NULL;
        Integer BatchCount = 0;
        Savepoint sp = Database.setSavepoint();
        typeOfPMPlan = 'PRODUCT';
        
        //Static variable - don't query next time, if it is already queried.
        if(strProdServicedRType == null || strProdServicedRType.length() == 0 )
            strProdServicedRType = [Select Id From RecordType where SobjectType = 'SVMXC__Service_Order_Line__c' AND Name = 'Products Serviced'].Id;
        
        //Static Variable - don't describe next time, if it is already described.
        if(allObjmap == null || allObjmap.size() == 0){
            for(Schema.SObjectType s : Schema.getGlobalDescribe().values()){
                allObjmap.put(s.getDescribe().getName(), s);
            }
        }
        
        try
        {
            objEngineResp.success = true;
            if(objEngineRequest != NULL && objEngineRequest.valueMap != NULL && objEngineRequest.valueMap.size() > 0)
            {
                for(SVMXC.INTF_WebServicesDef.SVMXMap currentValMap : objEngineRequest.valueMap)
                {
                    if(currentValMap.key == 'PM_PROCESS_RECORD')
                        objPMProcess = (SVMXC__ServiceMax_Processes__c) currentValMap.record;
                    else if(currentValMap.key == 'PM_PLAN_RECORD')
                        objPMPlan = (SVMXC__PM_Plan__c) currentValMap.record;
                    else if(currentValMap.key == 'WORK_ORDER_RECORD')
                        objPMWorkOrd = (SVMXC__Service_Order__c) currentValMap.record;
                    else if(currentValMap.key == 'PM_SCHEDULE_RECORDId')
                        strPMScheduleId = currentValMap.value;
                    else if(currentValMap.key == 'PM_COVERAGE_LST')
                        lstPMCoverage.addAll((List<SVMXC__PM_Coverage__c>) currentValMap.data);
                    else if(currentValMap.key == 'TASK_CREATION_SETTING')
                        IsCreateTask = Boolean.valueOf(currentValMap.value);
                    else if(currentValMap.key == 'IS_LOCATION_BASED_PM_ON')
                        IsLocBasedPMEnabled = Boolean.valueOf(currentValMap.value);
                    else if(currentValMap.key == 'TASK_PRIORITY_SETTING')
                        TaskPriority = currentValMap.value;
                    else if(currentValMap.key == 'BATCH_COUNT')
                        BatchCount = Integer.valueOf(currentValMap.value);
                }
            }
            system.debug(LoggingLevel.WARN, 'Total Coverage: ' + lstPMCoverage);
            
            
            if(objPMProcess != NULL && objPMPlan != NULL && strPMScheduleId == 'NO_SCHEDULE')
            {
                objEngineResp.value = objPMProcess.Id;
                objEngineResp.eventName = objPMPlan.Id;
                strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Preventive Maintenance Plan: '+ objPMPlan.Name + ' (Batch: '+ BatchCount + ')';
                strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + getTAG006();
                objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
                return objEngineResp;
            }
            else if(objPMProcess != NULL && objPMPlan != NULL && strPMScheduleId != 'NO_SCHEDULE')
            {
                strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Preventive Maintenance Plan: '+ objPMPlan.Name + ' (Batch: '+ BatchCount + ')';
                objEngineResp.value = objPMProcess.Id;
                objEngineResp.eventName = objPMPlan.Id;
                
                //Get the PM Process definition information.
                if(objPMPlan.SVMXC__Coverage_Type__c != null && objPMPlan.SVMXC__Coverage_Type__c.toUpperCase() == 'ACCOUNT (VISIT ONLY)')
                    typeOfPMPlan = 'ACCOUNT';
                else if(objPMPlan.SVMXC__Coverage_Type__c != null && objPMPlan.SVMXC__Coverage_Type__c.toUpperCase() == 'LOCATION (MUST HAVE LOCATION)')
                    typeOfPMPlan = 'LOCATION';
                else if(objPMPlan.SVMXC__Coverage_Type__c != null && objPMPlan.SVMXC__Coverage_Type__c.toUpperCase() == 'PRODUCT (MUST HAVE IB)')
                    typeOfPMPlan = 'PRODUCT';
                
                strTaskObjName = objPMProcess.SVMXC__Target_Object_Name__c != NULL ? objPMProcess.SVMXC__Target_Object_Name__c : 'SVMX.NONE';
                WorkOrdMapId = typeOfPMPlan == 'LOCATION' ? String.valueOf(objPMProcess.SVMXC__Process3__c) : String.valueOf(objPMProcess.SVMXC__Node_Parent__c);
                
                /** Return, if Location Based PM is off, or PM Process is not configured to support location based PM Plan **/
                if(typeOfPMPlan == 'LOCATION')
                {
                    if(!IsLocBasedPMEnabled)
                    {
                        strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Location based Preventive Maintenance functionality is not enabled';
                        objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
                        return objEngineResp;
                    }
                    else if(WorkOrdMapId == null || String.valueOf(WorkOrdMapId).length() == 0)
                    {
                        strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Preventive Maintenance Process is not configured for Location based Preventive Maintenance Plan';
                        objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
                        return objEngineResp;
                    }
                }
                
                
                CaseMapId  = String.valueOf(objPMProcess.SVMXC__Process__c);
                ScheduleDefWOMapId = String.valueOf(objPMProcess.SVMXC__Submodule__c);
                strWOCreationBasedOn = objPMProcess.SVMXC__Create_Work_Order__c;
                TaskObjMapId = objPMProcess.SVMXC__Process1__c;
                ReqPartsMapId = objPMProcess.SVMXC__Process2__c;
                Integer intAdvWorkOrdCreationDays = objPMProcess.SVMXC__Frequency__c != NULL ? integer.valueOf(objPMProcess.SVMXC__Frequency__c) : 0;
                Date dtQualifiedScheduleDateCrit = date.today().addDays(intAdvWorkOrdCreationDays);
                
                //Get the PM Schedule record.
                List<SVMXC__PM_Schedule__c> lstPMSchedule = [Select SVMXC__PM_Plan__c,SVMXC__PM_Plan__r.SVMXC__Schedule_Type__c, Name, SVMXC__Scheduled_On__c,SVMXC__Last_Run_Date__c, SVMXC__PM_Schedule_Definition__c, SVMXC__PM_Schedule_Definition__r.SVMXC__Work_Order_Purpose__c, SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency__c, SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency_Unit__c, 
                                                                SVMXC__PM_Schedule_Definition__r.SVMXC__Processed__c,Id from SVMXC__PM_Schedule__c where Id =: strPMScheduleId];
                
                if(lstPMSchedule != NULL && lstPMSchedule.size() == 1)
                {
                    objPMSchedule = lstPMSchedule[0];
                    strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'PM Schedule: '+ objPMSchedule.Name;
                    if(objPMSchedule.SVMXC__PM_Plan__r.SVMXC__Schedule_Type__c == 'Time Based' && objPMSchedule.SVMXC__Scheduled_On__c != NULL && objPMSchedule.SVMXC__Scheduled_On__c <= dtQualifiedScheduleDateCrit )
                    {
                        if(objPMSchedule.SVMXC__PM_Schedule_Definition__c != NULL)
                        {
                            PMScheduleDefId = objPMSchedule.SVMXC__PM_Schedule_Definition__c;
                            if(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Work_Order_Purpose__c != NULL)
                                WorkTemplateId = objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Work_Order_Purpose__c;                            
                            
                            if(objPMPlan.SVMXC__SM_Adjustment_Type__c != NULL){
                                boolean rescheduleWOCreation = recalculateNextSchedule();  
                                if(rescheduleWOCreation){
                                    if(objPMSchedule.SVMXC__Scheduled_On__c  <= objPMPlan.SVMXC__End_Date__c){
                                        update objPMSchedule;   
                                        //Return if PM Schedule is rescheduled.
                                        strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + objPMSchedule.Name + ' PM Plan rescheduled to ' + objPMSchedule.SVMXC__Scheduled_On__c;
                                        objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
                                        return objEngineResp;                                                                        
                                    }
                                    
                                    delete objPMSchedule;
                                    sObject objPMDefiniton = objPMSchedule.getsObject('SVMXC__PM_Schedule_Definition__r');
                                    objPMDefiniton.put('SVMXC__Processed__c',true);
                                    
                                    update objPMDefiniton;

                                    //Return if PM Schedule is rescheduled.
                                    strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + objPMSchedule.Name + ' rescheduled date is exceeding PM plan End Date, hence PM Definition is marked as processed';
                                    objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
                                    return objEngineResp;  
                                }    
                            }
                        }   
                    }
                    else
                    {
                        //Return if PM Schedule is not qualified.
                        strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'PM Schedule is not valid';
                        objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
                        return objEngineResp;
                    }
                }
                else
                {
                    //Return if PM Schedule is not qualified.
                    strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + getTAG006();
                    objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
                    return objEngineResp;
                }
                
                //Don't process this block, if Work Order has already been created for the current PM Schedule in the previous batch, else get the Object is to be used in the mapping and create source record Id and Work Order object Map for passing apply mapping utility.
                if(objPMWorkOrd.Id == NULL && WorkOrdMapId != NULL && (typeOfPMPlan == 'PRODUCT' || typeOfPMPlan == 'ACCOUNT'))
                {
                    SVMXC__ServiceMax_Processes__c objSVMXProcess = new SVMXC__ServiceMax_Processes__c();
                    objSVMXProcess = [Select SVMXC__Source_Object_Name__c From SVMXC__ServiceMax_Processes__c where Id =: WorkOrdMapId];
                    strMappingObjName = objSVMXProcess.SVMXC__Source_Object_Name__c;
                    
                    if(strWOCreationBasedOn.toUpperCase() == 'ONE PER PLAN')
                    {
                        if(strMappingObjName == 'SVMXC__Service_Contract__c')
                        {
                            if(objPMPlan.SVMXC__Service_Contract__c != NULL){
                                updateSourceIdWOMap(objPMPlan.SVMXC__Service_Contract__c, mapSourceIdTargetWorkOrdObj, objPMPlan , objPMSchedule.SVMXC__PM_Schedule_Definition__c);
                            }
                            else
                            {
                                //If Service Contract is not available for Work Order creation through apply mapping, return.
                                strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + getTAG008();
                                objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
                                return objEngineResp;
                            }
                        }
                        else if(strMappingObjName == 'Account')
                        {
                            if(objPMPlan.SVMXC__Account__c != NULL){
                                updateSourceIdWOMap(objPMPlan.SVMXC__Account__c, mapSourceIdTargetWorkOrdObj, objPMPlan, objPMSchedule.SVMXC__PM_Schedule_Definition__c);
                            }
                            else
                            {
                                //If Account is not available for Work Order creation through apply mapping, return.
                                strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + getTAG007();
                                objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
                                return objEngineResp;
                            }
                        }
                    }
                }
                
                
                //Create IB- Work Order object Map for passing apply mapping utility and map of IB-Technician for Primary Technician assignment.
                for(SVMXC__PM_Coverage__c currProdCvrg : lstPMCoverage)
                {
                    if(typeOfPMPlan == 'PRODUCT' && currProdCvrg.SVMXC__Product_Name__c != NULL)
                    {
                        isNoPMCoverage = true;
                        updateSourceIdWOMap(currProdCvrg.SVMXC__Product_Name__c, mapSourceIBIdTargetWorkOrdObj, objPMPlan, objPMSchedule.SVMXC__PM_Schedule_Definition__c);
                        mapIBTechnician.put(currProdCvrg.SVMXC__Product_Name__c, currProdCvrg.SVMXC__Product_Name__r.SVMXC__Preferred_Technician__c);
                    }
                    else if(typeOfPMPlan == 'LOCATION' && currProdCvrg.SVMXC__Location_Name__c != NULL){
                        isNoPMCoverage = true;
                        updateSourceIdWOMap(currProdCvrg.SVMXC__Location_Name__c, mapSourceLocIdTargetWorkOrdObj, objPMPlan, objPMSchedule.SVMXC__PM_Schedule_Definition__c);
                        
                        if(currProdCvrg.SVMXC__Location_Name__r.SVMXC__Account__c != null && currProdCvrg.SVMXC__Location_Name__r.SVMXC__Account__r.SVMXC__Preferred_Technician__c != null)
                            mapLocationTechnician.put(currProdCvrg.SVMXC__Location_Name__c, currProdCvrg.SVMXC__Location_Name__r.SVMXC__Account__r.SVMXC__Preferred_Technician__c);
                    }
                }
                
                
                // Return, if there is no IB covered through this PM Plan.
                if(!isNoPMCoverage && strWOCreationBasedOn.toUpperCase() == 'ONE PER PRODUCT' && typeOfPMPlan != 'ACCOUNT')
                {
                    if(typeOfPMPlan == 'PRODUCT')
                        strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'This Preventive Maintenance Plan does not have any PM Coverage with Product Name (Installed Product).';
                    else if(typeOfPMPlan == 'LOCATION')
                        strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'This Preventive Maintenance Plan does not have any PM Coverage with Location';
                    objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
                    return objEngineResp;
                }
                
                //Account based PM Plan - It will create WO when PM Process has WOCreationBasedOn is set to "ONE PER PLAN"
                if(typeOfPMPlan == 'ACCOUNT'){
                    if(strWOCreationBasedOn.toUpperCase() == 'ONE PER PLAN'){
                    
                        if(objPMWorkOrd.Id == NULL){
                            mapSourceRecIdWorkOrderObj = objApplyMapping.getApplyMappingCore(WorkOrdMapId, mapSourceIdTargetWorkOrdObj, true, allObjmap);
                            mapSourceRecIdWorkOrderObj = populateWorkOrderFlds(mapSourceRecIdWorkOrderObj);
                        }
                    }
                    else{
                        strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Work Order(s) are not created for this Preventive Maintenance Plan as the Coverage type is set to Account (Visit Only)';
                        objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
                        return objEngineResp;
                    }
                }
                //Product based PM Plan
                else if(typeOfPMPlan == 'PRODUCT')
                {
                    if(strWOCreationBasedOn.toUpperCase() == 'ONE PER PLAN')
                    {
                        if(objPMWorkOrd.Id == NULL) 
                        {  
                            mapSourceRecIdWorkOrderObj = objApplyMapping.getApplyMappingCore(WorkOrdMapId, mapSourceIdTargetWorkOrdObj, true, allObjmap);
                            mapSourceRecIdWorkOrderObj = populateWorkOrderFlds(mapSourceRecIdWorkOrderObj);
                        }
                    }
                    else if(strWOCreationBasedOn.toUpperCase() == 'ONE PER PRODUCT')
                    {
                        mapSourceRecIdWorkOrderObj = objApplyMapping.getApplyMappingCore(WorkOrdMapId, mapSourceIBIdTargetWorkOrdObj, true, allObjmap);
                        mapSourceRecIdWorkOrderObj = populateWorkOrderFlds(mapSourceRecIdWorkOrderObj);
                    }
                }
                //Location based PM Plan
                else if(typeOfPMPlan == 'LOCATION'){
                    mapSourceRecIdWorkOrderObj = objApplyMapping.getApplyMappingCore(WorkOrdMapId, mapSourceLocIdTargetWorkOrdObj, true, allObjmap);
                    mapSourceRecIdWorkOrderObj = populateWorkOrderFlds(mapSourceRecIdWorkOrderObj);
                }
                mapSourceLocIdTargetWorkOrdObj.clear();
                mapSourceIBIdTargetWorkOrdObj.clear();
                mapSourceIdTargetWorkOrdObj.clear();
                
                
                //Query Required Parts.
                if(WorkTemplateId != NULL)
                {
                    lstPartsUsed = [Select SVMXC__Product__c, SVMXC__Quantity__c, SVMXC__Work_Order_Purpose__c from SVMXC__Required_Part__c where SVMXC__Work_Order_Purpose__c =: WorkTemplateId];
                }
                
                //Call Apply mapping utility, Get the Required Parts and Work Details map.
                if(ReqPartsMapId != NULL)
                {
                    for(SVMXC__Required_Part__c objPartsUsed : lstPartsUsed)
                        mapReqPartsWorkDetail.put(objPartsUsed.Id, allObjmap.get('SVMXC__Service_Order_Line__c').newSObject());
                    
                    if(mapReqPartsWorkDetail != NULL && mapReqPartsWorkDetail.size() > 0)
                        mapReqPartsWorkDetail = objApplyMapping.getApplyMappingCore(ReqPartsMapId, mapReqPartsWorkDetail, false, allObjmap);
                }
                
                
                //Query Tasks, get the Task or User selected object by using apply mapping utility.
                List<SVMXC__Task_Template__c> lstTask = new List<SVMXC__Task_Template__c>();
                if(WorkTemplateId != NULL)
                {
                    lstTask = [Select SVMXC__Priority__c, SVMXC__Description__c, SVMXC__Task_Title__c, SVMXC__Template_Name__c, SVMXC__Template_Type__c, SVMXC__Task_Template__c from SVMXC__Task_Template__c where RecordType.Name = 'Tasks' AND SVMXC__Task_Template__c =: WorkTemplateId];
                }
                
                //Call Apply mapping utility, Get Task Template and Task / User selected object map
                if(strTaskObjName.toUpperCase() != 'SVMX.NONE' && TaskObjMapId != NULL)
                {
                    for(SVMXC__Task_Template__c currTask : lstTask)
                    {
                        if(strTaskObjName.toUpperCase() == 'TASK')
                            mapTaskTemplateIdTask.put(currTask.Id, allObjmap.get('Task').newSObject());
                        else
                            mapTaskTemplateIdTask.put(currTask.Id, allObjmap.get(strTaskObjName).newSObject());
                    }
                    if(mapTaskTemplateIdTask != NULL && mapTaskTemplateIdTask.size() > 0)
                        mapTaskTemplateIdTask = objApplyMapping.getApplyMappingCore(TaskObjMapId, mapTaskTemplateIdTask, false, allObjmap);
                }
                
                
                //Create Work Order by using clone method for PM Schedule and PM Coverage.
                if(objPMWorkOrd.Id != NULL)
                {
                    //If Work Order has already been created for the PM Schedule in previous batch, then don't process it again. This condition is only applicable when Process says: Create Work Order = One Per Plan.
                    mapScheduleIdWorkOrder.put(objPMSchedule.Id, objPMWorkOrd);
                }
                else
                {
                    strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Creating Work Order';
                    
                    //Create WO for Account based PM Plan
                    if(typeOfPMPlan == 'ACCOUNT'){
                        if(strWOCreationBasedOn.toUpperCase() == 'ONE PER PLAN'){
                            if(strMappingObjName == 'Account' && mapSourceRecIdWorkOrderObj.get(objPMPlan.SVMXC__Account__c) != NULL){
                                Sobject sobjWorkOrd = mapSourceRecIdWorkOrderObj.get(objPMPlan.SVMXC__Account__c);
                                mapScheduleIdWorkOrder.put(objPMSchedule.Id, (SVMXC__Service_Order__c) sobjWorkOrd.clone());
                            }else if(strMappingObjName == 'SVMXC__Service_Contract__c' && mapSourceRecIdWorkOrderObj.get(objPMPlan.SVMXC__Service_Contract__c) != NULL){
                                Sobject sobjWorkOrd = mapSourceRecIdWorkOrderObj.get(objPMPlan.SVMXC__Service_Contract__c);
                                mapScheduleIdWorkOrder.put(objPMSchedule.Id, (SVMXC__Service_Order__c) sobjWorkOrd.clone());
                            }
                        }
                    }
                    //Create WO for Product based PM Plan
                    else if(typeOfPMPlan == 'PRODUCT')
                    {
                       
                        if(strWOCreationBasedOn.toUpperCase() == 'ONE PER PLAN')
                        {
                            if(strMappingObjName == 'Account' && mapSourceRecIdWorkOrderObj.get(objPMPlan.SVMXC__Account__c) != NULL)
                            {
                                Sobject sobjWorkOrd = mapSourceRecIdWorkOrderObj.get(objPMPlan.SVMXC__Account__c);
                                mapScheduleIdWorkOrder.put(objPMSchedule.Id, (SVMXC__Service_Order__c) sobjWorkOrd.clone());
                            }
                            else if(strMappingObjName == 'SVMXC__Service_Contract__c' && mapSourceRecIdWorkOrderObj.get(objPMPlan.SVMXC__Service_Contract__c) != NULL)
                            {
                                Sobject sobjWorkOrd = mapSourceRecIdWorkOrderObj.get(objPMPlan.SVMXC__Service_Contract__c);
                                mapScheduleIdWorkOrder.put(objPMSchedule.Id, (SVMXC__Service_Order__c) sobjWorkOrd.clone());
                            }
                            
                        }
                        else if(strWOCreationBasedOn.toUpperCase() == 'ONE PER PRODUCT')
                        {
                            if(lstPMCoverage != NULL && lstPMCoverage.size() > 0)
                            {
                                for(SVMXC__PM_Coverage__c PMCvrg : lstPMCoverage)
                                {
                                    if(typeOfPMPlan == 'PRODUCT')
                                    {
                                        if(PMCvrg.SVMXC__Product_Name__c != NULL)
                                        {
                                            if(mapSourceRecIdWorkOrderObj.get(PMCvrg.SVMXC__Product_Name__c) != NULL)
                                            {
                                                Sobject sobjWorkOrd = mapSourceRecIdWorkOrderObj.get(PMCvrg.SVMXC__Product_Name__c);
                                                mapScheduleIdWorkOrder.put(objPMSchedule.Id+'~'+PMCvrg.Id, (SVMXC__Service_Order__c) sobjWorkOrd.clone());
                                            }
                                        }
                                        else
                                            strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Product Name is blank for PM Coverage: '+ PMCvrg.Name;
                                    }
                                }
                            }
                            else
                            {
                                strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'PM Coverage is not defined for this Preventive Maintenance Plan.';
                            }
                        }
                    }
                    //Location based PM Plan - Create WO for each PM Coverage
                    else if(typeOfPMPlan == 'LOCATION' ){
                        if(lstPMCoverage != NULL && lstPMCoverage.size() > 0){
                            for(SVMXC__PM_Coverage__c PMCvrg : lstPMCoverage){
                                if(PMCvrg.SVMXC__Location_Name__c != NULL){
                                    if(mapSourceRecIdWorkOrderObj.get(PMCvrg.SVMXC__Location_Name__c) != NULL){
                                        Sobject sobjWorkOrd = mapSourceRecIdWorkOrderObj.get(PMCvrg.SVMXC__Location_Name__c);
                                        mapScheduleIdWorkOrder.put(objPMSchedule.Id+'~'+PMCvrg.Id, (SVMXC__Service_Order__c) sobjWorkOrd.clone());
                                    }
                                }
                                else{
                                    strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Location Name is blank for PM Coverage: '+ PMCvrg.Name;
                                }
                            }
                        }else{
                            strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'PM Coverage is not defined for this Preventive Maintenance Plan.';
                        }
                    }
                }
                
                //Insert the list of Work Orders record created above.
                if(mapScheduleIdWorkOrder != NULL && mapScheduleIdWorkOrder.values() != NULL && (mapScheduleIdWorkOrder.values()).size() > 0)
                {
                    //Get the technician available in the Work Order records.
                    for(SVMXC__Service_Order__c objWorkOrd : mapScheduleIdWorkOrder.values())
                    {
                        if(objWorkOrd.SVMXC__Group_Member__c != NULL)
                            setTechnicianIds.add(objWorkOrd.SVMXC__Group_Member__c);
                    }
                    
                    //Get the Org's default BusinessHours.
                    BusinessHours objDefaultBH = [Select id, TimeZoneSidKey from businesshours where IsDefault = true];
                    
                    //Query all the technicians associated with Work Order.
                    if(setTechnicianIds != NULL)
                    {
                        mapSFTechnician.putAll([Select Id, SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Active__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.IsActive, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey, SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive, SVMXC__Salesforce_User__r.TimeZoneSidKey from SVMXC__Service_Group_Members__c where ID IN: setTechnicianIds AND SVMXC__Active__c = true]);
                    }
                    
                    //For inactive SF User, reset SalesForce User field of Technician records.
                    for(SVMXC__Service_Group_Members__c objTech : mapSFTechnician.values())
                    {
                        if(objTech.SVMXC__Salesforce_User__c != NULL && objTech.SVMXC__Salesforce_User__r.IsActive == false)
                            objTech.SVMXC__Salesforce_User__c = NULL;
                    }
                    
                    //Update Technician, Preferred technician, Preferred start and end time of Work Order records.
                    for(String SourceId : mapScheduleIdWorkOrder.keySet())
                    {
                        mapScheduleIdWorkOrder.get(SourceId).SVMXC__Is_PM_Work_Order__c = true;
                        mapScheduleIdWorkOrder.get(SourceId).SVMXC__PM_Plan__c = objPMPlan.Id;
                        
                        //For inactive Technician, reset the technician field of Work Order record.
                        if(mapScheduleIdWorkOrder.get(SourceId).SVMXC__Group_Member__c != NULL && !mapSFTechnician.containsKey(mapScheduleIdWorkOrder.get(SourceId).SVMXC__Group_Member__c))
                        {
                            strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Inactive Technician found ' + mapScheduleIdWorkOrder.get(SourceId).SVMXC__Group_Member__c;
                            mapScheduleIdWorkOrder.get(SourceId).SVMXC__Group_Member__c = NULL;
                        }
                        
                        //Update the Preferred Technician field of Work Order record.
                        if(mapScheduleIdWorkOrder.get(SourceId).SVMXC__Group_Member__c != NULL)
                            mapScheduleIdWorkOrder.get(SourceId).SVMXC__Preferred_Technician__c = mapScheduleIdWorkOrder.get(SourceId).SVMXC__Group_Member__c ;
                        
                        //Update Preferred Start and End Time of Work Order record
                        if(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency__c != NULL && objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency_Unit__c != NULL)
                        {
                            system.debug(LoggingLevel.WARN, 'Populating WO preferred Stard Date & Enda date');
                            SVMXC__Service_Group_Members__c objTech = new SVMXC__Service_Group_Members__c(); 
                            objTech = mapSFTechnician.get(mapScheduleIdWorkOrder.get(SourceId).SVMXC__Group_Member__c);
                            date PMEndDate = objPMPlan.SVMXC__End_Date__c;
                            date StartDate = objPMSchedule.SVMXC__Scheduled_On__c;
                            date EndDate;
                            DateTime dtmStartDateTime;
                            DateTime dtmEndDateTime;
                            DateTime dtmPMPlanEndDateTime;
                            String timeZone;
                            
                            if(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency_Unit__c.toUpperCase() == 'WEEKS')
                                EndDate = objPMSchedule.SVMXC__Scheduled_On__c.addDays(integer.valueOf(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency__c * 7));
                            else if(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency_Unit__c.toUpperCase() == 'MONTHS')
                                EndDate = objPMSchedule.SVMXC__Scheduled_On__c.addMonths(integer.valueOf(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency__c));
                            else if(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency_Unit__c.toUpperCase() == 'YEARS')
                                EndDate = objPMSchedule.SVMXC__Scheduled_On__c.addYears(integer.valueOf(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency__c));
                            
                            //Get the TimeZone 
                            if(objTech != NULL && objTech.SVMXC__Salesforce_User__c != NULL && objTech.SVMXC__Salesforce_User__r.IsActive == true)
                                timeZone = objTech.SVMXC__Salesforce_User__r.TimeZoneSidKey;
                            else if(objTech != NULL && objTech.SVMXC__Service_Territory__c != NULL && objTech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c != NULL && objTech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.IsActive == true)
                                timeZone = objTech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
                            else
                                timeZone = objDefaultBH.TimeZoneSidKey; 
                            
                            //Get the start and end date time in respective timezone.
                            dtmStartDateTime = dcUtils.getDateTimeInTimezone(StartDate, Time.newInstance(0, 0, 0, 0), timeZone);
                            dtmEndDateTime = dcUtils.getDateTimeInTimezone(EndDate, Time.newInstance(23, 59, 59, 59), timeZone);
                            dtmPMPlanEndDateTime = dcUtils.getDateTimeInTimezone(PMEndDate, Time.newInstance(23, 59, 59, 59), timeZone);
                            
                            mapScheduleIdWorkOrder.get(SourceId).SVMXC__Preferred_Start_Time__c = dtmStartDateTime;
                            if(dtmEndDateTime <= dtmPMPlanEndDateTime)
                                mapScheduleIdWorkOrder.get(SourceId).SVMXC__Preferred_End_Time__c = dtmEndDateTime;
                            else
                                mapScheduleIdWorkOrder.get(SourceId).SVMXC__Preferred_End_Time__c = dtmPMPlanEndDateTime;
                        }
                    }
                    
                    if(strWOCreationBasedOn.toUpperCase() == 'ONE PER PLAN' && (typeOfPMPlan == 'PRODUCT' || typeOfPMPlan == 'ACCOUNT'))
                    {
                        if(mapScheduleIdWorkOrder.get(objPMSchedule.Id) != NULL && mapScheduleIdWorkOrder.get(objPMSchedule.Id).Id == NULL)
                        {
                            insert mapScheduleIdWorkOrder.values();
                            SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
                            objSVMXMap1.key = 'WORK_ORDER_RECORD';
                            objSVMXMap1.record = mapScheduleIdWorkOrder.values()[0];
                            objEngineResp.valueMap.add(objSVMXMap1);
                            
                            //Return the Work Order count.
                            String strWorkOrdCount = String.valueOf(mapScheduleIdWorkOrder.values().size());
                            objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('WORD_RECORD_COUNT', strWorkOrdCount));
                            
                            //Return the list Work Order Id for roll-back purpose.
                            List<String> lstWorkOrdIds = new List<String>(); 
                            lstWorkOrdIds.add(mapScheduleIdWorkOrder.values()[0].Id);
                            objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('WORK_ORDER_ID_LIST', '', lstWorkOrdIds));
                            strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Completed Work Order creation';
                        }
                    }
                    else
                    {
                        insert mapScheduleIdWorkOrder.values();
                        
                        //Return the Work Order count.
                        String strWorkOrdCount = String.valueOf(mapScheduleIdWorkOrder.values().size());
                        objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('WORD_RECORD_COUNT', strWorkOrdCount));
                        
                        //Return the list Work Order Id for roll-back purpose.
                        List<String> lstWorkOrdIds = new List<String>(); 
                        for(SVMXC__Service_Order__c objWorkOrd : mapScheduleIdWorkOrder.values())
                            lstWorkOrdIds.add(objWorkOrd.Id);
                        objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('WORK_ORDER_ID_LIST', '', lstWorkOrdIds));
                        strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Completed Work Order creation';
                    }
                    
                    //Create Case from Work Order
                    if(objPMWorkOrd.Id == NULL && objPMProcess.SVMXC__Include_Parent__c == true)
                    {
                        strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Creating Case';
                        Map<String, sObject> mapSourceRecIdCaseObj = new Map<String, sObject>();
                        
                        for(SVMXC__Service_Order__c objWorkOrd : mapScheduleIdWorkOrder.values())
                            mapSourceRecIdCaseObj.put(String.valueOf(objWorkOrd.get('Id')), allObjmap.get('Case').newSObject());

                        
                        //Call Apply Mapping utility class for mapping  
                        Map<String, Sobject> mapSourceIdCaseObj = objApplyMapping.getApplyMappingCore(CaseMapId, mapSourceRecIdCaseObj, true, allObjmap);
                        strLogger += '\n' + String.valueOfGmt(system.now()) + ': ----' + mapSourceIdCaseObj.keyset() + '-----' + mapSourceIdCaseObj.values();
                        mapSourceIdCaseObj = populateCaseFlds(mapSourceIdCaseObj);
                        
                        if(mapSourceIdCaseObj != NULL && (mapSourceIdCaseObj.values()).size() > 0)
                        {
                            insert mapSourceIdCaseObj.values();
                            
                            //Update Case Id in Work Order Case field
                            for(SVMXC__Service_Order__c objWorkOrd : mapScheduleIdWorkOrder.values())
                            {
                                if(mapSourceRecIdCaseObj.ContainsKey(String.valueOf(objWorkOrd.get('Id'))) && mapSourceRecIdCaseObj.get(String.valueOf(objWorkOrd.get('Id'))).Id != NULL)
                                    objWorkOrd.SVMXC__Case__c = mapSourceRecIdCaseObj.get(String.valueOf(objWorkOrd.get('Id'))).Id;
                            }
                            update mapScheduleIdWorkOrder.values();
                        }
                        strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Completed Case creation';
                    }
                }
                else
                {
                    //strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'There is no applicable PM Schedule available to process';
                    objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
                    return objEngineResp;
                }
                
                //Work Order Lines and PM History creation
                strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Creating Work Detail and PM History';
                if(typeOfPMPlan == 'ACCOUNT'){
                    if(strWOCreationBasedOn.toUpperCase() == 'ONE PER PLAN'){
                        if(mapScheduleIdWorkOrder.get(objPMSchedule.Id) != NULL){
                            String WOID = mapScheduleIdWorkOrder.get(objPMSchedule.Id).Id;
                            //Create PM History for each PM Schedule
                            lstPMHistory.add(createPMHistory(objPMPlan.Id, objPMSchedule.SVMXC__PM_Schedule_Definition__c, WOID, null, null, null));
                            //Create work detail for each Parts Used record with the following updates.
                            lstWorkOrdLine.addAll(createWorkDetailsFromReuiredParts(lstPartsUsed, mapReqPartsWorkDetail, WOID));
                        }
                    }
                }
                else if(typeOfPMPlan == 'PRODUCT')
                {
                    if(strWOCreationBasedOn.toUpperCase() == 'ONE PER PLAN')
                    {
                        if(mapScheduleIdWorkOrder.get(objPMSchedule.Id) != NULL)
                        {
                            if(lstPMCoverage != NULL && lstPMCoverage.size() > 0)
                            {
                                for(SVMXC__PM_Coverage__c PMCvrg : lstPMCoverage)
                                {
                                    String WOID = mapScheduleIdWorkOrder.get(objPMSchedule.Id).Id;
                                    //Create Work Order line of record type Product Serviced for each Installed Product
                                    lstWorkOrdLine.add(new SVMXC__Service_Order_Line__c(SVMXC__Serial_Number__c = PMCvrg.SVMXC__Product_Name__c, SVMXC__Service_Order__c = WOID, RecordTypeId = strProdServicedRType));
                                    //Create PM History for each Installed Product
                                    lstPMHistory.add(createPMHistory(objPMPlan.Id, objPMSchedule.SVMXC__PM_Schedule_Definition__c, WOID, PMCvrg.SVMXC__Product_Name__c, PMCvrg.Id, null));
                                    //Create work detail for each Parts Used record with the following updates.
                                    lstWorkOrdLine.addAll(createWorkDetailsFromReuiredParts(lstPartsUsed, mapReqPartsWorkDetail, WOID));
                                }
                            }
                            else
                            {
                                String WOID = mapScheduleIdWorkOrder.get(objPMSchedule.Id).Id;
                                //Create PM History for each PM Schedule
                                lstPMHistory.add(createPMHistory(objPMPlan.Id, objPMSchedule.SVMXC__PM_Schedule_Definition__c, WOID, null, null, null));
                                //Create work detail for each Parts Used record with the following updates.
                                lstWorkOrdLine.addAll(createWorkDetailsFromReuiredParts(lstPartsUsed, mapReqPartsWorkDetail, WOID));
                            }
                        }
                    }
                    else if(strWOCreationBasedOn.toUpperCase() == 'ONE PER PRODUCT')
                    {
                        for(SVMXC__PM_Coverage__c PMCvrg : lstPMCoverage)
                        {
                            if(mapScheduleIdWorkOrder.get(objPMSchedule.Id + '~' + PMCvrg.Id) != NULL)
                            {
                                String WOID = mapScheduleIdWorkOrder.get(objPMSchedule.Id + '~' + PMCvrg.Id).Id;
                                //Create PM History for each Installed Product
                                lstPMHistory.add(createPMHistory(objPMPlan.Id, objPMSchedule.SVMXC__PM_Schedule_Definition__c, WOID, PMCvrg.SVMXC__Product_Name__c, PMCvrg.Id, null));
                                //Create work detail for each Parts Used record with the following updates.
                                lstWorkOrdLine.addAll(createWorkDetailsFromReuiredParts(lstPartsUsed, mapReqPartsWorkDetail, WOID));
                            }
                        }
                    }
                }
                else if(typeOfPMPlan == 'LOCATION' ){
                    for(SVMXC__PM_Coverage__c PMCvrg : lstPMCoverage){
                        if(mapScheduleIdWorkOrder.get(objPMSchedule.Id + '~' + PMCvrg.Id) != NULL){
                            String WOID = mapScheduleIdWorkOrder.get(objPMSchedule.Id + '~' + PMCvrg.Id).Id;
                            //Create PM History for each Location
                            lstPMHistory.add(createPMHistory(objPMPlan.Id, objPMSchedule.SVMXC__PM_Schedule_Definition__c, WOID, PMCvrg.SVMXC__Product_Name__c, PMCvrg.Id, PMCvrg.SVMXC__Location_Name__c));
                            //Create work detail for each Parts Used record with the following updates.
                            lstWorkOrdLine.addAll(createWorkDetailsFromReuiredParts(lstPartsUsed, mapReqPartsWorkDetail, WOID));
                        }
                    }
                }
                //Insert Work Order line records
                if(lstWorkOrdLine != NULL && lstWorkOrdLine.size() > 0)
                    insert lstWorkOrdLine;
                
                //Insert PM History records
                if(lstPMHistory != NULL && lstPMHistory.size() > 0)
                    insert lstPMHistory;
                
                strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Completed Work Detail and PM History creation';
                system.debug(LoggingLevel.WARN, 'Number of SOQL queries that have been issued: '+ Limits.getQueries() +' of '+ Limits.getLimitQueries());
                
                //Task Creation
                if(objPMWorkOrd.Id == NULL && IsCreateTask && strTaskObjName.toUpperCase() != 'SVMX.NONE')
                {
                    strLogger += '\n' + String.valueOfgmt(system.now()) + ': ' + 'Creating Task';
                    for(String strScheduleId : mapScheduleIdWorkOrder.keySet())
                    {
                        SVMXC__Service_Order__c objWorkOrd = (SVMXC__Service_Order__c) mapScheduleIdWorkOrder.get(strScheduleId);
                        String ScheduleId = strWOCreationBasedOn.toUpperCase() == 'ONE PER PRODUCT' ? strScheduleId.split('~')[0] : strScheduleId;
                        
                        //Create Task only for Technician who is SF user.
                        if(objWorkOrd != NULL) 
            {
                            for(SVMXC__Task_Template__c objTask : lstTask)
                            {
                                
                                if(mapTaskTemplateIdTask.get(objTask.Id) != NULL)
                                {
                                    Sobject sObjTaskTemp = mapTaskTemplateIdTask.get(String.valueOf(objTask.Id));
                                    Sobject sObjTask = allObjmap.get(strTaskObjName).newSObject();
                                    sObjTask = sObjTaskTemp.clone();
                                    
                                    if(strTaskObjName.toUpperCase()  == 'TASK')
                                    {
                                            if(objWorkOrd.SVMXC__Group_Member__c != NULL && mapSFTechnician.containsKey(objWorkOrd.SVMXC__Group_Member__c))
                                            {
                                                system.debug(LoggingLevel.WARN, 'YES the object name is TASK');
                                                if(mapSFTechnician.get(objWorkOrd.SVMXC__Group_Member__c).SVMXC__Salesforce_User__c != NULL)
                                                {
                                                    sObjTask.put('OwnerId', mapSFTechnician.get(objWorkOrd.SVMXC__Group_Member__c).SVMXC__Salesforce_User__c);
                                                    sObjTask.put('WhatId', objWorkOrd.Id);
                                                    //Below condition is changed for fixing defect BAC-4088
                                                    //if(objTask.SVMXC__Priority__c == NULL )
                                                    if(sObjTask.get('Priority') == null )
                                                        sObjTask.put('Priority', TaskPriority);
                                                    if(objTask.SVMXC__Task_Title__c != NULL)
                                                        sObjTask.put('Subject', objTask.SVMXC__Task_Title__c);
                                                    if(objWorkOrd.SVMXC__Preferred_End_Time__c != NULL)
                                                        sObjTask.put('ActivityDate', date.valueOf(objWorkOrd.SVMXC__Preferred_End_Time__c));

                                                    lstSFTask.add(sObjTask);    
                                                }

                                            }       
                                    }
                                    else{
                                        sObjTask.put(objPMProcess.SVMXC__APL_Field_Name__c, objWorkOrd.Id);
                                        lstSFTask.add(sObjTask);
                                    }

                                }
                            }
                        }
                    }
                    if(lstSFTask != NULL && lstSFTask.size() > 0)
                        insert lstSFTask;
                    strLogger += '\n' + String.valueOfGmt(system.now()) + ': ' + 'Completed Task creation';
                }
            }
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            Database.rollback(sp);
            strLogger += '\nException: Type - '+ex.getTypeName();
            strLogger += '\nMessage - ' + ex.getMessage();
            objEngineResp.success = false;
            objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
            return objEngineResp;
        }
        objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('LOGGER', strLogger));
        objEngineResp.valueMap.add(new INTF_WebServicesDef.SVMXMap('SCHEDULE_DEF_ID', PMScheduleDefId));
        return objEngineResp;
    }
    
    public SVMXC__PM_History__c createPMHistory(String PMPlanID, String ScheduleDefnId, String WOID, String ProdId, String PMCvrgId, String LocID){
        
        SVMXC__PM_History__c objPMHistory = new SVMXC__PM_History__c(SVMXC__PM_Plan__c = PMPlanID, SVMXC__PM_Schedule_Definition__c = ScheduleDefnId, SVMXC__Work_Order__c = WOID, SVMXC__Work_Order_Created_on__c = dateTime.now());
        if(ProdId != null && ProdId.length() > 0)
            objPMHistory.SVMXC__Installed_Product__c = ProdId;
        if(PMCvrgId != null && PMCvrgId.length() > 0)
            objPMHistory.SVMXC__PM_Coverage__c = PMCvrgId;
        if(LocID != null && LocID.length() > 0)
            objPMHistory.SVMXC__Location__c = LocID;
        objPMHistory.SVMXC__SM_PM_Batch_ID__c = ScheduleDefnId + dateToStringFormat(objPMSchedule.SVMXC__Scheduled_On__c);    
        return objPMHistory;
    }
    
    public List<SVMXC__Service_Order_Line__c> createWorkDetailsFromReuiredParts(List<SVMXC__Required_Part__c> lstPartsUsed, Map<String,Sobject> mapReqPartsWorkDetail, String WOID){
        List<SVMXC__Service_Order_Line__c> lstWorkOrdLine = new List<SVMXC__Service_Order_Line__c>();
        for(SVMXC__Required_Part__c objPartsUsed : lstPartsUsed){
            if(mapReqPartsWorkDetail.containsKey(objPartsUsed.Id) && mapReqPartsWorkDetail.get(objPartsUsed.Id) != NULL){
                SVMXC__Service_Order_Line__c WOLine = (SVMXC__Service_Order_Line__c) mapReqPartsWorkDetail.get(String.valueOf(objPartsUsed.Id)).clone();
                WOLine.put('SVMXC__Service_Order__c', WOID);
                lstWorkOrdLine.add(WOLine);
            }
        }
        return lstWorkOrdLine;
    }
    
    // 19 Oct; Anchal
    // Method is updated to apply mapping from Schedule Object to WO record 1st and then the mapping from Product/ Location
    PREV_PMPlanUtils objPMPlanUtils = new PREV_PMPlanUtils(); //Added for the defect 046645 fix 
    public void updateSourceIdWOMap(String sourceId, Map<String, sObject> mapSourceIdTargetWorkOrdObj, SVMXC__PM_Plan__c objPMPlan, String scheduleDefinitionId){
        Sobject objWorkOrder = allObjmap.get('SVMXC__Service_Order__c').newSObject();
        objWorkOrder = updateAddressFields(objPMPlan, objWorkOrder);
        system.debug(ScheduleDefWOMapId + '------');
        if(String.isNotBlank(ScheduleDefWOMapId)){
            Map<String, sObject> mapScheduleDefIdTargetWorkOrdObj = new Map<String, sObject>();
            mapScheduleDefIdTargetWorkOrdObj.put(scheduleDefinitionId, objWorkOrder);
            //mapScheduleDefIdTargetWorkOrdObj = objApplyMapping.getApplyMappingCore(ScheduleDefWOMapId, mapScheduleDefIdTargetWorkOrdObj, true, allObjmap);
            //Commented above line and added below line for fixing defect 046645
            mapScheduleDefIdTargetWorkOrdObj = objPMPlanUtils.getApplyMappingPmPlan(ScheduleDefWOMapId, mapScheduleDefIdTargetWorkOrdObj, true, allObjmap);
            objWorkOrder = mapScheduleDefIdTargetWorkOrdObj.values();
        }
        
        mapSourceIdTargetWorkOrdObj.put(sourceId, objWorkOrder);
    }
    
    
    //Method to populate Location and Address field in the Work Order object
    public Sobject updateAddressFields(SVMXC__PM_Plan__c PMPlan, Sobject WorkOrder)
    {
        if(PMPlan.SVMXC__Location__c != NULL)
        {
            WorkOrder.put('SVMXC__Site__c', PMPlan.SVMXC__Location__c);
            if(PMPlan.SVMXC__Location__r.SVMXC__Country__c != NULL)
                WorkOrder.put('SVMXC__Country__c', PMPlan.SVMXC__Location__r.SVMXC__Country__c);
            if(PMPlan.SVMXC__Location__r.SVMXC__State__c != NULL)
                WorkOrder.put('SVMXC__State__c', PMPlan.SVMXC__Location__r.SVMXC__State__c);
            if(PMPlan.SVMXC__Location__r.SVMXC__City__c != NULL)
                WorkOrder.put('SVMXC__City__c', PMPlan.SVMXC__Location__r.SVMXC__City__c);
            if(PMPlan.SVMXC__Location__r.SVMXC__Street__c != NULL)
                WorkOrder.put('SVMXC__Street__c', PMPlan.SVMXC__Location__r.SVMXC__Street__c);
            if(PMPlan.SVMXC__Location__r.SVMXC__Zip__c != NULL)
                WorkOrder.put('SVMXC__Zip__c', PMPlan.SVMXC__Location__r.SVMXC__Zip__c);
            if(PMPlan.SVMXC__Location__r.SVMXC__Latitude__c != NULL)
                WorkOrder.put('SVMXC__Latitude__c', PMPlan.SVMXC__Location__r.SVMXC__Latitude__c);
            if(PMPlan.SVMXC__Location__r.SVMXC__Longitude__c != NULL)
                WorkOrder.put('SVMXC__Longitude__c', PMPlan.SVMXC__Location__r.SVMXC__Longitude__c);
        }
        return WorkOrder;
    }
    
    //Method to populate Work Order Assigned to fields from PM Process definition
    public Map<String, sObject> populateWorkOrderFlds(Map<String, sObject> mapSorcIdWorkOrd)
    {
        if(objPMProcess.SVMXC__Assign_Work_Order_To__c != NULL && mapSorcIdWorkOrd != NULL && mapSorcIdWorkOrd.size() > 0 )
        {
            for(String SourceId : mapSorcIdWorkOrd.keySet())
            {
                //Order to assign Primary Technician is: Installed Product's Technician, Service Contract's Technician, Account's Technician.
                if(objPMProcess.SVMXC__Assign_Work_Order_To__c == 'Primary Technician')
                {
                    if(typeOfPMPlan == 'ACCOUNT' || typeOfPMPlan == 'PRODUCT')
                    {
                        if(strWOCreationBasedOn.toUpperCase() == 'ONE PER PLAN')
                        {
                            if(mapSorcIdWorkOrd.get(SourceId) != NULL && objPMPlan.SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c != NULL)
                                mapSorcIdWorkOrd.get(SourceId).put('SVMXC__Group_Member__c', objPMPlan.SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c);
                            else if(mapSorcIdWorkOrd.get(SourceId) != NULL && objPMPlan.SVMXC__Account__r.SVMXC__Preferred_Technician__c != NULL)
                                mapSorcIdWorkOrd.get(SourceId).put('SVMXC__Group_Member__c', objPMPlan.SVMXC__Account__r.SVMXC__Preferred_Technician__c);
                        }
                        else if(strWOCreationBasedOn.toUpperCase() == 'ONE PER PRODUCT')
                        {
                            if(mapSorcIdWorkOrd.get(SourceId) != NULL && mapIBTechnician.get(SourceId) != NULL)
                                mapSorcIdWorkOrd.get(SourceId).put('SVMXC__Group_Member__c', mapIBTechnician.get(SourceId));
                        }
                    }
                    else if(typeOfPMPlan == 'LOCATION')
                    {
                        if(mapSorcIdWorkOrd.get(SourceId) != NULL && mapLocationTechnician.get(SourceId) != NULL)
                            mapSorcIdWorkOrd.get(SourceId).put('SVMXC__Group_Member__c', mapLocationTechnician.get(SourceId));
                    }
                }
                else if(objPMProcess.SVMXC__Assign_Work_Order_To__c == 'Team' && objPMProcess.SVMXC__Assign_To_Service_Team__c != NULL)
                    mapSorcIdWorkOrd.get(SourceId).put('SVMXC__Service_Group__c', objPMProcess.SVMXC__Assign_To_Service_Team__c);
                else if(objPMProcess.SVMXC__Assign_Work_Order_To__c == 'Dispatcher' && objPMProcess.SVMXC__Assign_To_Dispatcher__c != NULL)
                    mapSorcIdWorkOrd.get(SourceId).put('OwnerId', objPMProcess.SVMXC__Assign_To_Dispatcher__c);
                else if(objPMProcess.SVMXC__Assign_Work_Order_To__c == 'Technician' && objPMProcess.SVMXC__Assign_To_Technician__c != NULL)
                    mapSorcIdWorkOrd.get(SourceId).put('SVMXC__Group_Member__c', objPMProcess.SVMXC__Assign_To_Technician__c);
                else if(objPMProcess.SVMXC__Assign_Work_Order_To__c == 'Queue' && objPMProcess.SVMXC__Assign_To_Queue__c != NULL)
                    mapSorcIdWorkOrd.get(SourceId).put('OwnerId', objPMProcess.SVMXC__Assign_To_Queue__c);
            }
        }
        return mapSorcIdWorkOrd;
    }
    
    //Method to populate Case Assigned to fields from PM Plan Process definition
    public Map<String, sObject> populateCaseFlds(Map<String, sObject> mapSourceIdCase)
    {
        if(mapSourceIdCase != NULL && mapSourceIdCase.size() > 0)
        {
            if(objPMProcess.SVMXC__Assign_Case_To__c != NULL)
            {
                for(String SourceId : mapSourceIdCase.keySet())
                {
                    mapSourceIdCase.get(SourceId).put('SVMXC__PM_Plan__c', objPMPlan.Id);
                    mapSourceIdCase.get(SourceId).put('SVMXC__Is_PM_Case__c', true);
                    
                    if(objPMProcess.SVMXC__Assign_Case_To__c == 'User' && objPMProcess.SVMXC__Case_Assign_To_User__c != NULL)
                        mapSourceIdCase.get(SourceId).put('OwnerId', objPMProcess.SVMXC__Case_Assign_To_User__c);
                    else if(objPMProcess.SVMXC__Assign_Case_To__c == 'Queue' && objPMProcess.SVMXC__Case_Assign_To_Queue__c != NULL)
                        mapSourceIdCase.get(SourceId).put('OwnerId', objPMProcess.SVMXC__Case_Assign_To_Queue__c);
                }
            }
            else
            {
                for(String SourceId : mapSourceIdCase.keySet())
                {
                    mapSourceIdCase.get(SourceId).put('SVMXC__PM_Plan__c', objPMPlan.Id);
                    mapSourceIdCase.get(SourceId).put('SVMXC__Is_PM_Case__c', true);
                }
            }
        }
        return mapSourceIdCase;
    }
    
    /**
     * BAC - 770 Time Based PM
     * Method to check if the next work order generation to be rescheduled or not based on PM plan configuration
     * 
     * @returns Returns boolean, If true WO creation will be rescheduled.
     */
    boolean recalculateNextSchedule(){
        
        boolean rescheduleWOCreation = false;
        String queryStr = 'SELECT Id, SVMXC__Work_Order__c, SVMXC__Work_Order_Closed_on__c, SVMXC__Work_Order_Created_on__c, ' + 
                                                   'SVMXC__PM_Plan__c,SVMXC__Work_Order__r.SVMXC__Preferred_Start_Time__c, SVMXC__SM_PM_Batch_ID__c'; 
        String activityDateField = objPMPlan.SVMXC__SM_Adjustment_Activity_Date__c;                                           
        
        if(activityDateField != null && activityDateField != ''){
            queryStr +=   ', SVMXC__Work_Order__r.' +  activityDateField ;                                                  
        }

        String pmBatchID = objPMSchedule.SVMXC__PM_Schedule_Definition__c + dateToStringFormat(objPMSchedule.SVMXC__Last_Run_Date__c);

        queryStr += ' FROM SVMXC__PM_History__c WHERE SVMXC__PM_Plan__c = \'' +  objPMPlan.Id  + '\'  AND SVMXC__PM_Schedule_Definition__c = \'' + objPMSchedule.SVMXC__PM_Schedule_Definition__c + '\' AND SVMXC__Work_Order_Closed_on__c = null ' +
                                                   + ' AND SVMXC__Work_Order__c != null AND SVMXC__SM_PM_Batch_ID__c = \''+ pmBatchID + '\' ORDER BY LastModifiedDate DESC';
        System.debug(LoggingLevel.INFO, 'Query String : ' + queryStr);                                                   
        
        List<SVMXC__PM_History__c> pmHistoryList = Database.Query(queryStr); 
        List<SVMXC__PM_History__c> updateHistoryList = new List<SVMXC__PM_History__c>();
        List<SVMXC__PM_History__c> openHistoryList;
        Date woClosedDate;
        Date woStartDate; 
       
        for(SVMXC__PM_History__c pmHistoryRec : pmHistoryList){
            
            SObject woObj = pmHistoryRec.getsObject('SVMXC__Work_Order__r');
            
            Date woActivityDate = (woObj.get(activityDateField) != null)? Date.valueOf(woObj.get(activityDateField)):null;
            
            woStartDate = Date.valueOf(woObj.get('SVMXC__Preferred_Start_Time__c'));

            if(woActivityDate != null){
                //updateHistoryList = new List<SVMXC__PM_History__c>();
                pmHistoryRec.SVMXC__Work_Order_Closed_on__c = woActivityDate;
                updateHistoryList.add(pmHistoryRec);  

                if(woClosedDate == null){
                    woClosedDate = woActivityDate;
                }

                if(objPMPlan.SVMXC__SM_Activity_Date_To_Consider__c != null){
                    if(objPMPlan.SVMXC__SM_Activity_Date_To_Consider__c.equalsIgnoreCase('First Activity')){
                        if(woClosedDate != null && woActivityDate < woClosedDate ){
                            woClosedDate = woActivityDate;
                        }    
                    }else{
                        if(woClosedDate != null && woActivityDate > woClosedDate ){
                            woClosedDate = woActivityDate;
                        }    
                    }    
                }            
            }else if(objPMPlan.SVMXC__SM_Activity_Date_To_Consider__c != null && objPMPlan.SVMXC__SM_Activity_Date_To_Consider__c.equalsIgnoreCase('Last Activity')){
                woClosedDate = null;
                break;
            }else if(objPMPlan.SVMXC__SM_Activity_Date_To_Consider__c != null && woClosedDate != null){
                pmHistoryRec.SVMXC__Work_Order_Closed_on__c = woClosedDate;
                updateHistoryList.add(pmHistoryRec);  
            }else{
                if(openHistoryList == null){
                    openHistoryList = new List<SVMXC__PM_History__c>();
                }
                openHistoryList.add(pmHistoryRec);
            }
        }   

        if(openHistoryList != null && woClosedDate != null){
            for(SVMXC__PM_History__c historyRec : openHistoryList){
                historyRec.SVMXC__Work_Order_Closed_on__c = woClosedDate;
                updateHistoryList.add(historyRec);
            }
        }

        Date nextIntervalDate;
        
        System.debug(LoggingLevel.INFO, 'WO Start Date : ' + woStartDate);
        System.debug(LoggingLevel.INFO, 'WO Closed Date : ' + woClosedDate);
        
        if(woStartDate != null){
            
            if(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency_Unit__c.equalsIgnoreCase('Weeks')){
                nextIntervalDate = woStartDate.addDays(integer.valueOf(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency__c) * 7);
            }else if(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency_Unit__c.equalsIgnoreCase('Months')){
                nextIntervalDate = woStartDate.addMonths(integer.valueOf(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency__c));
            }else if(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency_Unit__c.equalsIgnoreCase('Years')){
                nextIntervalDate = woStartDate.addYears(integer.valueOf(objPMSchedule.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency__c));
            }
        
            Integer timeIntervalInDays = woStartDate.daysBetween(nextIntervalDate);
            Decimal maxValue = (objPMPlan.SVMXC__SM_Adjustment_Max__c != null && objPMPlan.SVMXC__SM_Adjustment_Max__c <= timeIntervalInDays) ? objPMPlan.SVMXC__SM_Adjustment_Max__c : timeIntervalInDays;
            // If closed date is null during the time of next scheduled run, then dynamic time based is not applied. Hence replacing it with zero so that next run will not be rescheduled
            Integer dateDiff = (woClosedDate != null ) ? (woStartDate.daysBetween(woClosedDate)) : 0;  

            System.debug(LoggingLevel.INFO, 'dateDiff : ' + dateDiff);

            if(dateDiff > objPMPlan.SVMXC__SM_Adjustment_Min__c && dateDiff <= maxValue){
                rescheduleWOCreation = true;

                if(objPMPlan.SVMXC__SM_Adjustment_Type__c.equalsIgnoreCase('Actual')){  //Changed to Actual
                    objPMSchedule.SVMXC__Scheduled_On__c = objPMSchedule.SVMXC__Scheduled_On__c.addDays(dateDiff); 
                    System.debug(LoggingLevel.INFO, 'dateDiff : ' + dateDiff);
                }else if(objPMPlan.SVMXC__SM_Adjustment_Type__c.equalsIgnoreCase('Fixed')){

                    if(objPMPlan.SVMXC__SM_Adjustment_Unit__c.equalsIgnoreCase('Days')){
                        objPMSchedule.SVMXC__Scheduled_On__c = objPMSchedule.SVMXC__Scheduled_On__c.addDays(Integer.valueof(objPMPlan.SVMXC__SM_Adjustment_Value__c)); 
                    }else if(objPMPlan.SVMXC__SM_Adjustment_Unit__c.equalsIgnoreCase('Weeks')){
                        objPMSchedule.SVMXC__Scheduled_On__c = objPMSchedule.SVMXC__Scheduled_On__c.addDays(Integer.valueof(objPMPlan.SVMXC__SM_Adjustment_Value__c)*7); 
                    }else if(objPMPlan.SVMXC__SM_Adjustment_Unit__c.equalsIgnoreCase('Months')){
                        objPMSchedule.SVMXC__Scheduled_On__c = objPMSchedule.SVMXC__Scheduled_On__c.addMonths(Integer.valueof(objPMPlan.SVMXC__SM_Adjustment_Value__c)); 
                    }else if(objPMPlan.SVMXC__SM_Adjustment_Unit__c.equalsIgnoreCase('Years')){
                        objPMSchedule.SVMXC__Scheduled_On__c = objPMSchedule.SVMXC__Scheduled_On__c.addYears(Integer.valueof(objPMPlan.SVMXC__SM_Adjustment_Value__c)); 
                    }
                    
                }
            }else if(dateDiff > maxValue){
                rescheduleWOCreation = true;
                /*Max value can be less than frequency of recurrence, if the work order gets closed by more than max value, it should be delayed by frequency
                  of recurrence and not by Max value*/   
                //objPMSchedule.SVMXC__Scheduled_On__c = objPMSchedule.SVMXC__Scheduled_On__c.addDays(Integer.valueof(timeIntervalInDays));  
                objPMSchedule.SVMXC__Scheduled_On__c = objPMSchedule.SVMXC__Scheduled_On__c.addDays(Integer.valueof(maxValue));  
            }

        }
        
        if(updateHistoryList != null && !updateHistoryList.isEmpty()){
            System.debug(LoggingLevel.INFO, 'PM History List for Update : ' + updateHistoryList);
            update pmHistoryList;
        }

        System.debug(LoggingLevel.INFO, 'objPMSchedule.SVMXC__Scheduled_On__c :' + objPMSchedule.SVMXC__Scheduled_On__c + ' rescheduleWOCreation :' + rescheduleWOCreation);

        return rescheduleWOCreation;

    }

    String dateToStringFormat(Date dt){
        //Date scheduleDate = objPMSchedule.SVMXC__Scheduled_On__c;   
        return String.valueof(dt.Month()).leftpad(2,'0') + String.valueof(dt.Day()).leftpad(2,'0') + String.valueof(dt.Year());
 
    }

    /*public triggerCounterBasedPMCalculation(Map<String,Counter_Details__c> counterDefinitionReadingsMap){
        
        List<SVMXC__PM_Schedule__c> pmScheduleList = [SELECT SVMXC__PM_Plan__c,lastReading, nextReading,SVMXC__PM_Schedule_Definition__r.SVMXC__SM_Counter_Definition__c FROM SVMXC__PM_Schedule__c WHERE SVMXC__PM_Schedule_Definition__r.SVMXC__SM_Counter_Definition__c IN : counterDefinitionReadingsMap.keySet() 
                                              AND SVMXC__PM_Plan__r.SVMXC__Start_Date__c <= TODAY  AND SVMXC__PM_Plan__r.SVMXC__END_Date__c >= TODAY];
        Map<Id,List<SVMXC__PM_Schedule__c>> pmPlanScheduleMap = new Map<Id,List<SVMXC__PM_Schedule__c>>();                                       
                                              
        for(SVMXC__PM_Schedule__c pmScheduleRec : pmScheduleList){
        
            if(pmScheduleRec.SVMXC__PM_Plan__c != null){

                if(pmPlanScheduleMap.containsKey(pmScheduleRec.SVMXC__PM_Plan__c)){
                    List<SVMXC__PM_Schedule__c> tempList = pmPlanScheduleMap.get(pmScheduleRec.SVMXC__PM_Plan__c); 
                }
                tempList.add(pmScheduleRec);
                pmPlanScheduleMap.put(pmScheduleRec.SVMXC__PM_Plan__c,pmScheduleRec);
            }
        }                                              

        for(SVMXC__PM_Coverage__c pmCoverageRec : [SELECT Id,SVMXC__Product_Name__c,SVMXC__PM_Plan__c FROM SVMXC__PM_Coverage__c WHERE 
                                                   SVMXC__PM_Plan__c IN : pmPlanScheduleMap.keyset()]){
            
            if(pmCoverageRec.SVMXC__Product_Name__c != null && pmCoverageRec.SVMXC__PM_Plan__c != null){
                
                if(pmPlanScheduleMap.containsKey(pmCoverageRec.SVMXC__PM_Plan__c)){
                
                    for(SVMXC__PM_Schedule__c pmScheduleRec : pmPlanScheduleMap.get(pmCoverageRec.SVMXC__PM_Plan__c)){
                        String uniqueId = pmScheduleRec.SVMXC__PM_Schedule_Definition__r.SVMXC__SM_Counter_Definition__c + pmCoverageRec.SVMXC__Product_Name__c;    
                        
                        if(counterDefinitionReadingsMap.containsKey(uniqueId)){
                           Counter_Details__c counterReadingRec = counterDefinitionReadingsMap.get(uniqueId);

                           nextCalculatedReading = pmScheduleRec.lastReading + (pmScheduleRec.SVMXC__PM_Schedule_Definition__r.SVMXC__Frequency__c * SVMXC__SM_Threshold__c);

                           if( counterReadingRec.SVMXC__Counter_Reading__c > nextCalculatedReading){
                                createWorkOrders(); //TBD
                           }
                        }
                    }
                    
                }
            }
        }
    }  */


    //Custom Labels
    public String getTAG001(){return system.label.PREV006_TAG001;} //'Processing of Preventive Maintenance plans has been completed with the following results:'
    public String getTAG002(){return system.label.PREV006_TAG002;} //'Preventive Maintenance Process: '
    public String getTAG003(){return system.label.PREV006_TAG003;} //'Number of qualified Preventive Maintenance Plans: '
    public String getTAG004(){return system.label.PREV006_TAG004;} //'Preventive Maintenance Plan: '
    public String getTAG005(){return system.label.PREV006_TAG005;} //'Number of Work Orders created: '
    public String getTAG006(){return 'No valid PM Schedule (Time Based) is available for this Preventive Maintenance Plan.';}
    public String getTAG007(){return system.label.PREV006_TAG007;} //'Account is not available to create Work Order '
    public String getTAG008(){return system.label.PREV006_TAG008;} //'Service Contract is not available to create Work Order: '
    public String getTAG009(){return system.label.COMM001_TAG091;} //'Status: '

}