Global with sharing class WSCH_LTP_Scheduling_Stubs {
/**
    This is the stub class required to create request and parsing into json for Rest webservice invoke.
**/
    public static DCON_Utils dcUtils = new DCON_Utils();
    
    public class InitJobRequest_WP
    { 
        public String dispatchProcessGuid {get; set;}
        public String territoryGuid {get; set;}
        public String orgGuid {get; set;}
        public String jobInstanceId {get; set;}
        public String dispatchMethod {get; set;}
    }
    
    global class InitJobResponse_WP
    {
        public String jobInstanceId {get; set;}
        public String jobInstanceGuid {get; set;}
    }

    public class ExecuteJobRequest_WP
    {
        public String jobInstanceGuid {get; set;}
        public String jobInstanceId {get; set;}
        public List<String> workOrderIds {get; set;}
        public List<String> resourceIds {get; set;}
        public List<String> eventIds {get; set;}
        public Map<String, String> parameters {get; set;}
        public List<NodeColor_WP> nodeColors {get; set;}
    }

    public class NodeColor_WP
    {
        public Integer id{get; set;}
        public String colorName{get; set;}
        public String percentage{get; set;}
    }

     global class Response_WP
    {
        public String status{ get; set; }
        public String message{ get; set; }
    }
    
    global class SchedulingInputRequest_WP
    {
        public String jobInstanceGuid {get; set;}
        public List<String> Ids {get; set;}
        
    }
    
    global class SchedulingInputResponse_WP
    {
        public List<WorkOrder_WP> workOrders = new List<WorkOrder_WP>();
        public List<Technician_WP> resources = new List<Technician_WP>();
        public List<TechniciansEvent_WP> events= new List<TechniciansEvent_WP>();
    }

    global class SchedulingOutputRequest_WP
    {
        public String jobInstanceGuid {get; set;}
        public List<Route_WP> routes = new List<Route_WP>();
        public List<UnscheduledElement_WP> badSchedulingElements = new List<UnscheduledElement_WP>();
        public List<ScheduledElement_WP> resolvedSchedulingElements = new List<ScheduledElement_WP>();
        public List<UnscheduledElement_WP> unassignedSchedulingElements = new List<UnscheduledElement_WP>();
        public List<SchedulingJobStatistic_WP> schedulingJobStatistics = new List<SchedulingJobStatistic_WP>();
        public String exceptionMsg  {get; set;}
        public integer exceptionMsgCode {get; set;}
        public String createdDateTime {get; set;}
        public String callStatus {get; set;}    // For identifying call while divide route wise.    
        
    }

    public class Route_WP
    {
        public String routeId {get; set;}
        public String resourceId {get; set;}
        public String startLocationElementId {get; set;}
        public String endLocationElementId {get; set;}
        public List<ScheduledElement_WP> scheduledElements = new List<ScheduledElement_WP>(); 
        public RouteSummary_WP routeSummary = new RouteSummary_WP();
    }  

    public class RouteSummary_WP
    {
        public DateTime startTime {get; set;}
        public DateTime endTime {get; set;}
        public integer routeDuration {get; set;}
        public integer drivingDuration {get; set;}
        public Double distance {get; set;}
        public integer serviceDuration {get; set;}
        public integer idleDuration {get; set;}
        public integer returnDriveDuration {get; set;}
        public Double returnDistance {get; set;}
        
    }   
    public class UnscheduledElement_WP
    {
        public String id {get; set;}
        public String reason {get; set;}
        public Integer reasonCode {get; set;}
        public String unscheduledElementType {get; set;}
        public Double resolvedLatitude {get; set;}
        public Double resolvedLongitude {get; set;}       
    }  
    
    public class ScheduledElement_WP
    {
        public String id {get; set;}
        public String type {get; set;}
        public Double resolvedLatitude {get; set;}
        public Double resolvedLongitude {get; set;}
        public Booking_WP booking = new Booking_WP();
        public List<Violation_WP> violations = new List<Violation_WP>();
    }  

    public class Violation_WP
    {
        public String type {get; set;}
        public String value {get; set;}        
    }
    
    public class Booking_WP
    {
        public String resource {get; set;}
        public DateTime startTime {get; set;}
        public integer driveDuration {get; set;}
        public DateTime arrivalTime {get; set;}
        public integer returnDriveDuration {get; set;}
        public integer idleDuration {get; set;}
        public integer serviceDuration {get; set;}
        public DateTime endTime {get; set;}
        public String status {get; set;}
    }  
    
    public class SchedulingJobStatistic_WP
    {
        public String name {get; set;}
        public String value {get; set;}
        public String type {get; set;}      
    }
    
    /*
     *Type : Wrapper Class
     *Used : "InitJobRequest_WP" and "ManageWorkOrderRequest_WP" Wrapper Class
     *Desc : Holds work order information in required format
     */
    public class WorkOrder_WP
    {
        public String workOrderId{ get; set; }
        public Double serviceDuration{ get; set; }
        public Datetime preferredStart{ get; set; }
        public Datetime preferredEnd{ get; set;}
        public List<ExecutionTime_WP> accessHours = new List<ExecutionTime_WP>();
        public String address{ get; set; }
        public Integer importance{ get; set; }
        public Location_WP geoLocation = new Location_WP();
        public String assignedResourceId{get; set;}
        public String lockSchedule{ get; set; }        
        //public List<String> requiredExpertise = new List<String>();
        public List<Expertise_WP> requiredExpertise = new List<Expertise_WP>();
        public List<QualifiedTechnician_WP> recommendedResources = new List<QualifiedTechnician_WP>();
        public List<String> bannedResources = new List<String>();
        public List<String> mandatoryResources = new List<String>();
        public String nodeColor{ get; set; }

        
        public WorkOrder_WP(){}
        public WorkOrder_WP(SVMXC__Service_Order__c objWorkOrder, List<ExecutionTime_WP> woExeTime)
        {
            workOrderId = objWorkOrder.Name;
            if(objWorkOrder.SVMXC__Skill_Set__c != NULL){
                //requiredExpertise = True;
                //TODO: need to parse the skill set field from work order and send the skills to OptiMax.
                requiredExpertise=fetchSkills(objWorkOrder);
            }
            if(objWorkOrder.SVMXC__Service_Duration__c != NULL)
                serviceDuration = objWorkOrder.SVMXC__Service_Duration__c;
            
            // JOpt validation: Priority should be >=1
            if(objWorkOrder.SVMXC__Dispatch_Priority__c == NULL || objWorkOrder.SVMXC__Dispatch_Priority__c <= 0)
                importance = 1;
            else
                importance = objWorkOrder.SVMXC__Dispatch_Priority__c.intvalue();
                
            String strWrkOrdrAddress = ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0) ? objWorkOrder.SVMXC__Street__c : '') + ((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) ?  (((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0)) ? ', ' : '') + objWorkOrder.SVMXC__City__c : '') + ((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) ?  (((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__State__c : '') + ((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) ?  (((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Zip__c : '') + ((objWorkOrder.SVMXC__Country__c != NULL && objWorkOrder.SVMXC__Country__c.length() > 0) ?  (((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) || (objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Country__c : '');
            
            Address = strWrkOrdrAddress;
            geoLocation.latitude = objWorkOrder.SVMXC__Latitude__c;
            geoLocation.longitude = objWorkOrder.SVMXC__Longitude__c;
            
            if(woExeTime != NULL)
                accessHours = woExeTime;
                
            String qualifiedTechNewId;
            if(objWorkOrder.SVMXC__Qualified_Technicians__c != NULL){
                try{
                    List<SMAX_OptiMax_EngineUtils.stachRank> lstQTL = (List<SMAX_OptiMax_EngineUtils.stachRank>)JSON.deserialize(objWorkOrder.SVMXC__Qualified_Technicians__c, List<SMAX_OptiMax_EngineUtils.stachRank>.class);
                    for(SMAX_OptiMax_EngineUtils.stachRank objQTL: lstQTL)
                    {
                        if(objQTL.valid == true && objQTL.prefType=='Preferred'){
                            //adding technician name into the wrapper
                            qualifiedTechNewId = objQTL.tech + '_'+objQTL.tName;
                            //qualifiedTechnicians_LWP.add(new QualifiedTechnician_WP(objQTL.tech, objQTL.stackRank));
                            recommendedResources.add(new QualifiedTechnician_WP(qualifiedTechNewId, objQTL.stackRank));
                        }else if(objQTL.valid == true && objQTL.prefType=='Prohibited'){
                            qualifiedTechNewId = objQTL.tech + '_'+objQTL.tName;
                            bannedResources.add(qualifiedTechNewId);
                        }else if(objQTL.valid == true && objQTL.prefType=='Mandatory'){
                            qualifiedTechNewId = objQTL.tech + '_'+objQTL.tName;
                            mandatoryResources.add(qualifiedTechNewId);
                        }
                            
                    }
                }catch(Exception e){
                    WSCH_AuditLogger.error('Exception occured::WSCH_Provider_ECO_Stubs::WorkOrder_WP(): - '+e.getMessage());
                }
            }
            /*if(objWorkOrder.SVMXC__SM_Capacity_Rule_Name__c != null){
                nodeColor = objWorkOrder.SVMXC__SM_Capacity_Rule_Name__c.trim();
                //WSCH_AuditLogger.debug('objWorkOrder.SVMXC__SM_Capacity_Rule_Name__c: - '+objWorkOrder.SVMXC__SM_Capacity_Rule_Name__c);
            }*/
                
            //set the PST and PET values from work order
            preferredStart = objWorkOrder.SVMXC__Preferred_Start_Time__c;
            preferredEnd = objWorkOrder.SVMXC__Preferred_End_Time__c; 
            lockSchedule = objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c;               
        }
        
    }
    
    
    /*
     *Type : Wrapper Class
     *Used : "InitJobRequest_WP" and "ManageWorkOrderRequest_WP" Wrapper Class
     *Desc : Holds qualified technicians information in required format
     */
    public class QualifiedTechnician_WP{
        public String id { get; set; }
        public Integer priority{ get; set; }
        public QualifiedTechnician_WP(String id, Integer priority){
            this.id = id;
            this.priority = priority;
        }
    }
    
    /*
     *Type : Wrapper Class
     *Used : "InitJobRequest_WP" and "ManageTechnicianRequest_WP" Wrapper Class
     *Desc : Holds technicians information in required format
     */
    public class Technician_WP{
        public String resourceId { get; set; }
        public String address{ get; set; }
        public Double fixedCost{ get; set; }
        public Double hourlyCost{ get; set; }
        public Double travelUnitCost{ get; set; }
        public Double avgTravelSpeed{ get; set; }
        public Double maxHours{ get; set; }
        public Double maxDistance{ get; set; }
        public List<Expertise_WP> expertise = new List<Expertise_WP>();
        //public List<String> expertise = new List<String>();
        public Double overTimeTolerance{get; set;}
        public Double driveBeforeShiftStart{get; set;}
        public Double driveAfterShiftEnd{get; set;}
        public Location_WP geoLocation = new Location_WP();
        public List<ExecutionTime_WP> workingHours = new List<ExecutionTime_WP>();
               
        public Technician_WP(){}
        
        public Technician_WP(SVMXC__Service_Group_Members__c objTechnician)
        {
            resourceId = objTechnician.Id + '_' + objTechnician.Name;
            fixedCost = objTechnician.SVMXC__Fixed_Cost__c;
            avgTravelSpeed = objTechnician.SVMXC__Average_Speed__c;
            maxDistance = objTechnician.SVMXC__Max_Distance__c;
            maxHours = objTechnician.SVMXC__Max_Hours__c;
            if(objTechnician.SVMXC__Per_hour_Cost__c != null){
                hourlyCost = objTechnician.SVMXC__Per_hour_Cost__c;
            }
            
            if(objTechnician.SVMXC__Per_Mile_Cost__c != null){
                travelUnitCost = objTechnician.SVMXC__Per_Mile_Cost__c;
            }
            geoLocation.latitude = objTechnician.SVMXC__Latitude_Home__c;
            geoLocation.longitude = objTechnician.SVMXC__Longitude_Home__c;
            //workingHours = eventTime;
            String strTechAddress = ((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0) ? objTechnician.SVMXC__Street__c : '') + ((objTechnician.SVMXC__City__c != NULL && objTechnician.SVMXC__City__c.length() > 0) ?  (((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0)) ? ', ' : '') + objTechnician.SVMXC__City__c : '') + ((objTechnician.SVMXC__State__c != NULL && objTechnician.SVMXC__State__c.length() > 0) ?  (((objTechnician.SVMXC__City__c != NULL && objTechnician.SVMXC__City__c.length() > 0) || ((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objTechnician.SVMXC__State__c : '') + ((objTechnician.SVMXC__Zip__c != NULL && objTechnician.SVMXC__Zip__c.length() > 0) ?  (((objTechnician.SVMXC__State__c != NULL && objTechnician.SVMXC__State__c.length() > 0) || (objTechnician.SVMXC__City__c != NULL && objTechnician.SVMXC__City__c.length() > 0) || ((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objTechnician.SVMXC__Zip__c : '') + ((objTechnician.SVMXC__Country__c != NULL && objTechnician.SVMXC__Country__c.length() > 0) ?  (((objTechnician.SVMXC__Zip__c != NULL && objTechnician.SVMXC__Zip__c.length() > 0) || (objTechnician.SVMXC__State__c != NULL && objTechnician.SVMXC__State__c.length() > 0) || (objTechnician.SVMXC__City__c != NULL && objTechnician.SVMXC__City__c.length() > 0) || ((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objTechnician.SVMXC__Country__c : '');
            Address = strTechAddress;
            /*String strSkill;
            if(lstTechSkill != null && lstTechSkill.size() > 0){
                for(Integer i=0; i< lstTechSkill.size(); i++) {
                    if(String.isNotEmpty(strSkill)){
                        strSkill=strSkill+','+lstTechSkill[i];
                    }else{
                        strSkill=lstTechSkill[i];
                    }
                }
            }*/
            //expertise = lstTechSkill;
            //overTimeTolerance = dblTechOverTimeSecs; 
            //driveBeforeShiftStart = driveBeforeShiftStart;
            //driveAfterShiftEnd = driveAfterShiftEnd;
        }
        
        /*public Technician_WP(SVMXC__Service_Group_Members__c objTechnician, List<ExecutionTime_WP> eventTime, List<String> lstTechSkill, String strOperationType, Double dblTechOverTimeSecs, List<ExcSetting_WP> techParams)
        {
            this(objTechnician, eventTime, lstTechSkill, strOperationType, dblTechOverTimeSecs);
            //techParameters = techParams;
        }*/
        
    }
    
    /*
     *Type : Wrapper Class
     *Used : "InitJobRequest_WP" and "ManageTechnicianRequest_WP" Wrapper Class
     *Desc : Holds technicians event details in required format
     */
    public class TechniciansEvent_WP
    {
        public String assignedResourceId{ get; set; }
        public String eventId{ get; set; }
        //public Integer importance{ get; set; }
        public List<executionTime_WP> accessHours{ get; set; }
        public Double eventDuration{ get; set; }
        public Location_WP geoLocation = new Location_WP();
        public String address{ get; set; }
        public String eventType{ get; set; }          
        public TechniciansEvent_WP(){}

        public TechniciansEvent_WP(String strTerritoryId, String strPreferedResource, String strEventId, DateTime dtmStartTime, DateTime dtmEndTime, Double dblTimeWindowPriority, Double dblPreferredResourcePriority, Integer importance,String operationType,Location_WP location,String address)
        {
            //this.importance = importance;
            this.accessHours = new List<executionTime_WP>();
            this.eventId = strEventId;
            this.assignedResourceId = strPreferedResource;
            this.accessHours.add(new executionTime_WP(dtmStartTime, dtmEndTime));
            if(null != dtmEndTime && null !=dtmStartTime ){
                this.eventDuration = ( (dtmEndTime.getTime() - dtmStartTime.getTime()) / 1000);
            }
            if(location != null){
                this.eventType='CALENDAR_GEO_ITEM';
                this.geoLocation = location;
            }
            if(String.isNotEmpty(address)){
                this.eventType='CALENDAR_GEO_ITEM';
                this.address = address;
            }
            if(location == null && String.isEmpty(address)){
                this.eventType='CALENDAR_ITEM';
            }
            
        }
    }            
   
    /*
     *Type : Wrapper Class
     *Used : "WorkOrder_WP" wrapper class and "Technician_WP" wrapper class
     *Desc : Holds latitude and longitude
     */
    public class Location_WP
    {
        // latitude and longitudee have been introduced for better code readability.
        
        public Double latitude{ get; set; }
        public Double longitude{ get; set; }
        
        public void setLatitude(Double dbllatitude)
        {
            this.latitude = dbllatitude;
        }
        
        public void setLongitude(Double dbllongitude)
        {
            this.longitude = dbllongitude;
        }
        
        public Location_WP()
        {}
        
        public Location_WP(Double dbllatitude, Double dbllongitude)
        {
            this.latitude = dbllatitude;
            this.longitude = dbllongitude;
        }
        
    }

    /*
     *Type : Wrapper Class
     *Used : "WorkOrder_WP" wrapper class and "Technician_WP" wrapper class
     *Desc : Holds execution time details in required format
     */
    public class ExecutionTime_WP
    {
        public DateTime hoursBegin{ get; set; }
        public DateTIme hoursEnd{ get; set; }
        
        public void setHoursBegin(DateTime dtmStartDateTime)
        {
            this.hoursBegin = dtmStartDateTime;
        }
        
        public void setHoursEnd(DateTime dtmEndDateTime)
        {
            this.hoursEnd = dtmEndDateTime;
        }
        
        public ExecutionTime_WP()
        {}
        
        public ExecutionTime_WP(DateTime dtmStartDateTime, DateTime dtmEndDateTime)
        {
            this.hoursBegin = dtmStartDateTime;
            this.hoursEnd = dtmEndDateTime;
        }
        
        // If a time window spans across multiple days, split it into multiple time windows based on the given time zone, 1 per day
        public List<ExecutionTime_WP> doSplitDays(String strTimeZoneSidKey, Set<Date> setAllowedDates)
        {
            List<ExecutionTime_WP> lstExeTime = new List<ExecutionTime_WP>();
            Date datStartDate = Date.valueOf(this.hoursBegin.format('yyyy-MM-dd', strTimeZoneSidKey));
            Date datEndDate = Date.valueOf(this.hoursEnd.format('yyyy-MM-dd', strTimeZoneSidKey));
            
            // If the event end date is the same as the event start date in the given time zone,
            // the event does not span across multiple dates; so return the same event
            if (datStartDate == datEndDate)
            {
                lstExeTime.add(this);
                return lstExeTime;
            }
            
            // Else, the event spans across multiple dates and needs to be split
            for (Date tempDate = datStartDate; tempDate <= datEndDate; tempDate = tempDate.addDays(1))
            {
                if(setAllowedDates.contains(tempDate)) // For returning events for only the allowed dates, if the event spans across multiple days
                {
                    ExecutionTime_WP wrpExeTime = new ExecutionTime_WP();
                    if (tempDate == datStartDate)
                        wrpExeTime.hoursBegin = this.hoursBegin;
                    else
                        wrpExeTime.hoursBegin = dcUtils.getDateTimeInTimezone(tempDate, Time.newInstance(0,0,0,0), strTimeZoneSidKey);
                    if (tempDate == datEndDate)
                        wrpExeTime.hoursEnd = this.hoursEnd;
                    else
                        wrpExeTime.hoursEnd = dcUtils.getDateTimeInTimezone(tempDate, Time.newInstance(23,59,59,999), strTimeZoneSidKey);
                    if(wrpExeTime.hoursBegin != wrpExeTime.hoursEnd)
                        lstExeTime.add(wrpExeTime);
                }
            }
            return lstExeTime;
        }        
        
    }

    
    /*private static List<String> fetchSkills(SVMXC__Service_Order__c workOrder)
    {
        //Parse the skillSet which is in JSON format and extract the skillName and skillLevel from it
        //String skills;
        List<String> lstSkills = new List<String>();
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Stubs::fetchSkills()::Skill set in WO: - '+workOrder.SVMXC__Skill_Set__c);
        if(workOrder != null && String.isNotEmpty(workOrder.SVMXC__Skill_Set__c)) {
            JSONParser parser = JSON.createParser(workOrder.SVMXC__Skill_Set__c);
            String skillName,skillRequired;
            while(parser.nextToken() != null)
            {
                String skill;
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == WSCH_ECO_Constants.STR_SKILL_NAME)) {
                    //extract the skillName
                    parser.nextToken();
                    skillName = parser.getText();
                }else if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == WSCH_ECO_Constants.STR_SKILL_ID)) {
                    //extract the skillId
                    if(String.isNotEmpty(skillName)){
                        parser.nextToken();
                        skillRequired = parser.getText()+'_'+skillName;
                    }
                }else if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == WSCH_ECO_Constants.STR_SKILL_ISMANDATORY)) {
                    if(String.isNotEmpty(skillRequired)){
                        parser.nextToken();
                        if(parser.getText() == 'true'){
                            skill=skillRequired; 
                        }
                    }
                }
                
                if(String.isNotEmpty(skill)){
                    lstSkills.add(skill);
                    //if(String.isNotEmpty(skills)){
                    //    skills=skills+','+skill;
                    //}else{
                    //    skills=skill;
                    //}
                }
            }
        }
        //WSCH_AuditLogger.error('WSCH_Provider_ECO_Stubs::fetchSkills(): - '+skills);
        return lstSkills;
    }*/
    
    private static List<Expertise_WP> fetchSkills(SVMXC__Service_Order__c workOrder)
    {
        List<Expertise_WP> lstSkills = new List<Expertise_WP>();
        if(workOrder != null && String.isNotEmpty(workOrder.SVMXC__Skill_Set__c)) {
            WSCH_LTP_Scheduling_Stubs.Skill[] skills = (List<WSCH_LTP_Scheduling_Stubs.Skill>)JSON.deserialize(workOrder.SVMXC__Skill_Set__c,List<WSCH_LTP_Scheduling_Stubs.Skill>.class);
            for(Skill s : skills){
                Expertise_WP expertise = new Expertise_WP();
                if(s.isSkillMandatory){
                    expertise.id=s.skillId;
                    expertise.level=s.skillLevel;
                    lstSkills.add(expertise);
                }
            }
        }
        return lstSkills;
    }

    public class Expertise_WP
    {
        public String id{ get; set;}
        public Date validFrom{ get; set; }
        public Date validTo{ get; set; }
        public Double level{get; set;}
    }

    public class Skill{
        Id skillId;
        String skillName;
        Boolean isSkillMandatory;
        Integer skillLevel;    
    }
}