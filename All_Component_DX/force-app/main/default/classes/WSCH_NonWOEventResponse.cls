public with sharing class WSCH_NonWOEventResponse {
    
    private List<SVMXC__SVMX_Optimizer__c> events = new List<SVMXC__SVMX_Optimizer__c>();
    
    private List<WSCH_TechnicianEvent> techEvents = new List<WSCH_TechnicianEvent>();
    
    public List<SVMXC__SVMX_Optimizer__c> getEvents() {
        return events;
    }
    
    public void setEvents(List<SVMXC__SVMX_Optimizer__c> events) {
        this.events = events;
    }
    
    public List<WSCH_TechnicianEvent> getTechEvents() {
        return techEvents;
    }
    
    public void setTechEvents(List<WSCH_TechnicianEvent> techEvents) {
        this.techEvents = techEvents;
    }

}