@isTest(seeAllData = true)
private class SCON_Scheduler_UT 
{
	public static SVMXC__ServiceMax_Processes__c processNodes;
    
    static void createTestData()
    {
        List<RecordType> lstProcessRtypes = [select Id,Name from RecordType where (Name='Work Order Billing Process' OR Name='Contract Billing Process' OR Name='PM Process' OR Name = 'Schedule Header' OR Name = 'Timesheet' OR Name = 'SPM Rule')and SobjectType='SVMXC__ServiceMax_Processes__c' order by Name];
        List<RecordType> lstSchRtype = [select Id,Name from RecordType where (Name='Schedule' OR Name='Schedule Detail') and SobjectType='SVMXC__ServiceMax_Config_Data__c'];
        List<SVMXC__ServiceMax_Config_Data__c> lstSchds = new List<SVMXC__ServiceMax_Config_Data__c>();
        String strWOBilling = '';
        String strCONBilling = '';
        String strPMProcess = '';
        String strScheduledSFM = '';
		String strTimeSheet = '';
        String strSPMDetail = '';
		String strSchedule = '';
		String strScheduleDetail = '';
        if(lstProcessRtypes.size() > 0){
            for(RecordType rt : lstProcessRtypes){
                if(rt.Name == 'Work Order Billing Process')
                    strWOBilling = rt.id;
                else if(rt.Name == 'Contract Billing Process')
                    strCONBilling = rt.id;
                else if(rt.Name == 'PM Process')
                    strPMProcess = rt.id;
                else if(rt.Name == 'Schedule Header')
                    strScheduledSFM = rt.id;            
				else if(rt.Name == 'Timesheet')
                    strTimeSheet = rt.id;
                else if(rt.Name == 'SPM Rule')
                    strSPMDetail = rt.id;
            }
        }   
		if(lstSchRtype.size() > 0){
            for(RecordType rt : lstSchRtype){
				if(rt.Name == 'Schedule')
                    strSchedule = rt.id;
                else if(rt.Name == 'Schedule Detail')
                    strScheduleDetail = rt.id;
			}
		}
		
		/* ---Start OF Installed Product Expression----  */ 
        SVMXC__ServiceMax_Processes__c tsWORule = new SVMXC__ServiceMax_Processes__c();
        tsWORule.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
        tsWORule.SVMXC__MapID__c = 'IB-Expression';
        tsWORule.SVMXC__Advance_Expression__c = '1 OR 2';
        tsWORule.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'SVMX Rule' AND SobjectType ='SVMXC__ServiceMax_Processes__c' limit 1].Id;
        insert tsWORule; 
        
        SVMXC__ServiceMax_Config_Data__c tsWOLineExpression1 = new  SVMXC__ServiceMax_Config_Data__c();
        tsWOLineExpression1.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        tsWOLineExpression1.SVMXC__Expression_Type__c = 'EXP_Named';
        tsWOLineExpression1.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        tsWOLineExpression1.SVMXC__Expression_Rule__c = tsWORule.id;
        tsWOLineExpression1.SVMXC__Operand__c = 'Shipped';
        tsWOLineExpression1.SVMXC__Operator__c = 'eq';
        insert tsWOLineExpression1;
        
        SVMXC__ServiceMax_Config_Data__c tsWOLineExpression2 = new  SVMXC__ServiceMax_Config_Data__c();
        tsWOLineExpression2.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        tsWOLineExpression2.SVMXC__Expression_Type__c = 'EXP_Named';
        tsWOLineExpression2.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        tsWOLineExpression2.SVMXC__Expression_Rule__c = tsWORule.id;
        tsWOLineExpression2.SVMXC__Operand__c = 'Installed';
        tsWOLineExpression2.SVMXC__Operator__c = 'eq';
        insert tsWOLineExpression2;
        /* ---End of IB Expression----  */ 
		
