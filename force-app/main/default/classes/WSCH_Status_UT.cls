@isTest
public class WSCH_Status_UT {

	static testMethod void testWSCH_Status(){
        Test.startTest();
            WSCH_Status status = new WSCH_Status();
        	try {
                	insert new Account();
				}catch (Exception ex) {
					status.exceptionObj = ex;
					status.apiName = 'myTestAPI';
                    system.assertEquals(ex.getMessage(), status.exceptionObj.getMessage());
                    system.assertEquals('myTestAPI', status.apiName);
                }
        Test.stopTest();
    }
}