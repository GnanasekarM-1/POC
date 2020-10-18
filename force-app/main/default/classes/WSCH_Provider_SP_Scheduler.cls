global class WSCH_Provider_SP_Scheduler implements Schedulable {
    
    public Interface WSCH_SP_IScheduleDispatched 
    { 
        void execute(SchedulableContext sc); 
    } 
     
    
    global void execute(SchedulableContext sc) 
    {
        Type targetType = Type.forName('WSCH_Provider_SP_SchedulerHandler');   
        if (targetType != null) {
            WSCH_SP_IScheduleDispatched obj = (WSCH_SP_IScheduleDispatched) targetType.NewInstance();
            obj.execute(sc);  
        } 
    }
        
     
    global void startSyncScheduler(){
      
     WSCH_CommonUtils.startSyncScheduler();
     
    }
       
}