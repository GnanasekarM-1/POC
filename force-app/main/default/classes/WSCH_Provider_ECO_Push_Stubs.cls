/** Stub class to parse the incoming push messages from Optimax ECO **/
public with sharing class WSCH_Provider_ECO_Push_Stubs {
    
/*  public class Task {
        public string action { get; set; }
        public boolean tied { get; set; }
    }*/
    
    public class Booking {
        public string start { get; set; }
        public string end_x { get; set; }
        public string arr { get; set; }
        public Double driveDuration { get; set; }
        public Double idleDuration { get; set; }
        public Double visitDuration { get; set; }
        public Double returnHomeDrivingTime {get; set;}     
        public string tech { get; set; }
    }
    
/*  public class AtRisk {
        public integer offset { get; set; }
        public string type { get; set; }
    }*/
    
/*  public class WorkType {
        public string name { get; set; }
        public integer dur { get; set; }
    }*/

    public class WorkItem {
        public string id { get; set; }
        public string type { get; set; }
    //    public Task task { get; set; }
        public Booking booking { get; set; }
    //    public AtRisk atRisk { get; set; }
    //    public WorkType workType {get; set;}
    //    public string pullState {get; set;}
        public string errorMsg {get; set;}
        public Double resolvedLatitude {get; set;}
        public Double resolvedLongitude {get; set;}
        public Boolean ignored {get; set;}
    }
    
    public class PushRequest {
        public string changeTime;
        public List<WorkItem> workItems { get; set; }
       // public integer rowver { get; set; }
        public string errorcode { get; set; }
        public string state {get; set;}
        public string jobId {get; set;} //DispatchProcessId_TerritoryId
    }
}