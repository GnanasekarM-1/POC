@isTest
public with sharing class WSCH_Customizabilty_UT {

  public class WSCH_CustomBookJobHook implements WSCH_ICalloutHook {
  
      public void configure(){
        
      }
      
      public void beforeCall(WSCH_IRequest request, List<SVMXC__Service_Order__c> workorderList,WSCH_Status status) {
        WSCH_Provider_SP_StubsV91.JobBookRequest newRequest = (WSCH_Provider_SP_StubsV91.JobBookRequest)request;
        system.debug('WSCH_CustomBookJobHook::beforeCall():: account Hours'+ newRequest.accHoursPatts.accHoursPatt);
        
          //set horizon dates for access hours
          Datetime startTime=Datetime.now().addDays(9);
          Datetime endTime = startTime.addDays(7); 
                
      WSCH_Provider_SP_StubsV91.AccHoursPatt accHrPatt = new WSCH_Provider_SP_StubsV91.AccHoursPatt();
          accHrPatt.dateRange = new WSCH_Provider_SP_StubsV91.DateRange();
          accHrPatt.dateRange.start = WSCH_DateUtils.formatDate(startTime.dateGmt(),'GMT','YYYY-MM-dd');
          accHrPatt.dateRange.end_x = WSCH_DateUtils.formatDate(endTime.dateGmt(),'GMT','YYYY-MM-dd');
          accHrPatt.daysAndTimes = WSCH_Provider_SP_DataMapper.getDayTimePeriod(workorderList[0]);
          
          List<WSCH_Provider_SP_StubsV91.AccHoursPatt> accHoursPattLst = newRequest.accHoursPatts.accHoursPatt;
          accHoursPattLst.add(accHrPatt);
          newRequest.accHoursPatts.accHoursPatt = accHoursPattLst;
        //request=newRequest;
      }
      
      public void afterCall(WSCH_IResponse response, List<SVMXC__Service_Order__c> workorderList,WSCH_Status status) {
      }
  }

  static testMethod void testBookJobHook(){
    
  }
  
  static testMethod void testBookJobHookException(){
    
  }
}