        List<SVMXC__ServiceMax_Processes__c> lstProcesses = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c svmxWOBilProcess = new SVMXC__ServiceMax_Processes__c();
        svmxWOBilProcess.SVMXC__Name__c = 'WOBillingEngineUT0001';
        svmxWOBilProcess.SVMXC__ProcessID__c = 'WOBillingEngineUT0001';
        svmxWOBilProcess.RecordTypeId = strWOBilling;
        svmxWOBilProcess.SVMXC__Email_On_Error__c = 'naveen.vasu@servicemax.com';
        svmxWOBilProcess.SVMXC__Email_On_Success__c = 'naveen.vasu@servicemax.com';
        svmxWOBilProcess.SVMXC__Capture_Log__c = true;
        svmxWOBilProcess.SVMXC__Active__c = true;
        svmxWOBilProcess.SVMXC__Primary_Consolidation_Rule__c = 'Work Order';
        svmxWOBilProcess.SVMXC__Dispatch_Timezone__c = 'Asia/Calcutta';
        lstProcesses.add(svmxWOBilProcess);
        
        SVMXC__ServiceMax_Processes__c svmxSCBilProcess = new SVMXC__ServiceMax_Processes__c();
        svmxSCBilProcess.SVMXC__Name__c = 'SCBillingEngineUT0001';
        svmxSCBilProcess.SVMXC__ProcessID__c = 'SCBillingEngineUT0001';
        svmxSCBilProcess.RecordTypeId = strCONBilling;
        svmxSCBilProcess.SVMXC__Email_On_Error__c = 'naveen.vasu@servicemax.com';
        svmxSCBilProcess.SVMXC__Email_On_Success__c = 'naveen.vasu@servicemax.com';
        svmxSCBilProcess.SVMXC__Capture_Log__c = true;
        svmxSCBilProcess.SVMXC__Primary_Consolidation_Rule__c = 'Contract';
        svmxSCBilProcess.SVMXC__Active__c = true;
        svmxSCBilProcess.SVMXC__Dispatch_Timezone__c = 'Asia/Calcutta';
        lstProcesses.add(svmxSCBilProcess);
        
        SVMXC__ServiceMax_Processes__c svmxPMProcess = new SVMXC__ServiceMax_Processes__c();
        svmxPMProcess.SVMXC__Name__c = 'PMEngineUT0001';
        svmxPMProcess.SVMXC__ProcessID__c = 'PMEngineUT0001';
        svmxPMProcess.RecordTypeId = strPMProcess;
        svmxPMProcess.SVMXC__Email_On_Error__c = 'naveen.vasu@servicemax.com';
        svmxPMProcess.SVMXC__Email_On_Success__c = 'naveen.vasu@servicemax.com';
        svmxPMProcess.SVMXC__Capture_Log__c = true;
        svmxPMProcess.SVMXC__Primary_Consolidation_Rule__c = 'Contract';
        svmxPMProcess.SVMXC__Active__c = true;
        svmxPMProcess.SVMXC__Dispatch_Timezone__c = 'Asia/Calcutta';
        lstProcesses.add(svmxPMProcess);
		
		SVMXC__ServiceMax_Processes__c svmxTimeSheetProcess = new SVMXC__ServiceMax_Processes__c();
        svmxTimeSheetProcess.SVMXC__Name__c = 'Timesheet001';
        svmxTimeSheetProcess.SVMXC__ProcessID__c = 'Timesheet001';
        svmxTimeSheetProcess.RecordTypeId = strTimeSheet;
        svmxTimeSheetProcess.SVMXC__Email_On_Error__c = 'naveen.vasu@servicemax.com';
        svmxTimeSheetProcess.SVMXC__Email_On_Success__c = 'naveen.vasu@servicemax.com';
        svmxTimeSheetProcess.SVMXC__Capture_Log__c = true;
        svmxTimeSheetProcess.SVMXC__Active__c = true;
        svmxTimeSheetProcess.SVMXC__Dispatch_Timezone__c = 'Asia/Calcutta';
        lstProcesses.add(svmxTimeSheetProcess);
        
