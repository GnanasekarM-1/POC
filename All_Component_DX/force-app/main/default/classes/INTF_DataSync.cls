public with sharing class INTF_DataSync {
    
    private static Integer methodCount = 0;
    public static Integer eventCount = 0;
    public String ct;
    public String srid;
    public String sfrid;
    private static Boolean soqlLogsEnabled = false; 
    private static INTF_DataSync objSyncMonitor = NULL;
    public static Boolean performanceLogsEnabled = false;
    private static string orgType = 'Production';
    public static string endpointUrl = 'https://empp.servicemax-api.com/instrument/classicsyncengine';
    
    public List<EventLogger> events;
    public Map<Integer,EventLogger> em;
    
    public INTF_DataSync(){
        events = new List<EventLogger>();   
        em = new Map<Integer,EventLogger>();  
    }
    
    public static INTF_DataSync getInstance(){
        if(objSyncMonitor == NULL){
            objSyncMonitor = new INTF_DataSync();
        }
        return objSyncMonitor;
    }
    
    public class EventLogger{
        public String en;
        public String est;
        public String eet;
        public Map<Integer,MethodLogger> mlm;
        public List<MethodLogger> ml;
        
        public EventLogger(){
            mlm = new Map<Integer, MethodLogger>();
            ml = new List<MethodLogger>();
        }
        
        public EventLogger(String strEventName, String strEventStartTime, String strEventEndTime)
        {
            this.en = strEventName;
            this.est = strEventStartTime;
            this.eet = strEventEndTime;
            mlm = new Map<Integer, MethodLogger>();
            ml = new List<MethodLogger>();
        }
    }
    
    public class MethodLogger{
        public integer seq;
        public String mn;
        public String mst;
        public String met;
        public List<String> soql;
        
        public MethodLogger(integer sequence, String strMethodName, String strMethodStartTime, String strMethodEndTime){
            this.seq = sequence;
            this.mn = strMethodName;
            this.mst = strMethodStartTime;
            this.met = strMethodEndTime;
        }
    }
    
    public static Integer logMethodStartTS(String strMethodName){
        if(performanceLogsEnabled){
            INTF_DataSync objInstance = INTF_DataSync.getInstance();
            if(objInstance != NULL && objInstance.em!= NULL && objInstance.em.size() > 0 && objInstance.em.get(eventCount) <> NULL && objInstance.em.get(eventCount).mlm != NULL){
                INTF_DataSync.methodCount++;
                objInstance.em.get(eventCount).mlm.put(methodCount, new MethodLogger(methodCount, strMethodName,String.ValueOf(system.now().format('yyyy-MM-dd HH:mm:ss:SSS')) + ':' + Limits.getCPUTime() , ''));
            }   
        }
        return methodCount;
    }
    
    public static void logMethodEndTS(Integer intMethodCount, String strMethodName){
        if(performanceLogsEnabled){
            INTF_DataSync objInstance = INTF_DataSync.getInstance();
            if(objInstance != NULL && objInstance.em != NULL && objInstance.em.size() > 0 && objInstance.em.get(eventCount) != NULL && objInstance.em.get(eventCount).mlm != NULL && objInstance.em.get(eventCount).mlm.get(intMethodCount) != NULL){
                objInstance.em.get(eventCount).mlm.get(intMethodCount).met = String.ValueOf(system.now().format('yyyy-MM-dd HH:mm:ss:SSS')) + ':' + Limits.getCPUTime();
            }
        }
    }
    
    public static void logEventStartTS(String strEventName){
        if(performanceLogsEnabled){
            INTF_DataSync objInstance = INTF_DataSync.getInstance();
            INTF_DataSync.eventCount++;
            objInstance.em.put(eventCount, new EventLogger(strEventName, String.ValueOf(system.now().format('yyyy-MM-dd HH:mm:ss:SSS')) + ':' + Limits.getCPUTime(), '') );
        } 
    }
    
    public static void logEventEndTS(String strEventName){
        if(performanceLogsEnabled){
            INTF_DataSync objInstance = INTF_DataSync.getInstance();
            if(objInstance!= NULL && objInstance.em != NULL && objInstance.em.size() > 0 && objInstance.em.get(eventCount) != NULL){
                objInstance.em.get(eventCount).eet = String.ValueOf(system.now().format('yyyy-MM-dd HH:mm:ss:SSS')) + ':' + Limits.getCPUTime();
            }
        }
        
    }
    
    public static void logSOQL(Integer intMethodCount, String strSOQL){
        if(performanceLogsEnabled && soqlLogsEnabled){
             INTF_DataSync objInstance = INTF_DataSync.getInstance();
             if(objInstance != NULL && objInstance.em != NULL && objInstance.em.size() > 0 && objInstance.em.get(eventCount) != NULL && objInstance.em.get(eventCount).mlm != NULL){
                if(objInstance.em.get(eventCount).mlm.get(intMethodCount) != NULL){
                    List<String> lstSOQLs = objInstance.em.get(eventCount).mlm.get(intMethodCount).soql;
                    if(lstSOQLs != null && lstSOQLs.size() > 0)
                        lstSOQLs.add(strSOQL);
                    else{
                        lstSOQLs = new List<String>{strSOQL};
                    }
                    objInstance.em.get(eventCount).mlm.get(intMethodCount).soql = lstSOQLs; 
                }
             }
        }
    }
    
    public static void updateMethodList(){
        if(performanceLogsEnabled){
            INTF_DataSync objInstance = INTF_DataSync.getInstance();
            if(objInstance.em != NULL && objInstance.em.get(eventCount) != NULL && objInstance.em.get(eventCount).mlm != NULL && objInstance.em.get(eventCount).mlm.size() > 0){
                objInstance.em.get(eventCount).ml.addALL( objInstance.em.get(eventCount).mlm.values() );
                objInstance.em.get(eventCount).mlm.clear();
                objInstance.em.get(eventCount).mlm = NULL;
            }
        }
    }
    
    public static void updateEventList(){
        if(performanceLogsEnabled){
            INTF_DataSync objInstance = INTF_DataSync.getInstance();
            if(objInstance.em != NULL && objInstance.em.size()>0){
                objInstance.events.addAll(objInstance.em.values());
                //objInstance.em.clear();
                objInstance.em = NULL;
            }
        }
    }
    
    public static void getLogSettings(Id grpProfileId,INTF_WebServicesDef.INTF_SFMRequest request){
        
        string strDeviceType = getDeviceNameFromReq(request);
        system.debug(LoggingLevel.WARN,' Device from Request strDeviceType = '+strDeviceType);
        String strMobConfQuery  = 'select SVMXC__Access_Configuration_Profile__c, SVMXC__Display_Type__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c = : grpProfileId AND (SVMXC__Display_Type__c = \'Enable Performance Profiling\' OR SVMXC__Display_Type__c = \'Enable SOQL Profiling\' OR SVMXC__Display_Type__c = \'Performance Profiling Org Type\' OR SVMXC__Display_Type__c = \'Performance Profiling Endpoint Url\') '; 
        
        String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(grpProfileId, strDeviceType);
        if(strDevConfId != NULL && strDevConfId != ''){
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
        }
        system.debug(LoggingLevel.WARN,'Query formed for GetLogSettings = '+strMobConfQuery);
         
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = Database.query(strMobConfQuery);
                                
        if(configDataList != NULL){
            for(SVMXC__ServiceMax_Config_Data__c config : configDataList){
                if(config.SVMXC__Display_Type__c == 'Enable Performance Profiling'){
                    performanceLogsEnabled = Boolean.valueOf(config.SVMXC__Internal_Value__c);
                    system.debug(LoggingLevel.WARN, '***** Performance enabled?'+performanceLogsEnabled);
                }else if(config.SVMXC__Display_Type__c == 'Enable SOQL Profiling'){
                    soqlLogsEnabled = Boolean.valueOf(config.SVMXC__Internal_Value__c);
                    system.debug(LoggingLevel.WARN, '***** SOQL logs enabled?'+soqlLogsEnabled);
                }else if(config.SVMXC__Display_Type__c == 'Performance Profiling Org Type'){
                        orgType = config.SVMXC__Internal_Value__c;
                }if(config.SVMXC__Display_Type__c == 'Performance Profiling Endpoint Url'){
                        endpointUrl = config.SVMXC__Internal_Value__c;
                }
            }
        }
        
        if(orgType == 'Production'){
                endpointUrl = 'https://empp.servicemax-api.com/instrument/classicsyncengine';
        }else if(orgType == 'Sandbox'){
                endpointUrl = 'https://emppdev.servicemax-api.com/instrument/classicsyncengine';
        }                         
    }

    public static String getDeviceNameFromReq(INTF_WebServicesDef.INTF_SFMRequest request)
    {
        String strDeviceName = '';
        if(request.clientInfo != null && request.clientInfo.size() > 0)
        {
            for(INTF_WebServicesDef.SVMXClient clientInform : request.clientInfo)
            {
                if(clientInform.clientType != null)
                {
                    strDeviceName = clientInform.clientType;
                    break;
                }
            }
        }
        return strDeviceName;
    } 
    
    @future(callout=true)
    public static void sendLogsToAWS(String strRequestBody, String endpointUrl){
        system.debug(LoggingLevel.WARN, 'Heap Size before = '  + Limits.getHeapSize());
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setHeader('From', 'ServiceMaxNow');
        req.setHeader('clientId', UserInfo.getOrganizationId());
        req.setHeader('clientName', UserInfo.getOrganizationName());
        req.setBody(strRequestBody);
        req.setEndpoint(endpointUrl);
        system.debug('***Request structure :'+req);
        
        Http http = new Http();
        try{
           HTTPResponse res = http.send(req);
           //System.debug(loggingLevel.WARN, 'What in response -'+res);
        }
        catch(System.CalloutException e){
            system.debug(LoggingLevel.WARN, 'Exception = '  + e);
        }
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse dataSync(INTF_WebServicesDef.INTF_SFMRequest request, String svmxGrpProfileId)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        system.debug(loggingLevel.WARN, '===== Calling from the With Sharing Class .... ');
        
        if(request.eventName == 'TARGETED_SYNC' && request.eventType == 'SYNC')
        {
                response = (new SFMTransactionSync()).targetedSync(request);
        }
        else if(request.eventName == 'EVENT_RECORDS' && request.eventType == 'PURGING')
        {
          response = (new INTF_DataUtilityServices()).purgeEvents(request); 
        }
        else if(request.eventName == 'PURGE_RECORDS' && request.eventType == 'PURGING')
        {
            response = (new INTF_DataUtilityServices()).getRecordsForPurging(request, svmxGrpProfileId); 
        }
        else if(request.eventName == 'TECH_LOCATION_UPDATE' && request.eventType == 'SYNC')
        {
            response = (new INTF_DataUtilityServices()).updateTechLocation(request); 
        }
        else if(request.eventName == 'LOCATION_HISTORY' && request.eventType == 'SYNC')
        {
            response = (new INTF_DataUtilityServices()).updateTechLocHistory(request); 
        }
        else if(request.eventName == 'DATA_ON_DEMAND' && request.eventType == 'GET_DATA')
        { 
            response = (new INTF_DataUtilityServices()).downloadOnDemand(request, svmxGrpProfileId); 
        }
        else if(request.eventName == 'PUSH_NOTIFICATION' && request.eventType == 'GET_DATA')
        { 
            response = (new INTF_DataUtilityServices()).getPushNotificationData(request); 
        }
        else 
        {
            //Sync Logging Performance
            if(!((request.eventName == 'GENERATE_PDF' || request.eventName == 'SUBMIT_DOCUMENT' || request.eventName == 'SUBMIT_DOCUMENT_FILES' || request.eventName == 'GENERATE_PDF_FILES' || request.eventName == 'SYNC_PRODUCTIQ_DATA') && request.eventType == 'SYNC'))
                    INTF_SyncLogCapture.initiateLogging(request);
            
            try
            {
                if(request.eventName == 'ONE_CALL_SYNC' && request.eventType == 'SYNC')
                {
                    INTF_DataSync.logEventStartTS('ONE_CALL_SYNC');
                    response = (new INTF_TxnCache()).oneCallSync(request);
                    INTF_DataSync.updateMethodList();
                    INTF_DataSync.logEventEndTS('ONE_CALL_SYNC');
                }
                else if(request.eventName == 'EVENT_SYNC' && request.eventType == 'SYNC')
                {
                    INTF_DataSync.logEventStartTS('EVENT_SYNC');
                    response = (new INTF_DataUtilityServices()).RequestDataFromBase(request);
                    INTF_DataSync.updateMethodList();
                    INTF_DataSync.logEventEndTS('EVENT_SYNC');
                }
                else if(request.eventName == 'PUT_INSERT' && request.eventType == 'SYNC')
                {
                  response = (new INTF_DataUtilityServices()).InsertClientDataIntoBase(request);
                }
                else if(request.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                {
                    INTF_DataSync.logEventStartTS('DOWNLOAD_CREITERIA_SYNC');
                    response = (new INTF_TxnCache()).getDownloadCriteriaRecords(request);
                    INTF_DataSync.updateMethodList();
                    INTF_DataSync.logEventEndTS('DOWNLOAD_CREITERIA_SYNC');
                }
                else if(request.eventName == 'GET_INSERT_DOWNLOAD_CRITERIA' || request.eventName == 'GET_UPDATE_DOWNLOAD_CRITERIA' || request.eventName == 'GET_DELETE_DOWNLOAD_CRITERIA')
                {
                    response = (new INTF_DataUtilityServices()).RequestForCriteriaRecords(request);
                }
                else if(request.eventName == 'PUT_UPDATE' && request.eventType == 'SYNC')
                {
                    response = (new INTF_DataUtilityServices()).UpdateClientDataIntoBase(request);
                }
                else if(request.eventName == 'PUT_DELETE' && request.eventType == 'SYNC')
                {
                  response = (new INTF_DataUtilityServices()).SendClientDeletesToBase(request);
                }
                else if(request.eventName == 'TX_FETCH' && request.eventType == 'SYNC')
                {
                    INTF_DataSync.logEventStartTS('TX_FETCH');
                    try
                    {
                        response = (new INTF_DataUtilityServices()).getRecordsForIds(request);
                    }
                    catch(Exception ex)
                    {
                        INTF_DataSync.updateMethodList();
                        INTF_DataSync.logEventEndTS('TX_FETCH');
                        throw ex;
                    }
                    INTF_DataSync.updateMethodList();
                    INTF_DataSync.logEventEndTS('TX_FETCH');
                }
                else if(request.eventName == 'GET_INSERT' || request.eventName == 'GET_UPDATE' || request.eventName == 'GET_DELETE')
                {
                    response = (new INTF_DataUtilityServices()).RequestIncrementaldataFromBase(request);
                }
                else if(request.eventName == 'CLEAN_UP' || request.eventName == 'CLEAN_UP_SELECT')
                {
                  response = (new INTF_DataUtilityServices()).RequestIdCleanUp(request); 
                }
                else if(request.eventName == 'SFM_SEARCH' && request.eventType == 'SEARCH_RESULTS')
                {
                    response = (new INTF_DataUtilityServices()).getSearchResults(request); 
                }
                else if(request.eventName == 'PRICE_CALC_DATA' && request.eventType == 'SYNC')
                {
                    INTF_DataSync.logEventStartTS('PRICE_CALC_DATA');                
                    response = (new INTF_DataUtilityServices()).getPricingDefinitions(request); 
                    INTF_DataSync.updateMethodList();
                    INTF_DataSync.logEventEndTS('PRICE_CALC_DATA'); 
                }
                else if(request.eventName == 'DATA_ON_DEMAND' && request.eventType == 'GET_PRICE_INFO')
                { 
                    response = (new INTF_DataUtilityServices()).getWOPriceInfo(request, svmxGrpProfileId); 
                }
                else if(request.eventName == 'USER_TRUNK' && request.eventType == 'SYNC')
                { 
                    response = (new INTF_DataUtilityServices()).getTechnicianLocation(request); 
                }
                else if(request.eventName == 'ADV_DOWNLOAD_CRITERIA' && request.eventType == 'SYNC')
                { 
                    INTF_DataSync.logEventStartTS('ADV_DOWNLOAD_CRITERIA');
                    response = (new INTF_DataUtilityServices()).getAdvanceDownloadCriteriaRecIds(request); 
                    INTF_DataSync.updateMethodList();
                    INTF_DataSync.logEventEndTS('ADV_DOWNLOAD_CRITERIA'); 
                }
                else if(request.eventName == 'SUBMIT_DOCUMENT' && request.eventType == 'SYNC')
                {
                    INTF_DataSync.logEventStartTS('SUBMIT_DOCUMENT');
                    response = (new INTF_DataUtilityServices()).submitDocument(request);
                    INTF_DataSync.updateMethodList();
                    INTF_DataSync.logEventEndTS('SUBMIT_DOCUMENT');
                }
                else if(request.eventName == 'GENERATE_PDF' && request.eventType == 'SYNC')
                {
                    INTF_DataSync.logEventStartTS('GENERATE_PDF');
                    response = (new INTF_DataUtilityServices()).generatePdf(request);
                    INTF_DataSync.updateMethodList();
                    INTF_DataSync.logEventEndTS('GENERATE_PDF');
                }
                else if(request.eventName == 'TX_FETCH_OPTIMZED' && request.eventType == 'SYNC')
                {
                    INTF_TxnCache.restore(request.value);
                    response = (new INTF_TxnCache()).getRecordsForIds(request);
                }
                else if(request.eventName == 'SYNC_DOWNLOAD_CRITERIA' && request.eventType == 'SYNC')
                {
                    INTF_DataSync.logEventStartTS('SYNC_DOWNLOAD_CRITERIA');
                    response = (new INTF_DataUtilityServices()).getDownloadCriteriaRecordIds(request);
                    INTF_DataSync.updateMethodList();
                    INTF_DataSync.logEventEndTS('SYNC_DOWNLOAD_CRITERIA');
                }
                else if(request.eventName == 'SYNC_PRODUCTIQ_DATA' && request.eventType == 'SYNC')
                {
                    INTF_DataSync.logEventStartTS('SYNC_PRODUCTIQ_DATA');
                    response = (new INTF_TxnCache()).getProductIQData(request, svmxGrpProfileId);
                    INTF_DataSync.updateMethodList();
                    INTF_DataSync.logEventEndTS('SYNC_PRODUCTIQ_DATA');
                }
                else if(request.eventName == 'SYNC_PRODUCTIQ_PRODUCT_ATTR' && request.eventType == 'SYNC')
                {
                    response = (new INTF_TxnCache()).getProductAttributesTemplates(request, svmxGrpProfileId);
                }
                else if(request.eventName == 'SYNC_PRODUCTIQ_IB_ATTR' && request.eventType == 'SYNC')
                {
                    response = (new INTF_TxnCache()).getIBAttrTemplHistory(request, svmxGrpProfileId);
                }
                else if(request.eventName == 'GET_DELETE_PRODUCTIQ_DATA' && request.eventType == 'SYNC')
                {
                    response = (new INTF_TxnCache()).getDeletedProductIQData(request, svmxGrpProfileId);
                }
                else if(request.eventName == 'GET_PIQ_PICKLIST_DEFINITION' && request.eventType == 'SYNC')
                {
                    response = (new INTF_TxnCache()).getDeltaPicklistDef(request, svmxGrpProfileId);
                }
                else if(request.eventName == 'SYNC_CHECKLIST_DATA' && request.eventType == 'SYNC')
                {
                    INTF_DataSync.logEventStartTS('SYNC_CHECKLIST_DATA');
                    response = (new INTF_TxnCache()).getChecklistData(request, svmxGrpProfileId);
                    INTF_DataSync.updateMethodList();
                    INTF_DataSync.logEventEndTS('SYNC_CHECKLIST_DATA');
                }
                else if(request.eventName == 'SYNC_PIQ_ATTACHMENTS' && request.eventType == 'SYNC')
                {
                    response = (new INTF_TxnCache()).getAttachments(request, svmxGrpProfileId);
                }
                else if(request.eventName == 'SYNC_PRODUCT_TEMPLATES' && request.eventType == 'SYNC')
                {
                    response = (new INTF_TxnCache()).getPIQAttributesTemplates(request, svmxGrpProfileId);
                }
                else if(request.eventName == 'TRUNK_STOCK' && request.eventType == 'SYNC')
                {
                    INTF_DataSync.logEventStartTS('TRUNK_STOCK');                         
                    response = (new INTF_TxnCache()).getTrunkStock(request, svmxGrpProfileId);
                    INTF_DataSync.updateMethodList();
                    INTF_DataSync.logEventEndTS('TRUNK_STOCK'); 
                }
                else if(request.eventName == 'CATALOG_SEARCH' && request.eventType == 'SYNC')
                {
                    response = (new INTF_TxnCache()).getProducts(request);
                }                    
                else if(request.eventName == 'LOCATE_PART' && request.eventType == 'SYNC')
                {
                    response = (new INVT_Inventory_Utils()).locatePart(request,svmxGrpProfileId);
                }                              
                else if(request.eventName == 'TECHNICIAN_SEARCH' && request.eventType == 'SYNC')
                {
                    response = (new INTF_TxnCache()).getTechnician(request);
                }
                else if(request.eventName == 'STOCK_TRANSFER' && request.eventType == 'SYNC')
                {
                    response = (new INVT_Inventory_Utils()).getStockTransferWrapper(request,svmxGrpProfileId);
                } 
                else if(request.eventName == 'SYNC_SALESFORCE_FILES' && request.eventType == 'SYNC')
                {
                    response = (new INTF_SFDCFilesUtilityServices()).createSalesforceFiles(request);
                } 
                else if(request.eventName == 'DOWNLOAD_EVENT_FILES' && request.eventType == 'SYNC')
                {
                    response = (new INTF_SFDCFilesUtilityServices()).getEventRelatedFiles(request, svmxGrpProfileId);
                }
                else if(request.eventName == 'SYNC_PIQ_FILES' && request.eventType == 'SYNC')
                {
                    response = (new INTF_SFDCFilesUtilityServices()).getProductIQFiles(request, svmxGrpProfileId);
                }
                else if(request.eventName == 'SUBMIT_DOCUMENT_FILES' && request.eventType == 'SYNC')
                {
                    response = (new INTF_SFDCFilesUtilityServices()).submitDocumentForFiles(request);
                }
                else if(request.eventName == 'GENERATE_PDF_FILES' && request.eventType == 'SYNC')
                {
                    response = (new INTF_SFDCFilesUtilityServices()).generatePdfForFiles(request, svmxGrpProfileId);
                }
                if(!((request.eventName == 'GENERATE_PDF' || request.eventName == 'SUBMIT_DOCUMENT' || request.eventName == 'SUBMIT_DOCUMENT_FILES' || request.eventName == 'GENERATE_PDF_FILES' || request.eventName == 'SYNC_PRODUCTIQ_DATA') && request.eventType == 'SYNC'))                                 
                        INTF_SyncLogCapture.finishLogging(true);
            }catch(exception ex)
            {
                    if(!((request.eventName == 'GENERATE_PDF' || request.eventName == 'SUBMIT_DOCUMENT' || request.eventName == 'SUBMIT_DOCUMENT_FILES' || request.eventName == 'GENERATE_PDF_FILES' || request.eventName == 'SYNC_PRODUCTIQ_DATA') && request.eventType == 'SYNC'))
                        INTF_SyncLogCapture.finishLogging(false);
                    response.success = false;
                response.message = ex.getMessage();     
            }
        }
        return response;
    }
}