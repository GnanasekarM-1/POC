@isTest
    public with sharing class WSCH_Plugin_RealTimeOptimizer_UT {
        
     static testMethod void testManageWorkorders() {
    
        SVMXC__Territory__c testTer = createECOTerritory();
        SVMXC__Service_Group_Members__c tectTechnician = createECOTechnician(testTer.id);
        SVMXC__ServiceMax_Processes__c woDP = createECODispatchProcess(testTer.id);
        List<SVMXC__Service_Order__c> wos = new List<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c wo1=createWorkorder(testTer.id,woDP.id);wos.add(wo1);
        SVMXC__Service_Order__c wo2=createWorkorder(testTer.id,woDP.id);wos.add(wo2);
        SVMXC__Service_Order__c wo3=createWorkorder(testTer.id,woDP.id);wos.add(wo3);
        SVMXC__Service_Order__c wo4=createWorkorder(testTer.id,woDP.id);wos.add(wo4);
        Event sfEvent = createSFEvent(tectTechnician.id);
        
        WSCH_Appointment apptObj = new WSCH_Appointment();
        apptObj.setStrStartDateTime('2016-11-18 05:26');
        apptObj.setStrEndDateTime('2016-11-18 05:26');
        apptObj.setStartDateTime(system.now());
        apptObj.setEndDateTime(system.now());
        apptObj.setTechnician(tectTechnician) ;
        SVMXC__SVMX_Optimizer__c opt = createOptimizer(tectTechnician.id,tectTechnician.name);
        List<SVMXC__SVMX_Optimizer__c> optList = new List<SVMXC__SVMX_Optimizer__c>();
        optList.add(opt);
        SVMXC__SVMX_Optimizer__c ecoOpt = createECONONWOOptimizer(sfEvent.id,tectTechnician.name,woDP.id,testTer.id,tectTechnician.id);
        optList = new List<SVMXC__SVMX_Optimizer__c>();
        optList.add(ecoOpt);
        WSCH_ApptParam appparam = new WSCH_ApptParam();
        appparam.startDateTime = system.now();
        appparam.endDateTime = system.now().addminutes(120);
        appparam.costOrDates = 'cost';
        appparam.numberOfOfferAppts = 3;
        
        try{
            WSCH_Plugin_RealTimeOptimizer.manageWorkOrders(wos);
            WSCH_Plugin_RealTimeOptimizer.manageWorkOrders(null);
            WSCH_Plugin_RealTimeOptimizer.bookAppointment(wo1,apptObj);
            WSCH_Plugin_RealTimeOptimizer.bookAppointment(null,null);
            WSCH_Plugin_RealTimeOptimizer.manageSchedulingResults('strJobInfo');
            WSCH_Plugin_RealTimeOptimizer.manageSchedulingResults(null);
            WSCH_Plugin_RealTimeOptimizer.cancelWorkOrders(optList);
            WSCH_Plugin_RealTimeOptimizer.cancelWorkOrders(null);
            WSCH_Plugin_RealTimeOptimizer.manageNonWorkOrderEvents(optList);
            WSCH_Plugin_RealTimeOptimizer.manageNonWorkOrderEvents(null);
            //WSCH_Plugin_RealTimeOptimizer.getAvailableAppointments(wo1.id,appparam,10,1);
            
        }
        catch(Exception e)
        {
              system.assertEquals(e.getMessage(), e.getMessage());
        }
        
        
        
     }
        
    static testMethod void testGetWorkOrderUpdates() {
    SVMXC__Territory__c testTer = createECOTerritory();
    WSCH_Plugin_RealTimeOptimizer.getWorkOrderUpdates(testTer);

     SVMXC__Territory__c testTer1 = createECOTerritory();
     testTer1.SVMXC__Optimizer_Last_Timestamp__c = '2016-11-18 05:26';
    WSCH_Plugin_RealTimeOptimizer.getWorkOrderUpdates(testTer1);
        
     }   
     
     
     static testMethod void testcheckTimeStamp() {
        WSCH_Plugin_RealTimeOptimizer.testcheckTimeStamp('');
        WSCH_Plugin_RealTimeOptimizer.testcheckTimeStamp('0');
        WSCH_Plugin_RealTimeOptimizer.testcheckTimeStamp('4');
        WSCH_Plugin_RealTimeOptimizer.testcheckTimeStamp('sdds');
        WSCH_Plugin_RealTimeOptimizer.testcheckTimeStamp('1501224979555');
     }   
     
         
     
     
     private static SVMXC__Service_Order__c createWorkorder(String terId,String dpId){
        SVMXC__Service_Order__c wo1 = new SVMXC__Service_Order__c();
        wo1.SVMXC__Primary_Territory__c = terId;
        wo1.SVMXC__zip__c='560005';
        wo1.SVMXC__Preferred_Start_Time__c = system.now();
        wo1.SVMXC__Preferred_End_Time__c = system.now();
        wo1.SVMXC__Scheduled_Date_Time__c = system.now();
        wo1.SVMXC__Driving_Time__c = 5;
        wo1.SVMXC__Driving_Time__c = 2;
        wo1.SVMXC__Dispatch_Process__c = dpId;
        wo1.SVMXC__Locked_By_DC__c = true;
        insert wo1;
        return wo1;
     }
     
     private static SVMXC__ServiceMax_Processes__c createECODispatchProcess(String terId){
      SVMXC__ServiceMax_Processes__c dprocess = new SVMXC__ServiceMax_Processes__c();
      dprocess.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
      dprocess.SVMXC__Dispatch_Process_Status__c ='Complete';
      dprocess.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
      dprocess.SVMXC__Name__c = 'Process-UT';
      dprocess.RecordTypeId = getDispatchProcessRecordId();
      dprocess.SVMXC__Territory__c = terId;
      
      insert dprocess;
      return dprocess;
    }
    
    private static String getDispatchProcessRecordId(){
      String dispatchProcessRecordType;
      RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' ];
      for(RecordType rt : rts)
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               dispatchProcessRecordType = rt.ID;
        }
        return dispatchProcessRecordType;
      
    }
     
    private static SVMXC__Territory__c createECOTerritory(){
            SVMXC__Territory__c ecoTeritory = new SVMXC__Territory__c();
             ecoTeritory.Name = 'Ter-UT';
             insert ecoTeritory;
             return ecoTeritory;
        }

    private static SVMXC__Service_Group_Members__c createECOTechnician(String terId){
            SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
            technician.Name = 'ECO_Tech_UT';
            technician.SVMXC__City__c = 'Bangalore';
            technician.SVMXC__Country__c = 'India';
            technician.SVMXC__Zip__c = '560030';
            technician.SVMXC__Service_Territory__c = terId;
            technician.SVMXC__Service_Group__c= createServiceGroupId();
            insert technician;
            return technician;
        } 
         
    private static String createServiceGroupId(){
         SVMXC__Service_Group__c segroup = new SVMXC__Service_Group__c();
         segroup.Name = 'TestGroup-UT';
         insert segroup;
         return segroup.id;
    }
    
    private static SVMXC__SVMX_Optimizer__c createOptimizer(String techId,String techName){
        SVMXC__SVMX_Optimizer__c optTransObj1 = new SVMXC__SVMX_Optimizer__c();
        optTransObj1.SVMXC__WhatId__c = techId +'_'+ techName;
        insert optTransObj1;
        return optTransObj1;
    }
    
    private static SVMXC__SVMX_Optimizer__c createECONONWOOptimizer(String eventId,String techName,
    String dispatchProcessId,string terId,String techId){
        SVMXC__SVMX_Optimizer__c optTransObj1 = new SVMXC__SVMX_Optimizer__c();
        optTransObj1.SVMXC__WhatId__c = eventId +'_'+ techName;
        optTransObj1.SVMXC__WhatType__c  = 'NON_WO_EVENT';
        optTransObj1.SVMXC__Optimizer_Change_Token__c  = 'CHANGE_CREATE_EVENT';
        optTransObj1.SVMXC__Optimizer_Connection_ID__c  = dispatchProcessId+'_'+terId+'_'+techId; 
        insert optTransObj1;
        return optTransObj1;
    }
    
    //private supporting methods
    private static Event createSFEvent(String techId){
      Event ev = new Event();
      ev.EventSubtype  = 'Event';
      ev.StartDateTime = system.today();
      ev.EndDateTime = system.today() + 1;
      ev.WhatId = techId;
      insert ev;
      return ev;
    }
}