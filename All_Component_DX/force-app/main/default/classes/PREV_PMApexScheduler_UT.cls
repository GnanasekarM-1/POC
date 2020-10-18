@isTest(SeeAllData=true)
private with sharing class PREV_PMApexScheduler_UT 
{
    static testMethod void PREV_PMApexScheduler_Test() 
    {
        SVMXC.PREV_PMApexScheduler PMObject = new SVMXC.PREV_PMApexScheduler(); 
        SchedulableContext SC;
        PMObject.execute(SC);
        system.assert(PMObject.execute(SC)==null);
    }
}