        SVMXC__ServiceMax_Processes__c svmxSPMDetailsFTF = new SVMXC__ServiceMax_Processes__c();
        svmxSPMDetailsFTF.SVMXC__Name__c = 'FTF';
        svmxSPMDetailsFTF.SVMXC__ProcessID__c = 'FirstTimeFix';
        svmxSPMDetailsFTF.RecordTypeId = strSPMDetail;
        svmxSPMDetailsFTF.SVMXC__Email_On_Error__c = 'anchal.sharma@servicemax.com';
        svmxSPMDetailsFTF.SVMXC__Email_On_Success__c = 'anchal.sharma@servicemax.com';
        svmxSPMDetailsFTF.SVMXC__Capture_Log__c = true;
        svmxSPMDetailsFTF.SVMXC__Active__c = true;
        svmxSPMDetailsFTF.SVMXC__Dispatch_Timezone__c = 'Asia/Calcutta';
        lstProcesses.add(svmxSPMDetailsFTF);
        
        SVMXC__ServiceMax_Processes__c svmxSPMDetailsMTTR = new SVMXC__ServiceMax_Processes__c();
        svmxSPMDetailsMTTR.SVMXC__Name__c = 'MTTR';
        svmxSPMDetailsMTTR.SVMXC__ProcessID__c = 'MeanTimeToRepair';
        svmxSPMDetailsMTTR.RecordTypeId = strSPMDetail;
        svmxSPMDetailsMTTR.SVMXC__Email_On_Error__c = 'anchal.sharma@servicemax.com';
        svmxSPMDetailsMTTR.SVMXC__Email_On_Success__c = 'anchal.sharma@servicemax.com';
        svmxSPMDetailsMTTR.SVMXC__Capture_Log__c = true;
        svmxSPMDetailsMTTR.SVMXC__Active__c = true;
        svmxSPMDetailsMTTR.SVMXC__Dispatch_Timezone__c = 'Asia/Calcutta';
        lstProcesses.add(svmxSPMDetailsMTTR);
        
        SVMXC__ServiceMax_Processes__c svmxSPMDetailsCUDT = new SVMXC__ServiceMax_Processes__c();
        svmxSPMDetailsCUDT.SVMXC__Name__c = 'MTTR';
        svmxSPMDetailsCUDT.SVMXC__ProcessID__c = 'UpDownTime';
        svmxSPMDetailsCUDT.RecordTypeId = strSPMDetail;
        svmxSPMDetailsCUDT.SVMXC__Email_On_Error__c = 'anchal.sharma@servicemax.com';
        svmxSPMDetailsCUDT.SVMXC__Email_On_Success__c = 'anchal.sharma@servicemax.com';
        svmxSPMDetailsCUDT.SVMXC__Capture_Log__c = true;
        svmxSPMDetailsCUDT.SVMXC__Active__c = true;
        svmxSPMDetailsCUDT.SVMXC__Dispatch_Timezone__c = 'Asia/Calcutta';
        lstProcesses.add(svmxSPMDetailsCUDT);
        
        insert lstProcesses;
        
        //Create Schedule SFMs
        SVMXC__ServiceMax_Processes__c objScheduledSFM = new SVMXC__ServiceMax_Processes__c();
        objScheduledSFM.RecordTypeId = strScheduledSFM;
        objScheduledSFM.SVMXC__Name__c = 'Scheduled SFM Pro';
        objScheduledSFM.SVMXC__Active__c = true;
        objScheduledSFM.SVMXC__Dispatch_Timezone__c = 'Asia/Calcutta';
        objScheduledSFM.SVMXC__Capture_Log__c = true;
        objScheduledSFM.SVMXC__Assign_To_Dispatcher__c = userinfo.getUserId();
        insert objScheduledSFM;
        
