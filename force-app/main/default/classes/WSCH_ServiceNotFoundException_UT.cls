@isTest
public class WSCH_ServiceNotFoundException_UT {
    static testMethod void testServiceNotFoundException(){
        WSCH_ServiceNotFoundException servExcep = new WSCH_ServiceNotFoundException('Exception1', 'Exception2','Exception3','Exception4','Exception5');
    }
}