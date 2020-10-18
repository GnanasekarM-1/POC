/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @author Madhusudhan HK
 * @version 19.2000
 * @since 2019
 */
 //test command test

public virtual class DCX_ServiceBase extends DCX_RestBase

{
    public DCX_ServiceBase()   {}

    public DCX_ServiceBase(RestRequest req, RestResponse res)
    {
        super(req, res, 'svmx/DCX_ServiceIntf');
    }

    public virtual Object saveUserSettings(){return null;}
        public virtual Object fetchSchedulerData(){return null;}
            public virtual Object fetchEventsOnLaunch(){return null;}
    public virtual Object fetchEvents(){return null;}
    public virtual Object fetchMetaData(){return null;}
    // public virtual Object getSkills(){return null;}
     public virtual Object MCTMDetail(){return null;}
     public virtual Object techInfo(){return null;}
     public virtual Object keywordSearch(){return null;}
      public virtual Object retrievePageOfWorkOrders(){return null;}
    public virtual Object getViewWOCount(){return null;}
      public virtual Object getViewDefinition(){return null;}
       public virtual Object getViewData(){return null;}
       public virtual Object updateWOTech(){return null;}
       public virtual Object assignWOTeam(){return null;}
       public virtual Object assignWOTech(){return null;}
       public virtual Object unassignWO(){return null;}
       public virtual Object unassignJDMWO(){return null;}
       public virtual Object assignWOTOMutliTech(){return null;}
       public virtual Object unassignWOTOMutliTech(){return null;}
       public virtual Object resetWO(){return null;}
       public virtual Object getWOforMutliAssign(){return null;}
       public virtual Object getEventHover(){return null;}
       public virtual Object getDependencyDetails(){return null;}
       public virtual Object getDependencyCheck(){return null;}
       public virtual Object retriveWO(){return null;}
       public virtual Object fetchEventWOInfo(){return null;}
       public virtual Object fetchWOEvents(){return null;}
       public virtual Object fetchUpdatedEvents(){return null;}
       public virtual Object fetchDeletedEvents(){return null;}
       public virtual Object createEvents(){return null;}
       public virtual Object upsertEvents(){return null;}
       public virtual Object deleteEvents(){return null;}
       public virtual Object eventExistInBusinessHour(){return null;}
       public virtual Object eventSubjectDefinition(){return null;}
       public virtual Object fetchAllEvents(){return null;}
       public virtual Object fetchEventWarnings(){return null;}
       public virtual Object fetchOvernightEvents(){return null;}
       public virtual Object getTechWorkingHours() { return null; }
       public virtual Object getQualifiedTechList() { return null; }
       public virtual Object getListOfTechScheduled() {return null;}
       public virtual Object deployUserSetting() { return null; }
       public virtual Object restoreUserSetting() { return null; }
       public virtual Object getWObyIds() { return null; }
       public virtual Object retrieveWorkOrdersforIds() { return null; }
 
       public virtual Object fetchEvents1() { return null; }
       public virtual Object getEventHoverRules() { return null; }
       public virtual Object createLJSEvent() { return null; }
        public virtual Object listDispatcher() { return null; }
        public virtual Object fetchDCXSetting() { return null; }
        public virtual Object deleteAESEvent() { return null; }
        public virtual Object singleWODetails() { return null; }
        public virtual Object schedulerDataNew() { return null; }
        public virtual Object fetchTechnicianDetails() { return null;}
        public virtual Object fetchEventsAndWOInfo() { return null; }
        public virtual Object advTechSearch() { return null; }
        public virtual Object fetchDeltaEventsAndWOInfo() { return null; }
      public virtual Object retrieveEventIds() { return null; }
    public virtual Object retrieveEventsAndWOInfoForIds() { return null; }
    public virtual Object retrieveEventForIds() { return null; }

  /* public virtual Object getViews() { return getViews(); }
    public virtual Object fetchUserSettings() { return fetchUserSettings(); }
    public virtual Object getWorkorders() { return getWorkorders(); }
    public virtual Object getTags() { return getTags(); }
    public virtual Object getSettings() { return getSettings(); }   
    public virtual Object getWorkorderInfp() { return getWorkorderInfp(); }
    public virtual Object DCON_Retrieve_User_Settings_WS() { return DCON_Retrieve_User_Settings_WS(); }
    public virtual Object getWorkorderids() { return getWorkorderids(); }
    
    public virtual Object getTimeZones() { return getTimeZones(); }
    public virtual Object getLocalDate() { return getLocalDate(); }
    public virtual Object getSkillDetails() { return getSkillDetails(); }
    
    public virtual Object getObjectFieldList() { return getObjectFieldList(); }
    public virtual Object getTechnicians() { return getTechnicians(); }
    public virtual Object getTechDetails() { return getTechDetails(); }
    public virtual Object getTeam() { return getTeam(); }
    public virtual Object getTerritory() { return getTerritory(); }
    public virtual Object getEvents() { return getEvents(); }
    
    public virtual Object getGP1Response() { return getGP1Response(); }
    public virtual Object getServiceDocument() { return getServiceDocument(); }
   
    public virtual Object SFM_getObjectFieldList_WS() { return SFM_getObjectFieldList_WS(); }
  
    
    public virtual Object getDependencyDetails() { return getDependencyDetails(); }
    public virtual Object DCON_Update_User_Settings_WS() { return DCON_Update_User_Settings_WS(); }
   
   
//    public virtual Object fetchTechnicians() { return fetchTechnicians(); }
    public virtual Object getViewData_1() { return getViewData_1(); }
      public virtual Object deployUserSetting() { return deployUserSetting(); }*/
    
    
   override public Object invokeMethod(ComRestMethodInfo mi)
    {
long s2 = DateTime.Now().getTime();
        Object res = null;
        
        if(mi.MethodName.equals('saveUserSettings')) 
            res = saveUserSettings();
        else if(mi.MethodName.equals('schedulerData'))
            res = fetchSchedulerData();
        else if(mi.MethodName.equals('eventDataOnLaunch'))
            res = fetchEventsOnLaunch();
        else if(mi.MethodName.equals('eventData'))
            res = fetchEvents();
         else if(mi.MethodName.equals('metaData')) 
            res = fetchMetaData();
        //else if(mi.MethodName.equals('getSkills')) 
         //   res = getSkills();
        else if(mi.MethodName.equals('MCTMDetail')) 
            res = MCTMDetail();  
        else if(mi.MethodName.equals('techInfo')) 
            res = techInfo(); 
        else if(mi.MethodName.equals('keywordSearch')) 
            res = keywordSearch(); 
        else if(mi.MethodName.equals('pageOfWorkOrders')) 
            res = retrievePageOfWorkOrders();
        else if(mi.MethodName.equals('getViewWOCount')) 
            res = getViewWOCount();
        else if(mi.MethodName.equals('getViewDefinition')) 
            res = getViewDefinition();
        else if(mi.MethodName.equals('getViewData')) 
            res = getViewData();
        else if(mi.MethodName.equals('updateWOTech')) 
            res = updateWOTech();
        else if(mi.MethodName.equals('assignWOTeam')) 
            res = assignWOTeam();
        else if(mi.MethodName.equals('assignWOTech')) 
            res = assignWOTech();
        else if(mi.MethodName.equals('unassignWO')) 
            res = unassignWO(); 
        else if(mi.MethodName.equals('unassignJDMWO')) 
            res = unassignJDMWO();
        else if(mi.MethodName.equals('assignWOTOMutliTech')) 
            res = assignWOTOMutliTech(); 
        else if(mi.MethodName.equals('unassignWOTOMutliTech')) 
            res = unassignWOTOMutliTech();
        else if(mi.MethodName.equals('resetWO')) 
            res = resetWO(); 
        else if(mi.MethodName.equals('getWOforMutliAssign')) 
            res = getWOforMutliAssign();
        else if(mi.MethodName.equals('getEventHover')) 
            res = getEventHover(); 
        else if(mi.MethodName.equals('getDependencyDetails')) 
            res = getDependencyDetails();
        else if(mi.MethodName.equals('getDependencyCheck')) 
            res = getDependencyCheck(); 
        else if(mi.MethodName.equals('retriveWO')) 
            res = retriveWO();
        else if(mi.MethodName.equals('fetchEventWorkOrderInfo')) 
            res = fetchEventWOInfo(); 
        else if(mi.MethodName.equals('fetchWorkOrderEvents')) 
            res = fetchWOEvents();
        else if(mi.MethodName.equals('fetchUpdatedEvents')) 
            res = fetchUpdatedEvents();
        else if(mi.MethodName.equals('fetchDeletedEvents')) 
            res = fetchDeletedEvents(); 
        else if(mi.MethodName.equals('createEvents')) 
            res = createEvents();
        else if(mi.MethodName.equals('upsertEvents')) 
            res = upsertEvents(); 
        else if(mi.MethodName.equals('deleteEvents')) 
            res = deleteEvents();
        else if(mi.MethodName.equals('existInBusinessHour')) 
            res = eventExistInBusinessHour(); 
        else if(mi.MethodName.equals('eventSubjectDefinition')) 
            res = eventSubjectDefinition();
        else if(mi.MethodName.equals('eventSubjectDefinition')) 
            res = eventSubjectDefinition(); 
        else if(mi.MethodName.equals('fetchAllEvents')) 
            res = fetchAllEvents(); 
        else if(mi.MethodName.equals('fetchEventWarnings')) 
            res = fetchEventWarnings();
        else if(mi.MethodName.equals('fetchOvernightEvents')) 
            res = fetchOvernightEvents();
        else if(mi.MethodName.equals('getTechWorkingHours')) 
            res = getTechWorkingHours();
        else if(mi.MethodName.equals('getQualifiedTechList')) 
            res = getQualifiedTechList();
        else if(mi.MethodName.equals('getListOfTechScheduled')) 
            res = getListOfTechScheduled();
        else if(mi.MethodName.equals('deployUserSetting')) 
            res = deployUserSetting();
        else if(mi.MethodName.equals('restoreUserSetting')) 
            res = restoreUserSetting();
         else if(mi.MethodName.equals('getWObyIds')) 
            res = getWObyIds();
        else if(mi.MethodName.equals('retrieveWOForIds')) 
            res = retrieveWorkOrdersforIds();

        // else if(mi.MethodName.equals('fetchEvents1')) 
        //     res = fetchEvents1();
        else if(mi.MethodName.equals('getEventHoverRules')) 
            res = getEventHoverRules();
        else if(mi.MethodName.equals('createLJSEvent')) 
            res = createLJSEvent();
        else if(mi.MethodName.equals('listDispatcher')) 
            res = listDispatcher();
        else if(mi.MethodName.equals('fetchDCXSetting')) 
            res = fetchDCXSetting();
         else if(mi.MethodName.equals('deleteAESEvent')) 
            res = deleteAESEvent();
         else if(mi.MethodName.equals('singleWODetails')) 
            res = singleWODetails(); 
        else if(mi.MethodName.equals('schedulerDataNew'))
            res = schedulerDataNew();
        else if(mi.MethodName.equals('technicianDetails'))
            res = fetchTechnicianDetails(); 
        else if(mi.MethodName.equals('eventDataAndWOInfo'))
            res = fetchEventsAndWOInfo();
        else if(mi.MethodName.equals('advTechSearch'))
            res = advTechSearch();
        else if(mi.MethodName.equals('deltaEvents'))
            res = fetchDeltaEventsAndWOInfo();
        else if(mi.MethodName.equals('fetchEventIds'))
            res = retrieveEventIds();
        else if(mi.MethodName.equals('eventDataAndWOInfoForIds'))
            res = retrieveEventsAndWOInfoForIds();
        else if(mi.MethodName.equals('retrieveEventForIds'))
            res = retrieveEventForIds();
        else
            res = invokeMissingMethod();    
long s1 = DateTime.Now().getTime(); 
system.debug('ServiceBase time taken: '+(s1-s2));
        return res;
            
            
        /*
        if(mi.MethodName.equals('fetchUserSettings')) 
            res = fetchUserSettings();
        if(mi.MethodName.equals('getTags')) 
            res = getTags();
        else if(mi.MethodName.equals('getSettings')) 
            res = getSettings();
        else if(mi.MethodName.equals('getViews'))
            res = getViews();
        else if(mi.MethodName.equals('getWorkorders')) 
            res = getWorkorders();
            
        else if(mi.MethodName.equals('getWorkorderInfp')) 
            res = getWorkorderInfp();
        else if(mi.MethodName.equals('getWorkorderids')) 
            res = getWorkorderids();
       
        else if(mi.MethodName.equals('getTimeZones')) 
            res = getTimeZones();
        else if(mi.MethodName.equals('getLocalDate')) 
            res = getLocalDate();     
        else if(mi.MethodName.equals('getSkillDetails')) 
            res = getSkillDetails();    
        else if(mi.MethodName.equals('getObjectFieldList')) 
            res = getObjectFieldList();   
        else if(mi.MethodName.equals('getTechnicians')) 
            res = getTechnicians();      
        else if(mi.MethodName.equals('getTechDetails')) 
            res = getTechDetails();   
        else if(mi.MethodName.equals('getTeam')) 
            res = getTeam(); 
        else if(mi.MethodName.equals('getTerritory')) 
            res = getTerritory();  
        else if(mi.MethodName.equals('getEvents')) 
            res = getEvents(); 
        else if(mi.MethodName.equals('getGP1Response')) 
            res = getGP1Response();
        
        else if(mi.MethodName.equals('SFM_getObjectFieldList_WS')) 
            res = SFM_getObjectFieldList_WS();
        
        
        else if(mi.MethodName.equals('getDependencyDetails')) 
            res = getDependencyDetails();
        else if(mi.MethodName.equals('getTechWorkingHours')) 
            res = getTechWorkingHours();
        

        else if(mi.MethodName.equals('getViewData_1')) 
            res = getViewData_1();
        else if(mi.MethodName.equals('deployUserSetting')) 
            res = deployUserSetting();*/
        
            
        
    }
}