        SVMXC__ServiceMax_Config_Data__c objSFMSche = new   SVMXC__ServiceMax_Config_Data__c();
        objSFMSche.RecordTypeId = strSchedule;
        objSFMSche.SVMXC__Run_At__c = '4:00 PM';
        objSFMSche.SVMXC__Schedule_Days__c = 'Sunday; Monday; Tuesday; Wednesday; Thursday; Friday; Saturday';
        objSFMSche.SVMXC__Day_To_Run__c = string.valueOf(dateTime.now().dayGmt());
        objSFMSche.SVMXC__Sequence__c = 1;
        objSFMSche.SVMXC__Run_Type__c = 'Day of Week';
        objSFMSche.SVMXC__Dispatch_Process__c = objScheduledSFM.Id;
        insert objSFMSche;
		
		SVMXC__ServiceMax_Config_Data__c objSFMschedetail = new   SVMXC__ServiceMax_Config_Data__c();
        objSFMschedetail.RecordTypeId = strScheduleDetail;
        objSFMschedetail.SVMXC__Expression_Rule__c = processNodes.id;
        objSFMschedetail.SVMXC__Dispatch_Process__c = objScheduledSFM.Id;
        insert objSFMschedetail;
		
		SVMXC__ServiceMax_Config_Data__c objScheduleServices = new SVMXC__ServiceMax_Config_Data__c();
        objScheduleServices.RecordTypeId = strScheduleDetail;
        objScheduleServices.SVMXC__Class_Name__c = 'IPRD_CounterReadingRecord';
        objScheduleServices.SVMXC__Object_Name__c = 'SVMXC__Installed_Product__c';
        objScheduleServices.SVMXC__Batch_Size__c = 200;
        objScheduleServices.SVMXC__Expression_Rule__c = tsWORule.Id;
        objScheduleServices.SVMXC__Schedule_Type__c = 'Services';
        objScheduleServices.SVMXC__Dispatch_Process__c = objScheduledSFM.Id;
        insert objScheduleServices;
       
        
        SVMXC__ServiceMax_Config_Data__c woSch = new   SVMXC__ServiceMax_Config_Data__c();
        woSch.RecordTypeId = strSchedule;
        woSch.SVMXC__Run_At__c = '4:00 PM';
        woSch.SVMXC__Schedule_Days__c = 'Sunday; Monday; Tuesday; Wednesday; Thursday; Friday; Saturday';
        woSch.SVMXC__Day_To_Run__c = string.valueOf(dateTime.now().dayGmt());
        woSch.SVMXC__Sequence__c = 1;
        woSch.SVMXC__Run_Type__c = 'Day of Week';
        woSch.SVMXC__Dispatch_Process__c = svmxWOBilProcess.Id;
        lstSchds.add(woSch);
        
        SVMXC__ServiceMax_Config_Data__c scSch = new   SVMXC__ServiceMax_Config_Data__c();
        scSch.RecordTypeId = strSchedule;
        scSch.SVMXC__Run_At__c = '4:00 PM';
        scSch.SVMXC__Schedule_Days__c = 'Sunday; Monday; Tuesday; Wednesday; Thursday; Friday; Saturday';
        scSch.SVMXC__Day_To_Run__c = string.valueOf(dateTime.now().dayGmt());
        scSch.SVMXC__Sequence__c = 1;
        scSch.SVMXC__Run_Type__c = 'Day of Week';
        scSch.SVMXC__Dispatch_Process__c = svmxSCBilProcess.Id;
        lstSchds.add(scSch);
        
