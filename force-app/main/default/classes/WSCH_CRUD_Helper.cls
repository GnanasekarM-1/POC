/* The purpose of this class is to perform CRUD(Create, Retrieve, Update, Delete) operations in System Mode, i.e EXPLICIT Without Sharing. 
 */
public without sharing class WSCH_CRUD_Helper{      //SDL-SVMX-WITH-SHARING-NOT-ENFORCED-BY-DESIGN

    public static Event fetchSFEventObjectById(String eventId) {
        WSCH_AuditLogger.debug('WSCH_CRUD_Helper::fetchSFEventObjectById:eventId- '+eventId);
        List<Event> lstEventObj = [Select Id, Subject, StartDateTime, EndDateTime, Owner.Id, OwnerId, DurationInMinutes, Type, SVMXC__Service_Duration__c, SVMXC__SM_Optimizer_Message_Creation_Date_Time__c From Event WHERE Id = :eventId];
        WSCH_AuditLogger.debug('WSCH_CRUD_Helper::fetchSFEventObjectById:lstEventObj- '+lstEventObj);
        if(!lstEventObj.isEmpty()){
            return lstEventObj[0];
        }
        return null;
    }
    //This overloaded method takes a string custom field for SFEvent object as a parameter and returns the record containing this new custom field
    public static Event fetchSFEventObjectById(String eventId, String sfEventCustomField) {
        WSCH_AuditLogger.debug('WSCH_CRUD_Helper::fetchSFEventObjectById:eventId- '+eventId);
        List<Event> lstEventObj = new List<Event>();
        String strQuery = 'Select Id, Subject, StartDateTime, EndDateTime, Owner.Id, OwnerId, DurationInMinutes, Type,SVMXC__Service_Duration__c' + sfEventCustomField + ' From Event WHERE Id = :eventId';
        lstEventObj = Database.query(strQuery);
        WSCH_AuditLogger.debug('WSCH_CRUD_Helper::fetchSFEventObjectById:lstEventObj- '+lstEventObj);
        if(!lstEventObj.isEmpty()){
            return lstEventObj[0];
        }
        return null;
    }
    public static List<Event> fetchListSFEvent(Set<String> setIds){
        List<Event> lstEventObj = new List<Event>(); 
        String strQuery = 'Select Id, Subject, StartDateTime, EndDateTime, Owner.Id, OwnerId, DurationInMinutes, Type,SVMXC__Service_Duration__c, SVMXC__SM_Optimizer_Message_Creation_Date_Time__c From Event WHERE Id IN :setIds';
        lstEventObj = Database.query(strQuery);
        return lstEventObj;
    }
    public static void upsertEvents(Event sfEvent){
        WSCH_AuditLogger.debug('WSCH_CRUD_Helper::upsertEvents:sfEvent- '+sfEvent);
        if(sfEvent != null){
            Database.upsert(sfEvent);
        }
    }
    public static void deleteEvents(SObject sObjEvent){
        WSCH_AuditLogger.debug('WSCH_CRUD_Helper::deleteEvents:sObjEvent- '+sObjEvent);
        if(sObjEvent != null){
            Database.delete(sObjEvent);
        }
    }
    public static void deleteListEvents(List<SObject> lstSObject){
        WSCH_AuditLogger.debug('WSCH_CRUD_Helper::deleteListEvents:lstSObject Size- '+lstSObject.size());
        if(lstSObject != null && lstSObject.size() > 0){        
            Database.DeleteResult[] delList = Database.delete(lstSObject, false);

            for(Database.DeleteResult dList : delList) {
                if (!dList.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dList.getErrors()) {
                        WSCH_AuditLogger.debug('WSCH_CRUD_Helper::deleteListEvents: '+err.getMessage() +' : '+err.getFields());
                    }
                }
            }
        }
    }
    public static void upsertListEvents(List<SObject> lstUpdSObject){
        WSCH_AuditLogger.debug('WSCH_CRUD_Helper::upsertListEvents:lstSObject Size- '+lstUpdSObject.size());
        if(lstUpdSObject != null){
            Database.UpsertResult[] upsList = Database.upsert(lstUpdSObject, false);

            for(Database.UpsertResult uList : upsList) {
                if (!uList.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : uList.getErrors()) {
                        WSCH_AuditLogger.debug('WSCH_CRUD_Helper::upsertListEvents: '+err.getMessage() +' : '+err.getFields());
                    }
                }
            }
        }
    }
    public static List<sObject> fetchSObject(String sfdcId, String strFields, String objName) {
        WSCH_AuditLogger.debug('WSCH_CRUD_Helper::fetchSFEventObject:eventId- '+sfdcId + ' :strFields-' + strFields + ' :objName' + objName);
        String strQuery = '';
        List<sObject> lstSObj = new List<sObject>();
        If(String.isNotBlank(strFields)){
            strQuery = 'SELECT Id, ' + strFields + ' FROM '+ objName + ' WHERE ID = :sfdcId';
            WSCH_AuditLogger.debug('WSCH_CRUD_Helper::fetchSFEventObject:strQuery- '+strQuery);
            lstSObj = Database.query(strQuery);
        }
        WSCH_AuditLogger.debug('WSCH_CRUD_Helper::fetchSFEventObject:lstSObj Size- '+lstSObj.size());
        if(!lstSObj.isEmpty()){
            return lstSObj;
        }
        
        return null;
    }
}