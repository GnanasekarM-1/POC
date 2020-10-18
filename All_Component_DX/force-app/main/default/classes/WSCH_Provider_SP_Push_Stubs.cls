public with sharing class WSCH_Provider_SP_Push_Stubs {

  public class Task {
      public string action { get; set; }
      public boolean tied { get; set; }
  }
  
  public class Booking {
      public string start { get; set; }
      public string end_x { get; set; }
      public string arr { get; set; }
      public string tech { get; set; }
  }
  
  public class AtRisk  {
      public integer offset { get; set; }
      public string type { get; set; }
  }
  
  public class WorkType {
      public string name { get; set; }
      public integer dur { get; set; }
  }

  public class WorkItem {
      public string id { get; set; }
      public string type { get; set; }
      public Task task { get; set; }
      public Booking booking { get; set; }
      public AtRisk atRisk { get; set; }
      public WorkType workType {get; set;}
      public string pullState {get; set;}
  }
  
  public class PushRequest {
      public string changeTime;
      public List<WorkItem> workItems { get; set; }
      public integer rowver { get; set; }
      public string state {get; set;}
  }
}