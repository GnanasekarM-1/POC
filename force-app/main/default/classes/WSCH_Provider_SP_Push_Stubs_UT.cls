/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class WSCH_Provider_SP_Push_Stubs_UT {

    static testMethod void myUnitTest() {
        WSCH_Provider_SP_Push_Stubs objPushStubs = new WSCH_Provider_SP_Push_Stubs();
        
            WSCH_Provider_SP_Push_Stubs.AtRisk atRisk = new WSCH_Provider_SP_Push_Stubs.AtRisk();
            atRisk.offset = 1;
            atRisk.type = 'type';
            
            WSCH_Provider_SP_Push_Stubs.Booking booking = new WSCH_Provider_SP_Push_Stubs.Booking();
            booking.arr = 'arr';
            booking.end_x = 'end_x';
            booking.start = 'start';
            booking.tech = 'tech';
            
            WSCH_Provider_SP_Push_Stubs.PushRequest pushReq = new WSCH_Provider_SP_Push_Stubs.PushRequest();
            pushReq.rowver = 1;
            pushReq.state = 'state';
            pushReq.workItems = new List<WSCH_Provider_SP_Push_Stubs.WorkItem>();
            
            WSCH_Provider_SP_Push_Stubs.Task task = new WSCH_Provider_SP_Push_Stubs.Task();
            task.action = 'action';
            task.tied = true;
            
            WSCH_Provider_SP_Push_Stubs.WorkItem workItem = new WSCH_Provider_SP_Push_Stubs.WorkItem();
            workItem.atRisk = new WSCH_Provider_SP_Push_Stubs.AtRisk();
            workItem.booking = new WSCH_Provider_SP_Push_Stubs.Booking();
            workItem.id = 'id';
            workItem.task = new WSCH_Provider_SP_Push_Stubs.Task();
            workItem.type = 'type';
            workItem.workType = new WSCH_Provider_SP_Push_Stubs.WorkType();
            workItem.pullState = 'state';
            
      WSCH_Provider_SP_Push_Stubs.WorkType workType = new WSCH_Provider_SP_Push_Stubs.WorkType();
      workType.dur = 1;
      workType.name = 'name';
        
    }
}