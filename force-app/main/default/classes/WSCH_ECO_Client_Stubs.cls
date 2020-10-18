/**
  * This is the stub class required to parse request json from server and update client objects.
 */
public with sharing class WSCH_ECO_Client_Stubs {
    // Job notification Web Service request from OptiMax server
    public class JobNotificationRequest_WP
    { 
        public String dispatchProcessGuid {get; set;}
        public String territoryGuid {get; set;}
        public String orgGuid {get; set;}
        public String jobInstanceGuid {get; set;}
        public List<Params_WP> jobDetails = new List<Params_WP>();
        public String operation {get; set;}
    }
    
    // Technician horizion update Web Service request from OptiMax server
    public class TechnicianHorizonUpdateRequest_WP
    { 
        public String dispatchProcessGuid {get; set;}
        public String territoryGuid {get; set;}
        public String operation {get; set;}
    }

    /**
     * Type : Wrapper Class
     * Used : "JobNotificationRequest_WP" Wrapper Class
     * Desc : This is an additional parameter
     */
    public class Params_WP
    {
        public String name {get; set;}
        public String value {get; set;}
    }  
    // ex: {"name":"Status","value":"Failure"} 
    // ex: {"name":"errorMsg","value":"Server threw unknow exception"} 

    public class ExecuteJobRequest_WP
    {
        public String jobInstanceGuid {get; set;}//OrgId-DPId-TerritoryId
        public String jobInstanceId {get; set;} 
        public List<String> workOrderIds {get; set;}
        public List<String> resourceIds {get; set;}
        public List<String> eventIds {get; set;} //null
        public Map<String, String> parameters {get; set;}
        public List<String> dependencyGrpIds {get; set;}
    }
    
    public class SchedulingInputRequest_WP
    {
        public String jobInstanceGuid {get; set;}
        public List<String> Ids {get; set;}
        
    } 
    
    
}