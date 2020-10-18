/**
 * SFM Event Delivery service implementation
 *
 * @author      Eric Ingram
 * @date        02.22.2013 
 */
 /* Security Scanned */
public class SFMEventDeliveryServiceImpl extends SFMEventDeliveryServiceBase {

    public SFMEventDeliveryServiceImpl(RestRequest req, RestResponse res){
        super(req, res);
    }
    
    public SFMEventDeliveryServiceImpl(){
    }
    
    override public Object getData() {
    
        return getDataInternal();
    }
    
    public Object getDataInternal() {
        
        // construct response
        DataResponse result = new DataResponse();
        result.events = getEventData();
        result.users = getUserData(result.events);
        //result.tasks = getTaskData();
        result.userinfo = getUserInfo();
        result.success = 'true';
        
        return result;
    }
    
    public Event[] getEventData() {
        
        // get all events
        return [
            SELECT
                Description,EndDateTime,Id,IsAllDayEvent,IsChild,
                IsPrivate,IsRecurrence,Location,OwnerId,RecurrenceActivityId,
                RecurrenceDayOfMonth,RecurrenceDayOfWeekMask,RecurrenceEndDateOnly,
                RecurrenceInstance,RecurrenceInterval,RecurrenceMonthOfYear,RecurrenceStartDateTime,
                RecurrenceType,ShowAs,StartDateTime,Subject,WhatId,WhoId
                FROM Event
        ];
    }
    
    public User[] getUserData(Event[] events) {
        
        // get users matching events
        List<String> userIds = new List<String>();
        for (Event e :events) {
            userIds.add(e.OwnerId);
        }
        return [
            SELECT
                Id,FirstName,LastName
                FROM User
                WHERE Id IN :userIds
        ];
    }
    
   /* public Work_Order_Task__c[] getTaskData() {
        
        // get all work order tasks
        return [
            SELECT
                Id,IsDeleted,LastActivityDate,OwnerId,Task_Completed__c,Task_Description__c,
                Task_Order__c,Tech_Description__c,Work_Order__c
                FROM Work_Order_Task__c
        ];
    }*/
    
    public Object getUserInfo() {
    
        // get userifo response
        return new UserInfoResponse();
    }
    
    public class DataResponse {
        public Event[] events;
        public User[] users;
        //public Work_Order_Task__c[] tasks;
        public Object userinfo;
        public String success;
    }
    
    public class UserInfoResponse {
        public String UserId;
        public String DateFormat;
        public String Language;
        public UserInfoResponse(){
            UserId = UserInfo.getUserId();
            Language = UserInfo.getLanguage();
            DateFormat = SVMXC.DCON_Configuration_WS.DCON_GetLocalDate_WS(UserId);  
        }
    }
    
    public class DataRequest {
        // TODO?
    }
}