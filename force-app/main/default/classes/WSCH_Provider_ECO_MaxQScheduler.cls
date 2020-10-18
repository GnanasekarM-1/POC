/**
    Scheduler to Process work order updates and make callout to OptiMax.
**/

global class WSCH_Provider_ECO_MaxQScheduler implements Schedulable{

    public Interface WSCH_ECO_IScheduleDispatched
    {
        void execute(SchedulableContext sc);
    }

    global void execute(SchedulableContext sc)
    {
        Type targetType = Type.forName('WSCH_Provider_ECO_MaxQSchHandler');
        if (targetType != null) {
            WSCH_ECO_IScheduleDispatched obj = (WSCH_ECO_IScheduleDispatched) targetType.NewInstance();
            obj.execute(sc);
        }
    }

    global void startMaxQScheduler(){
        //Start the Schedule Apex in next 10 seconds.
        WSCH_Provider_ECO_MaxQSchHandler.startMaxQCronJob(30);
    }
}