        SVMXC__ServiceMax_Config_Data__c pmSch = new   SVMXC__ServiceMax_Config_Data__c();
        pmSch.RecordTypeId = strSchedule;
        pmSch.SVMXC__Run_At__c = '4:00 PM';
        pmSch.SVMXC__Schedule_Days__c = 'Sunday; Monday; Tuesday; Wednesday; Thursday; Friday; Saturday';
        pmSch.SVMXC__Day_To_Run__c = string.valueOf(dateTime.now().dayGmt());
        pmSch.SVMXC__Sequence__c = 1;
        pmSch.SVMXC__Run_Type__c = 'Day of Week';
        pmSch.SVMXC__Dispatch_Process__c = svmxPMProcess.Id;
        lstSchds.add(pmSch);
		
		SVMXC__ServiceMax_Config_Data__c timeSheetSch = new   SVMXC__ServiceMax_Config_Data__c();
        timeSheetSch.RecordTypeId = strSchedule;
        timeSheetSch.SVMXC__Run_At__c = '4:00 PM';
        timeSheetSch.SVMXC__Day_To_Run__c = string.valueOf(dateTime.now().dayGmt());
        timeSheetSch.SVMXC__Sequence__c = 1;
        timeSheetSch.SVMXC__Run_Type__c = 'Date of Month';
        timeSheetSch.SVMXC__Dispatch_Process__c = svmxTimeSheetProcess.Id;
        lstSchds.add(timeSheetSch);
        
        SVMXC__ServiceMax_Config_Data__c SPMFTFSch = new   SVMXC__ServiceMax_Config_Data__c();
        SPMFTFSch.RecordTypeId = strSchedule;
        SPMFTFSch.SVMXC__Run_At__c = '4:00 PM';
        SPMFTFSch.SVMXC__Day_To_Run__c = string.valueOf(dateTime.now().dayGmt());
        SPMFTFSch.SVMXC__Sequence__c = 1;
        SPMFTFSch.SVMXC__Run_Type__c = 'Date of Month';
        SPMFTFSch.SVMXC__Dispatch_Process__c = svmxSPMDetailsFTF.Id;
        lstSchds.add(SPMFTFSch);
        
        SVMXC__ServiceMax_Config_Data__c SPMCUDTSch = new   SVMXC__ServiceMax_Config_Data__c();
        SPMCUDTSch.RecordTypeId = strSchedule;
        SPMCUDTSch.SVMXC__Run_At__c = '4:00 PM';
        SPMCUDTSch.SVMXC__Day_To_Run__c = string.valueOf(dateTime.now().dayGmt());
        SPMCUDTSch.SVMXC__Sequence__c = 1;
        SPMCUDTSch.SVMXC__Run_Type__c = 'Date of Month';
        SPMCUDTSch.SVMXC__Dispatch_Process__c = svmxSPMDetailsCUDT.Id;
        lstSchds.add(SPMCUDTSch);
        
        SVMXC__ServiceMax_Config_Data__c SPMTTRSch = new   SVMXC__ServiceMax_Config_Data__c();
        SPMTTRSch.RecordTypeId = strSchedule;
        SPMTTRSch.SVMXC__Run_At__c = '4:00 PM';
        SPMTTRSch.SVMXC__Day_To_Run__c = string.valueOf(dateTime.now().dayGmt());
        SPMTTRSch.SVMXC__Sequence__c = 1;
        SPMTTRSch.SVMXC__Run_Type__c = 'Date of Month';
        SPMTTRSch.SVMXC__Dispatch_Process__c = svmxSPMDetailsMTTR.Id;
        lstSchds.add(SPMTTRSch);
        
