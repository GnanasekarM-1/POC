global class SVMX_RCALoggingController implements Database.Batchable<SObject>,Database.AllowsCallouts {
    
    global String strQuery = '';
    global String rcaLogType = 'OptiMax';
    global static Map<String,Integer> logLevelsMap = new Map<String,Integer> {'DEBUG'=>0,'RCA'=>1};

    global SVMX_RCALoggingController ()
    {
        system.debug('SVMX_RCALoggingController constructor');
        strQuery = 'SELECT Id,SVMXC__Log_Context__c,SVMXC__Message__c,SVMXC__Log_Category__c from SVMXC__SVMX_Job_Logs__c WHERE SVMXC__Type__c =  \''+rcaLogType+'\' Order By ID ASC';
    
    }


    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug('Query: ' + strQuery);
        return Database.getQueryLocator(strQuery);

    }

    global void execute(Database.BatchableContext BC, List<sObject> lstSObject)
    {
    
       system.debug('Into Execute of RCA Controller'+lstSObject.size());
       system.debug('RCA_Logging_Scheduler is Starting');
       //List<SVMXC__SVMX_Job_Logs__c> rcaLogsList = fetchRCALogs();
       List<SVMXC__SVMX_Job_Logs__c> rcaLogsList = (list <SVMXC__SVMX_Job_Logs__c>)(lstSObject);
       List<String> woNames = extractWONames(rcaLogsList);
       List<SVMXC__Service_Order__c> worOrders = fetchWorkorders(woNames);
       Map<String,String> woNTeritoryMap= fetchWOTeritories(worOrders);
       Map<String,String> woNDispatchProcessMap= fetchWODispatchProcess(worOrders);

       //Construct Request
       RCALogEntry_WP rcaEntry;
       List<RCALogEntry_WP> rcaEntries = new List<RCALogEntry_WP>();
       TimeStamp timstamp = new TimeStamp();
       timstamp.Seconds = Integer.ValueOf(DateTime.now().getTime()/1000);
       timstamp.Nanos =    Integer.ValueOf((DateTime.now().getTime()/1000)*1000000);
       String woId='';
       String terId='';
       String dpId='';
       String techId='';
       String jobId=''; 
       String eventId='';
       List<String> woIds = new List<String>();
       for(SVMXC__SVMX_Job_Logs__c jobLog : rcaLogsList){
            
            rcaEntry = new RCALogEntry_WP();
                rcaEntry.Aid = 1;
                rcaEntry.Mod =  1;
                rcaEntry.Sid =  'InitJob';
                rcaEntry.Oid =  Userinfo.getOrganizationId().substring(0,15);
                rcaEntry.ctx =  Integer.ValueOf(jobLog.SVMXC__Log_Category__c);
                rcaEntry.Act =  1;
                rcaEntry.lvl =  1;
                rcaEntry.msg =  jobLog.SVMXC__Message__c; 
                rcaEntry.dct =  2;
                rcaEntry.Tsp=timstamp;
                if(woId!=null && woId.contains(',')){
                    //Bulk Orders
                    system.debug('WO contains , ');
                    woIds = woId.split(',');
                    system.debug('splitwoIds '+woIds);
                    if(woIds!=null && woIds.size()>0){
                        for(String splitWo : woIds ){
                        system.debug('splitWo '+splitWo);
                        system.debug('woNTeritoryMap '+woNTeritoryMap);
                        system.debug('woNDispatchProcessMap '+woNDispatchProcessMap);
                        if(woNTeritoryMap !=null && woNTeritoryMap.size()>0 &&
                                woNTeritoryMap.containsKey(splitWo)){
                           terId = woNTeritoryMap.get(splitWo);
                        }
                        if(woNDispatchProcessMap !=null && woNDispatchProcessMap.size()>0
                              && woNDispatchProcessMap.containsKey(splitWo)){
                           dpId = woNDispatchProcessMap.get(splitWo);
                        }
                        }
                    }
                    

                }else{
                    //Single WO
                    woId  = jobLog.SVMXC__Log_Context__c;
                    if(jobLog.SVMXC__Log_Context__c != ''){
                        if(woNTeritoryMap !=null && woNTeritoryMap.size()>0 &&
                                woNTeritoryMap.containsKey(woId)){
                           terId = woNTeritoryMap.get(woId);
                        }
                        if(woNDispatchProcessMap !=null && woNDispatchProcessMap.size()>0
                              && woNDispatchProcessMap.containsKey(woId)){
                           dpId = woNDispatchProcessMap.get(woId);
                        }
                    }
                    
                }
                rcaEntry.Tid =  terId;
                rcaEntry.Dp  =  dpId;
                rcaEntry.Jid =  jobId;
                rcaEntry.Nid =  woId;
                rcaEntry.Rid =  techId;
                rcaEntry.Eid =  eventId;
                rcaEntries.add(rcaEntry);   
        }

        //Call the webservice
       RCALogRequest_WP rcaRequest= new RCALogRequest_WP();
      rcaRequest.Logs=rcaEntries; 
      String requestJson=JSON.serialize(rcaRequest); 
      callOut(requestJson);
    }
    
    
      private List<SVMXC__SVMX_Job_Logs__c> fetchRCALogs(){

        List<SVMXC__SVMX_Job_Logs__c> rcaLogsList = [SELECT Id,SVMXC__Log_Context__c,SVMXC__Message__c from SVMXC__SVMX_Job_Logs__c WHERE SVMXC__Type__c = 'OptiMaxRCA'];

        return rcaLogsList;

    }

    private List<String> extractWONames(List<SVMXC__SVMX_Job_Logs__c> rcaLogsList){
        system.debug('extractWONames rcaLogsList :- '+rcaLogsList);
        List<String> woNames = new List<String>();
        String logContext;
        for(SVMXC__SVMX_Job_Logs__c logObj : rcaLogsList){
            logContext =  logObj.SVMXC__Log_Context__c;
            //system.debug('logContext:- '+logContext);
            if(logContext !=null && logContext!=''){
                if(logContext.contains(',')){
                    List<String> splitWoids =  logContext.split(',');
                    //system.debug('splitWoids'+splitWoids);
                    for(String morewo : splitWoids){
                        //system.debug('morewo :'+morewo);
                         if(!woNames.contains(morewo)){
                            system.debug('the List contains this WO'+morewo);
                            woNames.add(morewo);
                    }
                    }
                }else{
                    if(!woNames.contains(logContext)){
                        woNames.add(logContext);
                    }
                }

            }
        }
        system.debug('extractWONames woNames:- '+woNames);
        return woNames;

    }

    private List<SVMXC__Service_Order__c>  fetchWorkorders(List<String> woNames){
        List<SVMXC__Service_Order__c> woOrders = 
                   [Select Name, SVMXC__Group_Member__c, SVMXC__Dispatch_Process__c, SVMXC__Zip__c, SVMXC__Primary_Territory__c from SVMXC__Service_Order__c where name in : woNames];
        system.debug('fetchWorkorders woNames:- '+woOrders);
         
        return woOrders;
    }

    private Map<String,String> fetchWOTeritories(List<SVMXC__Service_Order__c> woOrders){
        Map<String,String> woNTeritories = new  Map<String,String>();
        
         Map<String,String> woNTerIdMap = new Map<String,String>();
            for(SVMXC__Service_Order__c wo:woOrders){
                woNTerIdMap.put(wo.Name,wo.SVMXC__Primary_Territory__c);
            }
          system.debug('fetchWOTeritories woNTerIdMap:- '+woNTerIdMap);
          Map<Id,SVMXC__Territory__c> territories =  new Map<Id,SVMXC__Territory__c>([Select Id,name From SVMXC__Territory__c where Id in : woNTerIdMap.values()]);
          
          system.debug('fetchWOTeritories territories:- '+territories);

          String terName;
          String terId;
          for(String woName : woNTerIdMap.keyset()){
            terId = woNTerIdMap.get(woName);
                if(territories !=null && territories.size()>0 ){
                    if(territories.get(terId)!= null){
                     system.debug('TErr is not null');
                     terName = territories.get(terId).name;
                  }
                 }
            woNTeritories.put(woName,terName);
          }
          system.debug('fetchWOTeritories woNTeritories'+woNTeritories);
          return woNTeritories;
    }
    
    private Map<String,String> fetchWODispatchProcess(List<SVMXC__Service_Order__c> woOrders){
       Map<String,String> woNDispatchProcessNamesMap = new  Map<String,String>();
        Map<String,String> woNDPIdMap = new Map<String,String>();
            for(SVMXC__Service_Order__c wo:woOrders){
                woNDPIdMap.put(wo.Name,wo.SVMXC__Dispatch_Process__c);
            }
        system.debug('fetchWODispatchProcess woNDPIdMap:- '+woNDPIdMap);
         Map<Id,SVMXC__ServiceMax_Processes__c> dispatchProcessMap =  new Map<Id,SVMXC__ServiceMax_Processes__c>([Select name,SVMXC__Name__c from SVMXC__ServiceMax_Processes__c where Id in : woNDPIdMap.values()]);

         system.debug('fetchWODispatchProcess dispatchProcessMap:- '+dispatchProcessMap);
         
         String dpId;
         String dpName='';
         for(String woName : woNDPIdMap.keyset()){
            dpId = woNDPIdMap.get(woName);
                if(dispatchProcessMap !=null && dispatchProcessMap.size()>0 ){
                    if(dispatchProcessMap.get(dpId)!= null){
                     system.debug('TErr is not null');
                     dpName = dispatchProcessMap.get(dpId).SVMXC__Name__c;
                  }
                 }
            woNDispatchProcessNamesMap.put(woName,dpName);
          }
           system.debug('fetchWODispatchProcess woNDispatchProcessNamesMap'+woNDispatchProcessNamesMap);
          return woNDispatchProcessNamesMap;

    }

     public void callOut(String requestJson){
        String calloutEndpoint = 'https://services.servicemax-api.com:8086/v1/svmx/log';
        try{
            Http http = new Http();
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(calloutEndpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            system.debug('WSCH_AuditLogger : callOut'+requestJson);
              
            request.setBody(requestJson);
            HttpResponse response = http.send(request);
            system.debug('WSCH_AuditLogger : callOut'+response);
            
            if (response.getStatusCode() != 200 && response.getStatusCode() != 202) {
                WSCH_AuditLogger.debug('Exception:-WSCH_AuditLogger::callOut(): The status code returned was not expected:'+response.getBody());
            } else {
                WSCH_AuditLogger.debug('WSCH_AuditLogger::callOut(): response - '+response.getBody());  
            }           
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception occured::WSCH_AuditLogger::callOut(): - '+e.getMessage());
        }   
    }
     
     //AppType{OPT,SFD,GMX,OAU}
     public enum AppType{OPT,SFD,GMX,OAU}
     public enum ModeType{BAT,RTO}
     public enum ContextType{DBG,RCA}
     public enum ActionType{AW,UW,DW,AR,UR,DR,AE,UE,DE}
     public enum LogLevelType{DEBUG,INFO,WARN,ERROR,PANIC,FATAL}
     public enum DataCatType{OTH,INP,OUT,INOUT}


     public class RCALogRequest_WP{ 
         public List<RCALogEntry_WP> Logs= new List<RCALogEntry_WP>();
    }


     public class RCALogEntry_WP{
        public  Integer Aid;             //application 
        public  Integer Mod;             //Mode - BAT/RTO
        public  string Sid { get; set; } //
        public  String Oid{ get; set; }  //Org Id
        public  String Tid{ get; set; }  //Teritory Id
        public  String Dp{ get; set; }   //Dispatch Process
        public  String Jid{ get; set; }  //Job Id
        public  String Nid{ get; set; }  //Node Id- WO Id
        public  String Rid{ get; set; }  //Resource Id -Technician Id
        public  String Eid{ get; set; }  //Event Id
        public  Integer Ctx;             //Context
        public  Integer Act;             //ActionType
        public  String msg{ get; set; } //log
        public  Integer Lvl;            //loglevel
        public  TimeStamp   Tsp;        //TimeStamp
        public  Integer Dct;            //DataCategory

    }
    
    public class TimeStamp{
        public Integer Seconds;
        public Integer Nanos;
    
    }    

   
    global void finish(Database.BatchableContext bc){
        List<SVMXC__SVMX_Job_Logs__c> jobLogs = [SELECT Id FROM SVMXC__SVMX_Job_Logs__c where SVMXC__Type__c='OptiMax'];
        delete jobLogs;
        system.debug('Finished Executing the Batch');
        
    } 
    
    

}