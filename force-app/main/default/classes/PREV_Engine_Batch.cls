global with sharing class PREV_Engine_Batch implements Database.Batchable<sObject>, Database.Stateful
{
    global Map<String, Integer> mapPMPlanIdVsNumberOfOccurencesInStart = new Map<String, Integer>(); //Added for the story BAC-4429
    global Map<String, Integer> mapPMPlanIdVsNumberOfOccurencesInExecute = new Map<String, Integer>(); //Added for the story BAC-4429
    global Map<String, List<INTF_WebservicesDef.INTF_SFMResponse>> mapPMPlanIdVsListEngineResp = new Map<String,List<INTF_WebservicesDef.INTF_SFMResponse>>(); //Added for the story BAC-4429
    global Set<String> setProcessIds = new Set<String>();
    global Map<String, List<String>> mapPMProcessIdPMPlanLst; // Unused locked variable
    global Map<String, String> mapPMPlanIdPMProcessId; // Unused locked variable
    global Map<String,SVMXC__ServiceMax_Processes__c> mapPMProcess; // Unused locked variable
    global Map<Id, Id> mapPMPlanIdPMProcessId2 = new Map<Id, Id>();
    global Map<Id, SVMXC__ServiceMax_Processes__c> mapPMProcess2 = new Map<Id, SVMXC__ServiceMax_Processes__c>();
    global List<SVMXC.INTF_WebservicesDef.INTF_SFMResponse> lstEngineResp = new List<SVMXC.INTF_WebservicesDef.INTF_SFMResponse>();
    global Map<Id, Map<Id, List<SVMXC__PM_Coverage__c>>> mapPMPlanIdPMScheduleLstPMCvrgLst = new Map<Id, Map<Id, List<SVMXC__PM_Coverage__c>>>();
    global Map<Id, SVMXC__PM_Plan__c> mapPMPlan = new Map<Id, SVMXC__PM_Plan__c>();
    global Map<String, SVMXC__Service_Order__c> mapScheduleIdWorkOrder = new Map<String, SVMXC__Service_Order__c>();
    public List<String> lstWorkOrdIDs = new List<String>();
    public boolean IsCreateTask = false;
    public boolean IsLocBasedPMEnabled = false;
    public String TaskPriority = '';
    public Integer InstalledProdCount = 200;
    public Integer BatchNumberCount = 0;
    
    global Iterable<sObject> start(Database.BatchableContext scPMEngine)
    {
        try
        {
            boolean isAllPMPlan = false;
            List<SVMXC__PM_Plan__c> lstPMPlans = new List<SVMXC__PM_Plan__c>();
            Map<String,String> mapEntryCritIdPMProcessId = new Map<String,String>();
            Map<Id, Set<Id>> mapPMProcessIdSetPMPlanId = new Map<Id, Set<Id>>();
            
            //Get the PM Process Definition
            mapPMProcess2.putAll([Select SVMXC__Name__c, SVMXC__Frequency__c, SVMXC__Parent_Object__c, SVMXC__Submodule__c, SVMXC__Target_Object_Name__c, SVMXC__Process1__c, SVMXC__APL_Field_Name__c, SVMXC__Process2__c, SVMXC__Process3__c, SVMXC__Preferred_Tech_Enabled__c, Id, SVMXC__Product_Match_Enabled__c, SVMXC__Module__c, SVMXC__Number_of_Lookup_Records__c, SVMXC__Node_Parent__c, SVMXC__Create_Work_Order__c, SVMXC__Assign_Work_Order_To__c, SVMXC__Assign_To_Dispatcher__c, SVMXC__Assign_To_Queue__c, SVMXC__Assign_To_Service_Team__c, SVMXC__Assign_To_Technician__c, SVMXC__Include_Parent__c,SVMXC__Assign_Case_To__c,SVMXC__Case_Assign_To_User__c, SVMXC__Case_Assign_To_Queue__c, SVMXC__Process__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__Capture_Log__c From SVMXC__ServiceMax_Processes__c where Id =: setProcessIds AND SVMXC__Active__c = true]);
            if(mapPMProcess2 != null && mapPMProcess2.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c currPMProcess : mapPMProcess2.values())
                    mapPMProcessIdSetPMPlanId.put(currPMProcess.Id, new Set<Id>());
            }
            
            if(mapPMProcess2 != null && mapPMProcess2.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c currPMProcess : mapPMProcess2.values())
                {
                    if(currPMProcess.SVMXC__Module__c != null)
                    {
                        mapEntryCritIdPMProcessId.put(currPMProcess.SVMXC__Module__c, currPMProcess.Id);
                    }
                    else
                    {
                        isAllPMPlan = true;

                        /*
                            For Time Based, Querying only PM Plans of Schedule Type 'Time Based', Blank value is also considered as Time Based. Hence, updated the below query
                            to query only for Time based records.
                        */
                        lstPMPlans = [Select SVMXC__Coverage_Type__c, SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c, SVMXC__End_Date__c, SVMXC__Account__r.SVMXC__Preferred_Technician__c, SVMXC__Service_Contract__c, SVMXC__Location__c, 
                                      SVMXC__Location__r.SVMXC__Country__c, SVMXC__Location__r.SVMXC__State__c, SVMXC__Location__r.SVMXC__City__c, SVMXC__Location__r.SVMXC__Street__c, SVMXC__Location__r.SVMXC__Zip__c, SVMXC__Location__r.SVMXC__Latitude__c, 
                                      SVMXC__Location__r.SVMXC__Longitude__c, SVMXC__Account__c, Name, Id, OwnerId, Owner.isActive, SVMXC__SM_Adjustment_Type__c,SVMXC__SM_Adjustment_Activity_Date__c,SVMXC__SM_Adjustment_Unit__c, SVMXC__SM_Adjustment_Value__c,
                                      SVMXC__SM_Activity_Date_To_Consider__c,SVMXC__SM_Adjustment_Max__c,SVMXC__SM_Adjustment_Min__c    
                                      From SVMXC__PM_Plan__c where SVMXC__Status__c = 'Active' AND SVMXC__Start_Date__c != NULL AND SVMXC__End_Date__c != NULL AND SVMXC__Start_Date__c <= today and SVMXC__End_Date__c >= today AND
                                      SVMXC__Schedule_Type__c IN ('','Time Based') ];   

                        mapPMPlan.putAll(lstPMPlans);
                        
                        for(SVMXC__PM_Plan__c objPMPlan: lstPMPlans)
                        {
                            mapPMPlanIdPMProcessId2.put(objPMPlan.Id, currPMProcess.Id);
                            mapPMProcessIdSetPMPlanId.get(currPMProcess.Id).add(objPMPlan.Id);
                        }
                        break;
                    }
                }
                
                if(isAllPMPlan == false && lstPMPlans.size() == 0 && mapEntryCritIdPMProcessId.size() > 0)
                {
                    List<SVMXC__ServiceMax_Processes__c> lstEntryCritExp = new List<SVMXC__ServiceMax_Processes__c>();
                    lstEntryCritExp = [Select Id, SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Id = :mapEntryCritIdPMProcessId.keySet()];
                    
                    for(SVMXC__ServiceMax_Processes__c objEntryCritExp : lstEntryCritExp)
                    {
                        String strWhereClause = null;
                        List<SVMXC__PM_Plan__c> lstPMPlansTemp = new List<SVMXC__PM_Plan__c>();
                        
                        if(objEntryCritExp.SVMXC__Parent_Object_Criteria__c != null)
                        {
                            strWhereClause = ' (' + objEntryCritExp.SVMXC__Parent_Object_Criteria__c + ' )';
                            if(strWhereClause != null && strWhereClause.length() > 0)
                                lstPMPlansTemp = database.query('Select SVMXC__Coverage_Type__c, SVMXC__Location__c, SVMXC__Location__r.SVMXC__Country__c, SVMXC__Location__r.SVMXC__State__c, SVMXC__Location__r.SVMXC__City__c, SVMXC__Location__r.SVMXC__Street__c, SVMXC__Location__r.SVMXC__Zip__c, SVMXC__Location__r.SVMXC__Latitude__c, SVMXC__Location__r.SVMXC__Longitude__c, SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c, SVMXC__Account__r.SVMXC__Preferred_Technician__c, SVMXC__End_Date__c, SVMXC__Service_Contract__c, SVMXC__Account__c, Name, Id, OwnerId, Owner.isActive,SVMXC__SM_Adjustment_Type__c,SVMXC__SM_Adjustment_Activity_Date__c, SVMXC__SM_Adjustment_Unit__c, SVMXC__SM_Adjustment_Value__c,' +
                                      + ' SVMXC__SM_Activity_Date_To_Consider__c,SVMXC__SM_Adjustment_Max__c,SVMXC__SM_Adjustment_Min__c From SVMXC__PM_Plan__c where SVMXC__Status__c = \'Active\' AND SVMXC__Start_Date__c != NULL AND SVMXC__End_Date__c != NULL AND SVMXC__Start_Date__c <= today AND SVMXC__End_Date__c >= today AND ' + strWhereClause);
                            else
                                lstPMPlansTemp = database.query('Select SVMXC__Coverage_Type__c, SVMXC__Location__c, SVMXC__Location__r.SVMXC__Country__c, SVMXC__Location__r.SVMXC__State__c, SVMXC__Location__r.SVMXC__City__c, SVMXC__Location__r.SVMXC__Street__c, SVMXC__Location__r.SVMXC__Zip__c, SVMXC__Location__r.SVMXC__Latitude__c, SVMXC__Location__r.SVMXC__Longitude__c, SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c, SVMXC__Account__r.SVMXC__Preferred_Technician__c, SVMXC__End_Date__c, SVMXC__Service_Contract__c, SVMXC__Account__c, Name, Id, OwnerId, Owner.isActive,SVMXC__SM_Adjustment_Type__c,SVMXC__SM_Adjustment_Activity_Date__c, SVMXC__SM_Adjustment_Unit__c, SVMXC__SM_Adjustment_Value__c,' +
                                      + ' SVMXC__SM_Activity_Date_To_Consider__c,SVMXC__SM_Adjustment_Max__c,SVMXC__SM_Adjustment_Min__c From SVMXC__PM_Plan__c where SVMXC__Status__c = \'Active\' AND SVMXC__Start_Date__c != NULL AND SVMXC__End_Date__c != NULL AND SVMXC__Start_Date__c <= today AND SVMXC__End_Date__c >= today');
                            
                            
                            if(lstPMPlansTemp != null && lstPMPlansTemp.size() > 0)
                            {
                                lstPMPlans.addAll(lstPMPlansTemp);
                                mapPMPlan.putAll(lstPMPlans);
                            }
                            for(SVMXC__PM_Plan__c objPMPlan : lstPMPlansTemp)
                            {
                                mapPMPlanIdPMProcessId2.put(objPMPlan.Id, mapEntryCritIdPMProcessId.get(objEntryCritExp.Id));
                                mapPMProcessIdSetPMPlanId.get(mapEntryCritIdPMProcessId.get(objEntryCritExp.Id)).add(objPMPlan.Id); 
                            }
                        }
                    }
                }
            }
            
            //Get the PM settings.
            List<String> lstSubModules = new List<String>{'PREV001', 'PREV003','PREV004'};
            Map<String, Map<String, String>> AllsvmxSettingList = new Map<String, Map<String, String>>();
            AllsvmxSettingList = new SVMXC.COMM_Utils_ManageSettings().SVMX_getSettingList(lstSubModules);
            Map<String, String> svmxSettingListPREV001 = AllsvmxSettingList.get('PREV001');
            Map<String, String> svmxSettingListPREV003 = AllsvmxSettingList.get('PREV003');
            Map<String, String> svmxSettingListPREV004 = AllsvmxSettingList.get('PREV004');
            
            if(svmxSettingListPREV001.containsKey('SET003') && svmxSettingListPREV001.get('SET003').toUpperCase() == 'TRUE')
                IsLocBasedPMEnabled = boolean.valueOf(svmxSettingListPREV001.get('SET003'));
            
            if(svmxSettingListPREV003.containsKey('SET002') && svmxSettingListPREV003.get('SET002') != NULL)
                InstalledProdCount = Integer.valueOf(svmxSettingListPREV003.get('SET002'));
            
            if(svmxSettingListPREV004.containsKey('SET001') && svmxSettingListPREV004.get('SET001').toUpperCase() == 'TRUE')
                IsCreateTask = boolean.valueOf(svmxSettingListPREV004.get('SET001'));
            
            if(svmxSettingListPREV004.containsKey('SET002') && svmxSettingListPREV004.get('SET002') != NULL)
                TaskPriority = svmxSettingListPREV004.get('SET002');
            
            for(SVMXC__PM_Plan__c PMPlan : lstPMPlans)
            {
                if(!mapPMPlanIdPMScheduleLstPMCvrgLst.containsKey(PMPlan.Id))
                    mapPMPlanIdPMScheduleLstPMCvrgLst.put(PMPlan.Id, new Map<Id, List<SVMXC__PM_Coverage__c>>());
            }
            
            //PM Plan Id and List of PM Coverage Map creation
            /*Map<Id, List<SVMXC__PM_Coverage__c>> mapPMPlanIdPMCvrgLst = new Map<Id, List<SVMXC__PM_Coverage__c>>();
            for(SVMXC__PM_Coverage__c currProdCvrg : [Select SVMXC__Product_Name__c, Name, SVMXC__Product_Name__r.SVMXC__Preferred_Technician__c, SVMXC__PM_Plan__c, SVMXC__Location_Name__c, SVMXC__Location_Name__r.SVMXC__Account__c, SVMXC__Location_Name__r.SVMXC__Account__r.SVMXC__Preferred_Technician__c, Id from SVMXC__PM_Coverage__c where SVMXC__PM_Plan__c =: mapPMPlanIdPMScheduleLstPMCvrgLst.keySet()])
            {
                if(!mapPMPlanIdPMCvrgLst.containsKey(currProdCvrg.SVMXC__PM_Plan__c))
                    mapPMPlanIdPMCvrgLst.put(currProdCvrg.SVMXC__PM_Plan__c, new List<SVMXC__PM_Coverage__c>());
                mapPMPlanIdPMCvrgLst.get(currProdCvrg.SVMXC__PM_Plan__c).add(currProdCvrg);
            }*/
            //Commented above code and added below one for the story BAC-4395
            //--------Start--------Added for the story BAC-4395
            Map<Id, Integer> mapPMPlanIdPMCvrgCount = new Map<Id, Integer>();
            Map<Id, Map<Id, Integer>> mapPMPlanIdPMScheduleLstPMCvrgCount = new Map<Id, Map<Id, Integer>>();
            
            List<AggregateResult> lstPMCoverageAR = [SELECT SVMXC__PM_Plan__c, Count(Id) FROM SVMXC__PM_Coverage__c WHERE SVMXC__PM_Plan__c =: mapPMPlanIdPMScheduleLstPMCvrgLst.keySet() Group by SVMXC__PM_Plan__c];
            
            for(AggregateResult objAggregateResult : lstPMCoverageAR){
                mapPMPlanIdPMCvrgCount.put((Id)objAggregateResult.get('SVMXC__PM_Plan__c'), (Integer)objAggregateResult.get('expr0'));
                System.debug(objAggregateResult.get('SVMXC__PM_Plan__c') +'-----'+objAggregateResult.get('expr0'));
            }
            //--------End----------Added for the story BAC-4395
            
            // PM Plan and time based PM Schedule Map creation
            //BAC-4250 - Added fields ""SVMXC__Scheduled_On__c" and "SVMXC__PM_Plan__r.SVMXC__Schedule_Type__c" in query
            for(SVMXC__PM_Schedule__c PMSchedule : [Select SVMXC__PM_Plan__c, Id, SVMXC__Scheduled_On__c, SVMXC__PM_Plan__r.SVMXC__Schedule_Type__c from SVMXC__PM_Schedule__c where SVMXC__PM_Plan__c =: mapPMPlanIdPMScheduleLstPMCvrgLst.keySet()])
            {
                //BAC-4250-----Start-----//
                if(PMSchedule.SVMXC__PM_Plan__c != null){
                    if(mapPMPlanIdPMProcessId2 != null && mapPMPlanIdPMProcessId2.size() > 0 && mapPMPlanIdPMProcessId2.containsKey(PMSchedule.SVMXC__PM_Plan__c) && mapPMPlanIdPMProcessId2.get(PMSchedule.SVMXC__PM_Plan__c) != null){
                        if(mapPMProcess2 != null && mapPMProcess2.size() > 0 && mapPMProcess2.containsKey(mapPMPlanIdPMProcessId2.get(PMSchedule.SVMXC__PM_Plan__c)) && mapPMProcess2.get(mapPMPlanIdPMProcessId2.get(PMSchedule.SVMXC__PM_Plan__c)) != null){
                            SVMXC__ServiceMax_Processes__c objPMProcess = mapPMProcess2.get(mapPMPlanIdPMProcessId2.get(PMSchedule.SVMXC__PM_Plan__c));
                            Integer intAdvWorkOrdCreationDays = objPMProcess.SVMXC__Frequency__c != null ? Integer.valueOf(objPMProcess.SVMXC__Frequency__c) : 0;
                            Date dtQualifiedScheduleDateCrit = date.today().addDays(intAdvWorkOrdCreationDays);
                            if(PMSchedule.SVMXC__PM_Plan__r.SVMXC__Schedule_Type__c == 'Time Based' && PMSchedule.SVMXC__Scheduled_On__c != null && PMSchedule.SVMXC__Scheduled_On__c > dtQualifiedScheduleDateCrit){
                                continue;
                            }
                        }
                    }
                }
                //BAC-4250-----End-------//
                
                if(!mapPMPlanIdPMScheduleLstPMCvrgLst.containsKey(PMSchedule.SVMXC__PM_Plan__c))
                    mapPMPlanIdPMScheduleLstPMCvrgLst.put(PMSchedule.SVMXC__PM_Plan__c, new Map<Id, List<SVMXC__PM_Coverage__c>>());
                if(!mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMSchedule.SVMXC__PM_Plan__c).containsKey(PMSchedule.Id))
                    mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMSchedule.SVMXC__PM_Plan__c).put(PMSchedule.Id, new List<SVMXC__PM_Coverage__c>());
                /* //Commented for the story BAC-4395
                if(mapPMPlanIdPMCvrgLst.ContainsKey(PMSchedule.SVMXC__PM_Plan__c) && mapPMPlanIdPMCvrgLst.get(PMSchedule.SVMXC__PM_Plan__c) != NULL)
                    mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMSchedule.SVMXC__PM_Plan__c).get(PMSchedule.Id).addAll(mapPMPlanIdPMCvrgLst.get(PMSchedule.SVMXC__PM_Plan__c));
                */
                    
                //--------Start--------//Added for the story BAC-4395
                if(!mapPMPlanIdPMScheduleLstPMCvrgCount.containsKey(PMSchedule.SVMXC__PM_Plan__c))
                    mapPMPlanIdPMScheduleLstPMCvrgCount.put(PMSchedule.SVMXC__PM_Plan__c, new Map<Id, Integer>());
                if(!mapPMPlanIdPMScheduleLstPMCvrgCount.get(PMSchedule.SVMXC__PM_Plan__c).containsKey(PMSchedule.Id))
                    mapPMPlanIdPMScheduleLstPMCvrgCount.get(PMSchedule.SVMXC__PM_Plan__c).put(PMSchedule.Id, 0);
                    
                if(mapPMPlanIdPMCvrgCount.ContainsKey(PMSchedule.SVMXC__PM_Plan__c) && mapPMPlanIdPMCvrgCount.get(PMSchedule.SVMXC__PM_Plan__c) != NULL)
                    mapPMPlanIdPMScheduleLstPMCvrgCount.get(PMSchedule.SVMXC__PM_Plan__c).put(PMSchedule.Id, mapPMPlanIdPMCvrgCount.get(PMSchedule.SVMXC__PM_Plan__c));
                //--------End----------//Added for the story BAC-4395
            }
            //mapPMPlanIdPMCvrgLst.clear(); //Commented for the story BAC-4395
            mapPMPlanIdPMCvrgCount.clear(); //Added for the story BAC-4395
            
            //Batch calculation
            List<SVMXC__PM_Plan__c> lstPMPlansTemp = new List<SVMXC__PM_Plan__c>();
            /* Commented for the story BAC-4395
            for(Id PMPlanId : mapPMPlanIdPMScheduleLstPMCvrgLst.keySet())
            {
                if(mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId) != NULL && mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId).size() > 0)
                {
                    for(Id PMScheduleId : mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId).keySet())
                    {
                        if(mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId).get(PMScheduleId) != NULL && mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId).get(PMScheduleId).size() > 0)
                        {
                            if(mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId).get(PMScheduleId).size() <= InstalledProdCount)
                                lstPMPlansTemp.add(mapPMPlan.get(PMPlanId));
                            else
                            {
                                Integer count = Integer.valueOf(mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId).get(PMScheduleId).size()/InstalledProdCount);
                                for(Integer k=0; k < count; k++)
                                    lstPMPlansTemp.add(mapPMPlan.get(PMPlanId));
                                if(math.mod(mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId).get(PMScheduleId).size(), InstalledProdCount) > 0)
                                    lstPMPlansTemp.add(mapPMPlan.get(PMPlanId));
                            }
                        }
                        else 
                        {
                            //PM Plans which has no Covearge.
                            lstPMPlansTemp.add(mapPMPlan.get(PMPlanId));
                        }
                    }
                }
                else
                {
                     //PM Plans which has no PM Schedule.
                    lstPMPlansTemp.add(mapPMPlan.get(PMPlanId));
                }
            }
            */
            
            //-------Start-------Added for the story BAC-4395
            for(Id PMPlanId : mapPMPlanIdPMScheduleLstPMCvrgCount.keySet())
            {
                //------Start-----Added for the story BAC-4429
                if(!mapPMPlanIdVsNumberOfOccurencesInStart.containsKey(PMPlanId)){
                    mapPMPlanIdVsNumberOfOccurencesInStart.put(PMPlanId, 0);
                }
                //------End-----Added for the story BAC-4429

                if(mapPMPlanIdPMScheduleLstPMCvrgCount.get(PMPlanId) != NULL && mapPMPlanIdPMScheduleLstPMCvrgCount.get(PMPlanId).size() > 0)
                {
                    for(Id PMScheduleId : mapPMPlanIdPMScheduleLstPMCvrgCount.get(PMPlanId).keySet())
                    {
                        if(mapPMPlanIdPMScheduleLstPMCvrgCount.get(PMPlanId).get(PMScheduleId) != NULL && mapPMPlanIdPMScheduleLstPMCvrgCount.get(PMPlanId).get(PMScheduleId) > 0)
                        {
                            if(mapPMPlanIdPMScheduleLstPMCvrgCount.get(PMPlanId).get(PMScheduleId) <= InstalledProdCount){
                                lstPMPlansTemp.add(mapPMPlan.get(PMPlanId));
                                mapPMPlanIdVsNumberOfOccurencesInStart.put(PMPlanId, mapPMPlanIdVsNumberOfOccurencesInStart.get(PMPlanId) + 1); //Added for the story BAC-4429
                            }
                            else
                            {
                                Integer count = Integer.valueOf(mapPMPlanIdPMScheduleLstPMCvrgCount.get(PMPlanId).get(PMScheduleId)/InstalledProdCount);
                                for(Integer k=0; k < count; k++){
                                    lstPMPlansTemp.add(mapPMPlan.get(PMPlanId));
                                    mapPMPlanIdVsNumberOfOccurencesInStart.put(PMPlanId, mapPMPlanIdVsNumberOfOccurencesInStart.get(PMPlanId) + 1); //Added for the story BAC-4429
                                }
                                if(math.mod(mapPMPlanIdPMScheduleLstPMCvrgCount.get(PMPlanId).get(PMScheduleId), InstalledProdCount) > 0){
                                    lstPMPlansTemp.add(mapPMPlan.get(PMPlanId));
                                    mapPMPlanIdVsNumberOfOccurencesInStart.put(PMPlanId, mapPMPlanIdVsNumberOfOccurencesInStart.get(PMPlanId) + 1); //Added for the story BAC-4429
                                }
                            }
                        }
                        else 
                        {
                            //PM Plans which has no Covearge.
                            lstPMPlansTemp.add(mapPMPlan.get(PMPlanId));
                            mapPMPlanIdVsNumberOfOccurencesInStart.put(PMPlanId, mapPMPlanIdVsNumberOfOccurencesInStart.get(PMPlanId) + 1); //Added for the story BAC-4429
                        }
                    }
                }
                else
                {
                    //PM Plans which has no PM Schedule.
                    lstPMPlansTemp.add(mapPMPlan.get(PMPlanId));
                    mapPMPlanIdVsNumberOfOccurencesInStart.put(PMPlanId, mapPMPlanIdVsNumberOfOccurencesInStart.get(PMPlanId) + 1); //Added for the story BAC-4429
                }
            }
            System.debug(LoggingLevel.WARN, 'mapPMPlanIdVsNumberOfOccurencesInStart: '+mapPMPlanIdVsNumberOfOccurencesInStart); //Added for the story BAC-4429
            //-------End-------Added for the story BAC-4395
            
            //Notification Mail for the Processes for which there is no PM Plan
            if(mapPMProcessIdSetPMPlanId != NULL && mapPMProcessIdSetPMPlanId.size() > 0)
            {
                for(Id PMProcessId : mapPMProcessIdSetPMPlanId.keySet())
                {
                    if(mapPMProcessIdSetPMPlanId.get(PMProcessId) != NULL && mapPMProcessIdSetPMPlanId.get(PMProcessId).size() == 0)
                    {
                        String strSummary = getTAG001() + '\n\n' + getTAG005() + '\n\n' + getTAG002() + ' ' + mapPMProcess2.get(PMProcessId).SVMXC__Name__c + '\n' + getTAG003() + ' ' + 0 + '\n' + getTAG010() +': '+ getTAG008();
                        Set<String> setEMailIds = new Set<String>();
                        setEMailIds.add(mapPMProcess2.get(PMProcessId).SVMXC__Email_On_Success__c);
                        emailStatusInfo(strSummary, '', setEMailIds, getTAG011(), false);
                    }
                }
            }
            lstPMPlans.clear();
            lstPMPlans.addAll(lstPMPlansTemp);
            lstPMPlansTemp.clear();
            system.debug(LoggingLevel.WARN, 'PM Plan list size: ' + lstPMPlans.size() +'; PM Plan list: '+ lstPMPlans);
            return lstPMPlans;
        }
        catch(Exception ex)
        {
            throw ex;
        }
    }
    
    global void execute(Database.BatchableContext scPMEngine, List<sObject> scope)
    {
        BatchNumberCount += 1;
        Set<String> setPMPlanIDsInCurrentScope = new Set<String>(); //Added for the story BAC-4429
        
        //------Start-------Added for the story BAC-4395
        Set<String> setPMPlanIds = new Set<String>();
        for(sObject objPM : scope){
            if(objPM.get('Id') != null){
                setPMPlanIds.add((String) objPM.get('Id'));
            }
        }
        System.debug('setPMPlanIds: '+setPMPlanIds);
        
        if(setPMPlanIds.size() > 0){
            Map<Id, List<SVMXC__PM_Coverage__c>> mapPMPlanIdCovList = new Map<Id, List<SVMXC__PM_Coverage__c>>(); 
            
            List<SVMXC__PM_Coverage__c> lstPMCvrg = [Select SVMXC__Product_Name__c, Name, SVMXC__Product_Name__r.SVMXC__Preferred_Technician__c, SVMXC__PM_Plan__c, SVMXC__Location_Name__c, SVMXC__Location_Name__r.SVMXC__Account__c, SVMXC__Location_Name__r.SVMXC__Account__r.SVMXC__Preferred_Technician__c, Id from SVMXC__PM_Coverage__c where SVMXC__PM_Plan__c IN: setPMPlanIds];
            System.debug('lstPMCvrg: '+lstPMCvrg);
            
            for(SVMXC__PM_Coverage__c objPMCov : lstPMCvrg){
                if(!mapPMPlanIdCovList.containsKey(objPMCov.SVMXC__PM_Plan__c))
                    mapPMPlanIdCovList.put(objPMCov.SVMXC__PM_Plan__c, new List<SVMXC__PM_Coverage__c>());
                
                mapPMPlanIdCovList.get(objPMCov.SVMXC__PM_Plan__c).add(objPMCov);
            }
            System.debug('mapPMPlanIdCovList: '+mapPMPlanIdCovList);
            lstPMCvrg = null;
            
            for(Id PMPlanId : mapPMPlanIdCovList.keySet()){
                if(mapPMPlanIdPMScheduleLstPMCvrgLst.containsKey(PMPlanId) && mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId) != NULL && mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId).size() > 0) {
                    for(Id PMScheduleId : mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId).keySet()){
                        if(mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId).get(PMScheduleId) != null && mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId).get(PMScheduleId).size() == 0){
                            mapPMPlanIdPMScheduleLstPMCvrgLst.get(PMPlanId).get(PMScheduleId).addAll(mapPMPlanIdCovList.get(PMPlanId));
                        }
                    }
                }
            }
            mapPMPlanIdCovList = null;
            System.debug('mapPMPlanIdPMScheduleLstPMCvrgLst: '+mapPMPlanIdPMScheduleLstPMCvrgLst);
        }        
        //------End---------Added for the story BAC-4395
        
        for(sObject currObj : scope)
        {
            SVMXC__PM_Plan__c objPMPlan = new SVMXC__PM_Plan__c();
            objPMPlan = (SVMXC__PM_Plan__c)currObj;
            SVMXC.INTF_WebservicesDef.INTF_SFMResponse objINTF_SFMResp = new SVMXC.INTF_WebservicesDef.INTF_SFMResponse();
            SVMXC.INTF_WebServicesDef.INTF_SFMRequest objSFMRequest = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
            objSFMRequest.valueMap = new List<SVMXC.INTF_WebservicesDef.SVMXMap>();
            
            //------Start-----Added for the story BAC-4429
            setPMPlanIDsInCurrentScope.add(objPMPlan.Id);
            if(!mapPMPlanIdVsNumberOfOccurencesInExecute.containsKey(objPMPlan.Id)){
                mapPMPlanIdVsNumberOfOccurencesInExecute.put(objPMPlan.Id, 0);
            }
            //------End-----Added for the story BAC-4429

            if(mapPMPlanIdPMProcessId2 != null && mapPMPlanIdPMProcessId2.containsKey(objPMPlan.Id))
            {
                if(mapPMPlanIdPMScheduleLstPMCvrgLst.get(objPMPlan.Id) != NULL && mapPMPlanIdPMScheduleLstPMCvrgLst.get(objPMPlan.Id).size() > 0)
                {
                    Map<Id, List<SVMXC__PM_Coverage__c>> mapPMScheduleIdPMCvrgLst = new Map<Id, List<SVMXC__PM_Coverage__c>>();
                    mapPMScheduleIdPMCvrgLst.putAll(mapPMPlanIdPMScheduleLstPMCvrgLst.get(objPMPlan.Id));
                    
                    for(Id PMScheduleId : mapPMScheduleIdPMCvrgLst.keySet())
                    {
                        if(mapPMScheduleIdPMCvrgLst.get(PMScheduleId) != NULL && mapPMScheduleIdPMCvrgLst.get(PMScheduleId).size() > 0)
                        {
                            SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
                            objSVMXMap1.key = 'PM_PROCESS_RECORD';
                            objSVMXMap1.record = mapPMProcess2.get(mapPMPlanIdPMProcessId2.get(objPMPlan.Id));
                            objSFMRequest.valueMap.add(objSVMXMap1);
                            
                            SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap2 = new SVMXC.INTF_WebservicesDef.SVMXMap();
                            objSVMXMap2.key = 'PM_PLAN_RECORD';
                            objSVMXMap2.record = objPMPlan;
                            objSFMRequest.valueMap.add(objSVMXMap2);
                            
                            if(mapScheduleIdWorkOrder.containsKey(PMScheduleId) && mapScheduleIdWorkOrder.get(PMScheduleId) != NULL)
                            {
                                SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap3 = new SVMXC.INTF_WebservicesDef.SVMXMap();
                                objSVMXMap3.key = 'WORK_ORDER_RECORD';
                                objSVMXMap3.record = mapScheduleIdWorkOrder.get(PMScheduleId);
                                objSFMRequest.valueMap.add(objSVMXMap3);
                            }
                            
                            objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('PM_SCHEDULE_RECORDID', PMScheduleId));
                            objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_CREATION_SETTING', String.valueOf(IsCreateTask)));
                            objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('IS_LOCATION_BASED_PM_ON', String.valueOf(IsLocBasedPMEnabled)));
                            objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_PRIORITY_SETTING', TaskPriority));
                            objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('BATCH_COUNT', String.valueOf(BatchNumberCount)));
                            if(mapPMScheduleIdPMCvrgLst.get(PMScheduleId).size() <= InstalledProdCount)
                            {
                                SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap4 = new SVMXC.INTF_WebservicesDef.SVMXMap();
                                objSVMXMap4.key = 'PM_COVERAGE_LST';
                                objSVMXMap4.data = mapPMScheduleIdPMCvrgLst.get(PMScheduleId);
                                objSFMRequest.valueMap.add(objSVMXMap4);
                                objINTF_SFMResp = new PREV_EngineUtils().createWorkOrders(objSFMRequest);
                                mapPMPlanIdPMScheduleLstPMCvrgLst.get(objPMPlan.Id).remove(PMScheduleId);
                                mapPMPlanIdVsNumberOfOccurencesInExecute.put(objPMPlan.Id, mapPMPlanIdVsNumberOfOccurencesInExecute.get(objPMPlan.Id) + 1); //Added for the story BAC-4429
                                break;
                            }
                            else
                            {
                                List<SVMXC__PM_Coverage__c> lstPMCoverage = new List<SVMXC__PM_Coverage__c> ();
                                List<SVMXC__PM_Coverage__c> lstPMCoverage1 = new List<SVMXC__PM_Coverage__c>();
                                lstPMCoverage.addAll(mapPMPlanIdPMScheduleLstPMCvrgLst.get(objPMPlan.Id).get(PMScheduleId));
                                for(Integer i=0; i < lstPMCoverage.size(); i++)
                                {
                                    lstPMCoverage1.add(lstPMCoverage[i]);
                                    if( mapPMScheduleIdPMCvrgLst.get(PMScheduleId).size() > 0 )
                                    {
                                        mapPMPlanIdPMScheduleLstPMCvrgLst.get(objPMPlan.Id).get(PMScheduleId).remove(0);
                                    }
                                    if(lstPMCoverage1.size() ==  InstalledProdCount)
                                    {
                                        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap4 = new SVMXC.INTF_WebservicesDef.SVMXMap();
                                        objSVMXMap4.key = 'PM_COVERAGE_LST';
                                        objSVMXMap4.data = lstPMCoverage1;
                                        objSFMRequest.valueMap.add(objSVMXMap4);
                                        objINTF_SFMResp = new PREV_EngineUtils().createWorkOrders(objSFMRequest);
                                        if(mapPMScheduleIdPMCvrgLst.get(PMScheduleId).size() == 0)
                                            mapPMPlanIdPMScheduleLstPMCvrgLst.get(objPMPlan.Id).remove(PMScheduleId);
                                        mapPMPlanIdVsNumberOfOccurencesInExecute.put(objPMPlan.Id, mapPMPlanIdVsNumberOfOccurencesInExecute.get(objPMPlan.Id) + 1); //Added for the story BAC-4429
                                        break;
                                    }
                                }
                            }
                        }
                        else
                        {
                            SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
                            objSVMXMap1.key = 'PM_PROCESS_RECORD';
                            objSVMXMap1.record = mapPMProcess2.get(mapPMPlanIdPMProcessId2.get(objPMPlan.Id));
                            objSFMRequest.valueMap.add(objSVMXMap1);
                            
                            SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap2 = new SVMXC.INTF_WebservicesDef.SVMXMap();
                            objSVMXMap2.key = 'PM_PLAN_RECORD';
                            objSVMXMap2.record = objPMPlan;
                            objSFMRequest.valueMap.add(objSVMXMap2);
                            
                            objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('PM_SCHEDULE_RECORDID', PMScheduleId));
                            objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_CREATION_SETTING', String.valueOf(IsCreateTask)));
                            objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('IS_LOCATION_BASED_PM_ON', String.valueOf(IsLocBasedPMEnabled)));
                            objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_PRIORITY_SETTING', TaskPriority));
                            objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('BATCH_COUNT', String.valueOf(BatchNumberCount)));
                            objINTF_SFMResp = new PREV_EngineUtils().createWorkOrders(objSFMRequest);
                            mapPMPlanIdPMScheduleLstPMCvrgLst.get(objPMPlan.Id).remove(PMScheduleId);
                            mapPMPlanIdVsNumberOfOccurencesInExecute.put(objPMPlan.Id, mapPMPlanIdVsNumberOfOccurencesInExecute.get(objPMPlan.Id) + 1); //Added for the story BAC-4429
                            break;
                        }
                        
                        if(objINTF_SFMResp.success == true)
                        {
                            for(INTF_WebServicesDef.SVMXMap objSVMXMap : objINTF_SFMResp.valueMap)
                            {
                                if(objSVMXMap.key == 'WORK_ORDER_RECORD')
                                {
                                    if(!mapScheduleIdWorkOrder.containsKey(PMScheduleId))
                                        mapScheduleIdWorkOrder.put(PMScheduleId, (SVMXC__Service_Order__c) objSVMXMap.record);
                                    break;
                                }
                            }
                        }
                        else
                        {
                            //If there is any failure occurs during the any intermediate batch, no need to process that PM Schedule in the next batch.
                            mapPMPlanIdPMScheduleLstPMCvrgLst.get(objPMPlan.Id).remove(PMScheduleId);
                        }
                        break;
                    }
                }
                else
                {
                    SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
                    objSVMXMap1.key = 'PM_PROCESS_RECORD';
                    objSVMXMap1.record = mapPMProcess2.get(mapPMPlanIdPMProcessId2.get(objPMPlan.Id));
                    objSFMRequest.valueMap.add(objSVMXMap1);
                    
                    SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap2 = new SVMXC.INTF_WebservicesDef.SVMXMap();
                    objSVMXMap2.key = 'PM_PLAN_RECORD';
                    objSVMXMap2.record = objPMPlan;
                    objSFMRequest.valueMap.add(objSVMXMap2);
                    
                    objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_CREATION_SETTING', String.valueOf(IsCreateTask)));
                    objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('IS_LOCATION_BASED_PM_ON', String.valueOf(IsLocBasedPMEnabled)));
                    objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_PRIORITY_SETTING', TaskPriority));
                    objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('BATCH_COUNT', String.valueOf(BatchNumberCount)));
                    objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('PM_SCHEDULE_RECORDID', 'NO_SCHEDULE'));
                    objINTF_SFMResp = new PREV_EngineUtils().createWorkOrders(objSFMRequest);
                    mapPMPlanIdPMScheduleLstPMCvrgLst.remove(objPMPlan.Id);
                    mapPMPlanIdVsNumberOfOccurencesInExecute.put(objPMPlan.Id, mapPMPlanIdVsNumberOfOccurencesInExecute.get(objPMPlan.Id) + 1); //Added for the story BAC-4429
                }
            }
            //lstEngineResp.add(objINTF_SFMResp);

            //------Start-------Added for the story BAC-4429
            if(!mapPMPlanIdVsListEngineResp.containsKey(objPMPlan.Id)){
                mapPMPlanIdVsListEngineResp.put(objPMPlan.Id, new List<INTF_WebservicesDef.INTF_SFMResponse>());
            }
            mapPMPlanIdVsListEngineResp.get(objPMPlan.Id).add(objINTF_SFMResp);
            //------Start-------Added for the story BAC-4429
        }

        //------Start-------Added for the story BAC-4429
        for(String strPMPlanId: setPMPlanIDsInCurrentScope){
            
            if(mapPMPlanIdVsNumberOfOccurencesInStart.containsKey(strPMPlanId) && mapPMPlanIdVsNumberOfOccurencesInExecute.containsKey(strPMPlanId) && mapPMPlanIdVsNumberOfOccurencesInStart.get(strPMPlanId) == mapPMPlanIdVsNumberOfOccurencesInExecute.get(strPMPlanId)){
                System.debug('PMPlanId for Schedule update: '+strPMPlanId);

                if(mapPMPlanIdVsListEngineResp.containsKey(strPMPlanId)){
                    
                    List<INTF_WebservicesDef.INTF_SFMResponse> lstEngineResponse = mapPMPlanIdVsListEngineResp.get(strPMPlanId);
                    Set<String> setSuccessPMPlanID = new Set<String>();
                    Set<String> setSuccessPMScheduleID = new Set<String>();
                    
                    for(INTF_WebServicesDef.INTF_SFMResponse objResponse: lstEngineResponse){
                        if(objResponse.success == true){
                            setSuccessPMPlanID.add(objResponse.eventName);
                            for(INTF_WebServicesDef.SVMXMap currMap : objResponse.valueMap){
                                if(currMap.key == 'SCHEDULE_DEF_ID' && currMap.value != null){
                                    setSuccessPMScheduleID.add(currMap.value);
                                }
                            }
                        }
                    }
                    List<String> lstPMPlanId = new List<Id>();
                    lstPMPlanId.addAll(setSuccessPMPlanID);
                    setSuccessPMPlanID.clear();

                    List<String> lstPMScheduleId = new List<Id>();
                    lstPMScheduleId.addAll(setSuccessPMScheduleID);
                    setSuccessPMScheduleID.clear();
                    
                    if(lstPMScheduleId.size() > 0){
                        INTF_WebServicesDef.INTF_Request reqToCalcNxtSchedule = new INTF_WebServicesDef.INTF_Request();
                        reqToCalcNxtSchedule.recordIds = lstPMPlanId;
                        reqToCalcNxtSchedule.stringListMap = new List<INTF_WebServicesDef.INTF_StringListMap>();
                        reqToCalcNxtSchedule.stringListMap.add(new INTF_WebServicesDef.INTF_StringListMap('SCHEDULEID', lstPMScheduleId));
                        new PREV_PMPlanUtils().PREV_CalculateNextSchedule(reqToCalcNxtSchedule);    
                    }
                }
            }
        }
        //------End-------Added for the story BAC-4429
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //---Start-----Added for the story BAC-4255
        mapPMPlanIdPMScheduleLstPMCvrgLst = null;
        mapPMPlanIdPMProcessId2 = null;
        mapScheduleIdWorkOrder = null;
        //---End-----Added for the story BAC-4255
        Boolean isSVMXfileEnabled = COMM_FileHandlerUtilities.checkFileSetting(); //Added for BAC-2276
        //system.debug(LoggingLevel.WARN, 'lstEngineResp List: ' + lstEngineResp); //Commented as part of story BAC-4429
        System.debug(LoggingLevel.WARN, 'mapPMPlanIdVsListEngineResp: '+mapPMPlanIdVsListEngineResp); //Added for the story BAC-4429
        //Set<String> setSuccessPMPlanID = new Set<String>(); //Commented as part of story BAC-4429
        Set<String> setFailurePMPlanID = new Set<String>();
        //Set<String> setSuccessPMScheduleID = new Set<String>(); //Commented as part of story BAC-4429
        List<Task> lstActivityTask = new List<Task>();
        Map<Id,String> mapPMPlanIdLogger = new Map<Id,String>();
        Map<Id,Set<Id>> mapPMProcessIdPMPlanIdSet = new Map<Id,Set<Id>>();
        Map<Id,List<INTF_WebservicesDef.INTF_SFMResponse>> mapPMPlanIdEngineResp = new Map<Id,List<INTF_WebservicesDef.INTF_SFMResponse>>();
        //Map<ID, Set<String>> mapPMPlanIdScheduleDefId = new Map<ID, Set<String>>(); //Commented as part of story BAC-4429
        
        /*
        For story BAC-4429, Commented this block of code and added below piece of code for creating map mapPMProcessIdPMPlanIdSet from the map mapPMPlanIdVsListEngineResp

        if(lstEngineResp != null && lstEngineResp.size() > 0)
        {
            for(SVMXC.INTF_WebservicesDef.INTF_SFMResponse currResponse: lstEngineResp)
            {
                if(currResponse.value != null && currResponse.value.length() > 0)
                {
                    if(!mapPMProcessIdPMPlanIdSet.containsKey(currResponse.value))
                        mapPMProcessIdPMPlanIdSet.put(Id.valueOf(currResponse.value), new Set<Id>());
                    mapPMProcessIdPMPlanIdSet.get(Id.valueOf(currResponse.value)).add(Id.valueOf(currResponse.eventName));
                }
                
                if(currResponse.eventName != null && currResponse.eventName.length() > 0)
                {
                    if(!mapPMPlanIdEngineResp.containsKey(currResponse.eventName))
                        mapPMPlanIdEngineResp.put(Id.valueOf(currResponse.eventName), new List<SVMXC.INTF_WebservicesDef.INTF_SFMResponse>());
                    mapPMPlanIdEngineResp.get(Id.valueOf(currResponse.eventName)).add(currResponse);
                }
            }
        }
        */

        //-------Start----------Added for the story BAC-4429
        for(String strPlanId : mapPMPlanIdVsListEngineResp.keySet()){
            for(SVMXC.INTF_WebservicesDef.INTF_SFMResponse currResponse: mapPMPlanIdVsListEngineResp.get(strPlanId)){
                if(currResponse.value != null && currResponse.value.length() > 0){
                    if(!mapPMProcessIdPMPlanIdSet.containsKey(currResponse.value))
                        mapPMProcessIdPMPlanIdSet.put(Id.valueOf(currResponse.value), new Set<Id>());

                    mapPMProcessIdPMPlanIdSet.get(Id.valueOf(currResponse.value)).add(Id.valueOf(currResponse.eventName));
                }
            }
        }
        //-------End----------Added for the story BAC-4429
        
        lstEngineResp = null; //Added for the story BAC-4255
        
        if(mapPMProcessIdPMPlanIdSet != NULL && mapPMProcessIdPMPlanIdSet.size() > 0)
        {
            for(String strPMProcessID : mapPMProcessIdPMPlanIdSet.keySet())
            {
                List<String> listLoggerAttachmentId = new List<String>(); //Added for the story BAC-4437
                if(mapPMProcessIdPMPlanIdSet.get(strPMProcessID) != NULL && mapPMProcessIdPMPlanIdSet.get(strPMProcessID).size() > 0)
                {
                    //boolean isSuccessEMail = true;
                    boolean isAttachLog = mapPMProcess2.get(strPMProcessID).SVMXC__Capture_Log__c;
                    String strSucessEmailId = mapPMProcess2.get(strPMProcessID).SVMXC__Email_On_Success__c;
                    String strFailureEmailId = mapPMProcess2.get(strPMProcessID).SVMXC__Email_On_Error__c;
                    String strSummary = getTAG001() + '\n\n' + getTAG005() + '\n' + getTAG002() + ' ' + mapPMProcess2.get(strPMProcessID).SVMXC__Name__c + '\n' + getTAG003() + ' ' + mapPMProcessIdPMPlanIdSet.get(strPMProcessID).size();
                    String strLogger = '';
                    Set<Boolean> setExecutionResults = new Set<Boolean>(); 
                    
                    for(Id PMPlanId : mapPMProcessIdPMPlanIdSet.get(strPMProcessID))
                    {
                        //if(mapPMPlanIdEngineResp.get(PMPlanId) != NULL && mapPMPlanIdEngineResp.get(PMPlanId).size() > 0)
                        //Commented above line and added below line for using new variable for the story BAC-4429
                        if(mapPMPlanIdVsListEngineResp.get(PMPlanId) != NULL && mapPMPlanIdVsListEngineResp.get(PMPlanId).size() > 0)
                        {
                            strSummary += '\n\n' + getTAG012() + ' ' + mapPMPlan.get(PMPlanId).Name;
                            Integer intWorkOrderCount = 0;
                            boolean isSuccessEMail = true;
                            boolean isExecutionSuccess = true;
                            /* Commented this block as it is not needed as part of story BAC-4429
                            if(!mapPMPlanIdScheduleDefId.containsKey(PMPlanId))
                                mapPMPlanIdScheduleDefId.put(PMPlanId, new Set<String>());
                            */
                            
                            //for(INTF_WebServicesDef.INTF_SFMResponse objResponse : mapPMPlanIdEngineResp.get(PMPlanId))
                            //Commented above line and added below line for using new variable for the story BAC-4429
                            for(INTF_WebServicesDef.INTF_SFMResponse objResponse : mapPMPlanIdVsListEngineResp.get(PMPlanId))
                            {
                                for(INTF_WebServicesDef.SVMXMap currMap : objResponse.valueMap)
                                {
                                    String strAttachment = '';
                                    if(objResponse.success == false)
                                    {
                                        isSuccessEMail = false;
                                        isExecutionSuccess = false;
                                        setFailurePMPlanID.add(PMPlanId);
                                    }
                                    /* Commented this block as it is not needed as part of story BAC-4429
                                    else
                                    {
                                        setSuccessPMPlanID.add(PMPlanId);
                                    }
                                    */
                                    if(currMap.key == 'WORD_RECORD_COUNT')
                                        intWorkOrderCount = Integer.valueOf(intWorkOrderCount + Integer.valueOf(currMap.value));
                                    else if(currMap.key == 'WORK_ORDER_ID_LIST')
                                        lstWorkOrdIDs.addAll(currMap.values);
                                    else if(currMap.key == 'LOGGER')
                                    {
                                        //Added condition here for the story BAC-4437 for reducing heap size
                                        if(isAttachLog){
                                            strLogger += currMap.value;                                         
                                        }
                                        
                                        if(mapPMPlanIdLogger.containsKey(PMPlanId))
                                            strAttachment += mapPMPlanIdLogger.get(PMPlanId);
                                        strAttachment += currMap.value;
                                        mapPMPlanIdLogger.put(PMPlanId, strAttachment);
                                    }
                                    /* Commented this block as it is not needed as part of story BAC-4429
                                    else if(currMap.key == 'SCHEDULE_DEF_ID')
                                    {
                                        setSuccessPMScheduleID.add(currMap.value);
                                        mapPMPlanIdScheduleDefId.get(PMPlanId).add(currMap.value);
                                    }
                                    */
                                }
                            }
                            system.debug(LoggingLevel.WARN, 'isSuccessEMail: ' + isSuccessEMail);
                            setExecutionResults.add(isSuccessEMail);
                            
                            //Create Activity Task after successful or failure execution
                            if(isExecutionSuccess)
                            {
                                strSummary +=  '\n' + getTAG013() + ' ' + intWorkOrderCount + '\n' + getTAG010() +': '+ getTAG008();
                                if(mapPMProcess2.get(strPMProcessID) != NULL && mapPMProcess2.get(strPMProcessID).SVMXC__Product_Match_Enabled__c == true && mapPMPlan.get(PMPlanId) != NULL)
                                {
                                    if(mapPMPlan.get(PMPlanId).Owner.isActive == true)
                                        lstActivityTask.add(new Task(OwnerId = mapPMPlan.get(PMPlanId).OwnerId, WhatId = mapPMPlan.get(PMPlanId).Id, IsReminderSet = false, Description = getTag014(), Subject = System.Label.PREV003_TAG007, Status = system.Label.PREV003_TAG009, Priority = system.Label.PREV003_TAG010));
                                    else
                                        strSummary += '\n' + getTAG017();
                                }
                            }
                            else
                            {
                                strSummary +=  '\n' + getTAG013() + ' ' + 0 + '\n' + getTAG010() +': '+ getTAG009();
                                if(mapPMProcess2.get(strPMProcessID) != NULL && mapPMProcess2.get(strPMProcessID).SVMXC__Preferred_Tech_Enabled__c == true && mapPMPlan.get(PMPlanId) != NULL)
                                {
                                    if(mapPMPlan.get(PMPlanId).Owner.isActive == true)
                                        lstActivityTask.add(new Task(OwnerId = mapPMPlan.get(PMPlanId).OwnerId, WhatId = mapPMPlan.get(PMPlanId).Id, IsReminderSet = false, Description = getTag015(), Subject = System.Label.PREV003_TAG008, Status = system.Label.PREV003_TAG009, Priority = system.Label.PREV003_TAG010));
                                    else
                                        strSummary += '\n' + getTAG017();
                                }
                            }
                        }
                        //------Start--------Added for the story BAC-4437
                        if(isAttachLog && Limits.getHeapSize() > 8000000){
                            System.debug('Limits.getHeapSize in Finish method- '+ Limits.getHeapSize());
                            if(isSVMXfileEnabled){ //Added for BAC-2276
                                try{
                                    List<ContentVersion> lstCVInstances = new List<ContentVersion>();
                                    ContentVersion cvTemp = new ContentVersion();
                                    cvTemp.VersionData = Blob.valueOf(strLogger);
                                    cvTemp.Title = mapPMProcess2.get(strPMProcessID).SVMXC__Name__c;
                                    cvTemp.PathOnClient = mapPMProcess2.get(strPMProcessID).SVMXC__Name__c;
                                    cvTemp.SVMXC__SM_Process_ID__c = mapPMProcess2.get(strPMProcessID).Id;
                                    lstCVInstances.add(cvTemp);
                                    List<Id> lstCVIds = COMM_FileHandlerUtilities.insertListOfContentVersion(lstCVInstances);
                                    strLogger = null;
                                    strLogger = '';
                                    cvTemp = null;
                                    lstCVInstances = null;
                                    List<String> fieldSet = new List<String>();
                                    fieldSet.add('SVMXC__SM_Process_ID__c');
                                    fieldSet.add('ContentDocumentId');
                                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'ContentVersion', fieldSet, COMM_SecurityUtils.Access.Accessible ) ) {
                                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                                    }
                                    List<ContentVersion> lstCVDetails = Database.query('SELECT Id, SVMXC__SM_Process_ID__c, ContentDocumentId FROM ContentVersion WHERE Id IN: lstCVIds');
                                    List<ContentDocumentLink> listContentDocumentLinkInstances = new List<ContentDocumentLink>();
                                    for(ContentVersion cv: lstCVDetails){
                                        listLoggerAttachmentId.add(cv.Id);
                                        listContentDocumentLinkInstances.add(COMM_FileHandlerUtilities.createContentDocumentLink(cv.SVMXC__SM_Process_ID__c,cv.ContentDocumentId));
                                        
                                    }
                                    List<Id> lstCDLids = COMM_FileHandlerUtilities.insertContentDocumentLink(listContentDocumentLinkInstances);                            
                                }catch(Exception ex){
                                    System.debug('Error during logger Salesforce file creation: '+ex.getMessage());
                                }
                            }else{
                                try{
                                    Attachment logAttachment = new Attachment();
                                    logAttachment.Name = mapPMProcess2.get(strPMProcessID).SVMXC__Name__c;
                                    logAttachment.ParentId = mapPMProcess2.get(strPMProcessID).Id;
                                    logAttachment.ContentType = 'text/plain';
                                    logAttachment.Body = Blob.valueof(strLogger);
                                    insert logAttachment;
                                    listLoggerAttachmentId.add(logAttachment.Id);
                                    System.debug('Limits.getHeapSize in Finish method- '+ Limits.getHeapSize());
                                    strLogger = null;
                                    strLogger = '';
                                    logAttachment = null;
                                }
                                catch(Exception ex){
                                    System.debug('Error during logger attachment creation: '+ex.getMessage());
                                }
                            }
                            System.debug('Limits.getHeapSize in Finish method- '+ Limits.getHeapSize());
                        }
                        //------End----------Added for the story BAC-4437
                    }
                    
                    if(isAttachLog) 
                        strSummary += '\n\n' + getTAG006();
                    
                    system.debug(LoggingLevel.WARN, 'setExecutionResults: ' + setExecutionResults);
                    System.debug(LoggingLevel.WARN, 'listLoggerAttachmentId: ' + listLoggerAttachmentId);
                    System.debug('Limits.getHeapSize in Finish method- '+ Limits.getHeapSize());
                    
                    //------Start-------Added for the story BAC-4437
                    if(listLoggerAttachmentId.size() > 0){
                        strSummary += '\n\n' + System.Label.PREV006_TAG011; //Link to Attachment(s) which has additional logging information:
                        if(isSVMXfileEnabled){ //Added for BAC-2276
                            for(String strAttchId : listLoggerAttachmentId){
                                String urlAttachment = URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + strAttchId;
                                strSummary += '\n' + urlAttachment;
                            }
                        }else{
                            for(String strAttchId : listLoggerAttachmentId){
                                String urlAttachment = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + strAttchId;
                                strSummary += '\n' + urlAttachment;
                            }
                        }
                    }
                    //------End---------Added for the story BAC-4437
                    Set<String> setEmailIDs = new Set<String>();
                    if(setExecutionResults.contains(true) && setExecutionResults.contains(false)) 
                    {
                        setEmailIDs.add(strSucessEmailId);
                        setEmailIDs.add(strFailureEmailId);
                        emailStatusInfo(strSummary, strLogger, setEmailIDs, getTAG011(), isAttachLog);
                    }
                    else if(setExecutionResults.contains(true)) 
                    {
                        setEmailIDs.add(strSucessEmailId);
                        emailStatusInfo(strSummary, strLogger, setEmailIDs, getTAG011(), isAttachLog);
                    }
                    else
                    {
                        setEmailIDs.add(strFailureEmailId);
                        emailStatusInfo(strSummary, strLogger, setEmailIDs, getTAG011(), isAttachLog);
                    }
                }
            }

            //------Start------Added for the story BAC-4255
            System.debug('Limits.getHeapSize in Finish method- '+ Limits.getHeapSize());
            mapPMProcess2 = null;
            mapPMPlan = null;
            //------End------Added for the story BAC-4255
            
            //Activity Task List
            if(lstActivityTask != NULL && lstActivityTask.size() > 0)
                insert lstActivityTask;
            
            List<Attachment> lstAttachment = new List<Attachment>();
            List<ContentVersion> lstCVInstances = new List<ContentVersion>(); //Added for BAC-2276
            Map<Id,Id> mapTaskandOwnerIds = new Map<Id,Id>(); //Added for BAC-2276
            for(Task objTask : lstActivityTask)
            {
                //Success/Failure Attachment
                if(mapPMPlanIdLogger.containsKey(objTask.WhatId) && mapPMPlanIdLogger.get(objTask.WhatId) != NULL)
                {
                    
                    //String strAttachmentBody =  mapPMPlanIdLogger.get(objTask.WhatId).replaceFirst('\n\n', ''); 
                    // SK Regex issue fix story BAC-4255 by removing the replace method which is not needed.
                    String strAttachmentBody =  mapPMPlanIdLogger.get(objTask.WhatId);
                    if(isSVMXfileEnabled){ //Added for BAC-2276
                        ContentVersion cvTemp = new ContentVersion();
                        cvTemp.VersionData = Blob.valueof(strAttachmentBody);
                        cvTemp.Title = getTAG016();
                        cvTemp.PathOnClient = getTAG016();
                        //cvTemp.IsMajorVersion = false;
                        cvTemp.SVMXC__SM_Process_ID__c = objTask.Id;
                        mapTaskandOwnerIds.put(objTask.Id, objTask.OwnerId);
                        lstCVInstances.add(cvTemp);
                    }else{
                        lstAttachment.add(new Attachment(OwnerId = objTask.OwnerId, ParentId = objTask.Id, Name = getTAG016(), Body = Blob.valueof(strAttachmentBody), ContentType = 'text/plain'));
                    }
                    mapPMPlanIdLogger.remove(objTask.WhatId);  //Added for the story BAC-4437
                }
            }
            if(isSVMXfileEnabled && lstCVInstances.size()>0){ //Added for BAC-2276
                List<Id> lstCVIds = COMM_FileHandlerUtilities.insertListOfContentVersion(lstCVInstances);
                List<String> fieldSet = new List<String>();
                fieldSet.add('SVMXC__SM_Process_ID__c');
                fieldSet.add('ContentDocumentId');
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'ContentVersion', fieldSet, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                List<ContentVersion> lstCVDetails = Database.query('SELECT Id, SVMXC__SM_Process_ID__c, ContentDocumentId FROM ContentVersion WHERE Id IN: lstCVIds');
                List<ContentDocumentLink> listContentDocumentLinkInstances = new List<ContentDocumentLink>();
                for(ContentVersion cv: lstCVDetails){
                    ContentDocumentLink cdlTemp1 = new ContentDocumentLink();
                    
                    
                    listContentDocumentLinkInstances.add(COMM_FileHandlerUtilities.createContentDocumentLink(cv.SVMXC__SM_Process_ID__c,cv.ContentDocumentId));
                    if(mapTaskandOwnerIds.get(cv.SVMXC__SM_Process_ID__c) != null){
                        cdlTemp1.ContentDocumentId = cv.ContentDocumentId;
                        cdlTemp1.LinkedEntityId = mapTaskandOwnerIds.get(cv.SVMXC__SM_Process_ID__c);
                        cdlTemp1.ShareType = 'V';
                    }
                    listContentDocumentLinkInstances.add(cdlTemp1);
                    
                }
                List<Id> lstCDLids = COMM_FileHandlerUtilities.insertContentDocumentLink(listContentDocumentLinkInstances);
            } // End for BAC-2276
            lstActivityTask = null; //Added for the story BAC-4437
            mapPMPlanIdLogger = null; //Added for the story BAC-4437
            
            if(lstAttachment != NULL && lstAttachment.size() > 0)
                insert lstAttachment;
            lstAttachment = null; //Added for the story BAC-4437
            System.debug('Limits.getHeapSize in Finish method- '+ Limits.getHeapSize());
            
            /*
            This block of code is commented as this logic is moved to execute method as part of story BAC-4429
            If(setFailurePMPlanID != NULL && setFailurePMPlanID.size() > 0)
            {
                for(ID PlanID : setFailurePMPlanID)
                {
                    if(setSuccessPMPlanID.contains(PlanID))
                        setSuccessPMPlanID.remove(PlanID);
                    if(mapPMPlanIdScheduleDefId.containskey(PlanID) && mapPMPlanIdScheduleDefId.get(PlanID) != NULL)
                        setSuccessPMScheduleID.removeAll(mapPMPlanIdScheduleDefId.get(PlanID));
                }
            }
            
            List<String> lstPMPlanId = new List<Id>();
            lstPMPlanId.addAll(setSuccessPMPlanID);
            setSuccessPMPlanID.clear();
            List<String> lstPMScheduleId = new List<Id>();
            lstPMScheduleId.addAll(setSuccessPMScheduleID);
            setSuccessPMScheduleID.clear();
            
            if(lstPMScheduleId != NULL && lstPMScheduleId.size() > 0)
            {
                INTF_WebServicesDef.INTF_Request reqToCalcNxtSchedule = new INTF_WebServicesDef.INTF_Request();
                reqToCalcNxtSchedule.recordIds = new List<String>();
                reqToCalcNxtSchedule.recordIds = lstPMPlanId;
                reqToCalcNxtSchedule.stringListMap = new List<INTF_WebServicesDef.INTF_StringListMap>();
                reqToCalcNxtSchedule.stringListMap.add(new INTF_WebServicesDef.INTF_StringListMap('SCHEDULEID', lstPMScheduleId));
                new PREV_PMPlanUtils().PREV_CalculateNextSchedule(reqToCalcNxtSchedule);    
            }
            */
        }
        
        //Roll back PM Plans, if any failure occurs
        if(lstWorkOrdIDs != NULL && lstWorkOrdIDs.size() > 0 && setFailurePMPlanID != NULL && setFailurePMPlanID.size() > 0)
            rollBackPMExecution(lstWorkOrdIDs, setFailurePMPlanID);
       
        //Clear all the global variable
        //mapPMPlanIdPMScheduleLstPMCvrgLst.clear(); //Moving this line to start of finish method for the story BAC-4255
        //mapPMPlanIdPMProcessId2.clear(); //Moving this line to start of finish method for the story BAC-4255
        //mapScheduleIdWorkOrder.clear(); //Moving this line to start of finish method for the story BAC-4255
        //mapPMProcess2.clear(); //Moving this line to where the use of this variable is over for the story BAC-4255
        //lstEngineResp.clear(); //Moving this line to where the use of this variable is over for the story BAC-4255
        //mapPMPlan.clear(); //Moving this line to where the use of this variable is over for the story BAC-4255
    }
    
    //Roll back method
    public void rollBackPMExecution(List<String> lstWorkOrdIDs, Set<String> setFailurePMPlanID)
    {
        if(lstWorkOrdIDs != NULL && lstWorkOrdIDs.size() > 0)
        {
            Set<Id> setCaseIDs = new Set<Id>();
            list<Case> lstFailurePMCase = new list<Case>();
            list<SVMXC__Service_Order__c> lstFailureWorkOrder = new list<SVMXC__Service_Order__c>();
            List<SVMXC__PM_History__c> lstFailurePMHistory = new List<SVMXC__PM_History__c>();
            
            if(setFailurePMPlanID.contains(NULL))
                setFailurePMPlanID.remove(NULL);
            
            if(setFailurePMPlanID != NULL && setFailurePMPlanID.size() > 0)
                lstFailureWorkOrder = [SELECT Id, SVMXC__Case__c FROM SVMXC__Service_Order__c WHERE Id IN: lstWorkOrdIDs AND SVMXC__PM_Plan__c IN: setFailurePMPlanID AND SVMXC__Is_PM_Work_Order__c = true];
            
            for(SVMXC__Service_Order__c currentWO : lstFailureWorkOrder)
                setCaseIDs.add(currentWO.SVMXC__Case__c);
            
            if(setCaseIDs.contains(NULL))
                setCaseIDs.remove(NULL);
            
            if(setCaseIDs != NULL && setCaseIDs.size() > 0 && setFailurePMPlanID != NULL && setFailurePMPlanID.size() > 0)
                lstFailurePMCase = [SELECT Id FROM Case WHERE Id IN: setCaseIDs AND SVMXC__PM_Plan__c IN: setFailurePMPlanID AND SVMXC__Is_PM_Case__c = true];
            
            if(setFailurePMPlanID != NULL && setFailurePMPlanID.size() > 0)
                lstFailurePMHistory = [select id from SVMXC__PM_History__c WHERE SVMXC__Work_Order__c IN: lstWorkOrdIDs AND SVMXC__PM_Plan__c IN: setFailurePMPlanID];
            
            system.debug(LoggingLevel.WARN, 'List of Work Orders during the PM failure: ' + lstFailureWorkOrder);
            system.debug(LoggingLevel.WARN, 'List of Cases during the PM failure: ' + lstFailurePMCase);
            system.debug(LoggingLevel.WARN, 'List of PM History during the PM failure: ' + lstFailurePMHistory);
            
            if(lstFailurePMCase != NULL && lstFailurePMCase.size() > 0)
                delete lstFailurePMCase;
            
            if(lstFailurePMHistory != NULL && lstFailurePMHistory.size() > 0)
                delete lstFailurePMHistory;
            
            if(lstFailureWorkOrder != NULL && lstFailureWorkOrder.size() > 0)
                delete lstFailureWorkOrder;
        }
    }
    
    // Method to send mail on Success/Failure
    public static void emailStatusInfo(String strSummary, String strLogger, Set<String> setEmailIDs ,String strSubject, boolean isAttachLog)
    {
        try
        {
            if(setEmailIDs != NULL && setEmailIDs.size() > 0)
            {
                List<String> lstEmailIDs = new List<String>();
                lstEmailIDs.addAll(setEmailIDs);
                Messaging.SingleEmailMessage objSingleEmailMsg = new Messaging.SingleEmailMessage();
                objSingleEmailMsg.setToAddresses(lstEmailIDs);
                objSingleEmailMsg.setSenderDisplayName(getTAG007());
                objSingleEmailMsg.setSubject(getTAG007() + ': ' + strSubject);
                objSingleEmailMsg.setBccSender(false);
                objSingleEmailMsg.setUseSignature(false);
                
                if(isAttachLog && strLogger != NULL && strLogger.length() > 0)
                {
                    // SK Regex issue fix story BAC-4255 by commenting the line below. 
                    //strLogger = strLogger.replaceFirst('\n\n', '');
                    Messaging.EmailFileAttachment objFileAttachment = new Messaging.EmailFileAttachment();
                    objFileAttachment.setFileName('Attachment');
                    objFileAttachment.setBody(Blob.valueof(strLogger));
                    objSingleEmailMsg.setFileAttachments(new Messaging.EmailFileAttachment[] {objFileAttachment});
                }
                objSingleEmailMsg.setPlainTextBody(strSummary);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objSingleEmailMsg });
            }
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Email Exception: ' + ex.getMessage());
        }
    }
    
    public String getTAG001(){return system.label.COMM001_TAG093 ;} //'NOTE: THIS IS A SYSTEM GENERATED EMAIL. PLEASE DO NOT REPLY TO THIS MESSAGE.'
    public String getTAG002(){return system.label.PREV006_TAG002;} //'Preventive Maintenance Process: '
    public String getTAG003(){return system.label.PREV006_TAG003;} //'Number of qualified Preventive Maintenance Plans: '
    public String getTAG004(){return system.label.COMM001_TAG095;} //'Attachment'
    public String getTAG005(){return system.label.PREV006_TAG001;} //Processing of Preventive Maintenance plans has been completed with the following results:
    public String getTAG006(){return system.label.COMM001_TAG092;} //'See attached log for more details.'
    public static String getTAG007(){return system.label.COMM001_TAG090;} //'ServiceMax'
    public String getTAG008(){return system.label.COMM001_TAG096;} //'Success'
    public String getTAG009(){return system.label.COMM001_TAG097;} //'Failed'
    public String getTAG010(){return system.label.COMM001_TAG091;} //'Status'
    public String getTAG011(){return system.label.PREV006_TAG009;} //'Preventive Maintenance Plan Status'
    public String getTAG012(){return system.label.PREV006_TAG004;} //'Preventive Maintenance Plan: '
    public String getTAG013(){return system.label.PREV006_TAG005;} //'Number of Work Orders created: '
    public String getTAG014(){return 'Detailed log is generated and attached to this Task as file PM Completion Log';} //
    public String getTAG015(){return 'Detailed log is generated and attached to this Task as file PM Completion Log';} //
    public String getTAG016(){return 'PM Completion Log';}
    public String getTAG017(){return system.label.PREV006_TAG010;}
    public String getTAG018(){return system.label.PREV006_TAG012;}
    public String getTAG019(){return system.label.PREV006_TAG013;}
}