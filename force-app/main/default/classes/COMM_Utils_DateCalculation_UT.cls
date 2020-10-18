@isTest
private class COMM_Utils_DateCalculation_UT 
{
    static testMethod void COMM_Utils_DateCalculation_UT()
    {
        
        SVMXC.COMM_Utils_DateCalculation obj = new COMM_Utils_DateCalculation();
        test.startTest();
        Long intSecondsToConvert = 12345678;
        Long intSeconds  = 12223; 
        Long days = 12;
        Long intTotalSeconds = 12344;
        Long hours  = 123;
        system.assert(obj.convertSecondsToHHMMSS(intSecondsToConvert)!=null,'getTargetRecType assertion failed');
        system.assert(obj.convertHours(intSeconds,days)!=null,12321312);
        system.assert(obj.convertDay(intSeconds)!=null,12321312);
        system.assert(obj.convertMinutes(intSeconds)!=null,12321312);
        system.assert(obj.getRemainingSeconds(intTotalSeconds)!=null,12321312);
        system.assert(obj.getRemainingMinutes(intSeconds,days,hours)!=null,12321312);
        system.assert(obj.getCountDown(intSecondsToConvert)!=null,12321312);
        test.stopTest();
        
    }
}