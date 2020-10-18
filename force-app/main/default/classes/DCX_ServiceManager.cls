public with sharing class DCX_ServiceManager {
    
    public INTF_WebServicesDef.INTF_Response getMapData(string objectname,string viewId,Integer recordlimit,double latitude,double longitude,double radius) {
        return DCX_MapServiceManager.getMapData(objectname,viewId,recordlimit,latitude,longitude,radius);
    }
    
    /*public static DCX_SchedulerServiceManager.SchedulerDataDCx fetchSchedulerData() {
        return DCX_SchedulerServiceManager.fetchSchedulerData();
    }*/
/*    
    public static List<DCxSchedulerServiceManager.Technician_WP> fetchTechnicians(String SearchType,List<String> ServiceTeamTerr) {
        returnDCX_SchedulerServiceManager.fetchTechnicians(searchType,ServiceTeamTerr);
    }
*/
    public static  DCX_CommonServiceManager.UserSetting fetchUserSettings() {
        return  DCX_SettingServiceManager.fetchUserSettings();
    }
    
    public static  DCX_WOServiceManager.workorderDCx retrieveWorkOrders(String viewId, Boolean isInitial,Boolean isQueue, List<String> dispatchStatus, List<String> invisibleWorkOrderIds, String pageSize, String sortField, Boolean isAscending, String searchField, String searchFieldValue) {
        return  DCX_WOServiceManager.retrieveWorkOrders(viewId,isInitial,isQueue,dispatchStatus,invisibleWorkOrderIds,pageSize,sortField,isAscending,searchField,searchFieldValue);
    }
    
   /* public static  DCX_WOServiceManager.workorderDCx retrieveWorkOrdersJsr(String viewId, Boolean isInitial, List<String> dispatchStatus, List<String> invisibleWorkOrderIds, String pageSize, String sortField, Boolean isAscending, String searchField, String searchFieldValue) {
        return  DCX_WOServiceManager.retrieveWorkOrders(viewId,isInitial,dispatchStatus,invisibleWorkOrderIds,pageSize,sortField,isAscending,searchField,searchFieldValue);
    }*/
    
    public static void saveUserSettings(String usrSettings) {
        DCX_SettingServiceManager.saveUserSettings(usrSettings);
    }
    
    /*public static DCX_EventServiceManager.DCxFetchLaunchEvents fetchEventsOnLaunch() {
        return DCX_EventServiceManager.fetchEventsOnLaunch();
    }*/

 /*   public static DCX_EventServiceManager.DCxEvents fetchEvents(String StartDate, String EndDate, String timeZoneDateTimeFormat, List<String> TechnicianIds) {
        return DCX_EventServiceManager.fetchEvents(StartDate, EndDate, timeZoneDateTimeFormat, TechnicianIds);
    }*/  
     public static DCX_EventServiceManager.DCxEvents fetchEvents(String UserId,String StartDate, String EndDate,String status, String timeZoneDateTimeFormat, List<String> TechnicianIds) {
        return DCX_EventServiceManager.fetchEvents1(UserId,StartDate, EndDate,status, timeZoneDateTimeFormat, TechnicianIds);
    }
    
    public static DCX_MetaDataServiceManager.metaDataSetting fetchMetaData() {
        return DCX_MetaDataServiceManager.fetchMetaData();
    }

    public static DCX_SettingServiceManager.EventHoverRules fetchEventHoverRules() {
        return DCX_SettingServiceManager.fetchEventHoverRules();
    }

    /*public static DCX_EventServiceManager.DCEvent_WO_WP createEvents(List<Event> lstEvent, String timeZone, list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue) {
        return DCX_EventServiceManager.createEvents(lstEvent,timeZone,lstKeyValue);
    }*/

    public static DCX_SettingServiceManager.SettingDCX fetchDCXSetting() {
        return  DCX_SettingServiceManager.retriveAppandUserSetting();
    }

     public static String eventSubject(String woIdandUserId) {
        return  DCX_EventServiceManager.eventSubject(woIdandUserId);
    }

     public static  DCX_WOServiceManager.workorderDCx singleWO(String viewId, Boolean isInitial) {
        return  DCX_WOServiceManager.singleWO(viewId,isInitial);
    }

}