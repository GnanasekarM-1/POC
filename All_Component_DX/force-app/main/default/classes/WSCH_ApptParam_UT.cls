@isTest
public class WSCH_ApptParam_UT {
    
    static testMethod void testWSCH_ApptParam(){
        Test.startTest();
            WSCH_ApptParam apptParam = new WSCH_ApptParam();
            apptParam.startDateTime = system.now();
            apptParam.endDateTime = system.now();
        	System.assertEquals(system.now(), apptParam.endDateTime);
        	System.assertEquals(system.now(), apptParam.startDateTime);
        Test.stopTest();
    }

}