@RestResource(urlMapping='/scheduling/batch/initiate')
global with sharing class WSCH_LTP_Initiate_Service {
    public static final String NO_OP_ERROR_MESSAGE = 'Empty or Invalid operation type';

    public class SVMXException extends Exception{}
    SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
    
    @HttpPost
    global static WSCH_LTP_Scheduling_Stubs.InitJobResponse_WP doPost() {
        //String returnMsg = NO_OP_ERROR_MESSAGE;
        WSCH_LTP_Scheduling_Stubs.InitJobResponse_WP initResponse = new WSCH_LTP_Scheduling_Stubs.InitJobResponse_WP();
        RestRequest request = RestContext.request;
        Blob data = request.requestBody;
        String initReq = data.toString();
        try {
            WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doPost::Json Request: ' + initReq);
            WSCH_LTP_Scheduling_Stubs.InitJobRequest_WP req = (WSCH_LTP_Scheduling_Stubs.InitJobRequest_WP)JSON.deserialize(initReq, WSCH_LTP_Scheduling_Stubs.InitJobRequest_WP.class);
            WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::after parsing...: ' + req);
	        initResponse = invokeInitJob(req);
        } catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_LTP_Initiate_Service::doPost():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
        } finally{
            WSCH_AuditLogger.finish();
        }
        return initResponse;
    }
    
    
    public static WSCH_LTP_Scheduling_Stubs.InitJobResponse_WP invokeInitJob(WSCH_LTP_Scheduling_Stubs.InitJobRequest_WP req) {
        WSCH_LTP_Scheduling_Stubs.InitJobResponse_WP initResponse = new WSCH_LTP_Scheduling_Stubs.InitJobResponse_WP();
        String dispatchProcessGuid = req.dispatchProcessGuid;
        String territoryGuid;
        WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::invokeInitJob req.dispatchMethod : ' + req.dispatchMethod);
        String strDispatchMethod='LTP'; //Default is LTP for 20.1. Server send dispatch method as null.
        if(req.dispatchMethod != null && req.dispatchMethod.equalsIgnoreCase('Optimized Batch')){
            strDispatchMethod = 'FULL';
        }else if(req.dispatchMethod != null && req.dispatchMethod.equalsIgnoreCase('Long-Term Planner')){
            strDispatchMethod = 'LTP';
        }

        if(req.territoryGuid.contains('_'))
        {
            list<String> lstTerritoryDef = new list<String>();
            lstTerritoryDef = req.territoryGuid.split('_');
            territoryGuid = lstTerritoryDef[0];
        }
        String connectionId = dispatchProcessGuid + '_' + territoryGuid;
        //String respJson='';
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSettings = new list<string>();
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('OMAX002_SET002');
        map<String, String> mapSetting = commSettings.SVMX_getGlobalSettingList(lstSettings);

        // Do not proceed if the setting Enable Dispatch Optimization is set to FALSE
        if(mapSetting.containsKey('GLOB001_GBL007') && mapSetting.get('GLOB001_GBL007').toUpperCase() == 'FALSE')
        {
            throw new SVMXException('Dispatch optimization is not enabled for the organization.');
        }

        if(dispatchProcessGuid != null && dispatchProcessGuid.length() > 0 && territoryGuid != null && territoryGuid.length() > 0)
        {
            // Check if there are any jobs running for the given dispatch process & territory
            // with status Initiated, In Progress, Precalc Completed, QTL Completed, Resources Sent or Work Orders Being Sent. If yes, check age of job and decide as below
            // (1) If zombie, mark as zombie and start new job
            // (2) If not, throw exception and do not start new job 
            list<SVMXC__SVMX_Jobs__c> SVMXJobs = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, SVMXC__End_Time__c   from SVMXC__SVMX_Jobs__c where SVMXC__SVMX_Process__c = :dispatchProcessGuid and SVMXC__Territory__c = :territoryGuid and SVMXC__Type__c = :strDispatchMethod and (SVMXC__OptiMax_Message__c = 'Initiated' OR SVMXC__OptiMax_Message__c = 'Staging' OR SVMXC__OptiMax_Message__c = 'In Progress')];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::invokeInitJob...: ' + SVMXJobs.size());
            boolean createNewJobRecord = false;
            if(SVMXJobs.size() == 0)
                createNewJobRecord = true;
            
            if(SVMXJobs.size() > 0)
            {
                list <SVMXC__SVMX_Jobs__c> SVMXJobsUpdate = new list<SVMXC__SVMX_Jobs__c> ();
                Datetime dtmNow = system.now();
                String strJobIds = '';
                String zombieJobId = '';
                try
                {
                    for(SVMXC__SVMX_Jobs__c oj: SVMXJobs)
                    {
                        Double dblAge = ((dtmNow.getTime() - oj.SVMXC__Start_Time__c.getTime()) / 60000);
                        if(dblAge >= Double.valueof(mapSetting.get('OMAX002_SET002')))
                        {
                            oj.SVMXC__Age__c = dblAge;
                            oj.SVMXC__Status__c = String.valueof(-4);
                            oj.SVMXC__End_Time__c = dtmNow;
                            oj.SVMXC__OptiMax_Message__c = 'Canceled - Zombie';
                            zombieJobId = oj.id;
                            SVMXJobsUpdate.add(oj);
                            // Marked existing job as Zombie, so create a new job for this run
                            createNewJobRecord = true;
                        }
                        else
                        {
                            strJobIds += oj.Id + '-' + oj.Name;
                            throw new SVMXException('OptiMax job(s) ' + strJobIds + ' for the same territory in progress');
                        }
                    }
                    
                    update SVMXJobsUpdate; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
		        } catch(Exception ex){
		            WSCH_AuditLogger.error('WSCH_LTP_Initiate_Service::invokeInitJob():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
					//respJson = ex.getMessage();
		            WSCH_AuditLogger.finish();
		        }
            }

            if(createNewJobRecord)
            {
                // Check if territory exists
                SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
                try
                {
                    objTerritory = [Select Id from SVMXC__Territory__c where Id = :territoryGuid.trim()];
	                WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::Territory ' + territoryGuid + ' exists');

	                // Check if dispatch process exists
	                SVMXC__ServiceMax_Processes__c objSVMXProcess = new SVMXC__ServiceMax_Processes__c();
                    objSVMXProcess = [Select Id from SVMXC__ServiceMax_Processes__c where Id = :dispatchProcessGuid]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
	                system.debug('Dispatch Process ' + dispatchProcessGuid + ' exists');
	                
	                SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
	                objSVMXJob.SVMXC__SVMX_Process__c = dispatchProcessGuid;
	                objSVMXJob.SVMXC__Territory__c = territoryGuid;
	                objSVMXJob.SVMXC__OptiMax_Message__c = 'Initiated'; 
	                objSVMXJob.SVMXC__Start_Time__c = system.now();
	                objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
                    objSVMXJob.SVMXC__Status__c = req.jobInstanceId;
                    objSVMXJob.SVMXC__Type__c = strDispatchMethod;
	                insert objSVMXJob; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
	                WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::invokeInitJob():SVMX Job record created: ' + objSVMXJob);
	                initResponse.jobInstanceId = req.jobInstanceId;
	                initResponse.jobInstanceGuid = objSVMXJob.Id;
	                //respJson=JSON.serialize(resp);
	                //invoke future call for callout with workorders, technicians and events ids.
	                doSendIds(objSVMXJob.Id);
		        } catch(Exception ex){
		            WSCH_AuditLogger.error('WSCH_LTP_Initiate_Service::invokeInitJob():Exception occured while trying to create svmxjob record..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
		            WSCH_AuditLogger.finish();
		        }
            }
        }
        return initResponse;
    }
    
    @future(callout=true)
    public static void doSendIds(String strSVMXJobId){
        WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds: Start of Future call: No of Queries used in this transaction so far: ' + Limits.getQueries()+' | '+'heap size :'+Limits.getHeapSize());
		Datetime dtmSchedulingHorizonStart;
		Datetime dtmSchedulingHorizonEnd;
	    SMAX_OptiMax_Engine_Ext clsOMaxExtension = new SMAX_OptiMax_Engine_Ext();
        String strDefaultBHourId;
        BusinessHours objDefTerritoryBH;
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
        SVMXC__ServiceMax_Processes__c objSVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__SVMX_Jobs__c objJob = new SVMXC__SVMX_Jobs__c();
        List<SVMXC__SVMX_Jobs__c> lstSvmxJobs = new List<SVMXC__SVMX_Jobs__c>();
        List<SVMXC__Service_Group_Members__c> lstTechnicians = new List<SVMXC__Service_Group_Members__c>();
        List<SVMXC__Service_Order__c> lstWorkOrderObj = new List<SVMXC__Service_Order__c>();        
        list<BusinessHours> lstBusinessHours = new list<BusinessHours>();
        Map<String, BusinessHours> mapBusinessHours = new Map<String, BusinessHours>();
		List<String> lstWOIds = new List<String>();
		List<String> lstTechIds = new List<String>();
		List<String> lstEventIds = new List<String>();
        set<String> setAvailTechAsSFUserList = new set<String>();
        set<String> setAvailTechAsSVMXUserList = new set<String>();
		map<String,SVMXC__Service_Order__c> mapConfirmedWOs = new  map<String,SVMXC__Service_Order__c>();
        Map<Id, Event> mapSFEvent = new Map<Id, Event>();
		Map<Id, SVMXC__SVMX_Event__c> mapSVMXEvent = new Map<Id, SVMXC__SVMX_Event__c>();   
        Map<String, String> mapUsersTechnicians = new Map<String, String>();
        WSCH_LTP_Scheduling_Stubs.ExecuteJobRequest_WP exeJobReq = new WSCH_LTP_Scheduling_Stubs.ExecuteJobRequest_WP();
        Map<String, String> optParameters = new Map<String, String>();
        SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
        String serviceName = WSCH_Provider_ECO_Callout_Helper.LTP_SERVICE_PATH;
        List<SVMXC__Service_Order__c> lstInvalidWOs = new List<SVMXC__Service_Order__c>();  
		//WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::begin...');

        list<string> lstSettings = new list<string>{'OMAX001_SET001','OMAX001_SET002','OMAX001_SET003','OMAX001_SET004','OMAX001_SET005','OMAX001_SET006','OMAX001_SET007','OMAX001_SET008','OMAX001_SET009','OMAX001_SET011','OMAX001_SET012','OMAX001_SET013',
            'OMAX002_SET002','OMAX002_SET003','OMAX002_SET004','OMAX002_SET005','OMAX002_SET006','OMAX002_SET007','OMAX002_SET008','OMAX002_SET009','OMAX002_SET010','OMAX003_SET004','OMAX003_SET018','OMAX003_SET012','OMAX003_SET020','OMAX003_SET021',
            'OMAX003_SET022','OMAX003_SET023','OMAX003_SET024','OMAX003_SET025','OMAX003_SET026','OMAX003_SET027','OMAX003_SET028','OMAX003_SET029','OMAX003_SET037','OMAX003_SET038','OMAX003_SET039','OMAX003_SET040','OMAX003_SET041',
            'OMAX001_SET015','OMAX001_SET016','OMAX001_SET017','GLOB001_GBL005','GLOB001_GBL006','GLOB001_GBL007', 'OMAX001_SET014', 'DCON004_SET014','DCON001_SET071','OMAX003_SET054','OMAX003_SET053','OMAX003_SET052','OMAX001_SET00999','OMAX001_SET00888','OMAX001_SET00700','OMAX001_SET00701','OMAX001_SET00702'};
        map<String, String> mapSettingValues = clsCommSettings.SVMX_getGlobalSettingList(lstSettings);

		try
		{
			objJob = [Select Id, SVMXC__Status__c, SVMXC__Age__c, SVMXC__Start_Time__c, SVMXC__End_Time__c, SVMXC__SVMX_Process__c,
						SVMXC__Territory__c, SVMXC__Sent_Work_Orders__c, SVMXC__Sent_Resources__c, SVMXC__Sent_Events_Count__c, SVMXC__OptiMax_Message__c,SVMXC__Type__c,SVMXC__Message__c from SVMXC__SVMX_Jobs__c where Id = :strSVMXJobId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
			WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::objJob:'+objJob);
		
			objTerritory = [Select Id, SVMXC__Territory_s_Business_Hours__c, SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey, SVMXC__Territory_s_Business_Hours__r.Id, SVMXC__Break_Hours__c, SVMXC__Average_Driving_Time__c, SVMXC__Per_Mile_Cost__c,
							SVMXC__Max_Distance__c, SVMXC__Average_Speed__c, SVMXC__Fixed_Cost__c, SVMXC__Per_hour_Cost__c, SVMXC__Mode_Of_Travel__c,SVMXC__SM_Overnight_Stay_Policy__c
							from SVMXC__Territory__c
							where Id = :objJob.SVMXC__Territory__c];
			WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::objTerritory:'+objTerritory);

	        lstBusinessHours = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
	                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
	                            from BusinessHours where Id =: objTerritory.SVMXC__Territory_s_Business_Hours__c OR IsDefault = TRUE];
	                            //where IsActive = TRUE AND (IsDefault = TRUE OR TimeZoneSidKey = :territoryTZsidKey)];
	        lstBusinessHours = clsOMaxExtension.getCompleteBusinessHour(lstBusinessHours);
	        for(BusinessHours bh : lstBusinessHours)
	        {
	            mapBusinessHours.put(bh.Id, bh);
	            if(bh.IsDefault == TRUE)
	                strDefaultBHourId = bh.Id;
	        }
	        //Heap size issue
	        lstBusinessHours.clear();

			
			objSVMXProcess = [Select Id, SVMXC__Child_Object_Criteria__c, SVMXC__Frequency__c, SVMXC__Full_Run_Unit__c, SVMXC__Retain_Appointment__c,
							SVMXC__Retain_Assignment__c, SVMXC__Route_Type__c, SVMXC__Weight_Time_Window__c, SVMXC__Weight_Total_Distance__c, SVMXC__Weight_Route_Distance__c,
							SVMXC__Weight_Node_Type__c, SVMXC__Calendar_Start_Type__c, SVMXC__Calendar_End_Type__c, 
							SVMXC__Weight_Route_Time__c,
							SVMXC__Tolerance__c, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Preferred_Tech_Enabled__c, SVMXC__Expertise_Match_Enabled__c,
							SVMXC__Product_Match_Enabled__c, SVMXC__SM_Drive_Before_Shift_Start__c, SVMXC__SM_Drive_After_Shift_End__c, SVMXC__Optimization_Goal__c,SVMXC__Window_Height__c,SVMXC__Window_Width__c 
							from SVMXC__ServiceMax_Processes__c
							where Id =:objJob.SVMXC__SVMX_Process__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
			WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::objSVMXProcess:'+objSVMXProcess);

			//TODO: calculate LTP horizon from dispatch process definition
	        objDefTerritoryBH = mapBusinessHours.get(objTerritory.SVMXC__Territory_s_Business_Hours__c);
	        WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::objDefTerritoryBH:'+objDefTerritoryBH);
            Map<String, list<Date>> mapHorizonDetails = new Map<String, list<Date>>();            
            if(objJob.SVMXC__Type__c.equalsIgnoreCase('LTP')){
                mapHorizonDetails = doCreateLTPHorizon(objSVMXProcess,objDefTerritoryBH);
            }else if(objJob.SVMXC__Type__c.equalsIgnoreCase('FULL')){
                //mapHorizonDetails = doCreateLTPHorizon(objSVMXProcess,objDefTerritoryBH);
                mapHorizonDetails = doCreateBatchHorizon(objSVMXProcess,objDefTerritoryBH);
            }
			List<Date> lstSchedHorizDates = new List<Date>();
			lstSchedHorizDates.addAll(mapHorizonDetails.values()[0]);
			List<String> lstString = new List<String>();
			lstString.addAll(mapHorizonDetails.keySet());
			List<String> ltpStartEndDT = lstString[0].split(',');
			dtmSchedulingHorizonStart = Datetime.valueOfGMT(ltpStartEndDT[0].trim());
			dtmSchedulingHorizonEnd = Datetime.valueOfGMT(ltpStartEndDT[1].trim());
			WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::LTP Job horizon start and end datetime:'+dtmSchedulingHorizonStart+' - '+dtmSchedulingHorizonEnd);
			WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::setSchedHorizDates size:'+lstSchedHorizDates.size());
	        WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds: start preparing work order Ids: No of Queries used in this transaction so far: ' + Limits.getQueries()+' | '+'heap size :'+Limits.getHeapSize());

			//TODO:Need to implement batch query due to query limit (50K records)
			//Split the horizon dates into multiple group of 30 days           			
			String strWorkOrderQuery = 'Select Id, Name, SVMXC__Preferred_Business_Hours__c, SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Primary_Territory__c, SVMXC__QTL_Status__c,SVMXC__Zip__c,SVMXC__Locked_By_DC__c,SVMXC__SM_Lock_Appointment_Schedule__c, SVMXC__Latitude__c,SVMXC__Longitude__c,SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Country__c,SVMXC__Preferred_Start_Time__c,SVMXC__Preferred_End_Time__c,SVMXC__OptiMax_Error_Text__c from SVMXC__Service_Order__c WHERE SVMXC__Primary_Territory__c = \'' + objJob.SVMXC__Territory__c + '\' AND SVMXC__Dispatch_Process__c = \'' + objJob.SVMXC__SVMX_Process__c + '\'';

			if(objSVMXProcess.SVMXC__Child_Object_Criteria__c != NULL && objJob.SVMXC__Type__c.equalsIgnoreCase('LTP'))
				strWorkOrderQuery += ' AND (' + objSVMXProcess.SVMXC__Child_Object_Criteria__c + ')';
			
			WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::strWorkOrderQuery:'+strWorkOrderQuery);		

			lstWorkOrderObj = Database.query(strWorkOrderQuery);
			WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::lstWorkOrderObj size():'+lstWorkOrderObj.size());

            for(SVMXC__Service_Order__c wo : lstWorkOrderObj){
            	//create map of work orders falls under confirmed. Need to send the events instead work order.
            	if(wo.SVMXC__Locked_By_DC__c == true || wo.SVMXC__SM_Lock_Appointment_Schedule__c == WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE ){ 
            		mapConfirmedWOs.put(wo.Id,wo);
            		continue;
            	}
                if(wo.SVMXC__Preferred_Start_Time__c == NULL && wo.SVMXC__Preferred_End_Time__c == NULL && objJob.SVMXC__Type__c.equalsIgnoreCase('LTP')) {
                    WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds:As both PST and PET are not available and its LTP job, so skipping this WO - ' + wo.Id);
                    String errorText = 'As both PST and PET are not available, skipping this WO from scheduling';
                    WSCH_CommonUtils.setOptimizerErrorText(wo, errorText);
                    lstInvalidWOs.add(wo);
                    continue;
                }                
            	lstWOIds.add(wo.Name);
            }
			WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::lstWOIds.size():'+lstWOIds.size());
                        
	        WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds: start preparing technician Ids: No of Queries used in this transaction so far: ' + Limits.getQueries()+' | '+'heap size :'+Limits.getHeapSize());

			// Retrieve technician records from Service_Group_Members__c for the given territory ID
			lstTechnicians = [Select Id, Name, SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Service_Territory__r.SVMXC__Per_Mile_Cost__c,
							SVMXC__Service_Territory__r.SVMXC__Per_Hour_Cost__c, SVMXC__Service_Territory__r.SVMXC__Fixed_Cost__c, SVMXC__Service_Territory__r.SVMXC__Max_Hours__c,
							SVMXC__Service_Territory__r.SVMXC__Average_Speed__c, SVMXC__Service_Territory__r.SVMXC__Max_Daily_Hours__c, SVMXC__Max_Hours__c,
							SVMXC__Service_Territory__r.SVMXC__Max_Distance__c, 
							SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive, SVMXC__Fixed_Cost__c, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c, SVMXC__Per_hour_Cost__c,
							SVMXC__Per_Mile_Cost__c, SVMXC__Average_Speed__c, SVMXC__Max_Daily_Hours__c, SVMXC__Max_Distance__c,
							SVMXC__Working_Hours__c ,SVMXC__Working_Hours__r.IsActive, SVMXC__Break_Hours__r.IsActive,
							SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c , SVMXC__Break_Hours__c, SVMXC__Enable_Scheduling__c,SVMXC__SM_Overnight_Stay_Policy__c,SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.IsActive
							from SVMXC__Service_Group_Members__c 
							where SVMXC__Active__c = TRUE AND SVMXC__Service_Territory__c = :objJob.SVMXC__Territory__c AND ((SVMXC__Enable_Scheduling__c = TRUE AND SVMXC__Salesforce_User__c = NULL) OR (SVMXC__Salesforce_User__c != NULL AND SVMXC__Salesforce_User__r.IsActive = true) )];					
			WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::lstTechnicians size():'+lstTechnicians.size());

            for(SVMXC__Service_Group_Members__c tech : lstTechnicians){
            	String strTechId = tech.Id+'_'+tech.Name;
				lstTechIds.add(strTechId);
                
                if(tech.SVMXC__Salesforce_User__c != NULL)
                {	
                    setAvailTechAsSFUserList.add(tech.SVMXC__Salesforce_User__c);
                    mapUsersTechnicians.put(tech.SVMXC__Salesforce_User__c, tech.Id);
                }
                else
                    setAvailTechAsSVMXUserList.add(tech.Id);
            }
            WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::setAvailTechAsSFUserList:'+setAvailTechAsSFUserList.size());
            WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::setAvailTechAsSVMXUserList:'+setAvailTechAsSVMXUserList.size());
			WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::lstTechIds:'+lstTechIds.size());

	        WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds: start preparing event Ids: No of Queries used in this transaction so far: ' + Limits.getQueries()+' | '+'heap size :'+Limits.getHeapSize());
			//Retrieve technician events and collect non workorder events            
            mapSFEvent = getMapNonWOSFEventforTech(setAvailTechAsSFUserList, dtmSchedulingHorizonStart,dtmSchedulingHorizonEnd,mapConfirmedWOs.keyset());
            mapSVMXEvent = getMapNonWOSVMXEventforTech(setAvailTechAsSVMXUserList, dtmSchedulingHorizonStart,dtmSchedulingHorizonEnd, mapConfirmedWOs.keyset());
            WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::mapSFEvent:'+mapSFEvent);
            WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::mapSVMXEvent:'+mapSVMXEvent);           
            
            for(Event e:mapSFEvent.values()){
            	String technicianId = mapUsersTechnicians.get(e.OwnerId);
            	String techEventId = 'Event_'+technicianId+'_'+e.Id;
            	lstEventIds.add(techEventId);
            }
            
			for(SVMXC__SVMX_Event__c e: mapSVMXEvent.values()){
            	String technicianId = e.SVMXC__Technician__c;
            	String techEventId = 'Event_'+technicianId+'_'+e.Id;
            	lstEventIds.add(techEventId);
            }
			WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::lstEventIds:'+lstEventIds);
            
            //setting optimization parameter for the run.
            //String strDistanceProvider = WSCH_CommonUtils.getSettingValue('DCON001','SET071'); 
            optParameters.put('distanceProvider', 'Heuristic');
            
            if(objTerritory.SVMXC__Mode_Of_Travel__c != NULL)
            {
                optParameters.put('modeOfTravel', String.valueOf(objTerritory.SVMXC__Mode_Of_Travel__c));
            }else{
                optParameters.put('modeOfTravel', 'Driving');
            }
            if(objJob.SVMXC__Type__c.equalsIgnoreCase('LTP'))
                optParameters.put('modeOfJob','LongTermPlan');

            optParameters = getParameters(objTerritory,objSVMXProcess,mapSettingValues);
            
            List<WSCH_LTP_Scheduling_Stubs.NodeColor_WP> lstNodeColors = new List<WSCH_LTP_Scheduling_Stubs.NodeColor_WP>();
            lstNodeColors = getNodeColors(objSVMXProcess);

            //setting the values in executeJob request wrapper for callout.
            exeJobReq.jobInstanceGuid=strSVMXJobId;
            exeJobReq.jobInstanceId = objJob.SVMXC__Status__c;
            exeJobReq.workOrderIds = lstWOIds;
            exeJobReq.resourceIds = lstTechIds;
            exeJobReq.eventIds = lstEventIds;
            exeJobReq.parameters = optParameters;
            exeJobReq.nodeColors = lstNodeColors;

            //making callout
            String requestJson=JSON.serialize(exeJobReq); 
            //WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::requestJson:'+requestJson);
	        WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds: End preparing event Ids: No of Queries used in this transaction so far: ' + Limits.getQueries()+' | '+'heap size :'+Limits.getHeapSize());
			String calloutEndpoint = WSCH_Provider_ECO_Callout_Helper.OPTIMAXSERVICE_ENDPOINT_URL + WSCH_Provider_ECO_Callout_Helper.LTP_SERVICE_PATH;
			WSCH_Provider_ECO_Stubs.Response_WP response_x =  WSCH_Provider_ECO_Callout_Helper.callOut(requestJson,calloutEndpoint);
           	if(response_x.status == '200'){
                WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::Callout was successfull.'+response_x);
            } else{
                WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds::Callout failed.'+response_x);
                objJob.SVMXC__OptiMax_Message__c = 'Initiate Error';
                objJob.SVMXC__End_Time__c = Datetime.now();
                objJob.SVMXC__Message__c = response_x.message;                 
            }
	        WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doSendIds: End of Future call: No of Queries used in this transaction so far: ' + Limits.getQueries()+' | '+'heap size :'+Limits.getHeapSize());
            if(lstInvalidWOs.size() > 0 ) update lstInvalidWOs;
            //TODO: update the no of work orders, technicians and events sent details in the SVMXJob record
            if(lstWOIds != null && lstWOIds.size() > 0 && lstTechIds != null && lstTechIds.size() > 0 ){
                objJob.SVMXC__Sent_Work_Orders__c = lstWOIds.size();
                objJob.SVMXC__Sent_Resources__c = lstTechIds.size();
                objJob.SVMXC__Sent_Events_Count__c = lstEventIds.size();
            }else{
                objJob.SVMXC__OptiMax_Message__c = 'Initiate Error';
                objJob.SVMXC__End_Time__c = Datetime.now();
                objJob.SVMXC__Message__c = 'Work Orders or Technicians not available for this run.'; 
            }
            update objJob;
			WSCH_AuditLogger.finish();
		}
		catch(Exception e)
		{
			WSCH_AuditLogger.error('WSCH_LTP_Initiate_Service::doSendIds::Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n');
            WSCH_AuditLogger.finish();
		}
    	
    }
    
    public static Map<String, List<Date>> doCreateBatchHorizon(SVMXC__ServiceMax_Processes__c objSVMXProcess, BusinessHours objDefTerritoryBH){
        Date datStartDate;
        Date datEndDate;
        Datetime dtmNow = system.now();
        DateTime dtmSchedulingHorizonStartDateTime;
        Datetime dtmLastProcessedDateTime;
        set<Date> setSchedHorizDates = new set<Date>();
        String strHorizonStartEndDT;
        Map<String, List<Date>> mapHorizonDetails = new Map<String, List<Date>>();
        SMAX_OptiMax_Engine_Ext clsOMaxExtension = new SMAX_OptiMax_Engine_Ext();
        Integer intNoOfDays = (objSVMXProcess.SVMXC__Calendar_End_Days__c).intValue();
        if(intNoOfDays < 1)
            intNoOfDays = 1;
        Integer intStartAfterDays;
        
        intStartAfterDays = objSVMXProcess.SVMXC__Calendar_Start_Days__c.intValue();
        if(intStartAfterDays < 0)
            intStartAfterDays = 0;
        
        Datetime tempStDt = clsOMaxExtension.getNextWorkingHour(objDefTerritoryBH, dtmNow);
        for (integer i = 0; i < intStartAfterDays; i++)
        {
            tempStDt = clsOMaxExtension.getNextWorkingHour(objDefTerritoryBH, tempStDt.addMinutes(1));
        }
        dtmSchedulingHorizonStartDateTime = tempStDt;

        // Get the date of the first day in the scheduling horizon in Business Hour time zone
        datStartDate = Date.valueOf(dtmSchedulingHorizonStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));        
        
        // Starting from the first day, get all the dates in the scheduling horizon
        Date tempDate = datStartDate;
        dtmlastProcessedDateTime = dtmSchedulingHorizonStartDateTime;
        strHorizonStartEndDT = String.ValueOfGMT(dtmlastProcessedDateTime);        
        setSchedHorizDates.add(tempDate);
                
        for(integer i = 0; i < intNoOfDays - 1; i++)
        {
            dtmlastProcessedDateTime = clsOMaxExtension.getNextWorkingHour(objDefTerritoryBH, dtmlastProcessedDateTime.addMinutes(1));
            tempDate = Date.valueOf(dtmlastProcessedDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
            setSchedHorizDates.add(tempDate);
            datEndDate = tempDate;
        }
		strHorizonStartEndDT = strHorizonStartEndDT+','+dtmlastProcessedDateTime;
		WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doCreateBatchHorizon::Batch Job horizon start and end datetime:'+strHorizonStartEndDT);
		if(datEndDate != NULL)
			intNoOfDays = datStartDate.daysBetween(datEndDate) + 1;
		
        List<Date> lstSchedHorizDates = new List<Date>(setSchedHorizDates);
		mapHorizonDetails.put(strHorizonStartEndDT,lstSchedHorizDates);
		return mapHorizonDetails;

    }

    public static Map<String, List<Date>> doCreateLTPHorizon(SVMXC__ServiceMax_Processes__c objSVMXProcess, BusinessHours objDefTerritoryBH){
	    SMAX_OptiMax_Engine_Ext clsOMaxExtension = new SMAX_OptiMax_Engine_Ext();
		Integer intNoOfDays = 0;
        Date datStartDate;
        Date datEndDate;
        Datetime dtmNow = system.now();
        DateTime dtmSchedulingHorizonStartDateTime;
        Datetime dtmLastProcessedDateTime;
        set<Date> setSchedHorizDates = new set<Date>();
        String strHorizonStartEndDT;
        Map<String, List<Date>> mapHorizonDetails = new Map<String, List<Date>>();
        if(objSVMXProcess.SVMXC__Calendar_End_Days__c != null)
            intNoOfDays = (objSVMXProcess.SVMXC__Calendar_End_Days__c).intValue();

		if(intNoOfDays < 1)
			intNoOfDays = 1;
		
        Integer intStartAfterDays;
        if(objSVMXProcess.SVMXC__Window_Height__c != null)
            intStartAfterDays = objSVMXProcess.SVMXC__Window_Height__c.intValue();

        if(intStartAfterDays < 0)
        intStartAfterDays = 0;

		Datetime tempStDt = clsOMaxExtension.getNextWorkingHour(objDefTerritoryBH, dtmNow);
		for (integer i = 1; i < intStartAfterDays; i++)
		{
			// We add 1 minute to the tempStDt every time through the loop to force getNextWorkingHour
			// function to return the next working day. Else, it will keep returning the same date time
			tempStDt = clsOMaxExtension.getNextWorkingHour(objDefTerritoryBH, tempStDt.addMinutes(5));
		}
        dtmSchedulingHorizonStartDateTime = tempStDt;
        
		// Get the date of the first day in the scheduling horizon in Business Hour time zone
		datStartDate = Date.valueOf(dtmSchedulingHorizonStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));

		// Starting from the first day, get all the dates in the scheduling horizon
		dtmlastProcessedDateTime = dtmSchedulingHorizonStartDateTime;
		strHorizonStartEndDT = String.ValueOfGMT(dtmlastProcessedDateTime);
		//WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doCreateLTPHorizon::LTP Job horizon startdatetime:'+strHorizonStartEndDT);

		// Starting from the primary job horizon end date, get all the dates till the LTP dispatch process definition end date.
        //SVMXC__Max_Hours_Per_Day__c - This is the field used to store the horizon end date for LTP
        integer intNoOfDaysLTP = 1;
        
        if(objSVMXProcess.SVMXC__Window_Width__c != null)
            intNoOfDaysLTP = objSVMXProcess.SVMXC__Window_Width__c.intValue();

		Date ltpTempDate = datStartDate;
		setSchedHorizDates.add(ltpTempDate);
		for(integer i = 0; i < intNoOfDaysLTP - 1; i++)
		{
			dtmlastProcessedDateTime = clsOMaxExtension.getNextWorkingHour(objDefTerritoryBH, dtmlastProcessedDateTime.addMinutes(1));
			ltpTempDate = Date.valueOf(dtmlastProcessedDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
			setSchedHorizDates.add(ltpTempDate);
			datEndDate = ltpTempDate;
		}
		strHorizonStartEndDT = strHorizonStartEndDT+','+dtmlastProcessedDateTime;
		WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doCreateLTPHorizon::LTP Job horizon start and end datetime:'+strHorizonStartEndDT);
		//lstHorizondate.add(dtmlastProcessedDateTime);
		if(datEndDate != NULL)
			intNoOfDays = datStartDate.daysBetween(datEndDate) + 1;
		
        List<Date> lstSchedHorizDates = new List<Date>(setSchedHorizDates);
		mapHorizonDetails.put(strHorizonStartEndDT,lstSchedHorizDates);
		return mapHorizonDetails;
    }

    //Get List of  SF Event for Tech within the time range
    public static Map<Id, Event> getMapNonWOSFEventforTech(set<string> lstOwnerID,DateTime inputStartTime, DateTime inputEndTime, set<String> setWOids)
    {
        date inputStartdate = inputStartTime.dateGMT();
        date inputEnddate = inputEndTime.dateGMT();
        datetime inputStartdatetime = Datetime.newInstanceGmt(inputStartTime.dateGMT(),Time.newInstance(0, 0, 0, 0));
 		WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::getMapNonWOSFEventforTech::LTP Job horizon start,end date and start dateime:'+inputStartdate+' | '+inputEnddate+' | '+inputStartdatetime);
        Map<Id, Event> tempEvents = new Map<Id, Event>([Select Id, WhatId,OwnerId from Event where (OwnerId in:lstOwnerID) AND (SVMXC__Service_Duration__c > 0)  AND ((StartDateTime <= :inputEndTime and EndDateTime >= :inputStartTime)OR (ActivityDate <= :inputEnddate and EndDateTime >= :inputStartdatetime AND IsAllDayEvent = true ) OR (ActivityDate = :inputStartdate AND IsAllDayEvent = true)) AND ((whatId in : setWOids) OR (WhatId = NULL)) ]);
        return tempEvents;
    }
    
    //Get List of  SVMX Event for Tech within the time range inputStartTime and inputEndtdate
    public static Map<Id, SVMXC__SVMX_Event__c> getMapNonWOSVMXEventforTech(set<String> lstTechID,DateTime inputStartTime, DateTime inputEndTime, set<String> setWOids)
    {
        date inputStartdate = inputStartTime.dateGMT();
        date inputEnddate = inputEndTime.dateGMT();
        datetime inputStartdatetime = Datetime.newInstanceGmt(inputStartTime.dateGMT(),Time.newInstance(0, 0, 0, 0));
 		WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::getMapNonWOSVMXEventforTech::LTP Job horizon start,end date and start dateime:'+inputStartdate+' | '+inputEnddate+' | '+inputStartdatetime);
        Map<Id, SVMXC__SVMX_Event__c> tempEvents = new Map<Id, SVMXC__SVMX_Event__c>([Select Id, Name,SVMXC__Technician__c from SVMXC__SVMX_Event__c where (SVMXC__Technician__c in:lstTechID) AND ((SVMXC__StartDateTime__c <= :inputEndTime and SVMXC__EndDateTime__c >= :inputStartTime)OR (SVMXC__ActivityDate__c <= :inputEnddate and SVMXC__EndDateTime__c >= :inputStartdatetime AND SVMXC__IsAllDayEvent__c = true) OR(SVMXC__StartDateTime__c = :inputStartdatetime AND SVMXC__IsAllDayEvent__c = true)) AND ((SVMXC__Service_Order__c in :setWOids) OR (SVMXC__Service_Order__c = null))]); 
        return tempEvents;
    }

    public static Map<String, String> getParameters(SVMXC__Territory__c objTerritory, SVMXC__ServiceMax_Processes__c objSVMXProcess,map<String, String> mapSettingValues){
        Map<String, String> optParameters = new Map<String, String>();
        String tempValue = String.valueof(mapSettingValues.get('DCON001_SET071'));
        optParameters.put('Optimax.Geocoding', tempValue);
        optParameters.put('distanceProvider', 'Heuristic');

        if(mapSettingValues.containsKey('OMAX001_SET011') == TRUE && mapSettingValues.containsKey('OMAX001_SET012') == TRUE)
        {   // Optimax.debug && Optimax.debugMail
            optParameters.put('Optimax.debug', String.valueof(mapSettingValues.get('OMAX001_SET011')) );
            optParameters.put('Optimax.debugMail', String.valueof(mapSettingValues.get('OMAX001_SET012')) );
        }
        if(mapSettingValues.containsKey('OMAX001_SET001') == TRUE)
        {   // JOpt.Assisted
            optParameters.put('JOpt.Assisted', String.valueof(mapSettingValues.get('OMAX001_SET001')) );
        }
        if(mapSettingValues.containsKey('OMAX001_SET002') == TRUE)
        {   // JOpt.AssistedMode
            optParameters.put('JOpt.AssistedMode', String.valueof(mapSettingValues.get('OMAX001_SET002')) );
        }
        if(mapSettingValues.containsKey('OMAX001_SET003') == TRUE)
        {   // JOpt.OptimizationRule
            optParameters.put('JOpt.OptimizationRule', String.valueof(mapSettingValues.get('OMAX001_SET003')) );
        }
        if(mapSettingValues.containsKey('OMAX001_SET007') == TRUE)
        {   // JOptExitCondition.JOptGenerationCount
            optParameters.put('JOptExitCondition.JOptGenerationCount', String.valueof(mapSettingValues.get('OMAX001_SET007')) );
        }
        if(objSVMXProcess.SVMXC__Route_Type__c != NULL)
        {   // JOpt.RouteType
            optParameters.put('JOpt.RouteType', objSVMXProcess.SVMXC__Route_Type__c );
        }
        if(objSVMXProcess.SVMXC__Weight_Time_Window__c != NULL)
        {   // JOptWeight.TimeWindow
             optParameters.put('JOptWeight.TimeWindow', String.valueof(objSVMXProcess.SVMXC__Weight_Time_Window__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET040'))));
        }
        if(objSVMXProcess.SVMXC__Weight_Total_Distance__c != NULL)
        {   // JOptWeight.TotalDistance
            optParameters.put('JOptWeight.TotalDistance', String.valueof(objSVMXProcess.SVMXC__Weight_Total_Distance__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET041'))));
        }
        if(objSVMXProcess.SVMXC__Weight_Route_Distance__c != NULL)
        {   // JOptWeight.RouteDistance
            optParameters.put('JOptWeight.RouteDistance', String.valueof(objSVMXProcess.SVMXC__Weight_Route_Distance__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET038'))));
        }
        if(objSVMXProcess.SVMXC__Weight_Route_Time__c != NULL)
        {   // JOptWeight.RouteTime
            optParameters.put('JOptWeight.RouteTime', String.valueof(objSVMXProcess.SVMXC__Weight_Route_Time__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET039'))));
        }
        if(objSVMXProcess.SVMXC__Weight_Node_Type__c != NULL)
        {   // JOptWeight.NodeType
             optParameters.put('JOptWeight.PreferableResource', String.valueof(objSVMXProcess.SVMXC__Weight_Node_Type__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET037'))));
        }
        if(objSVMXProcess.SVMXC__Weight_Total_Distance__c != NULL)
        {
            optParameters.put('distanceWeightage', String.valueof(objSVMXProcess.SVMXC__Weight_Total_Distance__c));
        }
        if(objSVMXProcess.SVMXC__Weight_Node_Type__c != NULL)
        {
             optParameters.put('MCTMWeightage', String.valueof(objSVMXProcess.SVMXC__Weight_Node_Type__c));
        }
        if(mapSettingValues.containsKey('OMAX001_SET017') == TRUE)
        {
            optParameters.put('distanceProvider', String.valueof(mapSettingValues.get('OMAX001_SET017')) );
        }
        if(objTerritory.SVMXC__Mode_Of_Travel__c != NULL)
        {
            optParameters.put('modeOfTravel', String.valueOf(objTerritory.SVMXC__Mode_Of_Travel__c) );
        }
        else
        {
            optParameters.put('modeOfTravel', 'Driving' );
        }
        
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getParameters():properties for the job is..'+lstExcSetting_WP);
        return optParameters;
    }    
    
    public static List<WSCH_LTP_Scheduling_Stubs.NodeColor_WP> getNodeColors(SVMXC__ServiceMax_Processes__c objSVMXProcess){
        List<WSCH_LTP_Scheduling_Stubs.NodeColor_WP> lstNodeColors = new List<WSCH_LTP_Scheduling_Stubs.NodeColor_WP>();
        Map<Id, SVMXC__ServiceMax_Processes__c> mapCapacityRules = new Map<Id, SVMXC__ServiceMax_Processes__c>();   
        mapCapacityRules.putAll([SELECT Id, Name, SVMXC__Sequence__c, SVMXC__Name__c, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__SM_Capacity_Threshold__c, RecordType.Name from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =:objSVMXProcess.Id And RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Capacity Reservation' order by SVMXC__Sequence__c]);         

        if(mapCapacityRules != null && mapCapacityRules.size() > 0){
            Integer intId = 100;
            for(SVMXC__ServiceMax_Processes__c capacityRule : mapCapacityRules.values()){                
                WSCH_LTP_Scheduling_Stubs.NodeColor_WP nodeColor = new WSCH_LTP_Scheduling_Stubs.NodeColor_WP();
                nodeColor.id = intId++;
                nodeColor.colorName = capacityRule.SVMXC__Name__c;
                nodeColor.percentage = String.valueof(capacityRule.SVMXC__SM_Capacity_Threshold__c);
                lstNodeColors.add(nodeColor);
            }                      
        }
        return lstNodeColors;
    }
    
}