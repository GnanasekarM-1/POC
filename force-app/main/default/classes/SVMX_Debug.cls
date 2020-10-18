global with sharing class SVMX_Debug {
    
    //SMAX_Debug Wrapper Class
    global class SMAX_Debug
    {
        webservice String timeStamp{get;set;}
        webservice String className{get;set;}   
        webservice String methodName{get;set;}
        webservice String logType{get;set;} //Picklist (ENTER,EXIT, INSERT, UPDATE,DELETE,UPSERT, SAVEPOINT SET, ROLLBACK, QUERY_TEXT,QUERY_RESPONSE, )
        webservice String logMsg{get;set;}
        
        public SMAX_Debug()
        {
            logMsg = '';
        }
        public SMAX_Debug(String className,String methodName,String logType,String logMsg)
        {
            this.className = className;
            this.methodName = methodName;
            this.logType = logType;
            this.logMsg = logMsg;
        }
    }   
    
    List<SMAX_Debug> debug_logger;
    Integer numberofMethods;
    String logedinClass;
    String logedinMethod;
    public SVMX_Debug(){
        debug_logger = new List<SMAX_Debug>();
        numberofmethods = 0;
    }
    
    public void setlog(String l_Type, String l_Message){
        SMAX_Debug log = new SMAX_Debug();
        log.className = logedinClass;
        log.methodName = logedinMethod;
        log.logType = l_Type;
        log.logMsg = l_Message;
        log.timeStamp = String.valueOf(system.now().date()) + ' ' + String.valueOf(system.now().time());
        debug_logger.add(log);
    }
    
    public void login(String className, String methodName){
        SMAX_Debug log = new SMAX_Debug();
        log.className = className;
        log.methodName = methodName;
        logedinClass = className;
        logedinMethod = methodName;
        numberofMethods = numberofMethods + 1;
        log.timeStamp = String.valueOf(system.now().date()) + ' ' + String.valueOf(system.now().time());
        log.logType = 'METHOD_ENTRY';
        log.logMsg = 'Entering into Class: ' + className + '\nMethod: ' + methodName;
        debug_logger.add(log);
    }
    
    public void logout(){
        SMAX_Debug log = new SMAX_Debug();
        log.className = logedinClass;
        log.methodName = logedinMethod;
        log.timeStamp = String.valueOf(system.now().date()) + ' ' + String.valueOf(system.now().time());
        log.logType = 'METHOD_EXIT';
        log.logMsg += 'Usage Details: \n\tHeap Size           : ' + Limits.getHeapSize() + ' / ' + Limits.getLimitHeapSize() + '\n\tCPU Time            : ' + Limits.getCpuTime() + ' / ' + Limits.getLimitCpuTime() + '\n';
        log.logMsg += 'Exiting from Class: ' + logedinClass + '\nMethod: ' + logedinMethod;
        debug_logger.add(log);
    }
    
    public List<SMAX_Debug> getlog(){
        return debug_logger;
    }
    
    public integer getMethodCount(){
        return numberofmethods;
    }
    
    public void print(){
        for(SMAX_Debug log: debug_logger){
            system.debug(log.logType+' : '+log.logMsg);
        }
    }

}