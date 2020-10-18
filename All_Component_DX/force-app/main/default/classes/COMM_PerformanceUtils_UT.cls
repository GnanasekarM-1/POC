@isTest
private class COMM_PerformanceUtils_UT 
{
    static testMethod void COMM_PerformanceUtils_UnitTest() 
    {
        Case acs = new Case();
        insert acs;
        
        COMM_PerformanceUtils util = new COMM_PerformanceUtils();
        util.isCreateLog = true;
        util.emailID = 'abc@abc.com';
        COMM_PerformanceUtils.stop('methodID');
        COMM_PerformanceUtils.start('methodID');
        COMM_PerformanceUtils.stop('methodID');
        util.end(string.valueOf(acs.Id), 'CASE-PROCESS');
        util.begin();
        COMM_PerformanceUtils.stop('methodID');
        COMM_PerformanceUtils.start('methodID');
        COMM_PerformanceUtils.stop('methodID');
        COMM_PerformanceUtils.start('methodID');
        COMM_PerformanceUtils.stop('methodID');
        util.end(string.valueOf(acs.Id), 'CASE-PROCESS');
        util.end(string.valueOf(acs.Id), 'CASE-PROCESS', 'abc@abc.com');
        util.begin();
        COMM_PerformanceUtils.stop('methodID');
        COMM_PerformanceUtils.start('methodID');
        COMM_PerformanceUtils.stop('methodID');
        util.end(string.valueOf(acs.Id), 'CASE-PROCESS', 'abc@abc.com');
        
        COMM_PerformanceUtils util2 = new COMM_PerformanceUtils();
        COMM_PerformanceUtils.start('methodID');
    }
}