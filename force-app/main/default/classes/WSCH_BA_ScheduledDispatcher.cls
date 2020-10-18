global class WSCH_BA_ScheduledDispatcher implements Schedulable {
    
    global String batchApexName = '';
  
    public WSCH_BA_ScheduledDispatcher(String name) {
        
        batchApexName = name;
    }
    
    public Interface WSCH_IScheduleDispatched 
    { 
        void execute(SchedulableContext sc, String batchApexName); 
    } 
    
    global void execute(SchedulableContext sc) 
    {
        Type targetType = Type.forName('WSCH_BA_ScheduleHandler');   
        if (targetType != null) {
            WSCH_IScheduleDispatched obj = (WSCH_IScheduleDispatched) targetType.NewInstance();
            obj.execute(sc, batchApexName);  
        } 
    }
}