/**
    Scheduler to get the work order updates from SP.
**/
global class WSCH_Provider_SP_WOUpdatesScheduler implements Schedulable{

    public Interface WSCH_SP_IScheduleDispatched
    {
        void execute(SchedulableContext sc);
    }

    global void execute(SchedulableContext sc)
    {
        Type targetType = Type.forName('WSCH_Provider_SP_WOUpdatesSchHandler');
        if (targetType != null) {
            WSCH_SP_IScheduleDispatched obj = (WSCH_SP_IScheduleDispatched) targetType.NewInstance();
            obj.execute(sc);
        }
    }

    global void startUpdatesWOScheduler(){
    	//Start the batch Apex in next 10 seconds.
        WSCH_Provider_SP_WOUpdatesSchHandler.startBatchApex(10);
    }
}