global class WSCH_Jeopardy_Manager_SchHandler {		//SDL-SVMX-WITH-SHARING-NOT-ENFORCED-BY-DESIGN
    
    public class SVMXException extends Exception {}
    public static map<string, Map<String, String>> mapExceptionSetting = new map<string, Map<String, String>>();
    public static DCON_Utils dcUtils = new DCON_Utils();
    public static Datetime thresholdDateTimeToCheckForJeopardy;
    public static Datetime currentTime;
    static 
    {
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    list<string> lstSubModuleId = new list<string>();
    lstSubModuleId.add('DCON006');
    lstSubModuleId.add('OMAX003');
    mapExceptionSetting = settings.SVMX_getSettingList(lstSubModuleId);
    }
    
    public WSCH_Jeopardy_Manager_SchHandler()
    {
        //calculates datetime of after 24 hours of Business(Default business hours of Org) from current time
        BusinessHours default_businesshr = [SELECT WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime,TimeZoneSidKey from BusinessHours where IsDefault = true and IsActive = true];	//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        System.debug('default_businesshr:' + default_businesshr);
        currentTime = System.now();
        System.debug('currentTime:'+ currentTime);
        Long nextMinutesDoCheckForJeopardy = 24*60*60*1000;
        System.debug('nextMinutesDoCheckForJeopardy:'+ nextMinutesDoCheckForJeopardy);
        Long totalMinutesConsumed = 0;
        for(Date tempdate = currentTime.dateGMT(); totalMinutesConsumed < nextMinutesDoCheckForJeopardy; tempdate = tempdate.addDays(1))
        {
            List<Datetime> techWorkingHRStartEndTime = new List<Datetime>();
            if(!GetHolidays(default_businesshr,tempdate))
                {
                    System.debug('tempdate:'+tempdate);
                    Long tempTotalMinutesConsumed = 0;
                    techWorkingHRStartEndTime = dcUtils.getBHStartEndDateTime('GMT',tempdate,default_businesshr);
                    System.debug('techWorkingHRStartEndTime:'+ techWorkingHRStartEndTime);
                    if(techWorkingHRStartEndTime.get(0).dateGMT() == currentTime.dateGMT())
                    {
                        if(currentTime <= techWorkingHRStartEndTime.get(0) && currentTime < techWorkingHRStartEndTime.get(1))   
                        {
                            tempTotalMinutesConsumed = techWorkingHRStartEndTime.get(1).getTime() - techWorkingHRStartEndTime.get(0).getTime();
                        }
                        else if(techWorkingHRStartEndTime.get(0) < currentTime && currentTime < techWorkingHRStartEndTime.get(1))
                        {
                            tempTotalMinutesConsumed = techWorkingHRStartEndTime.get(1).getTime() - currentTime.getTime();
                        }
                    }
                    else if(techWorkingHRStartEndTime.get(0).dateGMT() < currentTime.dateGMT() && currentTime.dateGMT() <= techWorkingHRStartEndTime.get(1).dateGMT())
                    {
                        if(currentTime <= techWorkingHRStartEndTime.get(1))
                        {
                            tempTotalMinutesConsumed = techWorkingHRStartEndTime.get(1).getTime() - currentTime.getTime();
                        }
                    }
                    else if(techWorkingHRStartEndTime.get(0).dateGMT() > currentTime.dateGMT())
                    {
                        tempTotalMinutesConsumed = techWorkingHRStartEndTime.get(1).getTime() - techWorkingHRStartEndTime.get(0).getTime();
                    }
                    totalMinutesConsumed = totalMinutesConsumed + tempTotalMinutesConsumed;
                    if(totalMinutesConsumed == nextMinutesDoCheckForJeopardy)
                    {
                        thresholdDateTimeToCheckForJeopardy = techWorkingHRStartEndTime.get(1);
                    }
                    else if(totalMinutesConsumed > nextMinutesDoCheckForJeopardy)
                    {
                        thresholdDateTimeToCheckForJeopardy = techWorkingHRStartEndTime.get(1).addSeconds(Integer.valueOf((nextMinutesDoCheckForJeopardy - totalMinutesConsumed)/1000));    
                        //thresholdDateTimeToCheckForJeopardy = techWorkingHRStartEndTime.get(1).addSeconds(-Integer.valueOf((totalMinutesConsumed - nextMinutesDoCheckForJeopardy)/1000)); 
                    }
               
                }
                System.debug('totalMinutesConsumed:'+ totalMinutesConsumed);
        }
        System.debug('thresholdDateTimeToCheckForJeopardy:'+ thresholdDateTimeToCheckForJeopardy);
    }
    //method changes jeopardy status to 'false' from 'true' if workorder is no more in jeopardy. 
    //Limits - start limit: 24 normal hours back from current time 
    //         end  limit: 24 business hours after current time
    public static void undoJeopardyAfterTechUpdate()
        {
            
            try
            {
                Integer schedulerFrequency;
                Integer gracePeriod;
                map<String, String> mapEachSetting = new map<String, String>();
                if(mapExceptionSetting.containsKey('DCON006') && mapExceptionSetting.get('DCON006') != null && mapExceptionSetting.get('DCON006').size() > 0)
                {
                    mapEachSetting = mapExceptionSetting.get('DCON006');
                    if(mapEachSetting !=NULL && mapEachSetting.containsKey('SET001') && mapEachSetting.get('SET001') != null)
                    {
                        schedulerFrequency = Integer.valueOf(mapEachSetting.get('SET001'));
                    }  
                    if(mapEachSetting !=NULL && mapEachSetting.containsKey('SET003') && mapEachSetting.get('SET003') != null)
                    {
                        gracePeriod = Integer.valueOf(mapEachSetting.get('SET003'));
                    } 
                    
                } 
                if (schedulerFrequency == null || schedulerFrequency == 0) 
                {
                    schedulerFrequency = 0;
                }
                if (gracePeriod == null) 
                {
                    gracePeriod = 0;
                }   
               
                List<SVMXC__Service_Order__c> lstworkorders = new List<SVMXC__Service_Order__c>();
                List<SVMXC__Service_Order__c> lstUpdatedWos = new List<SVMXC__Service_Order__c>();
                List<String> lstDispProcess = new List<String>();
                Set<Id> processIds = new Set<Id>();
                Set<String> setWoIds = new Set<String>();
                lstDispProcess.add('Real Time Optimization');
                lstDispProcess.add('Optimized Batch');
                    
                Map<Id,SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new Map<Id,SVMXC__ServiceMax_Processes__c>();
                mapSVMXProcess.putAll([SELECT Id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Dispatch Process' and SVMXC__Dispatch_Method__c IN : lstDispProcess order by SVMXC__Sequence__c]);
                    
                processIds.addAll(mapSVMXProcess.keySet());
                                
                Map<Id,List<SVMXC__Service_Order__c>> mapTechWorkorders = new Map<Id,List<SVMXC__Service_Order__c>>();
                Datetime startLimit = (currentTime.addDays(-1));
                    
                lstworkorders = Database.query('SELECT Id, SVMXC__Service_Duration__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c,SVMXC__Case__c, SVMXC__SLA_Terms__c,SVMXC__SM_In_Jeopardy__c,SVMXC__Dispatch_Process__c,SVMXC__Order_Status__c,SVMXC__Violation_Status2__c,SVMXC__Work_Order_Scheduling_Status__c,SVMXC__Scheduled_Date_Time__c,SVMXC__Driving_Time__c,SVMXC__Group_Member__c FROM SVMXC__Service_Order__c where SVMXC__Dispatch_Process__c IN :processIds and SVMXC__Group_Member__c != null and (SVMXC__Violation_Status2__c = null or SVMXC__Violation_Status2__c = \'\') and SVMXC__Work_Order_Scheduling_Status__c != null and (SVMXC__Scheduled_Date_Time__c != null) and (SVMXC__Scheduled_Date_Time__c >= :startLimit and SVMXC__Scheduled_Date_Time__c <= :thresholdDateTimeToCheckForJeopardy) and SVMXC__SM_In_Jeopardy__c = true order by SVMXC__Scheduled_Date_Time__c');
                
                System.debug('Input:lstworkorders4::' + lstworkorders);
                WSCH_AuditLogger.debug('Input:lstworkorders4::' + lstworkorders);
                    
                for(SVMXC__Service_Order__c oWO : lstworkorders)
                   {
                        setWoIds.add(oWO.Id);
                        if(String.valueOf(oWO.SVMXC__Group_Member__c) != null && !String.isBlank(String.valueOf(oWO.SVMXC__Group_Member__c)))
                            {   
                                if(mapTechWorkorders.containsKey(oWO.SVMXC__Group_Member__c))
                                {
                                    mapTechWorkorders.get(oWO.SVMXC__Group_Member__c).add(oWO);
                                }
                                else
                                {
                                    List<SVMXC__Service_Order__c> tempwo = new List<SVMXC__Service_Order__c>();
                                    tempwo.add(oWO);
                                    mapTechWorkorders.put(oWO.SVMXC__Group_Member__c,tempwo);
                                }
                            }   
                    }
                System.debug('mapTechWorkorders4:' + mapTechWorkorders);        
                WSCH_AuditLogger.debug('mapTechWorkorders4:' + mapTechWorkorders);
                for(Id techId: mapTechWorkorders.keySet()) 
                    {
                        System.debug('Tech Id:' + techId);
                        Boolean any_Of_WO_InJeopardy_For_Tech = false;
                        Datetime deltaTime_To_Start_NextWO;
                        for(SVMXC__Service_Order__c oWO : mapTechWorkorders.get(techId))
                        {
                            System.debug('any_Of_WO_InJeopardy_For_Tech:'+ any_Of_WO_InJeopardy_For_Tech);
                            if(oWO.SVMXC__Service_Duration__c == null)
                                oWO.SVMXC__Service_Duration__c = 0.0;
                            if(oWO.SVMXC__Driving_Time__c == null)
                                oWO.SVMXC__Driving_Time__c = 0.0;
                            
                            if(oWO.SVMXC__Scheduled_Date_Time__c != null)
                            {
                                if((oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Finished Onsite' || oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Completed'|| oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Cancelled'))
                                {
                                    oWO.SVMXC__SM_In_Jeopardy__c = false;
                                    lstUpdatedWos.add(oWO);
                                    any_Of_WO_InJeopardy_For_Tech = false;
                                    System.debug('Completed:'+ oWO.Id);
                                }
                                //In following if condition, we are ignoring workorders that are went to jeopardy beacause of cascading effect if intial workorder is still in jeopardy
                                else if(currentTime < (oWO.SVMXC__Scheduled_Date_Time__c.addMinutes(-Integer.valueOf(oWO.SVMXC__Driving_Time__c))).addMinutes(gracePeriod) && (oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Dispatched' || oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Received') && !any_Of_WO_InJeopardy_For_Tech)
                                {
                                    oWO.SVMXC__SM_In_Jeopardy__c = false;
                                    lstUpdatedWos.add(oWO); 
                                    any_Of_WO_InJeopardy_For_Tech = false;
                                    System.debug('dispatched not in cascading impact:'+ oWO.Id);
                                }
                                else if(currentTime > (oWO.SVMXC__Scheduled_Date_Time__c.addMinutes(-Integer.valueOf(oWO.SVMXC__Driving_Time__c))).addMinutes(gracePeriod) && currentTime < oWO.SVMXC__Scheduled_Date_Time__c.addMinutes(gracePeriod) && (oWO.SVMXC__Work_Order_Scheduling_Status__c == 'En Route'))
                                {
                                    oWO.SVMXC__SM_In_Jeopardy__c = false;
                                    lstUpdatedWos.add(oWO); 
                                    any_Of_WO_InJeopardy_For_Tech = false;
                                    System.debug('En Route:'+ oWO.Id);
                                }
                                else if(currentTime > oWO.SVMXC__Scheduled_Date_Time__c.addMinutes(gracePeriod) && currentTime < (oWO.SVMXC__Scheduled_Date_Time__c.addMinutes(Integer.valueOf(oWO.SVMXC__Service_Duration__c))).addMinutes(gracePeriod) && (oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Onsite'))
                                {
                                    oWO.SVMXC__SM_In_Jeopardy__c = false;
                                    lstUpdatedWos.add(oWO); 
                                    any_Of_WO_InJeopardy_For_Tech = false;
                                    System.debug('Onsite:'+ oWO.Id);
                                    System.debug('Onsite: any_Of_WO_InJeopardy_For_Tech:'+ any_Of_WO_InJeopardy_For_Tech);
                                }
                                else if(currentTime > (oWO.SVMXC__Scheduled_Date_Time__c.addMinutes(Integer.valueOf(oWO.SVMXC__Service_Duration__c))).addMinutes(gracePeriod) && (oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Finished Onsite' || oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Completed'))
                                {
                                    oWO.SVMXC__SM_In_Jeopardy__c = false;
                                    lstUpdatedWos.add(oWO); 
                                    any_Of_WO_InJeopardy_For_Tech = false;
                                    System.debug('last completed:'+ oWO.Id);
                                }
                                else
                                {
                                    any_Of_WO_InJeopardy_For_Tech = true;
                                    System.debug('last any_Of_WO_InJeopardy_For_Tech:'+ oWO.Id);
                                }
                            }
                        }
                    }
                System.debug('lstUpdatedWos4:'+ lstUpdatedWos);
                WSCH_AuditLogger.debug('lstUpdatedWos4:'+ lstUpdatedWos);
                WSCH_AuditLogger.debug('WSCH_Jeopardy_Manager_SchHandler::undoJeopardyAfterTechUpdate::No. of workorders moved to not in Jeopardy: '+ lstUpdatedWos.size());      
                //update lstUpdatedWos;
                // -CRUD
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstUpdatedWos,COMM_SecurityUtils.Access.Updateable))		//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    {
                        update lstUpdatedWos;
                    } 
                else 
                    {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                    }
                  
            }
            catch(Exception ex)
            {
                System.debug('Exception caught:WSCH_Jeopardy_Manager_SchHandler:' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            }   
        
        }
        //method makes workorder into jeopardy if technician is not assigned to workorder even after threshold limit
        //Limits - start limit: no limits
        //         end  limit: 24 business hours after current time
        public static void getWOInJeopardy_For_Unresourced_Unscheduled()
        {
            
            try
            {
                Integer thresholdValue;
                map<String, String> mapEachSetting = new map<String, String>();
                if(mapExceptionSetting.containsKey('DCON006') && mapExceptionSetting.get('DCON006') != null && mapExceptionSetting.get('DCON006').size() > 0)
                {
                    mapEachSetting = mapExceptionSetting.get('DCON006');
                    if(mapEachSetting !=NULL && mapEachSetting.containsKey('SET004') && mapEachSetting.get('SET004') != null)
                    {
                        thresholdValue = Integer.valueOf(mapEachSetting.get('SET004'));
                    }                    
                } 
                if (thresholdValue == null || thresholdValue == 0) 
                {
                    thresholdValue = 0;
                }               
                Datetime Fulfilment_Dead_Line_Time;
                List<SVMXC__Service_Order__c> lstworkorders = new List<SVMXC__Service_Order__c>();
                List<SVMXC__Service_Order__c> lstworkordersWithPET = new List<SVMXC__Service_Order__c>();
                List<SVMXC__Service_Order__c> lstworkordersWithOutPET = new List<SVMXC__Service_Order__c>();
                List<SVMXC__Service_Order__c> lstUpdatedWos = new List<SVMXC__Service_Order__c>();
                List<String> lstDispProcess = new List<String>();
                List<String> lstcaseIds = new List<String>();
                string strSLATimeStampForWO = ''; 
                string strSLATimeStampWOFieldAPIName;
                Set<Id> processIds = new Set<Id>();
                lstDispProcess.add('Real Time Optimization');
                lstDispProcess.add('Optimized Batch');
                    
                COMM_Utils_ManageSettings commUtils = new COMM_Utils_ManageSettings();
                Map<String, String> svmxSetting = new Map<String, String> ();
                svmxSetting = commUtils.SVMX_getSettingList('OMAX003','SET008');
                    
                strSLATimeStampForWO = svmxSetting.get('SET008');
                if('Onsite Response Customer' == strSLATimeStampForWO)
                    strSLATimeStampWOFieldAPIName = 'SVMXC__Onsite_Response_Customer_By__c';
                else if('Initial Response Customer' == strSLATimeStampForWO)
                    strSLATimeStampWOFieldAPIName = 'SVMXC__Initial_Response_Customer_By__c';
                else if('Restoration Customer' == strSLATimeStampForWO)
                    strSLATimeStampWOFieldAPIName = 'SVMXC__Restoration_Customer_By__c';
                else if('Resolution Customer' == strSLATimeStampForWO)
                    strSLATimeStampWOFieldAPIName = 'SVMXC__Resolution_Customer_By__c';
                else if('Onsite Response Internal' == strSLATimeStampForWO)
                    strSLATimeStampWOFieldAPIName = 'SVMXC__Onsite_Response_Internal_By__c';
                else if('Initial Response Internal' == strSLATimeStampForWO)
                    strSLATimeStampWOFieldAPIName = 'SVMXC__Initial_Response_Internal_By__c';
                else if('Restoration Internal' == strSLATimeStampForWO)
                    strSLATimeStampWOFieldAPIName = 'SVMXC__Restoration_Internal_By__c';
                else if('Resolution Internal' == strSLATimeStampForWO)
                    strSLATimeStampWOFieldAPIName = 'SVMXC__Resolution_Internal_By__c';
                        
                Map<Id,SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new Map<Id,SVMXC__ServiceMax_Processes__c>();
                mapSVMXProcess.putAll([SELECT Id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Dispatch Process' and SVMXC__Dispatch_Method__c IN : lstDispProcess order by SVMXC__Sequence__c]);
                    
                processIds.addAll(mapSVMXProcess.keySet());
                lstworkordersWithOutPET = Database.query('SELECT Id, SVMXC__Service_Duration__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c,SVMXC__Case__c, SVMXC__SLA_Terms__c,SVMXC__SM_In_Jeopardy__c,SVMXC__Order_Status__c,SVMXC__Violation_Status2__c,SVMXC__Dispatch_Status__c,SVMXC__Dispatch_Process__c FROM SVMXC__Service_Order__c where SVMXC__Dispatch_Process__c IN :processIds and SVMXC__Order_Status__c NOT IN (\'Closed\',\'Canceled\') and ((SVMXC__Violation_Status2__c IN (\'Unscheduled - Bad Data\',\'Unresourced\')) or (SVMXC__Dispatch_Status__c = \'New\')) and SVMXC__Preferred_End_Time__c = null and SVMXC__SM_In_Jeopardy__c = false');
                    
                lstworkordersWithPET = Database.query('SELECT Id, SVMXC__Service_Duration__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c,SVMXC__Case__c, SVMXC__SLA_Terms__c,SVMXC__SM_In_Jeopardy__c,SVMXC__Order_Status__c,SVMXC__Violation_Status2__c,SVMXC__Dispatch_Status__c,SVMXC__Dispatch_Process__c FROM SVMXC__Service_Order__c where SVMXC__Dispatch_Process__c IN :processIds and SVMXC__Order_Status__c NOT IN (\'Closed\',\'Canceled\') and ((SVMXC__Violation_Status2__c IN (\'Unscheduled - Bad Data\',\'Unresourced\')) or (SVMXC__Dispatch_Status__c = \'New\')) and SVMXC__Preferred_End_Time__c <= :thresholdDateTimeToCheckForJeopardy and SVMXC__SM_In_Jeopardy__c = false');
                    
                for(SVMXC__Service_Order__c oWO : lstworkordersWithOutPET)
                    {
                        lstcaseIds.add(oWO.SVMXC__Case__c);
                    }   
                    
                lstworkorders.addAll(lstworkordersWithPET);
                lstworkorders.addAll(lstworkordersWithOutPET);
                
                System.debug('Input:lstworkorders1::' + lstworkorders);
                        
                map<Id,case> mapcases = new map<Id,case>(); 
                mapcases.putAll([SELECT Id,SVMXC__Preferred_End_Time__c,SVMXC__Preferred_Start_Time__c FROM Case where Id IN :lstcaseIds]);
                for(SVMXC__Service_Order__c oWO : lstworkorders)
                    {
                        Fulfilment_Dead_Line_Time = null;
                        if(!oWO.SVMXC__SM_In_Jeopardy__c)   
                        {   
                            if(oWO.SVMXC__Service_Duration__c == null)
                                oWO.SVMXC__Service_Duration__c = 0.0;
                            
                            if(oWO.SVMXC__Preferred_End_Time__c == null)
                            {
                                // If Booking Window is applicable, take preferred time from BW
                                if(oWO.SVMXC__Case__c != null && mapcases.get(oWO.SVMXC__Case__c) != null && mapcases.get(oWO.SVMXC__Case__c).Preferred_End_Time__c != null)
                                {
                                    Fulfilment_Dead_Line_Time = mapcases.get(oWO.SVMXC__Case__c).Preferred_End_Time__c;
                                }
                                // Else, if SLA is applicable, take the SLA time
                                else if(oWO.SVMXC__SLA_Terms__c != null)
                                {
                                    Fulfilment_Dead_Line_Time = (DateTime)(oWO.get(strSLATimeStampWOFieldAPIName));
                                }   
                            }
                            else
                            {
                                Fulfilment_Dead_Line_Time = oWO.SVMXC__Preferred_End_Time__c;
                            }   
                            if(Fulfilment_Dead_Line_Time != null)
                            {
                                Datetime timeToReachLocation = (Fulfilment_Dead_Line_Time.addSeconds(-(Integer.valueof(oWO.SVMXC__Service_Duration__c)))).addMinutes(-thresholdValue);
                                if(timeToReachLocation < currentTime)
                                {
                                    oWO.SVMXC__SM_In_Jeopardy__c = true;
                                    lstUpdatedWos.add(oWO); 
                                }
                            }
                        }
                    }   
                System.debug('lstUpdatedWos:'+ lstUpdatedWos);  
                WSCH_AuditLogger.debug('lstUpdatedWos:'+ lstUpdatedWos);
                WSCH_AuditLogger.debug('WSCH_Jeopardy_Manager_SchHandler::getWOInJeopardy_For_Unresourced_Unscheduled::No. of workorders moved to Jeopardy: '+ lstUpdatedWos.size());
                //update lstUpdatedWos;
                // -CRUD
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstUpdatedWos,COMM_SecurityUtils.Access.Updateable))		//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    {
                        update lstUpdatedWos;
                    } 
                else 
                    {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                    }
            }
            catch(Exception ex)
            {
                System.debug('Exception caught:WSCH_Jeopardy_Manager_SchHandler ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            }   
        
        }
        //method makes workorder into jeopardy if assigned technician is not arrive and not completed the workorder 
        //Limits - start limit:  24 normal hours back from current time 
        //         end  limit: 24 business hours after current time
        public static void getWOInJeopardy_Scheduled_NotProgressing()
        {
            
            try
            {
                Boolean techUpdateStatus = false;
                Integer thresholdValue;
                map<String, String> mapEachSetting = new map<String, String>();
                if(mapExceptionSetting.containsKey('DCON006') && mapExceptionSetting.get('DCON006') != null && mapExceptionSetting.get('DCON006').size() > 0)
                {
                    mapEachSetting = mapExceptionSetting.get('DCON006');
                    if(mapEachSetting !=NULL && mapEachSetting.containsKey('SET002') && mapEachSetting.get('SET002') != null)
                    {
                        techUpdateStatus = Boolean.valueOf(mapEachSetting.get('SET002'));
                    }  
                    if(mapEachSetting !=NULL && mapEachSetting.containsKey('SET003') && mapEachSetting.get('SET003') != null)
                    {
                        thresholdValue = Integer.valueOf(mapEachSetting.get('SET003')); 
                    }
                } 
                if (thresholdValue == null || thresholdValue == 0) {
                                    thresholdValue = 0;
                                }
                
                if(techUpdateStatus)
                {   
                    Datetime Fulfilment_Dead_Line_Time;
                    List<SVMXC__Service_Order__c> lstworkorders = new List<SVMXC__Service_Order__c>();
                    List<SVMXC__Service_Order__c> lstUpdatedWos = new List<SVMXC__Service_Order__c>();
                    List<String> lstDispProcess = new List<String>();
                    Set<Id> processIds = new Set<Id>();
                    lstDispProcess.add('Real Time Optimization');
                    lstDispProcess.add('Optimized Batch');
                    
                    Map<Id,SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new Map<Id,SVMXC__ServiceMax_Processes__c>();
                    mapSVMXProcess.putAll([SELECT Id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Dispatch Process' and SVMXC__Dispatch_Method__c IN : lstDispProcess order by SVMXC__Sequence__c]);
                    
                    processIds.addAll(mapSVMXProcess.keySet());
                    
                    lstworkorders = Database.query('SELECT Id, SVMXC__Service_Duration__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c,SVMXC__Case__c, SVMXC__SLA_Terms__c,SVMXC__SM_In_Jeopardy__c,SVMXC__Dispatch_Process__c,SVMXC__Order_Status__c,SVMXC__Violation_Status2__c,SVMXC__Work_Order_Scheduling_Status__c,SVMXC__Scheduled_Date_Time__c,SVMXC__Driving_Time__c FROM SVMXC__Service_Order__c where SVMXC__Dispatch_Process__c IN :processIds and SVMXC__Order_Status__c NOT IN (\'Closed\',\'Canceled\') and SVMXC__Group_Member__c != null and (SVMXC__Violation_Status2__c = null or SVMXC__Violation_Status2__c = \'\') and (SVMXC__Work_Order_Scheduling_Status__c NOT IN (\'Cancelled\',\'Finished Onsite\',\'Completed\')) and (SVMXC__Scheduled_Date_Time__c != null) and SVMXC__Scheduled_Date_Time__c <= :thresholdDateTimeToCheckForJeopardy and SVMXC__SM_In_Jeopardy__c = false');
                    
                    System.debug('Input:lstworkorders2::' + lstworkorders);
                    WSCH_AuditLogger.debug('Input:lstworkorders2::' + lstworkorders);
                    for(SVMXC__Service_Order__c oWO : lstworkorders)
                        {
                            if(oWO.SVMXC__Service_Duration__c == null)
                                oWO.SVMXC__Service_Duration__c = 0.0;
                            if(oWO.SVMXC__Driving_Time__c == null)
                                oWO.SVMXC__Driving_Time__c = 0.0;
                            
                            if(oWO.SVMXC__Scheduled_Date_Time__c != null && !oWO.SVMXC__SM_In_Jeopardy__c)
                            {
                                                            
                                //Work order is dispatched to the mobile device (with or without drip feed) but technician has NOT acknowledged by the receipt of work
                                //Technician has not started driving to the work order site, yet
                                if(!(oWO.SVMXC__Work_Order_Scheduling_Status__c == 'En Route' || oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Onsite' || oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Finished Onsite' ||
                                oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Completed' || oWO.SVMXC__Work_Order_Scheduling_Status__c == null))
                                {
                                    if(currentTime > (oWO.SVMXC__Scheduled_Date_Time__c.addMinutes(-Integer.valueOf(oWO.SVMXC__Driving_Time__c))).addMinutes(thresholdValue))
                                    {
                                        oWO.SVMXC__SM_In_Jeopardy__c = true;
                                        lstUpdatedWos.add(oWO);     
                                    }
                                }
                                // Not arrived at the work order site, yet
                                else if(!(oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Onsite' || oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Finished Onsite' || oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Completed' || oWO.SVMXC__Work_Order_Scheduling_Status__c == null))
                                {
                                    if(currentTime > oWO.SVMXC__Scheduled_Date_Time__c.addMinutes(thresholdValue))
                                    {
                                        oWO.SVMXC__SM_In_Jeopardy__c = true;
                                        lstUpdatedWos.add(oWO);     
                                    }
                                    
                                }
                                //Not finished at site yet, taking longer than expected
                                else if(!(oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Finished Onsite' || oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Completed' || oWO.SVMXC__Work_Order_Scheduling_Status__c == null))
                                {
                                    if(currentTime > (oWO.SVMXC__Scheduled_Date_Time__c.addSeconds(Integer.valueOf(oWO.SVMXC__Service_Duration__c))).addMinutes(thresholdValue))
                                    {
                                        oWO.SVMXC__SM_In_Jeopardy__c = true;
                                        lstUpdatedWos.add(oWO);     
                                    }
                                    
                                }
                            }
                            
                        }
                    System.debug('lstUpdatedWos:'+ lstUpdatedWos);
                    WSCH_AuditLogger.debug('lstUpdatedWos:'+ lstUpdatedWos);
                    WSCH_AuditLogger.debug('WSCH_Jeopardy_Manager_SchHandler::getWOInJeopardy_Scheduled_NotProgressing::No. of workorders moved to Jeopardy: '+ lstUpdatedWos.size());      
                    //update lstUpdatedWos;
                    // -CRUD
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstUpdatedWos,COMM_SecurityUtils.Access.Updateable))		//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    {
                        update lstUpdatedWos;
                    } 
                    else 
                    {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                    }
                }   
            }
            catch(Exception ex)
            {
                System.debug('Exception caught:WSCH_Jeopardy_Manager_SchHandler:' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            }   
        
        }
        //method makes workorder into jeopardy if there is cascading jeopardy impact
        //Limits - start limit:  24 normal hours back from current time 
        //         end  limit: 24 business hours after current time 
        public static void getWOInCascadingJeopardy()
        {
            
            try
            {
                Integer schedulerFrequency;
                Integer gracePeriod;
                map<String, String> mapEachSetting = new map<String, String>();
                if(mapExceptionSetting.containsKey('DCON006') && mapExceptionSetting.get('DCON006') != null && mapExceptionSetting.get('DCON006').size() > 0)
                {
                    mapEachSetting = mapExceptionSetting.get('DCON006');
                    if(mapEachSetting !=NULL && mapEachSetting.containsKey('SET001') && mapEachSetting.get('SET001') != null)
                    {
                        schedulerFrequency = Integer.valueOf(mapEachSetting.get('SET001'));
                    }  
                    if(mapEachSetting !=NULL && mapEachSetting.containsKey('SET003') && mapEachSetting.get('SET003') != null)
                    {
                        gracePeriod = Integer.valueOf(mapEachSetting.get('SET003'));
                    } 
                    
                } 
                if (schedulerFrequency == null || schedulerFrequency == 0) 
                {
                    schedulerFrequency = 0;
                }
                if (gracePeriod == null) 
                {
                    gracePeriod = 0;
                }   
               
                List<SVMXC__Service_Order__c> lstworkorders = new List<SVMXC__Service_Order__c>();
                List<SVMXC__Service_Order__c> lstUpdatedWos = new List<SVMXC__Service_Order__c>();
                List<String> lstDispProcess = new List<String>();
                Set<Id> processIds = new Set<Id>();
                Set<String> setWoIds = new Set<String>();
                lstDispProcess.add('Real Time Optimization');
                lstDispProcess.add('Optimized Batch');
                    
                Map<Id,SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new Map<Id,SVMXC__ServiceMax_Processes__c>();
                mapSVMXProcess.putAll([SELECT Id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Dispatch Process' and SVMXC__Dispatch_Method__c IN : lstDispProcess order by SVMXC__Sequence__c]);
                    
                processIds.addAll(mapSVMXProcess.keySet());
                                
                Map<Id,List<SVMXC__Service_Order__c>> mapTechWorkorders = new Map<Id,List<SVMXC__Service_Order__c>>();
                //Datetime startLimit = (currentTime.addMinutes(-schedulerFrequency)).addMinutes(-gracePeriod);
                Datetime startLimit = currentTime.addDays(-1);
                    
                lstworkorders = Database.query('SELECT Id, SVMXC__Service_Duration__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c,SVMXC__Case__c, SVMXC__SLA_Terms__c,SVMXC__SM_In_Jeopardy__c,SVMXC__Dispatch_Process__c,SVMXC__Order_Status__c,SVMXC__Violation_Status2__c,SVMXC__Work_Order_Scheduling_Status__c,SVMXC__Scheduled_Date_Time__c,SVMXC__Driving_Time__c,SVMXC__Group_Member__c FROM SVMXC__Service_Order__c where SVMXC__Dispatch_Process__c IN :processIds and SVMXC__Order_Status__c NOT IN (\'Closed\',\'Canceled\') and SVMXC__Group_Member__c != null and (SVMXC__Violation_Status2__c = null or SVMXC__Violation_Status2__c = \'\') and (SVMXC__Work_Order_Scheduling_Status__c NOT IN (\'Cancelled\',\'Finished Onsite\',\'Completed\')) and (SVMXC__Scheduled_Date_Time__c != null) and (SVMXC__Scheduled_Date_Time__c >= :startLimit and SVMXC__Scheduled_Date_Time__c <= :thresholdDateTimeToCheckForJeopardy) order by SVMXC__Scheduled_Date_Time__c');
                
                System.debug('Input:lstworkorders3::' + lstworkorders);
                WSCH_AuditLogger.debug('Input:lstworkorders3::' + lstworkorders);
                    
                for(SVMXC__Service_Order__c oWO : lstworkorders)
                   {
                        setWoIds.add(oWO.Id);
                        if(String.valueOf(oWO.SVMXC__Group_Member__c) != null && !String.isBlank(String.valueOf(oWO.SVMXC__Group_Member__c)))
                            {   
                                if(mapTechWorkorders.containsKey(oWO.SVMXC__Group_Member__c))
                                {
                                    mapTechWorkorders.get(oWO.SVMXC__Group_Member__c).add(oWO);
                                }
                                else
                                {
                                    List<SVMXC__Service_Order__c> tempwo = new List<SVMXC__Service_Order__c>();
                                    tempwo.add(oWO);
                                    mapTechWorkorders.put(oWO.SVMXC__Group_Member__c,tempwo);
                                }
                            }   
                    }
                System.debug('mapTechWorkorders:' + mapTechWorkorders);     
                WSCH_AuditLogger.debug('mapTechWorkorders:' + mapTechWorkorders);
                for(Id techId: mapTechWorkorders.keySet()) 
                    {
                        Boolean any_Of_WO_InJeopardy_For_Tech = false;
                        Datetime deltaTime_To_Start_NextWO;
                        for(SVMXC__Service_Order__c oWO : mapTechWorkorders.get(techId))
                        {
                            if(oWO.SVMXC__Service_Duration__c == null)
                                oWO.SVMXC__Service_Duration__c = 0.0;
                            if(oWO.SVMXC__Driving_Time__c == null)
                                oWO.SVMXC__Driving_Time__c = 0.0;
                            
                            if(oWO.SVMXC__Scheduled_Date_Time__c != null)
                            {
                                if(oWO.SVMXC__SM_In_Jeopardy__c)
                                {
                                    System.debug('wo in Jeopardy for case 3:'+oWO.Id);
                                    WSCH_AuditLogger.debug('wo in Jeopardy for case 3:'+oWO.Id);
                                    if(String.valueOf(deltaTime_To_Start_NextWO) == null && String.isBlank(String.valueOf(deltaTime_To_Start_NextWO)))
                                    {
                                        deltaTime_To_Start_NextWO = currentTime;
                                    }
                                    else if(currentTime > deltaTime_To_Start_NextWO)
                                    {
                                        deltaTime_To_Start_NextWO = currentTime;
                                    }
                                    if(oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Dispatched' || oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Received')
                                    {   
                                        deltaTime_To_Start_NextWO = (deltaTime_To_Start_NextWO.addMinutes(Integer.valueOf(oWO.SVMXC__Driving_Time__c))).addSeconds(Integer.valueOf(oWO.SVMXC__Service_Duration__c));
                                    }   
                                    else if(oWO.SVMXC__Work_Order_Scheduling_Status__c == 'En Route' || oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Onsite')
                                    {   
                                        deltaTime_To_Start_NextWO = (deltaTime_To_Start_NextWO.addSeconds(Integer.valueOf(oWO.SVMXC__Service_Duration__c)));
                                    }   
                                }
                                else
                                {
                                    System.debug('deltaTime_To_Start_NextWO:'+ deltaTime_To_Start_NextWO);
                                    WSCH_AuditLogger.debug('deltaTime_To_Start_NextWO:'+ deltaTime_To_Start_NextWO);
                                    if(String.valueOf(deltaTime_To_Start_NextWO) != null && !String.isBlank(String.valueOf(deltaTime_To_Start_NextWO)) && (oWO.SVMXC__Scheduled_Date_Time__c < deltaTime_To_Start_NextWO) && !oWO.SVMXC__SM_In_Jeopardy__c)
                                    {
                                        oWO.SVMXC__SM_In_Jeopardy__c = true;
                                        lstUpdatedWos.add(oWO); 
                                        System.debug('wo in Jeopardy because of condition satisfied:'+oWO.Id);
                                        WSCH_AuditLogger.debug('wo in Jeopardy because of condition satisfied:'+oWO.Id);
                                        if(oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Dispatched' || oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Received')
                                        {   
                                            deltaTime_To_Start_NextWO = (deltaTime_To_Start_NextWO.addMinutes(Integer.valueOf(oWO.SVMXC__Driving_Time__c))).addSeconds(Integer.valueOf(oWO.SVMXC__Service_Duration__c));
                                        }   
                                        else if(oWO.SVMXC__Work_Order_Scheduling_Status__c == 'En Route' || oWO.SVMXC__Work_Order_Scheduling_Status__c == 'Onsite')
                                        {   
                                            deltaTime_To_Start_NextWO = (deltaTime_To_Start_NextWO.addSeconds(Integer.valueOf(oWO.SVMXC__Service_Duration__c)));
                                        }   
                                    }
                                                                    
                                }
                            }
                        }
                        deltaTime_To_Start_NextWO = null;    
                    }
                System.debug('lstUpdatedWos:'+ lstUpdatedWos);
                WSCH_AuditLogger.debug('lstUpdatedWos:'+ lstUpdatedWos);
                WSCH_AuditLogger.debug('WSCH_Jeopardy_Manager_SchHandler::getWOInCascadingJeopardy::No. of workorders moved to Jeopardy: '+ lstUpdatedWos.size());      
                //update lstUpdatedWos;
                // -CRUD
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstUpdatedWos,COMM_SecurityUtils.Access.Updateable))		//SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    {
                        update lstUpdatedWos;
                    } 
                else 
                    {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                    }
                  
            }
            catch(Exception ex)
            {
                System.debug('Exception caught:WSCH_Jeopardy_Manager_SchHandler:' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            }   
        
        }
        /**
         * Name             :   GetHolidays
         * Params           :   BusinessHours bh
                                Date givendate
         * Returns          :   Boolean
         * Description      :   return whether given date is holiday or not based on given BusinessHours
         */
        public static Boolean GetHolidays(BusinessHours bh, Date givendate)
        {
            Boolean isHoliday = false;
            if(givendate != null && bh != null)
            {
                Datetime dtmDayStartDateTime = dcUtils.getDateTimeInTimezone(givendate, Time.newInstance(0, 0, 0, 0), bh.timeZoneSidKey);
                      
                // Get the next working date time with respect to the given day's start
                Datetime dtmNextWkgDateTime = BusinessHours.addGmt(bh.id, dtmDayStartDateTime, 1L);
                    
                // Get the date of the next working date time in the given time zone
                Date datNextWkgDate = Date.valueOf(dtmNextWkgDateTime.format('yyyy-MM-dd', bh.timeZoneSidKey));
                  
                // If the given date and next working date are the same, the given day is a working day else given day is Holiday
                if(datNextWkgDate != givendate)
                    isHoliday = true;
            }
            
            return isHoliday;
        }
    }