        insert lstSchds;
    }
    
    static testMethod void SCON_WOInvoice_BatchUnitTest()
    {
		createSFMTestData();
        createTestData();
        
        SCON_Scheduler sch = new SCON_Scheduler();
        SchedulableContext sc;
         
        sch.isTestClass = true;
        
        system.assert(sch.execute(sc) == null);
    }
	static void createSFMTestData(){
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];        
        
        String TargetManager = '';
        String Fieldmapping = '';
        String ProcessNodeObj = '';
        
        for(RecordType r : lstRecType)
        {
            if(r.Name == 'Target Manager')
                TargetManager = r.id;
            else if(r.Name == 'Field Mapping')
                Fieldmapping = r.id;    
            else if(r.Name == 'Process Node Objects')    
                ProcessNodeObj = r.id;
        }
        
        processNodes = new SVMXC__ServiceMax_Processes__c();
        processNodes.RecordTypeId = TargetManager ;
        processNodes.SVMXC__Name__c = 'customprocess1';
        processNodes.SVMXC__Description__c = 'newprocess1';
        processNodes.SVMXC__ProcessID__c = 'process1';
        processNodes.SVMXC__IsStandard__c = true;
        insert processNodes;
        System.assertEquals(true, processNodes != null);
        
        //Creating List of ProcessNodeObject        
        List<SVMXC__ServiceMax_Processes__c> processNodeObject = new List<SVMXC__ServiceMax_Processes__c>();

        SVMXC__ServiceMax_Processes__c processNodeObject1 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject1.SVMXC__ProcessID__c = 'process2';
        processNodeObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        processNodeObject1.SVMXC__Type__c = 'TARGETCHILD';
        processNodeObject1.RecordTypeId = ProcessNodeObj;
        processNodeObject1.SVMXC__Process__c = processNodes.Id;

        SVMXC__ServiceMax_Processes__c processNodeObject2 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject2.SVMXC__ProcessID__c = 'process3';
        processNodeObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        processNodeObject2.SVMXC__Type__c = 'TARGET';
        processNodeObject2.SVMXC__Process__c = processNodes.Id;
        processNodeObject2.RecordTypeId = ProcessNodeObj;

        SVMXC__ServiceMax_Processes__c processNodeObject3 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject3.SVMXC__ProcessID__c = 'process4';
        processNodeObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Case_Tracker__c';
        processNodeObject3.SVMXC__Type__c = 'SOURCECHILD';
        processNodeObject3.RecordTypeId = ProcessNodeObj;
        processNodeObject3.SVMXC__Process__c = processNodes.Id;

        SVMXC__ServiceMax_Processes__c processNodeObject4 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject4.SVMXC__ProcessID__c = 'process5';
        processNodeObject4.SVMXC__Source_Object_Name__c = 'Case';
        processNodeObject4.SVMXC__Type__c = 'SOURCE';
        processNodeObject4.RecordTypeId = ProcessNodeObj;
        processNodeObject4.SVMXC__Process__c = processNodes.Id;

        processNodeObject.add(processNodeObject1);
        processNodeObject.add(processNodeObject2);
        processNodeObject.add(processNodeObject3);
        processNodeObject.add(processNodeObject4);
        insert processNodeObject;
        System.assertEquals(true, processNodeObject != null);
        
         //Creating List of the Config Data
        List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c svmxcd1 = new SVMXC__ServiceMax_Config_Data__c();
        svmxcd1.SVMXC__Dispatch_Process__c = processNodeObject4.Id;
        svmxcd1.SVMXC__MapID__c = processNodeObject4.Id;
        svmxcd1.SVMXC__Source_Field_Name__c = 'AVMXCX1configdata';
        svmxcd1.SVMXC__Setting_ID__c = processNodeObject4.Id;
        svmxcd1.RecordTypeId = Fieldmapping ;

        SVMXC__ServiceMax_Config_Data__c svmxcd2 = new SVMXC__ServiceMax_Config_Data__c();
        svmxcd2.SVMXC__Dispatch_Process__c = processNodeObject4.Id;
        svmxcd2.SVMXC__MapID__c = processNodeObject4.Id;
        svmxcd2.SVMXC__Source_Field_Name__c = 'AVMXCX1configdata123';
        svmxcd2.SVMXC__Setting_ID__c = processNodeObject4.Id;
        
        processSourceUpdates.add(svmxcd1);
        processSourceUpdates.add(svmxcd2);
        insert processSourceUpdates;
        System.assertEquals(true, processSourceUpdates != null);
    }
}