/*
 This is AutioLogger UT Class for code coverate of all the methods . 

*/

@isTest
//(seeAllData = true)
public with sharing class WSCH_AuditLogger_UT {
     static testMethod void auditLogger()
    {
        String SettingTypeId = '';
        String GlobalTypeId = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Setting Value' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c'){
                   SettingTypeId = rt.ID;
            }
            else  if(rt.Name == 'Settings' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c'){
                   GlobalTypeId = rt.ID;
            }
        }
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Enable Audit Logger for ServicePower web service APIs';
        svmxprocess.SVMXC__SubmoduleID__c='DCON004';
        svmxprocess.SVMXC__SettingID__c='SET003';
        svmxprocess.SVMXC__Active__c = true;
        svmxprocess.RecordTypeId = GlobalTypeId;
        svmxprocess.SVMXC__Setting_Type__c = 'Global';
        svmxprocess.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(svmxprocess);
        
        SVMXC__ServiceMax_Config_Data__c confObj = new SVMXC__ServiceMax_Config_Data__c();

        confObj.SVMXC__Display_Value__c = 'true';
        confObj.SVMXC__Internal_Value__c = 'true';
        confObj.SVMXC__Active__c = true;
        confObj.SVMXC__Setting_ID__c = svmxprocess.id;
        confObj.RecordTypeId = SettingTypeId;
        confObj.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(confObj);

        
        WSCH_AuditLogger.clear();
        WSCH_AuditLogger.info('INFO MESSAGE');
        WSCH_AuditLogger.debug('DEBUG MESSAGE');
        WSCH_AuditLogger.error('ERROR MESSAGE');
        WSCH_AuditLogger.warn('WARN MESSAGE');
        WSCH_AuditLogger.finish();
        
        /*Execute Below Test Class Method for 91% Coverage*/
        //WSCH_OptimizedSchedulingService_UT.scheduleWorkOrders();
        
        WSCH_AuditLogger.setLogContext('log context');
        WSCH_AuditLogger.setApexCPUTime(10);
        WSCH_AuditLogger.setAPIName('API');
        WSCH_AuditLogger.initPerfomanceMetrics();
        
        WSCH_AuditLogger.isLinxMetricLogEnabled = true;
        WSCH_AuditLogger.appendMetrics('WO-0011', 'metric_prefix', Datetime.now(), 1234567890);
        
        //RCA Logger Coverage
        WSCH_AuditLogger.doLevelLogging();
        WSCH_AuditLogger.doErrorLogging();
        
        WSCH_AuditLogger.isError= false;
        WSCH_AuditLogger.getPreformancMetricsMap();
        WSCH_AuditLogger.appendMetrics('WO-0011', 'metric_prefix', Datetime.now(), 1234567890);
        WSCH_AuditLogger.isLinxMetricLogEnabled = true;
        WSCH_AuditLogger.appendMetrics('WO-0011', 'metric_prefix', Datetime.now(), 1234567890, 'abc');
        WSCH_AuditLogger.setLogEnabled(true);
        WSCH_AuditLogger.debug('ERROR');
        WSCH_AuditLogger.getPreformancMetricsMap();
        WSCH_AuditLogger.savePerformanceMetrics();
        String requestJson = '{"state":"ON_TENTATIVE","errorcode":null,"workItems":[{"id":"WO-00619678","type":"JOB","booking":{"start":"2018-09-19 07:23","driveDuration":0.0,"arr":"2018-09-19 07:23","idleDuration":0.0,"visitDuration":3600.0,"end_x":"2018-09-19 08:23","tech":"a1i170000001cSMAAY_Tech12_OR"},"errorMsg":null,"ignored":false,"resolvedLatitude":0.0,"resolvedLongitude":0.0}],"changeTime":"2018-09-17 08:59","dispatched":false}';
        WSCH_AuditLogger.saveECORequestJson(requestJson);
        WSCH_AuditLogger.appendMetrics('WO-0011', 'metric_prefix', Datetime.now(), 1234567890,'newlog');
        WSCH_AuditLogger.savePerformanceMetricsForECO();
        WSCH_AuditLogger.getLogCatMap(45);

        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'territoryName';
        insert Territory1;

        List<RecordType> RecType = new  List<RecordType>();
        string DispatchRTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
        }
        SVMXC__ServiceMax_Processes__c prcessObjone = new SVMXC__ServiceMax_Processes__c();
        prcessObjone.RecordTypeId = DispatchRTypeId;
        prcessObjone.SVMXC__Name__c = 'Test LTP';
        prcessObjone.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        prcessObjone.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Weight_Time_Window__c = 1;
        prcessObjone.SVMXC__Weight_Total_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Time__c = 1;
        prcessObjone.SVMXC__Weight_Node_Type__c = 1;
        prcessObjone.SVMXC__Values__c = Territory1.id;
        prcessObjone.SVMXC__Route_Type__c = 'CLOSED';
        prcessObjone.SVMXC__Dispatch_Threshold__c = 30;
        prcessObjone.SVMXC__Optimizer_Sync_Interval__c = 30;
        prcessObjone.SVMXC__Calendar_End_Days__c=9;
        prcessObjone.SVMXC__Calendar_Start_Days__c=1;
        prcessObjone.SVMXC__Full_Run_Unit__c = 'DAYS';
        prcessObjone.SVMXC__Window_Height__c = 9.0;
        prcessObjone.SVMXC__Window_Width__c = 90.0;        
        insert prcessObjone;

        WSCH_AuditLogger.fetchTeritoryName(Territory1.Id);
        WSCH_AuditLogger.fetchDispatchProcessName(prcessObjone.Id);
        
        WSCH_AuditLogger.getLoggerDateTime();


        List<SVMXC__SVMX_Job_Logs__c> jobLogsList = new List<SVMXC__SVMX_Job_Logs__c>();
        WSCH_AuditLogger.insertJobLogs(jobLogsList);

        String logMsg = 'sdff dsfof dsfsdfdjhfsduej fdfjdsfasfdjfas  dsfjadsfouyasehjfdsf jkdfhadsf ajdfdsfsdf aeadjf dsufsdflasy';
        String logCtxt ='WO-32392382,WO-32392434,WO-3233232';
        WSCH_AuditLogger.saveLogs(logMsg, logCtxt);

        List<String> debugLogs = new List<String>();
        String log1 = 'test log1';
        string log2 = 'test log 2';
        string log3 = 'test log 3';
        debugLogs.add(log1);
        debugLogs.add(log2);
        debugLogs.add(log3);
        WSCH_AuditLogger.createLogs(debugLogs, logCtxt);
        
    }
}