global class SMAX_OptiMax_Engine_WS {
    
    /*
     *Type : Extension class
     *Used : "SMAX_OptiMax_Engine_WS" Class  
     *Desc : Used to return exception where ever required
     */
     
    public class SVMXException extends Exception{}
    
    public static DCON_Utils dcUtils = new DCON_Utils();
    public static String strSfEventKeyPrefix='';
    public static String strSvmxEventKeyPrefix='';
    public static SMAX_OptiMax_EngineUtils clsEngineUtils = new SMAX_OptiMax_EngineUtils();
    public static map<Id, Id> mapAssignedTechnicians = new map<Id, Id>();
    public static Boolean isMCTMenabled = false;
    
    
    /*
     *Type : Wrapper Class
     *Used : "SMAX_Initiate_OptiMax_Job_WS" Webservice Method
     *Desc : Output type for "SMAX_Initiate_OptiMax_Job_WS" webservice method
     */
    global class opInitateJobs_WP
    {
        webservice String jobId{ get; set; }
        webservice String jobNo{ get; set; }
        webservice String message{ get; set; }
        webservice Double status{ get; set; }
        webservice Double sentWOCount { get; set; }
        webservice Double sentTechCount { get; set; }
        webservice Double sentEventCount { get; set; }
        webservice List<WorkOrder_WP> workOrder_LWP = new List<WorkOrder_WP>();
        webservice List<Technician_WP> technician_LWP = new List<Technician_WP>();
        webservice List<ExcSetting_WP> Exec_SettingsMap = new List<ExcSetting_WP>();
        webservice List<TechniciansEvents_WP> technicianEvent_LWP = new List<TechniciansEvents_WP>();
        global opInitateJobs_WP()
        {}

        global List<TechniciansEvents_WP> gettechnicianEvent_LWP(){return technicianEvent_LWP;}
        global List<WorkOrder_WP> getworkOrder_LWP(){return workOrder_LWP;}
        global List<Technician_WP> gettechnician_LWP(){return technician_LWP;}
        global List<ExcSetting_WP> getExec_SettingsMap(){return Exec_SettingsMap;}
    }
    
    /*
     *Type : Wrapper Class
     *Used : "opInitateJobs_WP" Wrapper Class
     *Desc : Holds work order information in required format
     */
    global class WorkOrder_WP
    {
        webservice String workOrderId{ get; set; }
        webservice String skill{ get; set; }
        webservice String product{ get; set; }
        webservice String Address{ get; set; }
        webservice String preferredResourceId{ get; set; }
        webservice Double preferredResourcePriority{ get; set; }
        webservice Double priority{ get; set; }
        webservice Double visitDuration{ get; set; }
        webservice Double latitude{ get; set; }
        webservice Double longitude{ get; set; }
        webservice Integer Importance{ get; set; }
        webservice String workOrderType{ get; set; }
        webservice List<ExecutionTime_WP> executionTime_L = new List<ExecutionTime_WP>();
        webservice List<QualifiedTechnician_WP> qualifiedTechnicians_LWP = new List<QualifiedTechnician_WP>();
        webservice List<BannedTechnician_WP> bannedTechnicians_LWP = new List<BannedTechnician_WP>();
        webservice List<MandatoryTechnician_WP> mandatoryTechnicians_LWP = new List<MandatoryTechnician_WP>();
        webservice List<Expertise_WP> requiredExpertise = new List<Expertise_WP>();
        
       //Begin : Spr17- Sadiya - Overnight
        webservice WorkOrderAdditionalDetails_WP workOrderAdditionalDetails_WP = new WorkOrderAdditionalDetails_WP();
       //End : Spr17- Sadiya - Overnight
       
        webservice SVMXC__Service_Order__c wo_O = new SVMXC__Service_Order__c(); // Unused
        webservice ExecutionTime_WP executionTime = new ExecutionTime_WP(); // Deprecated & Unused
        global WorkOrder_WP(SVMXC__Service_Order__c objWorkOrder){}// Deprecated & Unused

        public WorkOrder_WP(SVMXC__Service_Order__c objWorkOrder, List<ExecutionTime_WP> woExeTime, String strWorkOrderType,WorkOrderAdditionalDetails_WP workOrderAdditionalDetails)
        {
            /*  If it is an externally scheduled work order, it can have more than one schedule
                So, to send the same work order multiple times to OptiMax, add _<Event Id> as suffix to work order id
                Event Id is sent in the field OptiMax_Status__c
            */
            workOrderType = strWorkOrderType;
            if(objWorkOrder.SVMXC__OptiMax_Status__c != NULL && ( (objWorkOrder.SVMXC__OptiMax_Status__c).startsWith(strSfEventKeyPrefix) || (objWorkOrder.SVMXC__OptiMax_Status__c).startsWith(strSvmxEventKeyPrefix) ) ){
                //below commentted because we are going to use work order name instead SFDC Id
                //workOrderId = objWorkOrder.Id + '_' + objWorkOrder.SVMXC__OptiMax_Status__c;
                workOrderId = objWorkOrder.Name + '_' + objWorkOrder.SVMXC__OptiMax_Status__c;
            }else{
                //below commentted because we are going to use work order name instead SFDC Id
                //workOrderId = objWorkOrder.Id;
                workOrderId = objWorkOrder.Name;
            }
            if(objWorkOrder.SVMXC__Product__c != NULL)
                product = objWorkOrder.SVMXC__Product__c;

            //if(objWorkOrder.SVMXC__Skill__c != NULL)
                //skill = objWorkOrder.SVMXC__Skill__c;
                
            //Multiple skills prepare from skill set field in work order.
            if(objWorkOrder.SVMXC__Skill_Set__c != NULL){
                //skill=SMAX_OptiMax_EngineUtils.fetchSkills(objWorkOrder);
                requiredExpertise = SMAX_OptiMax_EngineUtils.fetchSkills(objWorkOrder);
            }
                   
            
            //preferredResourceId = objWorkOrder.SVMXC__Preferred_Technician__c;
            //adding technican name into the preferred resource id
            String techNewId = objWorkOrder.SVMXC__Group_Member__r.Id + '_'+objWorkOrder.SVMXC__Group_Member__r.Name;
            preferredResourceId = techNewId;

            if(objWorkOrder.SVMXC__Service_Duration__c != NULL)
                visitDuration = objWorkOrder.SVMXC__Service_Duration__c;
                
            // JOpt validation: Priority should be >=1
            if(objWorkOrder.SVMXC__Dispatch_Priority__c == NULL || objWorkOrder.SVMXC__Dispatch_Priority__c <= 0)
                priority = 1;
            else
                priority = objWorkOrder.SVMXC__Dispatch_Priority__c;
                
            // Importance is used in STRICT mode of JOpt; set it to the same value as Priority.
            Importance = priority.intValue();
            preferredResourcePriority = (objWorkOrder.SVMXC__Preferred_Resource_Priority__c != NULL) ? objWorkOrder.SVMXC__Preferred_Resource_Priority__c : Importance;
            
            String strWrkOrdrAddress = ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0) ? objWorkOrder.SVMXC__Street__c : '') + ((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) ?  (((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0)) ? ', ' : '') + objWorkOrder.SVMXC__City__c : '') + ((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) ?  (((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__State__c : '') + ((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) ?  (((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Zip__c : '') + ((objWorkOrder.SVMXC__Country__c != NULL && objWorkOrder.SVMXC__Country__c.length() > 0) ?  (((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) || (objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Country__c : '');
            
            Address = strWrkOrdrAddress;
            latitude = objWorkOrder.SVMXC__Latitude__c;
            longitude = objWorkOrder.SVMXC__Longitude__c;
            
            if(woExeTime != NULL)
                executionTime_L = woExeTime;
            
            String qualifiedTechNewId;
            if(objWorkOrder.SVMXC__Qualified_Technicians__c != NULL){
                //Set the assigned technician with high stack rank so that it get high priority while rescheduling
                if(mapAssignedTechnicians.containsKey(objWorkOrder.Id) && mapAssignedTechnicians.get(objWorkOrder.Id) != NULL)
                {
                    //adding technician name into the wrapper
                    qualifiedTechNewId = objWorkOrder.SVMXC__Group_Member__r.Id + '_'+objWorkOrder.SVMXC__Group_Member__r.Name;
                    //qualifiedTechnicians_LWP.add(new QualifiedTechnician_WP(mapAssignedTechnicians.get(objWorkOrder.Id), 10));
                    qualifiedTechnicians_LWP.add(new QualifiedTechnician_WP(qualifiedTechNewId, 10));
                }
                try{
                    List<SMAX_OptiMax_EngineUtils.stachRank> lstQTL = (List<SMAX_OptiMax_EngineUtils.stachRank>)JSON.deserialize(objWorkOrder.SVMXC__Qualified_Technicians__c, List<SMAX_OptiMax_EngineUtils.stachRank>.class);
                    for(SMAX_OptiMax_EngineUtils.stachRank objQTL: lstQTL)
                    {
                        if(objQTL.valid == true && objQTL.prefType=='Preferred'){
                            //adding technician name into the wrapper
                            qualifiedTechNewId = objQTL.tech + '_'+objQTL.tName;
                            //qualifiedTechnicians_LWP.add(new QualifiedTechnician_WP(objQTL.tech, objQTL.stackRank));
                            qualifiedTechnicians_LWP.add(new QualifiedTechnician_WP(qualifiedTechNewId, objQTL.stackRank));
                        }else if(objQTL.valid == true && objQTL.prefType=='Prohibited'){
                            qualifiedTechNewId = objQTL.tech + '_'+objQTL.tName;
                            bannedTechnicians_LWP.add(new BannedTechnician_WP(qualifiedTechNewId));
                        }else if(objQTL.valid == true && objQTL.prefType=='Mandatory'){
                            qualifiedTechNewId = objQTL.tech + '_'+objQTL.tName;
                            mandatoryTechnicians_LWP.add(new MandatoryTechnician_WP(qualifiedTechNewId, objQTL.stackRank));
                        }
                            
                    }
                }catch(exception ex){}
            }
            if(objWorkOrder.SVMXC__SM_Schedule_Violation_Penalty__c != NULL){
                workOrderAdditionalDetails.scheduleViolationPenalty = objWorkOrder.SVMXC__SM_Schedule_Violation_Penalty__c;
            }
        
             //Begin : Spr17- Sadiya - Overnight
            workOrderAdditionalDetails_WP = workOrderAdditionalDetails;
             //End : Spr17- Sadiya - Overnight
        }
    }
    
    
    /*
     *Type : Wrapper Class
     *Used : "opInitateJobs_WP" wrapper class
     *Desc : Holds qualified technicians information in required format
     */
    global class QualifiedTechnician_WP{
        webservice String technicianId { get; set; }
        webservice Integer stackRank{ get; set; }
        global QualifiedTechnician_WP(String technicianId, Integer stackRank){
            this.technicianId = technicianId;
            this.stackRank = stackRank;
        }
    }
    
    /*
     *Type : Wrapper Class
     *Used : "opInitateJobs_WP" wrapper class
     *Desc : Holds banned technicians information in required format
     */
    global class BannedTechnician_WP{
        webservice String technicianId { get; set; }
        global BannedTechnician_WP(String technicianId){
            this.technicianId = technicianId;
        }
    }

    /*
     *Type : Wrapper Class
     *Used : "opInitateJobs_WP" wrapper class
     *Desc : Holds Mandatory technicians information in required format
     */
    global class MandatoryTechnician_WP{
        webservice String technicianId { get; set; }
        webservice Integer priority{ get; set; }
        global MandatoryTechnician_WP(String technicianId, Integer priority){
            this.technicianId = technicianId;
            this.priority = priority;
        }
    }
    
    /*
     *Type : Wrapper Class
     *Used : "opInitateJobs_WP" wrapper class
     *Desc : Holds technicians information in required format
     */
    global class Technician_WP{
        webservice String technicianId { get; set; }
        webservice String territoryGuid{ get; set; }
        webservice String Address{ get; set; }
        webservice String currentAddress{ get; set; }
        webservice Double fixedCost{ get; set; }
        webservice Double perHourCost{ get; set; }
        webservice Double perMileCost{ get; set; }
        webservice Double avgSpeed{ get; set; }
        webservice Double maxHours{ get; set; }
        webservice Double maxDistance{ get; set; }
        webservice Double latitude{ get; set; }
        webservice Double longitude{ get; set; }
        webservice Double currentLatitude{ get; set; }
        webservice Double currentLongitude{ get; set; }
        webservice TechnicianAdditonalDetails_WP techAddtionalDetailsWP = new TechnicianAdditonalDetails_WP();
        webservice List<ExecutionTime_WP> ExecutionTime_WPL = new List<ExecutionTime_WP>();
        webservice List<Product_WP> techProduct_WPL = new List<Product_WP>();
        webservice List<Expertise_WP> techExpertise_WPL = new List<Expertise_WP>();
        
        SVMXC__Service_Group_Members__c tech_O = new SVMXC__Service_Group_Members__c(); // Unused
        webservice Double maxDailyHours{ get; set; } // Deprecated & Unused
        webservice Double maxWeekHours{ get; set; } // Deprecated & Unused
        webservice Double capacity{ get; set; } // Deprecated & Unused
        
        global Technician_WP(SVMXC__Service_Group_Members__c objTechnician, List<ExecutionTime_WP> eventTime, List<Product_WP> products, List<Expertise_WP> skills, String addOnId)
        {
            if(addOnId != NULL)
                technicianId = objTechnician.Id + '_' + objTechnician.Name + addOnId;
            else
                technicianId = objTechnician.Id + '_' + objTechnician.Name;

            fixedCost = objTechnician.SVMXC__Fixed_Cost__c;
            perHourCost = objTechnician.SVMXC__Per_hour_Cost__c;
            perMileCost = objTechnician.SVMXC__Per_Mile_Cost__c;
            avgSpeed = objTechnician.SVMXC__Average_Speed__c;
            maxDistance = objTechnician.SVMXC__Max_Distance__c;
            maxHours = objTechnician.SVMXC__Max_Hours__c;
            maxWeekHours = NULL;
            maxDailyHours = NULL;
            latitude = objTechnician.SVMXC__Latitude_Home__c;
            longitude = objTechnician.SVMXC__Longitude_Home__c;
            territoryGuid = objTechnician.SVMXC__Service_Territory__c;
            ExecutionTime_WPL = eventTime;
            techProduct_WPL = products;
            techExpertise_WPL = skills;
            
            String strTechAddress = ((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0) ? objTechnician.SVMXC__Street__c : '') + ((objTechnician.SVMXC__City__c != NULL && objTechnician.SVMXC__City__c.length() > 0) ?  (((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0)) ? ', ' : '') + objTechnician.SVMXC__City__c : '') + ((objTechnician.SVMXC__State__c != NULL && objTechnician.SVMXC__State__c.length() > 0) ?  (((objTechnician.SVMXC__City__c != NULL && objTechnician.SVMXC__City__c.length() > 0) || ((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objTechnician.SVMXC__State__c : '') + ((objTechnician.SVMXC__Zip__c != NULL && objTechnician.SVMXC__Zip__c.length() > 0) ?  (((objTechnician.SVMXC__State__c != NULL && objTechnician.SVMXC__State__c.length() > 0) || (objTechnician.SVMXC__City__c != NULL && objTechnician.SVMXC__City__c.length() > 0) || ((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objTechnician.SVMXC__Zip__c : '') + ((objTechnician.SVMXC__Country__c != NULL && objTechnician.SVMXC__Country__c.length() > 0) ?  (((objTechnician.SVMXC__Zip__c != NULL && objTechnician.SVMXC__Zip__c.length() > 0) || (objTechnician.SVMXC__State__c != NULL && objTechnician.SVMXC__State__c.length() > 0) || (objTechnician.SVMXC__City__c != NULL && objTechnician.SVMXC__City__c.length() > 0) || ((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objTechnician.SVMXC__Country__c : '');
            Address = strTechAddress;
        }
        //Method overloading implemented due to new parameter added into technician wrapper. 
        //Overtime parameter added to TechnicianAdditonalDetails_WP under technician wrapper.
        global Technician_WP(SVMXC__Service_Group_Members__c objTechnician, List<ExecutionTime_WP> eventTime, List<Product_WP> products, List<Expertise_WP> skills, String addOnId, TechnicianAdditonalDetails_WP techAdditionalDetails){
            this(objTechnician, eventTime, products, skills, addOnId);
            techAddtionalDetailsWP = techAdditionalDetails;
        }
        
        global Technician_WP(SVMXC__Service_Group_Members__c objTechnician, List<ExecutionTime_WP> eventTime, List<Product_WP> products, List<Expertise_WP> skills){}
        global List<Product_WP> gettechProduct_WPL(){return techProduct_WPL;}
        global List<Expertise_WP> gettechExpertise_WPL(){return techExpertise_WPL;}
    }
    
    global class TechnicianAdditonalDetails_WP
    {
        webservice Double techOverTimeSecs{get; set;}
        
        //Begin : Overnight Changes - Sadiya
        webservice Double thresholdDistance  {get; set;}
        webservice Double thresholdDuration  {get; set;}
        webservice Double totalStaysOut {get; set;}
        webservice Double  staysOutInRow  {get; set;}
        webservice boolean  isPolicyOverRidesEfficiency  {get; set;}
        webservice Double minRecoverHours {get; set;}
        webservice List<ExcSetting_WP> techParam = new List<ExcSetting_WP>();
        //End : Overnight Changes - Sadiya
        
    }
    
    /*
     *Type : Wrapper Class
     *Used : "opInitateJobs_WP" wrapper class
     *Desc : Holds technicians event details in required format
     */
    global class TechniciansEvents_WP
    {
        webservice String territoryId{ get; set; }
        webservice String preferredResourceId{ get; set; }
        webservice String eventId{ get; set; }
        webservice Integer importance{ get; set; }
        webservice List<executionTime_WP> eventTimeWindow{ get; set; }
        webservice Double eventDuration{ get; set; }
        webservice Double timeWindowPriority{ get; set; }
        webservice Double preferredResourcePriority{ get; set; }
        webservice TechniciansEventsAdditonalDetails_WP techEventsAddtionalDetailsWP = new TechniciansEventsAdditonalDetails_WP();
        
        global TechniciansEvents_WP()
        {}
        global TechniciansEvents_WP(String strTerritoryId, String strPreferedResource, String strEventId, DateTime dtmStartTime, DateTime dtmEndTime, Double dblTimeWindowPriority, Double dblPreferredResourcePriority, Integer importance)
        {
            this.importance = importance;
            this.eventTimeWindow = new List<executionTime_WP>();
            this.eventId = strEventId;
            this.eventId = strEventId;
            this.preferredResourceId = strPreferedResource;
            this.eventTimeWindow.add(new executionTime_WP(dtmStartTime, dtmEndTime));
            this.territoryId = strTerritoryId;
            this.eventDuration = ( (dtmEndTime.getTime() - dtmStartTime.getTime()) / 1000);
            this.timeWindowPriority = dblTimeWindowPriority;
            this.preferredResourcePriority = dblPreferredResourcePriority;
        }
        
        global TechniciansEvents_WP(String strTerritoryId, String strPreferedResource, String strEventId, DateTime dtmStartTime, DateTime dtmEndTime, Double dblTimeWindowPriority, Double dblPreferredResourcePriority, Integer importance, TechniciansEventsAdditonalDetails_WP techEventsAddtionalDetails)
        {
            this(strTerritoryId, strPreferedResource, strEventId, dtmStartTime, dtmEndTime, dblTimeWindowPriority, dblPreferredResourcePriority, importance);
            this.techEventsAddtionalDetailsWP = techEventsAddtionalDetails;            
        }
        
    }
    
    global class TechniciansEventsAdditonalDetails_WP
    {
        webservice String address{ get; set; }
        webservice Double latitude{ get; set; }
        webservice Double longitude{ get; set; }
        webservice String eventtype{ get; set; }  
        webservice boolean isForcedStayNode{ get; set; }        
    }
    
    /*
     *Type : Wrapper Class
     *Used : "WorkOrder_WP" wrapper class and "Technician_WP" wrapper class
     *Desc : Holds execution time details in required format
     */
    global class ExecutionTime_WP
    {
        /*  startDateTime & endDateTime have been introduced for better code readability.
            startDate & endDate have been retained for avoiding changes in WSDL.
            This is to avoid changes to OptiMax Java code
        */
        public DateTime startDateTime{ get; set; }
        public DateTIme endDateTime{ get; set; }
        webservice DateTime startDate{ get; set; }
        webservice DateTIme endDate{ get; set; }
        
        //Begin : Overnight Changes - Sadiya
        webservice boolean isAvailableForOvernightStay {get; set;}
        //End : Overnight Changes - Sadiya
        
        public void setstartDateTime(DateTime dtmStartDateTime)
        {
            this.startDateTime = this.startDate = dtmStartDateTime;
        }
        
        public void setendDateTime(DateTime dtmEndDateTime)
        {
            this.endDateTime = this.endDate = dtmEndDateTime;
        }
        
        global ExecutionTime_WP()
        {}
        
        global ExecutionTime_WP(DateTime dtmStartDateTime, DateTime dtmEndDateTime)
        {
            this.startDateTime = this.startDate = dtmStartDateTime;
            this.endDateTime = this.endDate = dtmEndDateTime;
        }
        
        // If a time window spans across multiple days, split it into multiple time windows based on the given time zone, 1 per day
        public List<ExecutionTime_WP> doSplitDays(String strTimeZoneSidKey, Set<Date> setAllowedDates)
        {
            List<ExecutionTime_WP> lstExeTime = new List<ExecutionTime_WP>();
            Date datStartDate = Date.valueOf(this.startDateTime.format('yyyy-MM-dd', strTimeZoneSidKey));
            Date datEndDate = Date.valueOf(this.endDateTime.format('yyyy-MM-dd', strTimeZoneSidKey));
            
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
                        wrpExeTime.startDateTime = wrpExeTime.startDate = this.startDateTime;
                    else
                        wrpExeTime.startDateTime = wrpExeTime.startDate = dcUtils.getDateTimeInTimezone(tempDate, Time.newInstance(0,0,0,0), strTimeZoneSidKey);
                    if (tempDate == datEndDate)
                        wrpExeTime.endDateTime = wrpExeTime.endDate = this.endDateTime;
                    else
                        wrpExeTime.endDateTime = wrpExeTime.endDate = dcUtils.getDateTimeInTimezone(tempDate, Time.newInstance(23,59,59,999), strTimeZoneSidKey);
                    if(wrpExeTime.startDateTime != wrpExeTime.endDateTime)
                        lstExeTime.add(wrpExeTime);
                }
            }
            return lstExeTime;
        }
    }

    /*
     *Type : Wrapper Class
     *Used : "Technician_WP" wrapper class
     *Desc : Holds expertise details in required format
     */
    global class Expertise_WP
    { 
        webservice String id{ get; set; }
        webservice String name{ get; set; }
        webservice Date validFrom{ get; set; }
        webservice Date validTo{ get; set; }
        webservice integer level{get; set;}
        global Expertise_WP()
        {}
    }

    /*
     *Type : Wrapper Class
     *Used : "Technician_WP" wrapper class
     *Desc : Holds product details in required format
     */
    global class Product_WP
    {   
        webservice String id{ get; set; }
        webservice String name{ get; set; }
        global Product_WP()
        {}
    }

    /*
     *Type : Wrapper Class
     *Used : "opInitateJobs_WP" wrapper class
     *Desc : This is an additional parameter
     */
    global class ExcSetting_WP
    {
        webservice String name{ get; set; }
        webservice String value{ get; set; }
        global ExcSetting_WP()
        {}
        global ExcSetting_WP(String name, String value)
        {
        this.name = name;
        this.value = value;
        }
    }
    
    public class DblLocation_WP
    {
        public Double latitude{ get; set; }
        public Double longitude{ get; set; }
        
        public DblLocation_WP()
        {}
        
        public DblLocation_WP(String strLatitude, String strLongitude)
        {
            this.latitude = Double.valueOf(strLatitude);
            this.longitude = Double.valueOf(strLongitude);
        }
        public DblLocation_WP(Decimal dclLatitude, Decimal dclLongitude)
        {
            this.latitude = dclLatitude;
            this.longitude = dclLongitude;
        } 
    }
    
    public class WorkOrderSchedule_WP
    {
        public String strEventId{ get; set; }
        public String strPreferredTechnicainId{ get; set; }
        public DateTime dtmStartDateTime{ get; set; }
        public DateTime dtmEndDateTime{ get; set; }
        public Double dblServiceDuration{ get; set; }
        
        public WorkOrderSchedule_WP()
        {}
        
        public WorkOrderSchedule_WP(String strEventId, String strPreferredTechnicainId, DateTime dtmStartDateTime, DateTime dtmEndDateTime, Double dblServiceDuration)
        {
            this.strEventId = strEventId;
            this.strPreferredTechnicainId = strPreferredTechnicainId;
            this.dtmStartDateTime = dtmStartDateTime;
            this.dtmEndDateTime = dtmEndDateTime;
            this.dblServiceDuration = dblServiceDuration * 60;
        }
    }

    /*
     *Type : Wrapper Class
     *Used : SMAX_Run_Precalc_WS, SMAX_Get_OptiMax_ErrorWO_WS
     *Desc : Generic parameter used as input & output list by Web Services
     */
    global class KeyValue
    {
        webservice String name{get;set;}
        webservice String value{get;set;}
        global KeyValue()
        {}
        global KeyValue(String name, String value)
        {
            this.name = name;
            this.value = value;
        }
    }
    
     
     //Begin : Overnight Changes - Sadiya   
     /*
     *Type : Wrapper Class
     *Used :  Initiate 
     *Desc : Generic parameter used as work order additional details
     */
     global class   WorkOrderAdditionalDetails_WP
    {
        webservice Boolean isAvailableForOvernightStay {get; set;}
        webservice Double scheduleViolationPenalty{ get; set;}
        webservice List<Relation_WP> relation_LWP = new List<Relation_WP>();
        webservice List<ExcSetting_WP> workOrderParam = new List<ExcSetting_WP>();
    }
     //End : Overnight Changes - Sadiya

     /*
     *Type : Wrapper Class
     *Used :  Initiate 
     *Desc : Generic parameter used as work order Relation details
     */
     global class   Relation_WP
    {
        webservice String relationshipType {get; set;}
        webservice String masterNodeId { get; set;}
        webservice String resourceDependencyType {get; set;}
        webservice Double minimalDeviationSec { get; set;}
        webservice Double maximalDeviationSec { get; set;}
        
        //This variable is NOT TO BE USED. Could not remove it as it was already packaged.
        webservice Boolean sameResource {get; set;}
        webservice String relatedNodeId { get; set;}
    }

    /*
     *Type : Webservice Method
     *Used : OptiMax Server 
     *Dir  : From OptiMax to Customer Org
     *Desc : Web Service on SFDC that OptiMax invokes for ServiceMax version 6.3 and above to initiate Precalc before Initiate Job
     */
    webservice static list<KeyValue> SMAX_Run_Precalc_WS(list<KeyValue> lstKeyValuePairs)
    {
        String strDisptchProcId = '';
        String strTerritoryId = '';
        Boolean isFullRun = false;
        list<KeyValue> lstOutputKeyValuePairs = new list<KeyValue>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSettings = new list<string>();
        lstSettings.add('OMAX003_SET030');
        lstSettings.add('OMAX003_SET032');
        lstSettings.add('GLOB001_GBL007');
        //Apurva
        lstSettings.add('OMAX002_SET002');
        map<String, String> mapSetting = commSettings.SVMX_getGlobalSettingList(lstSettings);

        // Do not proceed if the setting Enable Dispatch Optimization is set to FALSE
        /*if(mapSetting.containsKey('GLOB001_GBL007') && mapSetting.get('GLOB001_GBL007').toUpperCase() == 'FALSE')
        {
            throw new SVMXException('Dispatch optimization is not enabled for the organization.');
        }*/

        system.debug('SMAX_Run_Precalc_WS input key value pair list: ' + lstKeyValuePairs);
        if(lstKeyValuePairs.size() > 0)
        {
            for(Integer i = 0; i < lstKeyValuePairs.size(); i++)
            {
                if(lstKeyValuePairs[i].name.touppercase() == 'DISPATCHPROCESSID')
                    strDisptchProcId = lstKeyValuePairs[i].value;
                else if(lstKeyValuePairs[i].name.touppercase() == 'TERRITORYID')
                    strTerritoryId = lstKeyValuePairs[i].value;
            }
        }
        
        // Split the territoryID received from OptiMax to get the actual territoryGUID and check whether the run is full run or incremental run
        if(strTerritoryId.contains('_'))
        {
            list<String> lstTerritoryDef = new list<String>();
            lstTerritoryDef = strTerritoryId.split('_');
            strTerritoryId = lstTerritoryDef[0];
            if(lstTerritoryDef.size() > 1)
            {
                if(lstTerritoryDef[1].contains('FULL'))
                    isFullRun = true;
            }
        }
        else
            isFullRun = TRUE;

        if(strDisptchProcId != null && strDisptchProcId.length() > 0 && strTerritoryId != null && strTerritoryId.length() > 0)
        {
            // Check if there are any jobs running for the given dispatch process & territory
            // with status Initiated, In Progress, Precalc Completed, QTL Completed, Resources Sent or Work Orders Being Sent. If yes, check age of job and decide as below
            // (1) If zombie, mark as zombie and start new job
            // (2) If not, throw exception and do not start new job 
            // list<SVMXC__SVMX_Jobs__c> SVMXJobs = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, SVMXC__End_Time__c   from SVMXC__SVMX_Jobs__c where SVMXC__SVMX_Process__c = :strDisptchProcId and SVMXC__Territory__c = :strTerritoryId and (SVMXC__OptiMax_Message__c = 'Running Precalc' OR SVMXC__OptiMax_Message__c = 'Precalc Completed' OR SVMXC__OptiMax_Message__c = 'Running QTL' OR SVMXC__OptiMax_Message__c = 'QTL Completed' OR SVMXC__OptiMax_Message__c = 'Initiated' OR SVMXC__OptiMax_Message__c = 'In Progress')];
            list<SVMXC__SVMX_Jobs__c> SVMXJobs = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, SVMXC__End_Time__c   from SVMXC__SVMX_Jobs__c where SVMXC__SVMX_Process__c = :strDisptchProcId and SVMXC__Territory__c = :strTerritoryId and (SVMXC__OptiMax_Message__c = 'Resources Sent' OR SVMXC__OptiMax_Message__c = 'Precalc Completed' OR SVMXC__OptiMax_Message__c = 'Work Orders Being Sent' OR SVMXC__OptiMax_Message__c = 'QTL Completed' OR SVMXC__OptiMax_Message__c = 'Initiated' OR SVMXC__OptiMax_Message__c = 'In Progress')];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            /*  If the age of an existing job is greater than the setting value for Zombie Job Minutes, update End_Time__c = Now() , status__c = Canceled - Zombie.
                    If the age is less than the setting value for Zombie Job Minutes, do not proceed as another OptiMax job for the same territory is in progress.
                    Age of an existing job is the difference between start time and current time
                */
            boolean createNewJobRecord = false;
            if(SVMXJobs.size() == 0)
                createNewJobRecord = true;
            
            if(SVMXJobs.size() > 0)
            {
                list <SVMXC__SVMX_Jobs__c> SVMXJobsUpdate = new list<SVMXC__SVMX_Jobs__c> ();
                Datetime dtmNow = system.now();
                String strJobIds = '';
                String zombieJobId = '';
                try
                {
                    for(SVMXC__SVMX_Jobs__c oj: SVMXJobs)
                    {
                        Double dblAge = ((dtmNow.getTime() - oj.SVMXC__Start_Time__c.getTime()) / 60000);
                        System.debug(logginglevel.error,'mapSetting.get(OMAX002_SET002): '+mapSetting.get('OMAX002_SET002')+'  dblAge: '+dblAge);
                        //strLogger += system.now() + 'AP++  : mapSetting.get(OMAX002_SET002):  ' + mapSetting.get('OMAX002_SET002') + ' dblAge: '+dblAge+'\n';
                        if(dblAge >= Double.valueof(mapSetting.get('OMAX002_SET002')))
                        {
                            oj.SVMXC__Age__c = dblAge;
                            oj.SVMXC__Status__c = String.valueof(-4);
                            oj.SVMXC__End_Time__c = dtmNow;
                            oj.SVMXC__OptiMax_Message__c = 'Canceled - Zombie';
                            zombieJobId = oj.id;
                            SVMXJobsUpdate.add(oj);
                            // Marked existing job as Zombie, so create a new job for this run
                            createNewJobRecord = true;
                        }
                        else
                        {
                            strJobIds += oj.Id + '-' + oj.Name;
                            throw new SVMXException('OptiMax job(s) ' + strJobIds + ' for the same territory in progress');
                        }
                    }
                    
                    system.debug(logginglevel.error,'SVMXJobsUpdate '+SVMXJobsUpdate);
                    update SVMXJobsUpdate; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
                catch(Exception ex)
                {
                   //throw new SVMXException('There was a Zombie Job.Please rerun the Job');
                }
               
            }

            //Apurva===========================================
            
            if(createNewJobRecord)
            {
                // Check if territory exists
                SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
                try
                {
                    objTerritory = [Select Id from SVMXC__Territory__c where Id = :strTerritoryId];
                }
                catch(Exception ex)
                {
                    throw new SVMXException('Invalid territory found.');
                }
                system.debug('Territory ' + strTerritoryId + ' exists');

                // Check if dispatch process exists
                SVMXC__ServiceMax_Processes__c objSVMXProcess = new SVMXC__ServiceMax_Processes__c();
                try
                {
                    objSVMXProcess = [Select Id from SVMXC__ServiceMax_Processes__c where Id = :strDisptchProcId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
                catch(Exception ex)
                {
                    throw new SVMXException('Invalid dispatch process Id found.');
                }
                system.debug('Dispatch Process ' + strDisptchProcId + ' exists');
                
                SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
                objSVMXJob.SVMXC__SVMX_Process__c = strDisptchProcId;
                objSVMXJob.SVMXC__Territory__c = strTerritoryId;
                objSVMXJob.SVMXC__OptiMax_Message__c = 'Precalc Completed'; // Precalc Completed
                objSVMXJob.SVMXC__Start_Time__c = system.now();
                objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
                objSVMXJob.SVMXC__Status__c = '101';
                if(isFullRun)
                    objSVMXJob.SVMXC__Type__c = 'Full'; // FULL
                else
                    objSVMXJob.SVMXC__Type__c = 'Incremental';  // INCREMENTAL
                insert objSVMXJob; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

                system.debug('SVMX Job record created: ' + objSVMXJob);
                KeyValue keyValuePair = new KeyValue();
                keyValuePair.name = 'ServiceMaxJobId';
                keyValuePair.value = objSVMXJob.id;
                lstOutputKeyValuePairs.add(keyValuePair);
            }
        }
        system.debug('SMAX_Run_Precalc_WS output key value pair list: ' + lstOutputKeyValuePairs);
        return lstOutputKeyValuePairs;
    }
    

    /*
     *Type : Webservice Method
     *Used : OptiMax Server 
     *Dir  : From OptiMax to Customer Org
     *Desc : Web Service on SFDC that OptiMax invokes for ServiceMax version 10.3 and above to initiate Qualified Technician List computation
     */
    webservice static list<KeyValue> SMAX_Run_QTL_WS(list<KeyValue> lstKeyValuePairs)
    {
        String strDisptchProcId = '';
        String strTerritoryId = '';
        Boolean isFullRun = false;
        list<KeyValue> lstOutputKeyValuePairs = new list<KeyValue>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSettings = new list<string>();
        lstSettings.add('OMAX003_SET032');
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('OMAX001_SET014');
        map<String, String> mapSetting = commSettings.SVMX_getGlobalSettingList(lstSettings);

        // Do not proceed if the setting Enable Dispatch Optimization is set to FALSE
        /*if(mapSetting.containsKey('GLOB001_GBL007') && mapSetting.get('GLOB001_GBL007').toUpperCase() == 'FALSE')
        {
            throw new SVMXException('Dispatch optimization is not enabled for the organization.');
        }*/

        system.debug('SMAX_Run_QTL_WS input key value pair list: ' + lstKeyValuePairs);
        if(lstKeyValuePairs.size() > 0)
        {
            for(Integer i = 0; i < lstKeyValuePairs.size(); i++)
            {
                if(lstKeyValuePairs[i].name.touppercase() == 'DISPATCHPROCESSID')
                    strDisptchProcId = lstKeyValuePairs[i].value;
                else if(lstKeyValuePairs[i].name.touppercase() == 'TERRITORYID')
                    strTerritoryId = lstKeyValuePairs[i].value;
            }
        }
        
        // Split the territoryID received from OptiMax to get the actual territoryGUID and check whether the run is full run or incremental run
        if(strTerritoryId.contains('_'))
        {
            list<String> lstTerritoryDef = new list<String>();
            lstTerritoryDef = strTerritoryId.split('_');
            strTerritoryId = lstTerritoryDef[0];
            if(lstTerritoryDef.size() > 1)
            {
                if(lstTerritoryDef[1].contains('FULL'))
                    isFullRun = true;
            }
        }
        else
            isFullRun = TRUE;

        if(strDisptchProcId != null && strDisptchProcId.length() > 0 && strTerritoryId != null && strTerritoryId.length() > 0)
        {
            //MCTM is calculated during precalculation hence not required to be validate the above logic. 
            //Fetch the svmxjob which status is Precalc Completed 
            SVMXC__SVMX_Jobs__c objSVMXJob;
            list<SVMXC__SVMX_Jobs__c> lstSvmxJobs = [Select Id, SVMXC__OptiMax_Message__c, SVMXC__Batch_Job__c
                            from SVMXC__SVMX_Jobs__c
                            where SVMXC__SVMX_Process__c = :strDisptchProcId and SVMXC__Territory__c = :strTerritoryId and 
                            SVMXC__OptiMax_Message__c = 'Precalc Completed' for update]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstSvmxJobs.size() > 0){
                objSVMXJob = lstSvmxJobs[0];
               //Update the job to QTL Completed and return to server for further initjob call
                objSVMXJob.SVMXC__Status__c = '201';
                objSVMXJob.SVMXC__OptiMax_Message__c = 'QTL Completed';
                upsert objSVMXJob; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                system.debug('SVMX Job record created: ' + objSVMXJob);
                KeyValue keyValuePair = new KeyValue();
                keyValuePair.name = 'ServiceMaxJobId';
                keyValuePair.value = objSVMXJob.id;
                lstOutputKeyValuePairs.add(keyValuePair);                      
            }
             
        }
        system.debug('SMAX_Run_QTL_WS output key value pair list: ' + lstOutputKeyValuePairs);
        return lstOutputKeyValuePairs;
    }
    
    /*
     *Type : Webservice Method
     *Used : OptiMax Server  
     *Dire : From OptiMax to Customer Org
     *Desc : Returns the list of Work Orders for which Pre-calc error occurred during batch update, and the value of configuration setting OMAX003 SET031
     */
    webservice static list<KeyValue> SMAX_Get_OptiMax_ErrorWO_WS(list<KeyValue> lstKeyValuePairs)
    {
        String strTerritoryId = '';
        String strWordOrder = '';
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSettings = new list<string>();
        lstSettings.add('OMAX003_SET030');
        lstSettings.add('OMAX003_SET031');
        map<String, String> mapSetting = commSettings.SVMX_getGlobalSettingList(lstSettings);
        Boolean isFullRun = false;
        KeyValue keyValuePair = new KeyValue();
        list<KeyValue> lstOutputKeyValuePairs = new list<KeyValue>();

        system.debug('SMAX_Get_OptiMax_ErrorWO_WS input key value pair list: ' + lstKeyValuePairs);
        if(lstKeyValuePairs.size() > 0)
        {
            for(Integer i = 0; i < lstKeyValuePairs.size(); i++)
            {
                if(lstKeyValuePairs[i].name.touppercase() == 'TERRITORYID')
                    strTerritoryId = lstKeyValuePairs[i].value;
            }
        }

        // Split the territoryID received from OptiMax to get the actual territoryGUID and check whether the run is full run or incremental run
        if(strTerritoryId.contains('_'))
        {
            list<String> lstTerritoryDef = new list<String>();
            lstTerritoryDef = strTerritoryId.split('_');
            strTerritoryId = lstTerritoryDef[0];
            if(lstTerritoryDef.size() > 1)
            {
                if(lstTerritoryDef[1].contains('FULL'))
                    isFullRun = true;
            }
        }
        else
            isFullRun = true;

        // If Runtime precalc is enabled and if it is a Full run, get the error work orders from the batch precalc
        if(mapSetting.containskey('OMAX003_SET030') && mapSetting.get('OMAX003_SET030').touppercase() == 'TRUE' && isFullRun)
        {
            list<SVMXC__Service_Order__c> lstWorkOrder = [select id, Name from SVMXC__Service_Order__c where SVMXC__Primary_Territory__c = :strTerritoryId and SVMXC__BatchUpdate__c = 'Yes' and SVMXC__OptiMax_Error_Occurred__c = true];
            for(SVMXC__Service_Order__c WO : lstWorkOrder)
            {
                if(strWordOrder.length() > 0)
                    strWordOrder += ',' + WO.id + '~' + WO.Name;
                else
                    strWordOrder +=  WO.id + '~' + WO.Name;
            }
        }

        // Return the error work order string and value of OMAX003_SET031
        keyValuePair.name = 'WorkOrders';
        keyValuePair.value = strWordOrder;
        lstOutputKeyValuePairs.add(keyValuePair);
        KeyValue keyValuePair1 = new KeyValue();
        keyValuePair1.name = 'Abort on error during runtime calculation of dispatch process and priority';
        if(mapSetting.containskey('OMAX003_SET031') && mapSetting.get('OMAX003_SET031') != null)
            keyValuePair1.value =  mapSetting.get('OMAX003_SET031');
        else
            keyValuePair1.value = 'False';
        lstOutputKeyValuePairs.add(keyValuePair1);
        System.debug('Get OptiMax Error WO WS Output key value pair list: ' + lstOutputKeyValuePairs);
        return lstOutputKeyValuePairs;                          
    }

    /*
     *Type : Webservice Method
     *Used : OptiMax Server 
     *Dir  : From OptiMax to Customer Org
     *Desc : Web Service on SFDC that OptiMax invokes to get the status of the SVMX Job Record
     */
    webservice static list<KeyValue> SMAX_Get_Job_Status_WS(list<KeyValue> lstKeyValuePairs)
    {
        String strJobID = '';
        KeyValue keyVal = new KeyValue();
        list<KeyValue> lstOutputKeyValuePairs = new list<KeyValue>();

        system.debug('SMAX_Get_Job_Status_WS input key value pair list: ' + lstKeyValuePairs);
        if(lstKeyValuePairs.size() > 0)
        {
            for(Integer i = 0; i < lstKeyValuePairs.size(); i++)
            {
                if(lstKeyValuePairs[i].name == 'ServiceMaxJobId')
                    strJobID = lstKeyValuePairs[i].value;
            }
        }

        try
        {
            SVMXC__SVMX_Jobs__c smaxJob = [Select SVMXC__Status__c, Id From SVMXC__SVMX_Jobs__c where Id = :strJobID]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
          
            if(smaxJob != null)
            {
                keyVal.name = 'StatusCode';
                keyVal.value = smaxJob.SVMXC__Status__c;
                lstOutputKeyValuePairs.add(keyVal);
            }
            
        }
        catch(exception ex)
        {
            throw new SVMXException('Got exception on querying for SVMX Job: ' + ex.getMessage());
        }

        system.debug('SMAX_Get_Job_Status_WS output key value pair list: ' + lstOutputKeyValuePairs);
        return lstOutputKeyValuePairs;
    }
    
    // To check if the particular day is holiday
    /*public static boolean isHoliday(Date datSelectedDate){
    
        boolean isHoliday = false;
        List<Holiday> listOfAllHolidays = [SELECT ActivityDate,IsRecurrence,CreatedDate,EndTimeInMinutes,Id,IsAllDay,Name,StartTimeInMinutes,RecurrenceEndDateOnly,RecurrenceStartDate FROM Holiday];
        
        for(Holiday eachHoliday : listOfAllHolidays) {
            if(datSelectedDate == eachHoliday.ActivityDate) {
                isHoliday = true;
            }
        }
        
        return isHoliday;
    }*/
    /*
     *Type : Webservice Method
     *Used : OptiMax Webservices
     *Dir  : From OptiMax to Customer Org
     *Desc : WebService Initiate Method
             This method is called when a dispatch optimization job is initiated in OptiMax for a territory. The service resides in Force.com and provides the applicable configuration settings and data (work orders and resources) to run the job in OptiMax
     */
    WebService static opInitateJobs_WP SMAX_Initiate_OptiMax_Job_WS(String strUserId, String strTerritoryId, String strDispatchProcessId)
    {
        opInitateJobs_WP wrapSet = new opInitateJobs_WP();
        TechnicianAdditonalDetails_WP techAddtionalDetailsWP = new TechnicianAdditonalDetails_WP();
        SMAX_OptiMax_Engine_Ext clsOMaxExtension = new SMAX_OptiMax_Engine_Ext();
        SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
        
        // Variable definitions
        String strLogger = '';
        String strWOeventLog;
        set<Id> setReschedExternalWOs;
        String strDefaultBHourId;
        String strDispatchProcessKeyPrefix;
        String strRunType;
        
        Date datStartDate;
        Date datEndDate;
        Datetime dtmNow = system.now();
        DateTime dtmSchedulingHorizonStartDateTime;
        Datetime dtmLastProcessedDateTime;
        Datetime dtmSchedulingHorizonEndDateTime;
        
        Integer intWOBatchSize = 100;
        Integer intNoOfDays;
        Integer intCapExtMaxThreshold;
        Integer intImportance = 0;
        Integer intRetainApptPriority = 6;
        Integer intIncrWOPriority = 100;
        Integer intPreferredResourcePriority = 1000;
        Integer intExternalWOPriority = 100;
        Integer intExternalWOPreferredResourcePriority = 100;
        Integer intLimitCpuTime = Limits.getLimitCpuTime();
        Integer intLimitHeapSize = Limits.getLimitHeapSize();
        Double dblDefaultServiceDuration = 0;
        Decimal dclAverageDriveTime;
        Integer intIncrementalRunLeadTime = 0;
        
        Boolean isDebugEnabled = FALSE;
        Boolean isFullRun = FALSE;
        Boolean isDays = FALSE;
        Boolean isFirstInitCall = FALSE;
        Boolean isProcessingAdditionalWorkOrders = FALSE;
        // Technician expertise batching - start
        Boolean isProcessingTechnicianExpertise = FALSE;
        // Technician expertise batching - end
        
        BusinessHours objDefTerritoryBH;
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
        SVMXC__ServiceMax_Processes__c objSVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__SVMX_Jobs__c objJob = new SVMXC__SVMX_Jobs__c();
        
        Expertise_WP techSkill;
        Product_WP techProduct;
        //Heap size issue - Commenting as it is not used
        //set<String> setAvailtech = new set<String>();
        set<String> setWorkOrdersToUpdate = new set<String>();
        set<Date> setSchedHorizDates = new set<Date>();
        
        list<BusinessHours> lstBusinessHours = new list<BusinessHours>();
        List<SVMXC__SVMX_Jobs__c> lstSvmxZombiJobs = new List<SVMXC__SVMX_Jobs__c>();
        List<SVMXC__SVMX_Jobs__c> lstSvmxJobs = new List<SVMXC__SVMX_Jobs__c>();
        List<SVMXC__Service_Group_Members__c> lstTechnicians = new List<SVMXC__Service_Group_Members__c>();
        //List<SVMXC__Service_Group_Skills__c> lstTeamSkills = new List<SVMXC__Service_Group_Skills__c>();
        //List<SVMXC__Service_Group_Product__c> lstTeamProducts = new List<SVMXC__Service_Group_Product__c>();
        //List<TechniciansEvents_WP> lstTechniciansEvents = new List<TechniciansEvents_WP>();
        List<Expertise_WP> lstTechSkill;
        List<Product_WP> lstTechProduct;
        List<SVMXC__Service_Order__c> lstWorkOrderObj = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Group_Members__c> listValidTech = new List<SVMXC__Service_Group_Members__c>();
        List<SVMXC__Service_Order__c> lstWorkOrderToUpdate = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> lstValidWorkOrder = new List<SVMXC__Service_Order__c>();        

        Map<String, BusinessHours> mapBusinessHours = new Map<String, BusinessHours>();
        Map<String, List<Product_WP>> mapTechProduct = new Map<String, List<Product_WP>>();
        Map<String, List<Expertise_WP>> mapTechSkill = new Map<String, List<Expertise_WP>>();
        Map<id, Map<date, list<ExecutionTime_WP>>> mapTechAvailability = new Map<id, Map<date, list<ExecutionTime_WP>>>();
        Map<String, TechniciansEventsAdditonalDetails_WP> mapTechAdditionalDetails = new Map<String, TechniciansEventsAdditonalDetails_WP>();
        Map<String, Map<Date, ExecutionTime_WP>> mapBHTimeWindows = new Map<String, Map<Date, ExecutionTime_WP>>();
        Map<String, List<ExecutionTime_WP>> mapWOTimeWindows = new Map<String, List<ExecutionTime_WP>>();
        //Map<Id, Map<DateTime, Id>> mapTechIdStrtDtTEventId = new Map<Id, Map<DateTime, Id>>();
        Map<DateTime, Id> mapStrtDtTEventId = new Map<DateTime, Id>();
        
        //Map of Technician with start date time and event id
        Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTechIdExecTimeEventId = new Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        
        //Map of Technician with start date time and ONS event id
        Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTechIdONSExecTimeEventId = new Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        
        //Map of Technician with BreakHour start and end datetime
        Map<Id, Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTechIdBreakEventExecTime = new Map<Id, Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        
        //Capacity Reservation
        Map<Id, SVMXC__ServiceMax_Processes__c> mapCapacityRules = new Map<Id, SVMXC__ServiceMax_Processes__c>();   
        
        list<BusinessHours> lstWOBusinessHours = new list<BusinessHours>();
        
        //Begin : Sadiya - Overnight Stay Policy
        Map<String,SVMXC__SM_Overnight_Stay_Policy__c> techniciansAndOvernightPolicyMap;
        SMAX_OptiMax_EngineUtils.OMAX_OvernightUtils omaxOvernightUtils = new SMAX_OptiMax_EngineUtils.OMAX_OvernightUtils();
        //end  : Sadiya - Overnight Stay Policy
        
        strlogger += system.now() + ': InitiateJob WS call input parameters: User Id - ' + strUserId + '; Territory Id - ' + strTerritoryId + '; Dispatch Process Id / SVMX Job Id - ' + strDispatchProcessId + '\n';
        //strLogger += system.now() + ': Usage Details: Before processing settings\n\tHeap Size     : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
        
        list<string> lstSettings = new list<string>{'OMAX001_SET001','OMAX001_SET002','OMAX001_SET003','OMAX001_SET004','OMAX001_SET005','OMAX001_SET006','OMAX001_SET007','OMAX001_SET008','OMAX001_SET009','OMAX001_SET011','OMAX001_SET012','OMAX001_SET013',
            'OMAX002_SET002','OMAX002_SET003','OMAX002_SET004','OMAX002_SET005','OMAX002_SET006','OMAX002_SET007','OMAX002_SET008','OMAX002_SET009','OMAX002_SET010','OMAX003_SET004','OMAX003_SET018','OMAX003_SET012','OMAX003_SET020','OMAX003_SET021',
            'OMAX003_SET022','OMAX003_SET023','OMAX003_SET024','OMAX003_SET025','OMAX003_SET026','OMAX003_SET027','OMAX003_SET028','OMAX003_SET029','OMAX003_SET037','OMAX003_SET038','OMAX003_SET039','OMAX003_SET040','OMAX003_SET041',
            'OMAX001_SET015','OMAX001_SET016','OMAX001_SET017','GLOB001_GBL005','GLOB001_GBL006','GLOB001_GBL007', 'OMAX001_SET014', 'DCON004_SET014','DCON001_SET071','OMAX003_SET054','OMAX003_SET053','OMAX003_SET052','OMAX001_SET00999','OMAX001_SET00888','OMAX001_SET00700','OMAX001_SET00701','OMAX001_SET00702'};
        map<String, String> mapSettingValues = clsCommSettings.SVMX_getGlobalSettingList(lstSettings);
        
        //system.debug('Usage Details: after retrieving settings\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
        // Only required for first InitiateJob WS call
        Map<String, String> mapTechWorkHours = new Map<String, String>();
        SMAX_OptiMax_Engine_Ext.capacityResult clsCapacityResult;
        
        // Only required for second InitiateJob WS call
        Map<Id, SVMXC__Service_Order__c> mapReschedWorkOrders = new Map<Id, SVMXC__Service_Order__c>();
        Map<Id, List<SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP>> mapExternalWOSchedule = new Map<Id, List<SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP>>();
        List<WorkOrder_WP> wo_WPL = new List<WorkOrder_WP>();
        
        if(mapSettingValues.containsKey('OMAX003_SET029'))
            intWOBatchSize = Integer.valueOf(mapSettingValues.get('OMAX003_SET029'));
        if(mapSettingValues.containsKey('OMAX003_SET020'))
            intRetainApptPriority = Integer.valueOf(mapSettingValues.get('OMAX003_SET020'));
        if(mapSettingValues.containsKey('OMAX003_SET023'))
            intIncrWOPriority = Integer.valueOf(mapSettingValues.get('OMAX003_SET023'));
        if(mapSettingValues.containsKey('OMAX003_SET025'))
            intPreferredResourcePriority = Integer.valueOf(mapSettingValues.get('OMAX003_SET025'));
        if(mapSettingValues.containsKey('OMAX003_SET026'))
            intExternalWOPriority = Integer.valueOf(mapSettingValues.get('OMAX003_SET026'));
        if(mapSettingValues.containsKey('OMAX003_SET027'))
            intExternalWOPreferredResourcePriority = Integer.valueOf(mapSettingValues.get('OMAX003_SET027'));
        if(intWOBatchSize < 1)
            intWOBatchSize = 100;
        if(intRetainApptPriority < 1)
            intRetainApptPriority = 6;
        if(intIncrWOPriority < 1)
            intIncrWOPriority = 6;
            
        Boolean isDependencyEnabled = false;
        //getting the dependency flag from the setting
        if(mapSettingValues.containsKey('DCON004_SET014')) {
            isDependencyEnabled = Boolean.valueOf(mapSettingValues.get('DCON004_SET014'));
        }
        
        // Get the key prefix for Salesforce Events
        Map<String, Schema.SObjectType> descAllObjs = Schema.getGlobalDescribe();
        Schema.Describesobjectresult descEventObj = descAllObjs.get('Event').getDescribe();
        strSfEventKeyPrefix = descEventObj.getKeyPrefix();

        // Get the key prefix for ServiceMax Events
        Schema.Describesobjectresult descSvmxEventsObj;
        if (descAllObjs.containsKey('SVMXC__SVMX_Event__c') == TRUE)
            descSvmxEventsObj = descAllObjs.get('SVMXC__SVMX_Event__c').getDescribe();
        else
            descSvmxEventsObj = descAllObjs.get('SVMX_Event__c').getDescribe();
        strSvmxEventKeyPrefix = descSvmxEventsObj.getKeyPrefix();

        // Get the key prefix for Dispatch Process
        Schema.Describesobjectresult descDispatchProcessObj;
        if (descAllObjs.containsKey('SVMXC__ServiceMax_Processes__c') == TRUE)
            descDispatchProcessObj = descAllObjs.get('SVMXC__ServiceMax_Processes__c').getDescribe();
        else
            descDispatchProcessObj = descAllObjs.get('ServiceMax_Processes__c').getDescribe();
        strDispatchProcessKeyPrefix = descDispatchProcessObj.getKeyPrefix();
        
        //Heap size issue
        descAllObjs.clear();
        descDispatchProcessObj = null;
        // Do not proceed if the setting Enable Dispatch Optimization is set to FALSE
        /*if(mapSettingValues.containsKey('GLOB001_GBL007') && mapSettingValues.get('GLOB001_GBL007').toUpperCase() == 'FALSE')
        {
            throw new SVMXException('Dispatch optimization is not enabled for the organization.');
        }*/
        
        // Split the territoryID received from OptiMax to get the actual territoryGUID and check whether the run is full run or incremental run
        if(strTerritoryId.contains('_'))
        {
            List<String> lstTerritoryDef = new List<String>();
            lstTerritoryDef = strTerritoryId.split('_');
            strTerritoryId = lstTerritoryDef[0];
            if(lstTerritoryDef.size() > 1)
            {
                if(lstTerritoryDef[1].contains('FULL'))
                    isFullRun = TRUE;
            }
        }
        else
            isFullRun = TRUE;
            
        // If the given dispatch process Id starts with the key prefix of ServiceMax Process object, it is the first InitiateJob WS call
        if(strDispatchProcessId.startsWith(strDispatchProcessKeyPrefix))
        {
            isFirstInitCall = TRUE;
        }
        
        /*  If it is the first InitiateJob WS call, retrieve the work orders, technicians, and events,
            calculate the capacity & extend it if needed, and send the technicians, events, and job params to OptiMax.
            Save the ids of new work orders, scheduling horizon dates, and start date time of the first day in scheduling horizon.
            This is required to process and send the list of work orders in response to the second InitiateJob WS call.
        */
        if(isFirstInitCall == TRUE)
        {
            // Checking if territory exists
            try
            {
                objTerritory = [Select Id, SVMXC__Territory_s_Business_Hours__c, SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey, SVMXC__Territory_s_Business_Hours__r.Id, SVMXC__Break_Hours__c, SVMXC__Average_Driving_Time__c, SVMXC__Per_Mile_Cost__c,
                                SVMXC__Max_Distance__c, SVMXC__Average_Speed__c, SVMXC__Fixed_Cost__c, SVMXC__Per_hour_Cost__c, SVMXC__Mode_Of_Travel__c,SVMXC__SM_Overnight_Stay_Policy__c
                                from SVMXC__Territory__c
                                where Id = :strTerritoryId];
            }
            catch(Exception ex)
            {
                throw new SVMXException('Invalid territory found.');
            }
            strLogger += system.now() + ': Territory ' + strTerritoryId + ' exists\n';
            
            // Retrieve the process definition record from ServiceMax_Processes__c by matching the ID with the given dispatch process ID
            try
            {
                objSVMXProcess = [Select Id, SVMXC__Child_Object_Criteria__c, SVMXC__Frequency__c, SVMXC__Full_Run_Unit__c, SVMXC__Retain_Appointment__c,
                                SVMXC__Retain_Assignment__c, SVMXC__Route_Type__c, SVMXC__Weight_Time_Window__c, SVMXC__Weight_Total_Distance__c, SVMXC__Weight_Route_Distance__c,
                                SVMXC__Weight_Node_Type__c, SVMXC__Calendar_Start_Type__c, SVMXC__Calendar_End_Type__c, 
                                SVMXC__Weight_Route_Time__c,
                                SVMXC__Tolerance__c, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Preferred_Tech_Enabled__c, SVMXC__Expertise_Match_Enabled__c,
                                SVMXC__Product_Match_Enabled__c, SVMXC__SM_Drive_Before_Shift_Start__c, SVMXC__SM_Drive_After_Shift_End__c, SVMXC__Optimization_Goal__c
                                from SVMXC__ServiceMax_Processes__c
                                where Id =:strDispatchProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            catch(Exception ex)
            {
                throw new SVMXException('Invalid dispatch process Id found.');
            }
            strLogger += system.now() + ': Dispatch Process ' + strDispatchProcessId + ' exists\n';

            // Retrieve records from SVMX_Jobs__c where Dispatch_Process__c = Given dispatch process ID, Territory__c = Given territory ID, status__c = In Progress or Initiated or Running Precalc
            try
            {
                lstSvmxJobs = [Select Id, SVMXC__OptiMax_Message__c, SVMXC__Batch_Job__c
                                from SVMXC__SVMX_Jobs__c
                                where SVMXC__SVMX_Process__c = :strDispatchProcessId and SVMXC__Territory__c = :strTerritoryId and 
                                SVMXC__OptiMax_Message__c = 'QTL Completed' for update]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstSvmxJobs.size() > 0)
                {
                    objJob = lstSvmxJobs[0];
                    // If QTL is completed, proceed with the Initiate Job by changing the status to Initiated
                    objJob.SVMXC__OptiMax_Message__c = 'Initiated'; // Initiated
                    objJob.SVMXC__Status__c = '0';
                    update lstSvmxJobs; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
                
            }
            catch(Exception e)
            {
                strLogger += system.now()+'Inside isFirstInitCall == TRUE ::Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n';
                throw new SVMXException(e.getMessage());
            }
            strLogger += system.now() + ': Initiating SVMX Job ' + objJob.Id + '\n';
        }
        else // if(isFirstInitCall == FALSE)
        {
            // Retrieve records from SVMX_Jobs__c where Id = Given dispatch process ID
            try
            {
                objJob = [Select Id, SVMXC__Status__c, SVMXC__Age__c, SVMXC__Sent_Work_Orders__c, SVMXC__Message__c, SVMXC__Start_Time__c, SVMXC__End_Time__c, SVMXC__SVMX_Process__c,
                            SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Territory__r.SVMXC__Break_Hours__c from SVMXC__SVMX_Jobs__c
                            where Id = :strDispatchProcessId for update]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(((dtmNow.getTime() - objJob.SVMXC__Start_Time__c.getTime()) / 60000) > 10)
                {
                    objJob.SVMXC__Status__c = String.valueof(-5);
                    objJob.SVMXC__End_Time__c = dtmNow;
                    objJob.SVMXC__OptiMax_Message__c = 'Aborted';
                    update objJob; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(isDebugEnabled == FALSE)
                        strLogger = '';
                    wrapSet.status = -1;
                    wrapSet.message = strLogger + 'Aborted the time difference between the two Init calls is > 10 minutes';
                    return wrapSet;
                }
                strDispatchProcessId = objJob.SVMXC__SVMX_Process__c;
            }
            catch(QueryException ex)
            {
                throw new SVMXException('Invalid Job Id ' + strDispatchProcessId + ' found');
            }
            catch(Exception e)
            {
                strLogger += system.now()+'Inside isFirstInitCall == FALSE::Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n';
                throw new SVMXException(e.getMessage());
            }
            
            // Retrieve the process definition record from ServiceMax_Processes__c by matching the ID with the dispatch process ID
            try
            {
                objSVMXProcess = [Select Id, SVMXC__Child_Object_Criteria__c, SVMXC__Frequency__c, SVMXC__Full_Run_Unit__c, SVMXC__Retain_Appointment__c, SVMXC__Retain_Assignment__c,
                                SVMXC__Route_Type__c, SVMXC__Weight_Time_Window__c, SVMXC__Weight_Total_Distance__c, SVMXC__Weight_Route_Distance__c, SVMXC__Weight_Node_Type__c,
                                SVMXC__Calendar_Start_Type__c, SVMXC__Calendar_End_Type__c,
                                SVMXC__Weight_Route_Time__c, SVMXC__Tolerance__c,
                                SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Preferred_Tech_Enabled__c, SVMXC__Expertise_Match_Enabled__c,
                                SVMXC__Product_Match_Enabled__c, SVMXC__Dispatch_Method__c, SVMXC__SM_Drive_Before_Shift_Start__c, SVMXC__SM_Drive_After_Shift_End__c, SVMXC__Optimization_Goal__c
                                from SVMXC__ServiceMax_Processes__c
                                where Id =:strDispatchProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            catch(Exception e)
            {
                strLogger += system.now()+'Invalid dispatch process Id found::Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n';
                throw new SVMXException('Invalid dispatch process Id found.');
            }
            if(isFullRun == TRUE)
            {
                if((objSVMXProcess.SVMXC__Full_Run_Unit__c).toUpperCase() == 'DAYS')
                {
                    isDays = TRUE;
                }
            }
        }
        
        try
        {
        if(mapSettingValues.containsKey('OMAX003_SET018') && mapSettingValues.get('OMAX003_SET018').toUpperCase() == 'TRUE')
            isDebugEnabled = TRUE;
        
        //Code fix  start for HACH customer
        //Fetching work orders and technicians and create set of BHs from work orders and technicians for query the BHs.
        //system.debug('Usage Details: Before retrieving work orders\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
        //strLogger += system.now() + ': Usage Details: Before retrieving work orders\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
        //Check the BH attachment already created or not
        set<String> setBhId = new set<String>();
        boolean isAttachmentAvailable = false;
        try {
            Attachment objBhIdAttach = [SELECT Body from Attachment where Name = 'Valid BusinessHours' and ParentId = :objJob.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            list<String> lstBHId = new List<String>();
            if(objBhIdAttach != null){
                isAttachmentAvailable = true;
                lstBHId = objBhIdAttach.Body.toString().split(',');
                setBhId = new set<String>(lstBHId);
            }
            strLogger += system.now() + ': lstBHId size..after retrieving from attachment.. ' + lstBHId.size() + ' \n';
            strLogger += system.now() + ': setBhId size..after retrieving from attachment.. ' + setBhId.size() + ' \n';
        }catch(Exception ex){
            isAttachmentAvailable = false;
            strLogger += system.now() + ': No Valid BusinessHours attachments.....  \n';
        }

        boolean isStartRun = true;
        if(!isAttachmentAvailable){
            //String strWorkOrderQuery = 'Select Id, Name, SVMXC__Dispatch_Priority__c, SVMXC__Service_Duration__c, SVMXC__Preferred_Business_Hours__c, SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Primary_Territory__r.name, SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__r.IsActive, SVMXC__QTL_Status__c,SVMXC__Zip__c,SVMXC__Locked_By_DC__c,SVMXC__Latitude__c,SVMXC__Longitude__c,SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Country__c,SVMXC__SM_Schedule_Violation_Penalty__c, SVMXC__Purpose_of_Visit__c from SVMXC__Service_Order__c WHERE SVMXC__Primary_Territory__c = \'' + strTerritoryId + '\' AND SVMXC__Dispatch_Process__c = \'' + strDispatchProcessId + '\' AND SVMXC__OptiMax_status__c != \'' + 'Processing Complete' + '\' for update';
            //added dispatch status = new and locked by dc != true
            String strWorkOrderQuery = 'Select Id, Name, SVMXC__Dispatch_Priority__c, SVMXC__Service_Duration__c, SVMXC__Preferred_Business_Hours__c, SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Primary_Territory__r.name, SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__r.IsActive, SVMXC__QTL_Status__c,SVMXC__Zip__c,SVMXC__Locked_By_DC__c,SVMXC__SM_Lock_Appointment_Schedule__c, SVMXC__SM_Appointment_Type__c, SVMXC__Latitude__c,SVMXC__Longitude__c,SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Country__c,SVMXC__SM_Schedule_Violation_Penalty__c, SVMXC__SM_Capacity_Rule_Name__c from SVMXC__Service_Order__c WHERE (SVMXC__Locked_By_DC__c != true OR SVMXC__SM_Lock_Appointment_Schedule__c != \'' + WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE + '\') AND SVMXC__Primary_Territory__c = \'' + strTerritoryId + '\' AND SVMXC__Dispatch_Process__c = \'' + strDispatchProcessId + '\' AND SVMXC__OptiMax_status__c != \'' + 'Processing Complete' + '\' AND SVMXC__Dispatch_Status__c = \'' + 'New' + '\' for update';

            if(isFullRun == FALSE)
            {
                if(objSVMXProcess.SVMXC__Child_Object_Criteria__c != NULL)
                strWorkOrderQuery += ' AND (' + objSVMXProcess.SVMXC__Child_Object_Criteria__c + ')';
            }
            lstWorkOrderObj = Database.query(strWorkOrderQuery);
            
            // Retrieve technician records from Service_Group_Members__c for the given territory ID
            //strLogger += system.now() + ': Usage Details: Before retrieving technicians\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
                          
            lstTechnicians = [Select Id, Name, SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Service_Territory__r.SVMXC__Per_Mile_Cost__c,
                            SVMXC__Service_Territory__r.SVMXC__Per_Hour_Cost__c, SVMXC__Service_Territory__r.SVMXC__Fixed_Cost__c, SVMXC__Service_Territory__r.SVMXC__Max_Hours__c,
                            SVMXC__Service_Territory__r.SVMXC__Average_Speed__c, SVMXC__Service_Territory__r.SVMXC__Max_Daily_Hours__c, SVMXC__Max_Hours__c,
                            SVMXC__Service_Territory__r.SVMXC__Max_Distance__c, 
                            SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive, SVMXC__Fixed_Cost__c, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c, SVMXC__Per_hour_Cost__c,
                            SVMXC__Per_Mile_Cost__c, SVMXC__Average_Speed__c, SVMXC__Max_Daily_Hours__c, SVMXC__Max_Distance__c,
                            SVMXC__Working_Hours__c ,SVMXC__Working_Hours__r.IsActive, SVMXC__Break_Hours__r.IsActive,
                            SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c , SVMXC__Break_Hours__c, SVMXC__Enable_Scheduling__c,SVMXC__SM_Overnight_Stay_Policy__c,SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.IsActive, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey
                            from SVMXC__Service_Group_Members__c 
                            where SVMXC__Active__c = TRUE AND SVMXC__Service_Territory__c = :strTerritoryId AND ((SVMXC__Enable_Scheduling__c = TRUE AND SVMXC__Salesforce_User__c = NULL) OR (SVMXC__Salesforce_User__c != NULL AND SVMXC__Salesforce_User__r.IsActive = true) )];                
            
            strLogger += system.now() + ': Number of work orders available: ' + lstWorkOrderObj.size() + ' \n';
            strLogger += system.now() + ': Number of technicians available: ' + lstTechnicians.size() + ' \n';
            
            //TODO: check the optimizer transaction record if there is no new work order for this run.
            if(lstWorkOrderObj.size() == 0){
                isStartRun = false;
                List<SVMXC__SVMX_Optimizer__c> lstBatchOptimizer = [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__WhatId__c,SVMXC__Optimizer_Connection_ID__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatType__c ='BATCH_TECHNICIAN' AND SVMXC__Optimizer_Connection_ID__c =: objTerritory.Id];
                if(lstBatchOptimizer != null && lstBatchOptimizer.size() > 0 && lstBatchOptimizer[0].SVMXC__Optimizer_Change_Token__c.equalsIgnoreCase('TRUE')){
                    strLogger += system.now() + ': No new work order for the run and check the flag status in optimizer record: ' + lstBatchOptimizer[0].SVMXC__Optimizer_Change_Token__c + ' \n';
                    isStartRun = true;
                }
            }
            
            //if(lstWorkOrderObj.size() == 0 || lstTechnicians.size() == 0)
            if(!isStartRun || lstTechnicians.size() == 0)
                throw new SVMXException('Work Orders or Technicians not available for this dispatch process.');
            //system.debug('Usage Details: After retrieving work orders and technicians\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
            //strLogger += system.now() + ': Usage Details: After retrieving work orders and technicians\n\tHeap Size       : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            //create valide set of BH id from work orders and technicians
            for(SVMXC__Service_Order__c wo : lstWorkOrderObj){
                if(wo.SVMXC__Preferred_Business_Hours__c != null && wo.SVMXC__Preferred_Business_Hours__r.IsActive)
                    setBhId.add(wo.SVMXC__Preferred_Business_Hours__c);   
            }
            //create set of Capacity Reservation rule id from work order.
            mapCapacityRules.putAll([SELECT Id, Name, SVMXC__Sequence__c, SVMXC__Name__c, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__SM_Capacity_Threshold__c, RecordType.Name from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =:objSVMXProcess.Id And RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Capacity Reservation' order by SVMXC__Sequence__c]); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA        
            strLogger += system.now() + ': First call - Capacity rules size : '+mapCapacityRules.size()+'\n';
                        
            for(SVMXC__Service_Group_Members__c tech : lstTechnicians){
                if(tech.SVMXC__Working_Hours__c != null && tech.SVMXC__Working_Hours__r.IsActive)
                    setBhId.add(tech.SVMXC__Working_Hours__c);   
                
                if(tech.SVMXC__Break_Hours__c != null && tech.SVMXC__Break_Hours__r.IsActive)
                    setBhId.add(tech.SVMXC__Break_Hours__c);
            }

            //include territory bh id into set.
            if(objTerritory.SVMXC__Territory_s_Business_Hours__c != NULL)
                setBhId.add(objTerritory.SVMXC__Territory_s_Business_Hours__c);

            String strBhId = '';
            for(String bhId : setBhId)
            {
                if(strBhId != '')
                    strBhId += ',';
                strBhId += bhId;
            }
            strLogger += system.now() + ': Before create Valid BusinessHours attachment::Valid BH ids...: ' + strBhId + '\n';
            
            //Create valid BH id as attachment for further initate job and complete job.
            Attachment objValidBHAttach = new Attachment(Name = 'Valid BusinessHours', ParentId = objJob.Id, Body = Blob.valueOf(strBhId), IsPrivate = TRUE);
            insert objValidBHAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            objValidBHAttach=null;
        }
        //Code fix end for HACH customer
                
        // Condition to load only default business hours or those in territory time zone
        //String territoryTZsidKey = objTerritory.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
        // Get the list of all the active Business Hours and put them in a map.
        lstBusinessHours = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
                            from BusinessHours where Id in : setBhId OR IsDefault = TRUE]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            //where IsActive = TRUE AND (IsDefault = TRUE OR TimeZoneSidKey = :territoryTZsidKey)];
        lstBusinessHours = clsOMaxExtension.getCompleteBusinessHour(lstBusinessHours);
        for(BusinessHours bh : lstBusinessHours)
        {
            mapBusinessHours.put(bh.Id, bh);
            if(bh.IsDefault == TRUE)
                strDefaultBHourId = bh.Id;
        }
        //Heap size issue
        lstBusinessHours.clear();
        /*  If Territory business hours is NULL or is not active, set it to the Org's Default business hours.
            This is the default Business Hours to be used for this Dispatch job.
        */
        //strLogger += system.now() + ': objTerritory.SVMXC__Territory_s_Business_Hours__c: ' + objTerritory.SVMXC__Territory_s_Business_Hours__c + '\n';
        //strLogger += system.now() + ': objJob.SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c: ' + objJob.SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c + '\n';
        
        //First Time when initJob() webservice is called from Server, Territory Object is queried. Hence check if the BH is available from Territory
        //If not available then refer the Default BH.
        if(isFirstInitCall) {
            if(objTerritory.SVMXC__Territory_s_Business_Hours__c == NULL || (mapBusinessHours.containsKey(objTerritory.SVMXC__Territory_s_Business_Hours__c) == FALSE ))
                objTerritory.SVMXC__Territory_s_Business_Hours__c = strDefaultBHourId;
            
            // If territory's break hours is inactive, set it to NULL
            if (objTerritory.SVMXC__Break_Hours__c != NULL && mapBusinessHours.containsKey(objTerritory.SVMXC__Break_Hours__c) == FALSE)
                objTerritory.SVMXC__Break_Hours__c = NULL;
        } else {
            //Second time when the initJob() webservice is called from server, Job object is queried and not Territory object. Hence get the Territory BH from the
            // Territory Reference from the Job Object as in the below logic. If not available, then refer the Default BH
            if(objJob.SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c == NULL || (mapBusinessHours.containsKey(objJob.SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c) == FALSE )) {
                objTerritory.SVMXC__Territory_s_Business_Hours__c = strDefaultBHourId;
            } else {
                objTerritory.SVMXC__Territory_s_Business_Hours__c = objJob.SVMXC__Territory__r.SVMXC__Territory_s_Business_Hours__c;
            }
            
            if (objJob.SVMXC__Territory__r.SVMXC__Break_Hours__c != NULL && mapBusinessHours.containsKey(objJob.SVMXC__Territory__r.SVMXC__Break_Hours__c) == FALSE)
                objTerritory.SVMXC__Break_Hours__c = NULL;
        }
        objDefTerritoryBH = mapBusinessHours.get(objTerritory.SVMXC__Territory_s_Business_Hours__c);
        
        
        strLogger += system.now() + ': Default Business Hours for this job: ' + objDefTerritoryBH.Id + '\n';
        strRunType = clsEngineUtils.getRunType(objDefTerritoryBH, isFullRun);
        strLogger += system.now() + ': Job RunType: ' + strRunType + '\n';
        //set Job RunType always as 'JOBTYPE.FULL_OVERNIGHT' to avoid setting current location for technician. 
        strRunType = 'JOBTYPE.FULL_OVERNIGHT';
        
         Boolean isMile = false;
         if(mapSettingValues.containsKey('GLOB001_GBL006') && mapSettingValues.get('GLOB001_GBL006').toUpperCase() == 'MILE')
         {
                isMile = true;
         }
    
        if(isFirstInitCall == TRUE)
        {
            /*  If isFullRun = TRUE:
                Validate the Start After Days: If Start After Days < 0, set it to 0
                Validate the scheduling horizon: If Schedule For Days < 1, set it to 1
            */
            if(isFullRun == TRUE)
            {
                intNoOfDays = (objSVMXProcess.SVMXC__Calendar_End_Days__c).intValue();
                if(intNoOfDays < 1)
                    intNoOfDays = 1;
                Integer intStartAfterDays;
                Integer intStartAfterHours;
                
                if((objSVMXProcess.SVMXC__Full_Run_Unit__c).toUpperCase() == 'DAYS')
                {
                    isDays = TRUE;
                    intStartAfterDays = objSVMXProcess.SVMXC__Calendar_Start_Days__c.intValue();
                    if(intStartAfterDays < 0)
                        intStartAfterDays = 0;
                }
                else
                {
                    isDays = FALSE;
                    intStartAfterHours = objSVMXProcess.SVMXC__Frequency__c.intValue();
                    if(intStartAfterHours < 1)
                        intStartAfterHours = 1;
                }
                
                if(isDays == TRUE)
                {
                    /*  Get the Start Date of the scheduling horizon as follows:
                        Get the next working day start time with reference to Current Time
                        e.g. If Current Time = 7 AM 1/Dec/2010, with 8 - 5 Mon - Fri BH, next working day start time = 1/Dec/2010 8 AM
                        Then add Start After days defined in the Dispatch Process using Business Hours. This will be the dtmSchedulingHorizonStartDateTime
                    */

                    Datetime tempStDt = clsOMaxExtension.getNextWorkingHour(objDefTerritoryBH, dtmNow);
                    //strLogger += system.now() + ': intStartAfterDays: ' + intStartAfterDays + '\n';
                    //strLogger += system.now() + ': before looping to find the actual Working day tempStDt: ' + tempStDt + '\n' ;
                    for (integer i = 0; i < intStartAfterDays; i++)
                    {
                        // We add 1 minute to the tempStDt every time through the loop to force getNextWorkingHour
                        // function to return the next working day. Else, it will keep returning the same date time
                        tempStDt = clsOMaxExtension.getNextWorkingHour(objDefTerritoryBH, tempStDt.addMinutes(1));
                        //strLogger += system.now() + ' inside loop tempStDt ' + tempStDt + '\n' ;
                    }
                    dtmSchedulingHorizonStartDateTime = tempStDt;
                }
                else // If run unit is Hour, get next working hour based on current time + startAfterHours
                {
                    dtmSchedulingHorizonStartDateTime = BusinessHours.addGmt(objDefTerritoryBH.id, dtmNow.addhours(intStartAfterHours), 1L);
                }
                //strLogger += system.now() + ': dtmSchedulingHorizonStartDateTime: ' + dtmSchedulingHorizonStartDateTime + ' , dtmNow: '+ dtmNow + ', intStartAfterHours: '+intStartAfterHours+'\n';
                // Get the date of the first day in the scheduling horizon in Business Hour time zone
                datStartDate = Date.valueOf(dtmSchedulingHorizonStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
                
                //strLogger += system.now() + ': Start date: ' + datStartDate + '\n';
                //strLogger += system.now() + ': First Day Start Time: ' + dtmSchedulingHorizonStartDateTime + '\n';
                
                // Starting from the first day, get all the dates in the scheduling horizon
                Date tempDate = datStartDate;
                dtmlastProcessedDateTime = dtmSchedulingHorizonStartDateTime;
                setSchedHorizDates.add(tempDate);
        
                //strLogger += system.now() + ': Initial scheduling horizon in business days: ' + intNoOfDays + '\n';
                
                for(integer i = 0; i < intNoOfDays - 1; i++)
                {
                    dtmlastProcessedDateTime = clsOMaxExtension.getNextWorkingHour(objDefTerritoryBH, dtmlastProcessedDateTime.addMinutes(1));
                    tempDate = Date.valueOf(dtmlastProcessedDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
                    setSchedHorizDates.add(tempDate);
                    datEndDate = tempDate;
                    //strLogger += system.now() + ': tempDate: ' + tempDate + '\n';
                }
                
                //strLogger += system.now() + ': setSchedHorizDates: ' + setSchedHorizDates + '\n';
                
                if(datEndDate != NULL)
                    intNoOfDays = datStartDate.daysBetween(datEndDate) + 1;
            }
            else // If Incremental Run
            {
                // Validate the Start After Hours: If Start After Hours < 1, set it to 1; Set Schedule For Days = 1
                Integer startAfterMinutes = objSVMXProcess.SVMXC__Frequency__c.intValue();
                if(startAfterMinutes < 1)
                    startAfterMinutes = 1;
                intIncrementalRunLeadTime = startAfterMinutes;
                intNoOfDays = 1;

                /*  Get the next business time by adding Start After Hours to current time; This is SchedulingHorizonStartDateTime
                    If the resulting date is not the same as today date (convert both to local date before comparing),
                    throw exception Not a working day / not enough working time left in the day, aborting this incremental run 
                */
                dtmSchedulingHorizonStartDateTime = BusinessHours.addGmt(objDefTerritoryBH.id, dtmNow.addminutes(startAfterMinutes), 1L);
                //strLogger += system.now() + ': dtmSchedulingHorizonStartDateTime: ' + dtmSchedulingHorizonStartDateTime + ' , dtmNow: '+ dtmNow +'\n';
                dtmlastProcessedDateTime = dtmSchedulingHorizonStartDateTime;
                Date datNextWorkingDate = Date.valueOf(dtmSchedulingHorizonStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
                Date datTodaysDate = Date.valueOf(dtmNow.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
                if(datNextWorkingDate != datTodaysDate)
                {
                    throw new SVMXException('Not a working day / not enough working time left in the day, aborting this incremental run');
                }

                // Add only the current working day to the scheduling horizon date list
                setSchedHorizDates.add(datNextWorkingDate);
            }

            //strLogger += system.now() + ': Initial scheduling horizon in calendar days: ' + intNoOfDays + '\n';
            
            //system.debug('Usage Details: before calling EngineUtils class for overnightpolicy related map settings\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
              
            // Begin Spring 17 - Sadiya - Overnight - Fetch the overnight policy for each technician and territory
               techniciansAndOvernightPolicyMap = omaxOvernightUtils.getTerritoryOvernightPolicy(objTerritory,lstTechnicians);
               strLogger += system.now() + ': SMAX_OptiMax_Engine_WS : SMAX_Initiate_OptiMax_Job_WS techniciansAndOvernightPolicyMap size: '+techniciansAndOvernightPolicyMap.size() + '\n';
            // End Spring 17 - Sadiya - Overnight - Fetch the overnight policy for each technician and territory
             //system.debug('Usage Details: after calling EngineUtils class for overnightpolicy related map settings\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
  
            /*  Update the Work Orders to ensure that Service Duration is non-NULL and valid
                before calling Capacity Calculation method to get correct required capacity calculation
            */
            if(mapSettingValues.containsKey('OMAX003_SET004') == TRUE)
                dblDefaultServiceDuration = decimal.valueof(mapSettingValues.get('OMAX003_SET004'));
            if(dblDefaultServiceDuration < 1)
                dblDefaultServiceDuration = 3600;
            
            //List<SVMXC__Service_Order__c> lstWorkOrderToUpdate = new List<SVMXC__Service_Order__c>();
            //List<SVMXC__Service_Order__c> lstValidWorkOrder = new List<SVMXC__Service_Order__c>();
            
            //Constructing new work orders for setting up New Work Orders attachment
            String strNewWorkOrders = '';
            Integer intNewWorkOrderCount = 0;
            String strBadWorkOrderDetails='';
            String strErrorDetail='';
            //system.debug('Usage Details: Before validating work orders and technicians\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
            //Fix for HACH customer, fetch setting for validating TZ
            Boolean isTZvalidation = false;
            if(mapSettingValues.containsKey('OMAX003_SET052') == TRUE && Boolean.valueOf(mapSettingValues.get('OMAX003_SET052'))) {
                isTZvalidation = true;
            }
            for(SVMXC__Service_Order__c objWorkOrder : lstWorkOrderObj)
            {
                //Validating work orders and create bad workorders attachment for updating back to work order during completeJob.
                strErrorDetail = clsOMaxExtension.doValidateWorkOrder(objWorkOrder,mapBusinessHours,strDefaultBHourId,isTZvalidation);                
                if(strErrorDetail ==''){
                    // Setup dispatch priority for Incremental run
                    if(isFullRun == FALSE)
                    {
                        objWorkOrder.SVMXC__Dispatch_Priority__c += intIncrWOPriority;
                        lstWorkOrderToUpdate.add(objWorkOrder);
                    }
                    if(objWorkOrder.SVMXC__Service_Duration__c == NULL || objWorkOrder.SVMXC__Service_Duration__c < 1)
                    {
                        objWorkOrder.SVMXC__Service_Duration__c = dblDefaultServiceDuration;
                    }
                    if(intNewWorkOrderCount == intWOBatchSize)
                    {
                        intNewWorkOrderCount = 0;
                        strNewWorkOrders += '_';
                    }
                    else if(strNewWorkOrders != '')
                        strNewWorkOrders += ',';
                    
                    //strNewWorkOrders += '\'' + objWorkOrder.Id + '\'';
                    strNewWorkOrders += '\'' + objWorkOrder.Name + '\'';
                    intNewWorkOrderCount++;
                    lstValidWorkOrder.add(objWorkOrder);
                }else{
                    //create attachment with work order error details
                    strBadWorkOrderDetails += strErrorDetail+';';
                }
            }
            //system.debug('Usage Details: after validating work orders and technicians\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
            if(strBadWorkOrderDetails != ''){
                Attachment objBadWorkOrderAttach = new Attachment(Name = 'Invalid WorkOrders', ParentId = objJob.Id, Body = Blob.valueOf(strBadWorkOrderDetails), IsPrivate = TRUE);
                insert objBadWorkOrderAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                objBadWorkOrderAttach = null;
                
                //Invoke batching to process and update invalid work orders
                OMAX_BatchProcessInvalidWO runInvalidWOBatch = new OMAX_BatchProcessInvalidWO(strBadWorkOrderDetails, strLogger);
                //OMAX_BatchRunQTL runInvalidWOBatch = new OMAX_BatchRunQTL(strBadWorkOrderDetails, strLogger,null);
                
                Integer intBatchSize = 0;
                ID batchProcessId;
                if(mapSettingValues.containskey('OMAX003_SET032') && mapSettingValues.get('OMAX003_SET032') != null)
                    intBatchSize = Integer.valueof(mapSettingValues.get('OMAX003_SET032'));
                if(intBatchSize > 0)    
                    batchProcessId = Database.executeBatch(runInvalidWOBatch, intBatchSize);
                else    
                    batchProcessId = Database.executeBatch(runInvalidWOBatch, 50);
                
                strLogger += system.now() + ': Batch started to process and update invalid workorders. Batch Id is : ' + batchProcessId + ' \n';                
            }

            strLogger += system.now() + ': Number of valid work orders available: ' + lstValidWorkOrder.size() + ' \n';
            //strLogger += system.now() + ': New workorders going to add into attachment after validate: ' + strNewWorkOrders + ' \n';
            //override the fetched workorders by valid workorders
            lstWorkOrderObj = lstValidWorkOrder; 
            
            if(isFullRun == FALSE)
                lstWorkOrderObj = lstWorkOrderToUpdate;
            //Heap size issue
            //lstWorkOrderToUpdate.clear();
            
            //if(lstWorkOrderObj.size() == 0 || strNewWorkOrders == '')
            if(!isStartRun)
                throw new SVMXException('Work Orders are not available for this dispatch process.');
            
            if(String.isNotBlank(strNewWorkOrders)){
                Attachment objNewWorkOrderAttach = new Attachment(Name = 'New Work Orders', ParentId = objJob.Id, Body = Blob.valueOf(strNewWorkOrders), IsPrivate = TRUE);
                insert objNewWorkOrderAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                //Heap size issue
                objNewWorkOrderAttach = null;
            }
            
            // Update the work order priority, if it is an incremental run ?Why do we update the work orders
            
            if(isFullRun == FALSE && lstWorkOrderObj.size() > 0)
            {
                 //update lstWorkOrderObj;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWorkOrderObj, COMM_SecurityUtils.Access.Updateable)){  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                     update lstWorkOrderObj;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            //strLogger += system.now() + ': Usage Details: After initial processing of work orders\n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            //system.debug('Usage Details: After initial processing of work orders\n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
          
            Boolean isKilometer = false;
            Decimal dclDefaultPerKmCost = 0;
            Decimal dclDefaultMaxDistance = 0;
            Decimal dclDefaultAverageSpeed = 0;
            Decimal dclDefaultFixedCost = 0;
            Decimal dclDefaultPerHourCost = 0;
            
            // Identifying default values for technicians from territory record
            if(mapSettingValues.containsKey('GLOB001_GBL006') && mapSettingValues.get('GLOB001_GBL006').toUpperCase() == 'MILE')
            {
                isMile = true;
                if(objTerritory.SVMXC__Per_Mile_Cost__c != NULL)
                    dclDefaultPerKmCost = objTerritory.SVMXC__Per_Mile_Cost__c * (0.621371192);
                else
                    dclDefaultPerKmCost = Decimal.valueOf(mapSettingValues.get('OMAX002_SET006')) * (0.621371192);
                if(objTerritory.SVMXC__Max_Distance__c != NULL)
                    dclDefaultMaxDistance = objTerritory.SVMXC__Max_Distance__c * (1.609344);
                else
                    dclDefaultMaxDistance = Decimal.valueOf(mapSettingValues.get('OMAX002_SET009')) * (1.609344);
                if(objTerritory.SVMXC__Average_Speed__c != NULL)
                    dclDefaultAverageSpeed = objTerritory.SVMXC__Average_Speed__c * (0.44704); // mph
                else
                    dclDefaultAverageSpeed = Decimal.valueOf(mapSettingValues.get('OMAX002_SET008')) * (0.44704);
            }
            else
            {
                if(objTerritory.SVMXC__Per_Mile_Cost__c != NULL)
                    dclDefaultPerKmCost = objTerritory.SVMXC__Per_Mile_Cost__c;
                else
                    dclDefaultPerKmCost = Decimal.valueOf(mapSettingValues.get('OMAX002_SET006'));
                if(objTerritory.SVMXC__Max_Distance__c != NULL)
                    dclDefaultMaxDistance = objTerritory.SVMXC__Max_Distance__c;
                else
                    dclDefaultMaxDistance = Decimal.valueOf(mapSettingValues.get('OMAX002_SET009'));
                if(objTerritory.SVMXC__Average_Speed__c != NULL)
                    dclDefaultAverageSpeed = objTerritory.SVMXC__Average_Speed__c * (0.27778); //mph
                else
                    dclDefaultAverageSpeed = Decimal.valueOf(mapSettingValues.get('OMAX002_SET008')) * (0.27778);
            }
            
            if(objTerritory.SVMXC__Fixed_Cost__c != NULL)
                dclDefaultFixedCost = objTerritory.SVMXC__Fixed_Cost__c;
            else
                dclDefaultFixedCost = Decimal.valueOf(mapSettingValues.get('OMAX002_SET007'));
            if(objTerritory.SVMXC__Per_hour_Cost__c != NULL)
                dclDefaultPerHourCost = objTerritory.SVMXC__Per_hour_Cost__c;
            else
                dclDefaultPerHourCost = Decimal.valueOf(mapSettingValues.get('OMAX002_SET005'));
            
            // Update Technicians
            strLogger += system.now() + ': Now updating technicians records\n';
            //List<SVMXC__Service_Group_Members__c> listValidTech = new List<SVMXC__Service_Group_Members__c>();
            String strInvalidDataTech = '';
            String strInvalidDataMssgTech = '';
            String strInvalidDataMssg = '';
            for(SVMXC__Service_Group_Members__c tech : lstTechnicians)
            {
                strInvalidDataTech = clsOMaxExtension.checkTechnicianInvalidData(tech, mapBusinessHours, strDefaultBHourId, strInvalidDataMssg, strLogger, isTZvalidation); // OPT-116
                //Heap size issue - Commenting as it is not used
                //setAvailtech.add(tech.Id);
                if(strInvalidDataTech.equalsIgnoreCase(''))
                {
                    if(tech.SVMXC__Working_Hours__c == NULL || mapBusinessHours.containsKey(tech.SVMXC__Working_Hours__c) == FALSE)
                    {
                        tech.SVMXC__Working_Hours__c = objTerritory.SVMXC__Territory_s_Business_Hours__c;
                        //tech.SVMXC__Break_Hours__c = objTerritory.SVMXC__Break_Hours__c;
                        strInvalidDataMssgTech =+ system.label.OMAX002_TAG025 + ' Tech: '+tech.name+'\n'; //technician doesnt have working hours.
                    }
                    
                    if(tech.SVMXC__Break_Hours__c == NULL || mapBusinessHours.containsKey(tech.SVMXC__Break_Hours__c) == FALSE){
                        tech.SVMXC__Break_Hours__c = objTerritory.SVMXC__Break_Hours__c;
                    }        
                    
                    mapTechWorkHours.put(tech.Id, tech.SVMXC__Working_Hours__c);
                    
                    // Converting Distance from Miles to KM, Per Mile Cost to Per KM Cost, & Average Speed from Miles/Hr to Meter/Sec if setting is Miles
                    if(isMile)
                    {
                        if(tech.SVMXC__Per_Mile_Cost__c != NULL)
                            tech.SVMXC__Per_Mile_Cost__c = tech.SVMXC__Per_Mile_Cost__c * (0.621371192);
                        else 
                            tech.SVMXC__Per_Mile_Cost__c = dclDefaultPerKmCost;
                        if(tech.SVMXC__Max_Distance__c != NULL)
                            tech.SVMXC__Max_Distance__c = tech.SVMXC__Max_Distance__c * (1.609344);
                        else 
                            tech.SVMXC__Max_Distance__c = dclDefaultMaxDistance;
                        if(tech.SVMXC__Average_Speed__c != NULL)
                            tech.SVMXC__Average_Speed__c = tech.SVMXC__Average_Speed__c * (0.44704);
                        else 
                            tech.SVMXC__Average_Speed__c = dclDefaultAverageSpeed;
                    }
                    // Converting Average Speed from KM/Hr to Meter/Sec if setting is not Miles
                    else
                    {
                        if(tech.SVMXC__Per_Mile_Cost__c == NULL)
                            tech.SVMXC__Per_Mile_Cost__c = dclDefaultPerKmCost;
                        if(tech.SVMXC__Max_Distance__c == NULL)
                            tech.SVMXC__Max_Distance__c = dclDefaultMaxDistance;
                        if(tech.SVMXC__Average_Speed__c != NULL)
                            tech.SVMXC__Average_Speed__c = tech.SVMXC__Average_Speed__c * (0.27778);
                        else 
                            tech.SVMXC__Average_Speed__c = dclDefaultAverageSpeed;
                    }
                    if(tech.SVMXC__Fixed_Cost__c == NULL)
                        tech.SVMXC__Fixed_Cost__c = dclDefaultFixedCost;
                    if(tech.SVMXC__Per_hour_Cost__c == NULL)
                        tech.SVMXC__Per_hour_Cost__c = dclDefaultPerHourCost;
                        
                    listValidTech.add(tech); // creating list of valid technicians.   
                    
                }else{
                    strInvalidDataMssgTech += strInvalidDataTech;
                }    
            }
            
            if(strInvalidDataMssgTech != ''){
                Attachment objBadTechnicianAttach = new Attachment(Name = 'Invalid Technicians', ParentId = objJob.Id, Body = Blob.valueOf(strInvalidDataMssgTech), IsPrivate = TRUE);
                insert objBadTechnicianAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                objBadTechnicianAttach = null;
            }
            
            lstTechnicians = listValidTech; // assigning the valid technicians to the list of technician.

            if(lstTechnicians.size() == 0)
                throw new SVMXException('Technicians are not available for this dispatch process.');


            // Technician expertise batching - start
            if(mapSettingValues.containsKey('OMAX003_SET053') == TRUE && Boolean.valueOf(mapSettingValues.get('OMAX003_SET053'))) {
                // Need to send technician skills in batches. Creating attachment with technician IDs delimited appropriately based on batch size
                Integer intTechExpertiseBatchSize = Integer.valueOf(mapSettingValues.get('OMAX003_SET054'));
                if(intTechExpertiseBatchSize < 1) {
                    intTechExpertiseBatchSize = 5;
                }
                
                String strTechnicians = '';
                Integer intTechnicianCount = 0;
                for(SVMXC__Service_Group_Members__c tech : lstTechnicians)
                {
                    if(intTechnicianCount == intTechExpertiseBatchSize) {
                        intTechnicianCount = 0;
                        strTechnicians += '_';
                    } else if(strTechnicians != '') {
                        strTechnicians += ',';
                    }
                    strTechnicians += tech.Id;
                    intTechnicianCount++;
                }
                System.debug(logginglevel.warn, 'Technician string values in attachment: ' + strTechnicians);
                Attachment objValidTechniciansAttach = new Attachment(Name = 'Valid Technicians', ParentId = objJob.Id, Body = Blob.valueOf(strTechnicians), IsPrivate = TRUE);
                insert objValidTechniciansAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                objValidTechniciansAttach = null;
            }
            // Technician expertise batching - end
            
            //strLogger += system.now() + ' lstTechnicians after assigning == '+lstTechnicians+'\n';
            //strLogger += system.now() + ' lstTechnicians after assigning.size == '+lstTechnicians.size()+'\n';
            
            // Get the average driving time for the territory. Convert to seconds as Work Order Service Duration is in seconds
            if(objTerritory.SVMXC__Average_Driving_Time__c != NULL)
                dclAverageDriveTime = objTerritory.SVMXC__Average_Driving_Time__c;
            else if(mapSettingValues.containsKey('OMAX003_SET012') == TRUE)
                dclAverageDriveTime = (decimal.valueof(mapSettingValues.get('OMAX003_SET012')) * 60);
            if(dclAverageDriveTime < 1) dclAverageDriveTime = 30 * 60;

            // Get the maximum threshold allowed for capacity expansion
            intCapExtMaxThreshold = Integer.valueof(mapSettingValues.get('OMAX002_SET010'));
            
            // Calling doCapacityComputation to retrieve basic result set with capacity extension
            clsOMaxExtension.dtmSchedulingHorizonStartDateTime = dtmSchedulingHorizonStartDateTime;
            clsOMaxExtension.isFullRun = isFullRun;
            clsOMaxExtension.isDays = isDays;

            strLogger += system.now() + ': Usage Details: Before capacity computation\n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            system.debug(': Usage Details: Before capacity computation\n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
            clsCapacityResult = clsOMaxExtension.doCapacityComputation(intNoOfDays, lstWorkOrderObj, mapBusinessHours, lstTechnicians, intCapExtMaxThreshold, dclAverageDriveTime, objDefTerritoryBH, strDispatchProcessId);
            
            strLogger += clsOMaxExtension.strLoggerString;
            strLogger += system.now() + ': Usage Details: After capacity computation\n\tHeap Size     : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            //system.debug(': Usage Details: After capacity computation\n\tHeap Size     : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
            strWOeventLog = clsCapacityResult.strWOsToReschedAndEvents;
            setReschedExternalWOs = clsCapacityResult.setReschedExternalWOs; //this set contains only reschedule WO. no External WOs
            mapTechAvailability = clsCapacityResult.mapTechAvailability;
            mapTechAdditionalDetails = clsCapacityResult.mapTechAdditionalDetails; // Technician Event additional details
            
            //need to comment or delete the below map
            //mapTechIdStrtDtTEventId = clsCapacityResult.mapTechIdStrtDtTEventId;
            
            //introduced the below two maps to store events and ONS events
            mapTechIdExecTimeEventId = clsCapacityResult.mapTechIdExecTimeEventId;
            mapTechIdONSExecTimeEventId = clsCapacityResult.mapTechIdONSExecTimeEventId;
            mapTechIdBreakEventExecTime = clsCapacityResult.mapTechIdBreakEventExecTime;
            
            //strLogger += system.now() + ':SMAX_Optimax_Engine_WS mapTechAdditionalDetails : ' + mapTechAdditionalDetails + '\n';
            //strLogger += system.now() + ': Number of calendar days in the updated scheduling horizon: ' + clsCapacityResult.intUpdatedNoOfDays + '\n';
            //strLogger += system.now() + ':SMAX_Optimax_Engine_WS mapTechIdStrtDtTEventId : ' + mapTechIdStrtDtTEventId + '\n';
            
            // Constructing rescheduled & external work orders id string for setting up Additional Work Orders attachment
            String strAdditionalWorkOrders = '';
            Integer intExternalWorkOrderCount = 0;
            for(Id idWorkOrder : setReschedExternalWOs)
            {
                if(intExternalWorkOrderCount == intWOBatchSize)
                {
                    intExternalWorkOrderCount = 0;
                    strAdditionalWorkOrders += '_';
                }
                else if(strAdditionalWorkOrders != '')
                    strAdditionalWorkOrders += ',';
                strAdditionalWorkOrders += idWorkOrder;
                intExternalWorkOrderCount++;
            }
            //strLogger += system.now() + ': Additional Work Orders: ' + strAdditionalWorkOrders + '\n';
            Attachment objAdditionalWorkOrderAttach = new Attachment(Name = 'Additional Work Orders', ParentId = objJob.Id, Body = Blob.valueOf(strAdditionalWorkOrders), IsPrivate = TRUE);
            insert objAdditionalWorkOrderAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            //Heap size issue
            objAdditionalWorkOrderAttach.clear();
            // Get the dates for the expanded scheduling horizon
            // As intCapExtendedByDays is in calendar days and we get the working days' dates only,
            // break out of the loop once the last date in the scheduling horizon is reached
            //Integer intCapExtendedByDays = clsCapacityResult.intUpdatedNoOfDays - intNoOfDays;
            //strLogger += system.now() + ': Capacity expanded by: ' + intCapExtendedByDays + '\n';
            /*if(intCapExtendedByDays > 0)
            {
                Date datSchedHorizLastDate = (Date.valueOf(dtmSchedulingHorizonStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey))).addDays(intNoOfDays - 1);
                for(integer i = 0; i < intCapExtendedByDays; i++)
                {
                    dtmlastProcessedDateTime = clsOMaxExtension.getNextWorkingHour(objDefTerritoryBH, dtmlastProcessedDateTime.addMinutes(1));
                    Date datTempDate = Date.valueOf(dtmlastProcessedDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
                    setSchedHorizDates.add(datTempDate);
                    if(dtmlastProcessedDateTime.dateGmt() == datSchedHorizLastDate)
                        break;
                }
                intNoOfDays = clsCapacityResult.intUpdatedNoOfDays;
            }*/
            
            //determining the horizon end date from the no. of days in Horizon
            dtmSchedulingHorizonEndDateTime = dtmSchedulingHorizonStartDateTime.addDays(intNoOfDays - 1);
            //Need to create attachment for technician batch to handle high nonwork order events
        } // End of if(isFirstInitCall == TRUE)
        
        /*  If it is the second InitiateJob WS call, retrieve the work orders, technicians, and events, and Job info.
            Process the above data and send the list of work orders in response to the second InitiateJob WS call.
        */
        else
        { // Start of if(isFirstInitCall == FALSE)
            boolean isNewWOAvailable = true;
            // Technician expertise batching - start
            if(mapSettingValues.containsKey('OMAX003_SET053') == TRUE && Boolean.valueOf(mapSettingValues.get('OMAX003_SET053'))) {
                set<String> setTechnicians = new set<String>();
                
                try {
                    Attachment objTechniciansAttach = [SELECT Body from Attachment where Name = 'Valid Technicians' and ParentId = :objJob.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    List<String> lstTechs = new List<String>();
                    lstTechs = objTechniciansAttach.Body.toString().split('_');
                    String strTechnicians = lstTechs.remove(0);
                    for(String strTech : strTechnicians.split(','))
                    {
                        if(strTech != NULL)
                            setTechnicians.add(strTech);
                    }
                    System.debug(logginglevel.warn, 'Batched technician IDs: ' + setTechnicians);
                    if(setTechnicians.size() > 0) {
                        isProcessingTechnicianExpertise = TRUE;                     
                    }
                    
                    //If more technicians are available for next batch
                    if(lstTechs.size() > 0)
                    {
                        wrapSet.status = 3;
                        // Update the attachment with the remaining technicians that need to be processed in next batch
                        String strTechnicianIds = '';
                        for(String strTech : lstTechs)
                        {
                            if(strTechnicianIds != '')
                                strTechnicianIds += '_';
                            strTechnicianIds += strTech;
                        }
                        objTechniciansAttach.Body = Blob.valueOf(strTechnicianIds);
                        update objTechniciansAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    }
                    else
                    {
                        // Finished executing for all technicians. From next call onwards work orders will get processed
                        wrapSet.status = 3;
                        delete objTechniciansAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    }
                    
                    // Heap size issue
                    lstTechnicians.clear();
                    listValidTech.clear();
                    objTechniciansAttach = null;
                    
                    // Get technicians and related skills. Create wrapper and send to server
                    if(isProcessingTechnicianExpertise) {
                        List<SVMXC__Service_Group_Members__c> lstTechForExpertise = new List<SVMXC__Service_Group_Members__c>();
                        lstTechForExpertise = [Select Id, Name, SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Service_Territory__r.SVMXC__Per_Mile_Cost__c,
                            SVMXC__Service_Territory__r.SVMXC__Per_Hour_Cost__c, SVMXC__Service_Territory__r.SVMXC__Fixed_Cost__c, SVMXC__Service_Territory__r.SVMXC__Max_Hours__c,
                            SVMXC__Service_Territory__r.SVMXC__Average_Speed__c, SVMXC__Service_Territory__r.SVMXC__Max_Daily_Hours__c, SVMXC__Max_Hours__c,
                            SVMXC__Service_Territory__r.SVMXC__Max_Distance__c, 
                            SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive, SVMXC__Fixed_Cost__c, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c, SVMXC__Per_hour_Cost__c,
                            SVMXC__Per_Mile_Cost__c, SVMXC__Average_Speed__c, SVMXC__Max_Daily_Hours__c, SVMXC__Max_Distance__c,
                            SVMXC__Working_Hours__c ,
                            SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c , SVMXC__Break_Hours__c, SVMXC__Enable_Scheduling__c,SVMXC__SM_Overnight_Stay_Policy__c
                            from SVMXC__Service_Group_Members__c 
                            where SVMXC__Active__c = TRUE AND SVMXC__Service_Territory__c = :strTerritoryId AND ((SVMXC__Enable_Scheduling__c = TRUE AND SVMXC__Salesforce_User__c = NULL) OR (SVMXC__Salesforce_User__c != NULL AND SVMXC__Salesforce_User__r.IsActive = true) )
                                AND Id in :setTechnicians];
                                
                        mapTechSkill = SMAX_OptiMax_EngineUtils.getTechSkillMap(lstTechForExpertise);
                        System.debug(logginglevel.warn, 'Batched technicians expertise: ' + mapTechSkill);
                        
                        for(SVMXC__Service_Group_Members__c tech : lstTechForExpertise) {
                            lstTechSkill = new List<Expertise_WP>();
                            lstTechSkill = mapTechSkill.get(tech.Id);
                            List<Expertise_WP> lstCOTechSkill = new List<Expertise_WP>();
                            if(lstTechSkill != NULL && lstTechSkill.size() > 0)
                                lstCOTechSkill.addAll(lstTechSkill);
                            Technician_WP tempTechWP = new Technician_WP(tech, NULL, NULL, lstCOTechSkill, NULL, NULL);
                            wrapSet.technician_LWP.add(tempTechWP);
                        }
                        
                        if(wrapSet.technician_LWP.size() > 0) {
                        // To Save the initiate job log only when OMAX003 setting SET028 is TRUE
                        if(mapSettingValues.containsKey('OMAX003_SET028') && mapSettingValues.get('OMAX003_SET028').toUpperCase() == 'TRUE')
                        {
                            try
                            {
                                Attachment objInitJobRespAttach = [SELECT Body from Attachment where Name = 'Initiate Job Response2' and ParentId = :objJob.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                objInitJobRespAttach.Body = Blob.valueOf(objInitJobRespAttach.Body.toString() + clsOMaxExtension.logInitiateJob(wrapSet));
                                update objInitJobRespAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            }
                            catch(QueryException ex)
                            {
                                Attachment objInitJobRespAttach = new Attachment(Name = 'Initiate Job Response2', ParentId = objJob.Id, Body = Blob.valueOf(clsOMaxExtension.logInitiateJob(wrapSet)), IsPrivate = TRUE);
                                insert objInitJobRespAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            }
                            
                        }
                        }
                        
                        return wrapSet;
                    }
                    
                } catch(QueryException ex) {
                    // No attachment available
                }
            }
            // Technician expertise batching - end
            
            set<String> setSFEvents= new set<String>();
            set<String> setSvmxEvents = new set<String>();
            set<String> setAdditionalWorkOrders = new set<String>();
            
            //strLogger += system.now() + ': Usage Details: Before retrieving the work orders\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';

            // Get list of rescheduled work orders
            String strSvmxJobMsg = '';
            try
            {
                Attachment objAdditionalWorkOrderAttach = [SELECT Body from Attachment where Name = 'Additional Work Orders' and ParentId = :objJob.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                List<String> lstAdditionalWorkOrders = new List<String>();
                lstAdditionalWorkOrders = objAdditionalWorkOrderAttach.Body.toString().split('_');
                String strAddtionalWorkOrders = lstAdditionalWorkOrders.remove(0);
                //strLogger += system.now() + ': Additional Work Orders: ' + strAddtionalWorkOrders + '\n';
                for(String strWO : strAddtionalWorkOrders.split(','))
                {
                    if(strWO != NULL && strWO.length() > 10)
                    setAdditionalWorkOrders.add(strWO);
                }
                if(setAdditionalWorkOrders.size() > 0)
                    isProcessingAdditionalWorkOrders = TRUE;
                    
                //If more work orders are available for next batch
                if(lstAdditionalWorkOrders.size() > 0)
                {
                    wrapSet.status = 2;
                    //Update the attachment with the remaining work order that needs to be processed in next batch
                    String strAdditionalWorkOrderIds = '';
                    for(String strAdditionalWO: lstAdditionalWorkOrders)
                    {
                        if(strAdditionalWorkOrderIds != '')
                            strAdditionalWorkOrderIds += '_';
                        strAdditionalWorkOrderIds += strAdditionalWO;
                    }
                    objAdditionalWorkOrderAttach.Body = Blob.valueOf(strAdditionalWorkOrderIds);
                    update objAdditionalWorkOrderAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
                else
                {
                    //Finished executing for all scheduled work order. From next call onwards only new work orders will get processed
                    wrapSet.status = 2;
                    delete objAdditionalWorkOrderAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
                
                //Heap size issue
                //lstAdditionalWorkOrders.clear();
                objAdditionalWorkOrderAttach = null; 
                
            }
            catch(QueryException ex)
            {
                // No attachment available
            }
            
            try
            {
                Attachment objgetAdditionalInfoAttach = [SELECT Body from Attachment where Name = 'Additional Work Order with Event Details' and ParentId = :objJob.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                strSvmxJobMsg = objgetAdditionalInfoAttach.Body.toString();
                //Heap size issue
                objgetAdditionalInfoAttach = null ;
            }
            catch(QueryException ex)
            {
                // No attachment available
            }
            
            if(strSvmxJobMsg != NULL && strSvmxJobMsg.length() > 0)
            {
                strSvmxJobMsg = strSvmxJobMsg.replace('~|~', '~');
                List<String> lstSvmxJobMsg = new List<String>();
                lstSvmxJobMsg = strSvmxJobMsg.split('~');
                if(lstSvmxJobMsg.size() > 0)
                {
                    if(objJob.SVMXC__Status__c == '1')// Soon after resource are sent and call is made first time to retrieve work orders
                    {
                        // Get the list of events associated with external / to be rescheduled work orders
                        if(lstSvmxJobMsg[1] != NULL && lstSvmxJobMsg[1].length() > 0)
                        {
                            for(String strWOEvent : lstSvmxJobMsg[1].split(','))
                            {
                                if(strWOEvent.startsWith(strSfEventKeyPrefix))
                                    setSFEvents.add(strWOEvent);
                                else
                                    setSvmxEvents.add(strWOEvent);
                            }
                        }
                    }
                    //strLogger += 'setSFEvents -' +setSFEvents+ 'setSvmxEvents -'+setSvmxEvents+'\n';
                    // Get the first day's start date time
                    if(lstSvmxJobMsg[4] != NULL && lstSvmxJobMsg[4].length() > 0)
                    {
                        dtmSchedulingHorizonStartDateTime = DateTime.valueof(lstSvmxJobMsg[4]);
                        strLogger += system.now() + ': Scheduling Horizon start date time : ' + lstSvmxJobMsg[4] + '\n';
                    }
                    //Get the end horizon date
                    if(lstSvmxJobMsg[5] != NULL && lstSvmxJobMsg[5].length() > 0)
                    {
                        dtmSchedulingHorizonEndDateTime = DateTime.valueof(lstSvmxJobMsg[5]);
                        strLogger += system.now() + ': Scheduling Horizon end date time : ' + lstSvmxJobMsg[5] + '\n';
                    }
                    // Get the list of scheduling horizon dates
                    if(lstSvmxJobMsg[3] != NULL && lstSvmxJobMsg[3].length() > 0)
                    {
                        strLogger += system.now() + ': Dates in the Scheduling Horizon : ';
                        for(String strWOEvent : lstSvmxJobMsg[3].split(','))
                        {
                            setSchedHorizDates.add(date.valueOf(strWOEvent));
                            strLogger += strWOEvent + ',';
                        }
                        strLogger += '\n';
                    }
                }
            }
            if(!isProcessingAdditionalWorkOrders)
            {
                try{
                    // Get the ids of all the new work orders from attachment and retrieve the work orders
                    Attachment objNewWorkOrderAttach = [SELECT Body from Attachment where Name = 'New Work Orders' and ParentId = :objJob.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    List<String> lstNewWorkOrders = new List<String>();
                    lstNewWorkOrders = objNewWorkOrderAttach.Body.toString().split('_');
                    String strNewWorkOrders = lstNewWorkOrders.remove(0);
                    //strLogger += system.now() + ': New Work Orders: ' + strNewWorkOrders + '\n';
                    if(lstNewWorkOrders.size() > 0)
                    {
                        wrapSet.status = 2;
                        //Update the attachment with the remaining work order that needs to be processed in next batch
                        String strNewWorkOrderIds = '';
                        for(String strNewWO: lstNewWorkOrders)
                        {
                            if(strNewWorkOrderIds != '')
                                strNewWorkOrderIds += '_';
                            strNewWorkOrderIds += strNewWO;
                        }
                        objNewWorkOrderAttach.Body = Blob.valueOf(strNewWorkOrderIds);
                        update objNewWorkOrderAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    }
                    else
                    {
                        wrapSet.status = 1;
                        delete objNewWorkOrderAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    }
                    //Heap size issue
                    objNewWorkOrderAttach = null;
                    String strWorkOrderQuery1 = 'Select Id, Name, SVMXC__Preferred_Resource_Priority__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Dispatch_Priority__c, SVMXC__Preferred_Technician__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Skill__c, SVMXC__Skill_Set__c,SVMXC__Skill__r.Name, SVMXC__Product__c, SVMXC__Product__r.Name, SVMXC__Primary_Territory__c, SVMXC__Group_Member__c, SVMXC__Group_Member__r.Id, SVMXC__Group_Member__r.Name, SVMXC__Apply_Business_Hours_For_OptiMax__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c , SVMXC__Service_Duration__c, SVMXC__Preferred_Business_Hours__c, SVMXC__Preferred_Business_Hours__r.Id, SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Qualified_Technicians__c, SVMXC__Locked_By_DC__c,SVMXC__SM_Lock_Appointment_Schedule__c, SVMXC__SM_Appointment_Type__c, SVMXC__SM_Schedule_Violation_Penalty__c, SVMXC__Dependency_Group__c, SVMXC__Dispatch_Process__c, SVMXC__SM_Capacity_Rule_Name__c from SVMXC__Service_Order__c ';
                    //strWorkOrderQuery += ' WHERE Id IN (' + strNewWorkOrders + ')';
                    strWorkOrderQuery1 += ' WHERE Name IN (' + strNewWorkOrders + ')';
                    lstWorkOrderObj = Database.query(strWorkOrderQuery1);
                }catch(QueryException ex){
                    wrapSet.status = 1;
                    isNewWOAvailable = false;
                    strLogger += system.now() + ': No New workorders attachments. But continue the run due to technician changes....  \n';
                }
            }
            // If there are work orders to be rescheduled, retrieve them and separate them into external & non-external work orders
            else
            {
                Map<Id, SVMXC__Service_Order__c> mapExternalWorkOrders = new Map<Id, SVMXC__Service_Order__c>();
                //Heap size issue
                //Map<Id, Event> mapSFEvent = new Map<Id, Event>();
                //Map<Id, SVMXC__SVMX_Event__c> mapSvmxEvent = new Map<Id, SVMXC__SVMX_Event__c>();
                Map<String, String> mapUsersTechnicians = new Map<String, String>();
                
                mapReschedWorkOrders.putAll([SELECT Id, Name, SVMXC__Preferred_Resource_Priority__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Dispatch_Priority__c,
                                            SVMXC__Preferred_Technician__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c,
                                            SVMXC__Skill__c, SVMXC__Skill__r.Name, SVMXC__Skill_Set__c,SVMXC__Product__c, SVMXC__Product__r.Name, SVMXC__Primary_Territory__c, SVMXC__Group_Member__c,
                                            SVMXC__Group_Member__r.Id, SVMXC__Group_Member__r.Name, SVMXC__Apply_Business_Hours_For_OptiMax__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c ,
                                            SVMXC__Service_Duration__c, SVMXC__Preferred_Business_Hours__c, SVMXC__Preferred_Business_Hours__r.Id, SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Qualified_Technicians__c, SVMXC__Locked_By_DC__c, SVMXC__SM_Lock_Appointment_Schedule__c, SVMXC__SM_Appointment_Type__c, SVMXC__Dependency_Group__c, SVMXC__SM_Capacity_Rule_Name__c
                                            from SVMXC__Service_Order__c
                                            where Id IN: setAdditionalWorkOrders and SVMXC__Dispatch_Process__c = :strDispatchProcessId]);

                if(mapReschedWorkOrders.size() > 0)
                    lstWorkOrderObj.addAll(mapReschedWorkOrders.values());
                
                mapExternalWorkOrders.putAll([SELECT Id, Name, SVMXC__Preferred_Resource_Priority__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Dispatch_Priority__c,
                                            SVMXC__Preferred_Technician__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c,
                                            SVMXC__Skill__c, SVMXC__Skill__r.Name, SVMXC__Skill_Set__c,SVMXC__Product__c, SVMXC__Product__r.Name, SVMXC__Primary_Territory__c, SVMXC__Group_Member__c,
                                            SVMXC__Group_Member__r.Id, SVMXC__Group_Member__r.Name, SVMXC__Apply_Business_Hours_For_OptiMax__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c,
                                            SVMXC__Service_Duration__c, SVMXC__Preferred_Business_Hours__c, SVMXC__Preferred_Business_Hours__r.Id, SVMXC__Preferred_Business_Hours__r.IsActive, SVMXC__Qualified_Technicians__c, SVMXC__Locked_By_DC__c, SVMXC__SM_Lock_Appointment_Schedule__c, SVMXC__SM_Appointment_Type__c, SVMXC__Dependency_Group__c, SVMXC__SM_Capacity_Rule_Name__c
                                            from SVMXC__Service_Order__c
                                            where Id IN: setAdditionalWorkOrders and (SVMXC__Dispatch_Process__c = NULL or SVMXC__Dispatch_Process__c != :strDispatchProcessId)]);
                
                // If there are external work orders, retrieve the details of associated events and technicians
                if(mapExternalWorkOrders.size() > 0)
                {
                    lstWorkOrderObj.addAll(mapExternalWorkOrders.values());
                    //Heap size issue
                    
                    /*lstTechnicians = [Select Id, SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive from SVMXC__Service_Group_Members__c 
                                        where SVMXC__Active__c = TRUE AND SVMXC__Service_Territory__c = :strTerritoryId AND
                                        ((SVMXC__Latitude_Home__c != NULL AND SVMXC__Longitude_Home__c != NULL) OR
                                        (SVMXC__Street__c != NULL OR SVMXC__City__c != NULL OR SVMXC__State__c!=NULL OR SVMXC__Zip__c != NULL OR SVMXC__Country__c != NULL)) AND
                                        ( (SVMXC__Enable_Scheduling__c = FALSE AND SVMXC__Salesforce_User__c != NULL AND SVMXC__Salesforce_User__r.IsActive = TRUE))];
            
                    for(SVMXC__Service_Group_Members__c tech : lstTechnicians)
                    {
                        mapUsersTechnicians.put(tech.SVMXC__Salesforce_User__c, tech.Id);
                    }*/
                    
                    lstTechnicians = [Select Id, SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive from SVMXC__Service_Group_Members__c 
                                        where SVMXC__Active__c = TRUE AND SVMXC__Service_Territory__c = :strTerritoryId AND
                                        ((SVMXC__Enable_Scheduling__c = FALSE AND SVMXC__Salesforce_User__c != NULL AND SVMXC__Salesforce_User__r.IsActive = TRUE))];
                                        
                    for(SVMXC__Service_Group_Members__c tech : lstTechnicians)
                    {
                        if(((tech.SVMXC__Latitude_Home__c != NULL && tech.SVMXC__Longitude_Home__c != NULL) ||
                                        (tech.SVMXC__Street__c != NULL || tech.SVMXC__City__c != NULL || tech.SVMXC__State__c!=NULL || tech.SVMXC__Zip__c != NULL || tech.SVMXC__Country__c != NULL))) {
                            mapUsersTechnicians.put(tech.SVMXC__Salesforce_User__c, tech.Id);             
                        }
                    }
                
                    //Heap size issue
                    //for(Event objEvent: mapSFEvent.values())
                    for(Event objEvent: [Select Id, ActivityDate, ActivityDateTime, OwnerId, DurationInMinutes, Subject, Description, WhatId, startDateTime, endDateTime, Location
                                        from Event
                                        where Id IN : setSFEvents and WhatId IN : mapExternalWorkOrders.keySet()])
                    {
                        List<SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP> wrpWorkOrderSchedule = new List<SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP>();
                        if(mapExternalWOSchedule.get(objEvent.WhatId) != NULL)
                            wrpWorkOrderSchedule = mapExternalWOSchedule.get(objEvent.WhatId);
                        wrpWorkOrderSchedule.add(new WorkOrderSchedule_WP(objEvent.Id, mapUsersTechnicians.get(objEvent.OwnerId), objEvent.StartDateTime, (objEvent.StartDateTime).addMinutes(objEvent.DurationInMinutes), objEvent.DurationInMinutes));
                        mapExternalWOSchedule.put(objEvent.WhatId, wrpWorkOrderSchedule);
                    }
                    //Heap size issue
                    //for(SVMXC__SVMX_Event__c objEvent: mapSvmxEvent.values())
                    for(SVMXC__SVMX_Event__c objEvent: [Select Id, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name,
                                        SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__Location__c
                                        from SVMXC__SVMX_Event__c 
                                        where Id IN : setSvmxEvents and SVMXC__WhatId__c IN : mapExternalWorkOrders.keySet()])
                    {
                        List<SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP> wrpWorkOrderSchedule = new List<SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP>();
                        if(mapExternalWOSchedule.get(objEvent.SVMXC__WhatId__c) != NULL)
                            wrpWorkOrderSchedule = mapExternalWOSchedule.get(objEvent.SVMXC__WhatId__c);
                        wrpWorkOrderSchedule.add(new WorkOrderSchedule_WP(objEvent.Id, objEvent.SVMXC__Technician__c, objEvent.SVMXC__StartDateTime__c, (objEvent.SVMXC__StartDateTime__c).addMinutes((objEvent.SVMXC__DurationInMinutes__c).intValue()), (objEvent.SVMXC__DurationInMinutes__c).intValue()));
                        mapExternalWOSchedule.put(objEvent.SVMXC__WhatId__c, wrpWorkOrderSchedule);
                    }
                }
                //Heap size issue
                mapExternalWorkOrders.clear();
            }
            
            //strLogger += system.now() + ': Usage Details: After retrieving the work orders\n\tHeap Size       : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            
            strLogger += system.now() + ': Create list of work orders BH from mapBussinessHours:'+' \n';
            set<BusinessHours> setWOBH = new set<BusinessHours>();
            //adding territory business hr into set.
            setWOBH.add(objDefTerritoryBH); 
                       
            //Capacity Reservation code                     
            for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrderObj)
            {
                //create list of BH from qualified work orders preferred BH
                if(objWorkOrder.SVMXC__Preferred_Business_Hours__c != null && objWorkOrder.SVMXC__Preferred_Business_Hours__r.IsActive){
                    setWOBH.add(mapBusinessHours.get(objWorkOrder.SVMXC__Preferred_Business_Hours__r.Id));
                }
            }
            //create set of Capacity Reservation rule id from work order.
            mapCapacityRules.putAll([SELECT Id, Name, SVMXC__Sequence__c, SVMXC__Name__c, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__SM_Capacity_Threshold__c, RecordType.Name from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =:objSVMXProcess.Id And RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Capacity Reservation' order by SVMXC__Sequence__c]);  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA       
            strLogger += system.now() + ': Capacity rules size : '+mapCapacityRules.size()+'\n';
            
            if(setWOBH != null){
                lstWOBusinessHours.addAll(setWOBH);
                strLogger += system.now() + ': work orders BH size : '+lstWOBusinessHours.size()+'\n';
            
                // Get the list of time windows in the scheduling horizon for each Business Hours
                if(isFullRun == FALSE || isDays == FALSE){
                    //Below code is commented because we are populated work order BH list instead all acive BH
                    //mapBHTimeWindows = clsOMaxExtension.generateBusinessHourDetails(lstBusinessHours, dtmSchedulingHorizonStartDateTime, setSchedHorizDates);
                    mapBHTimeWindows = clsOMaxExtension.generateBusinessHourDetails(lstWOBusinessHours, dtmSchedulingHorizonStartDateTime, setSchedHorizDates);
                    
                }else {
                    //Below code is commented because we are populated work order BH list instead all acive BH
                    //mapBHTimeWindows = clsOMaxExtension.generateBusinessHourDetails(lstBusinessHours, NULL, setSchedHorizDates);
                    mapBHTimeWindows = clsOMaxExtension.generateBusinessHourDetails(lstWOBusinessHours, NULL, setSchedHorizDates);
                }
            }
            //Heap size issue
            lstWOBusinessHours.clear();          
            strLogger += clsOMaxExtension.strLoggerString;
            //strLogger += system.now() + ': Usage Details: After building time windows in the scheduling horizon for all Business Hours\n\tHeap Size       : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';

            // Create Work Order Window
            List<SVMXC__Service_Order__c> lstAdditionalExternalWorkOrders = new List<SVMXC__Service_Order__c>();
            set<Id> setUpdatedExternalWOs = new set<Id>();
            
            // newly added
            //strLogger += system.now() + ': strDispatchProcessId:  '+strDispatchProcessId + ' , strTerritoryId : '+strTerritoryId;
            //strLogger += system.now() + ': objSVMXProcess.SVMXC__Calendar_Start_Days__c :  '+ objSVMXProcess.SVMXC__Calendar_Start_Days__c + ' :objSVMXProcess.SVMXC__Calendar_End_Days__c:  '+objSVMXProcess.SVMXC__Calendar_End_Days__c + ' , objDefTerritoryBH : '+objDefTerritoryBH;
            
            for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrderObj)
            {
                //strLogger += system.now() + ': Building time windows for Work Order: ' + objWorkOrder.Name + '\n';
                //strLogger += system.now() + ': Work Order skill set: ' + objWorkOrder.SVMXC__Skill_Set__c  + '\n';
                if(objSVMXProcess.SVMXC__Preferred_Tech_Enabled__c == FALSE)
                {
                    objWorkOrder.SVMXC__Preferred_Technician__c = NULL;
                }
                
                if(objSVMXProcess.SVMXC__Product_Match_Enabled__c == FALSE)
                {
                    objWorkOrder.SVMXC__Product__c = NULL;
                }
                
                if(objSVMXProcess.SVMXC__Expertise_Match_Enabled__c == FALSE)
                {
                    objWorkOrder.SVMXC__Skill__c = NULL;
                }
                
                if(isFullRun == TRUE)
                {
                    if((mapReschedWorkOrders).containsKey(objWorkOrder.Id))
                    {
                        /*  Retain Appointment for rescheduled work order:
                            Set Dispatch Priority OMAX003 SET020
                            Set preferred start time = scheduled start time
                            Set preferred end time = preferred start time + service duration
                        */
                        if(objSVMXProcess.SVMXC__Retain_Appointment__c == TRUE)
                        {
                            objWorkOrder.SVMXC__Dispatch_Priority__c = intRetainApptPriority;
                            objWorkOrder.SVMXC__Preferred_Start_Time__c = objWorkOrder.SVMXC__Scheduled_Date_Time__c;
                            objWorkOrder.SVMXC__Preferred_End_Time__c = objWorkOrder.SVMXC__Scheduled_Date_Time__c.addSeconds(Integer.valueOf(objWorkOrder.SVMXC__Service_Duration__c));
                        }
                        // Retain Assignment for rescheduled work order
                        if(objSVMXProcess.SVMXC__Retain_Assignment__c == TRUE)
                        {
                            mapAssignedTechnicians.put(objWorkOrder.Id, objWorkOrder.SVMXC__Group_Member__c);
                            objWorkOrder.SVMXC__Preferred_Technician__c = objWorkOrder.SVMXC__Group_Member__c;
                            objWorkOrder.SVMXC__Preferred_Resource_Priority__c = intPreferredResourcePriority;
                        }
                    }
                }
                else //If it is incremental run set assigned technician as preferred technician, to send complete event info for plugin
                {
                    if(objWorkOrder.SVMXC__Group_Member__c != NULL && objWorkOrder.SVMXC__Scheduled_Date_Time__c != NULL && objWorkOrder.SVMXC__Service_Duration__c != NULL)
                    {
                        objWorkOrder.SVMXC__Preferred_Technician__c = objWorkOrder.SVMXC__Group_Member__c;
                        objWorkOrder.SVMXC__Preferred_Start_Time__c = objWorkOrder.SVMXC__Scheduled_Date_Time__c;
                        objWorkOrder.SVMXC__Preferred_End_Time__c = objWorkOrder.SVMXC__Scheduled_Date_Time__c.addSeconds(Integer.valueOf(objWorkOrder.SVMXC__Service_Duration__c));
                        if(objSVMXProcess.SVMXC__Retain_Appointment__c == TRUE)
                        {
                            mapAssignedTechnicians.put(objWorkOrder.Id, objWorkOrder.SVMXC__Group_Member__c);
                            objWorkOrder.SVMXC__Dispatch_Priority__c = intRetainApptPriority;
                        }
                        // Retain Assignment for rescheduled work order
                        if(objSVMXProcess.SVMXC__Retain_Assignment__c == TRUE)
                        {
                            objWorkOrder.SVMXC__Preferred_Resource_Priority__c = intPreferredResourcePriority;
                        }
                    }
                }
                // Forfix apply for Rescheduled, External Work orders in FULL and Incremental Run.                
                // Set the above priority and technician for Forcefix work orders
                //strLogger += system.now() + ': is Locked by DC field set to : ' + objWorkOrder.SVMXC__Locked_By_DC__c + '\n';
                if((objWorkOrder.SVMXC__Locked_By_DC__c == true || objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c == WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE) && (mapReschedWorkOrders).containsKey(objWorkOrder.Id)){
                    strLogger += system.now() + ': Identified as ForceFix work order so setting Dispatch Priority, PST, PET, PT and Pre Resource Priority: ' + objWorkOrder.Id + '\n';                  
                    //Retain Appointment for Forcefix work order
                    objWorkOrder.SVMXC__Dispatch_Priority__c = intRetainApptPriority;
                    objWorkOrder.SVMXC__Preferred_Start_Time__c = objWorkOrder.SVMXC__Scheduled_Date_Time__c;
                    objWorkOrder.SVMXC__Preferred_End_Time__c = objWorkOrder.SVMXC__Scheduled_Date_Time__c.addSeconds(Integer.valueOf(objWorkOrder.SVMXC__Service_Duration__c));
                    //Retain Assignment for Forcefix work order
                    mapAssignedTechnicians.put(objWorkOrder.Id, objWorkOrder.SVMXC__Group_Member__c);
                    objWorkOrder.SVMXC__Preferred_Technician__c = objWorkOrder.SVMXC__Group_Member__c;
                    objWorkOrder.SVMXC__Preferred_Resource_Priority__c = intPreferredResourcePriority;
                }
                
                // If it is an externally scheduled work order, for all events create work orders with event details
                if((mapExternalWOSchedule).containsKey(objWorkOrder.Id))
                {
                    List<WorkOrderSchedule_WP> wrpWorkOrderSchedule = (mapExternalWOSchedule).get(objWorkOrder.Id);
                    
                    for(WorkOrderSchedule_WP wrpExternalWorkOrder: wrpWorkOrderSchedule)
                    {
                        // If this is the first schedule for the work order
                        if(!setUpdatedExternalWOs.contains(objWorkOrder.Id))
                        {
                            setUpdatedExternalWOs.add(objWorkOrder.Id);
                            objWorkOrder.SVMXC__OptiMax_Status__c = wrpExternalWorkOrder.strEventId;
                            objWorkOrder.SVMXC__Preferred_Technician__c = wrpExternalWorkOrder.strPreferredTechnicainId;
                            objWorkOrder.SVMXC__Service_Duration__c = wrpExternalWorkOrder.dblServiceDuration;
                            objWorkOrder.SVMXC__Preferred_Start_Time__c = wrpExternalWorkOrder.dtmStartDateTime;
                            objWorkOrder.SVMXC__Preferred_End_Time__c = wrpExternalWorkOrder.dtmEndDateTime;
                            objWorkOrder.SVMXC__Dispatch_Priority__c = intExternalWOPriority;
                            objWorkOrder.SVMXC__Preferred_Resource_Priority__c = intExternalWOPreferredResourcePriority;
                            mapAssignedTechnicians.put(objWorkOrder.Id, wrpExternalWorkOrder.strPreferredTechnicainId);
                        }
                        else
                        {   // Create an independent clone alone with id, since opt_preserve_id and opt_IsDeepClone is set to true 
                            SVMXC__Service_Order__c objClonedWorkOrder = objWorkOrder.clone(true, true);
                            objWorkOrder.SVMXC__OptiMax_Status__c = wrpExternalWorkOrder.strEventId;
                            objClonedWorkOrder.SVMXC__Preferred_Technician__c = wrpExternalWorkOrder.strPreferredTechnicainId;
                            objClonedWorkOrder.SVMXC__Service_Duration__c = wrpExternalWorkOrder.dblServiceDuration;
                            objClonedWorkOrder.SVMXC__Preferred_Start_Time__c = wrpExternalWorkOrder.dtmStartDateTime;
                            objClonedWorkOrder.SVMXC__Preferred_End_Time__c = wrpExternalWorkOrder.dtmEndDateTime;
                            objClonedWorkOrder.SVMXC__Dispatch_Priority__c = intExternalWOPriority;
                            objClonedWorkOrder.SVMXC__Preferred_Resource_Priority__c = intExternalWOPreferredResourcePriority;
                            mapAssignedTechnicians.put(objWorkOrder.Id, wrpExternalWorkOrder.strPreferredTechnicainId);
                            lstAdditionalExternalWorkOrders.add(objClonedWorkOrder);
                        }
                    }
                    continue;
                }
                
                List<ExecutionTime_WP> lstWOTimeWindows = new List<ExecutionTime_WP>();
                
                Map<Date, ExecutionTime_WP> mapWrkOrdrTimeWindows = new Map<Date, ExecutionTime_WP>();
                BusinessHours objWrkOrdBH;
                
                if(objWorkOrder.SVMXC__Preferred_Business_Hours__c != NULL && mapBusinessHours.containsKey(objWorkOrder.SVMXC__Preferred_Business_Hours__c))
                {
                    if(mapBHTimeWindows != null && mapBHTimeWindows.size() >0 )
                        mapWrkOrdrTimeWindows = mapBHTimeWindows.get(objWorkOrder.SVMXC__Preferred_Business_Hours__c);
                        
                    objWrkOrdBH = mapBusinessHours.get(objWorkOrder.SVMXC__Preferred_Business_Hours__c);
                }
                else
                {
                    objWorkOrder.SVMXC__Preferred_Business_Hours__c = NULL;
                    //set access hours from territory bh
                    if(mapBHTimeWindows != null && mapBHTimeWindows.size() >0 )
                        mapWrkOrdrTimeWindows = mapBHTimeWindows.get(objDefTerritoryBH.id);
                }
                
                //TODO: Locking to arrival window logic
                WSCH_Provider_ECO_Stubs.ExecutionTime_WP wrpExecTime;
                if(objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c == WSCH_ECO_Constants.SCHEDULE_LOCK_TO_ARRIVALWINDOW && (mapReschedWorkOrders).containsKey(objWorkOrder.Id)){
                    if(objWorkOrder.SVMXC__SM_Appointment_Type__c != null){
                        strLogger += system.now() + ': Identified as ScheduleFix work order with appointment type. so adding time window based on appointment type... \n';                  
                        wrpExecTime = WSCH_CommonUtils.getWorkOrderArrivalWindow(objWorkOrder,objDefTerritoryBH);
                        if(wrpExecTime == null){
                            strLogger += system.now() + 'As arrival window does not match with current scheduled datetime of the work order,so adding time window based on scheduled datetime...\n';
                            Datetime endDT = objWorkOrder.SVMXC__Scheduled_Date_Time__c.addSeconds(Integer.valueOf(objWorkOrder.SVMXC__Service_Duration__c));
                            wrpExecTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(objWorkOrder.SVMXC__Scheduled_Date_Time__c, endDT);
                        }
                    }else{
                        strLogger += system.now() + ': Identified as ScheduleFix work order without appointment type. so adding time window based on scheduled datetime... \n';                  
                        Datetime endDT = objWorkOrder.SVMXC__Scheduled_Date_Time__c.addSeconds(Integer.valueOf(objWorkOrder.SVMXC__Service_Duration__c));
                        wrpExecTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(objWorkOrder.SVMXC__Scheduled_Date_Time__c, endDT);
                    }
                    strLogger += system.now() + ': ScheduleFix workorder time window added..:'+wrpExecTime+'\n';
                    if(wrpExecTime != null){
                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpExecTimeSmax = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
                        wrpExecTimeSmax.startDateTime = wrpExecTime.workingHoursBegin;
                        wrpExecTimeSmax.endDateTime = wrpExecTime.workingHoursEnd;
                        lstWOTimeWindows.add(wrpExecTimeSmax);
                        List<ExecutionTime_WP> woCOExeTime = new List<ExecutionTime_WP>();
                        for(ExecutionTime_WP exeTime : lstWOTimeWindows)
                        {
                            woCOExeTime.add(new ExecutionTime_WP(exeTime.startDateTime, exeTime.endDateTime));
                        }
                        mapWOTimeWindows.put(objWorkOrder.id, woCOExeTime);
                        continue;
                    }else{
                        strLogger += system.now() + 'Some issue in identifying arrival window of the work order,so continue to build regular time window' + objWorkOrder.Id;
                    }
                }
                
                strLogger += system.now() + ': Validate preferred start & end dates: PST:' + objWorkOrder.SVMXC__Preferred_Start_Time__c +'; PET:'+ objWorkOrder.SVMXC__Preferred_End_Time__c+'; dtmSchedulingHorizonStartDateTime: '+dtmSchedulingHorizonStartDateTime+'\n';
                
                //Introduced this below logic to match with the SLA logic from Appointment booking
                //Validate preferred start and end dates against the Horizon and construct the Execution Time Windows
                if(objWorkOrder.SVMXC__Preferred_Start_Time__c == NULL || objWorkOrder.SVMXC__Preferred_End_Time__c == NULL ||
                            objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL || objWorkOrder.SVMXC__Preferred_End_Time__c != NULL) {
                    
                    Datetime territoryPrefStartDT;
                    Datetime territoryPrefEndDT;
                    //Datetime territoryHorizonStartDT;
                    //Datetime territoryHorizonEndDT;
                    Datetime tempStartDateTime;
                    Datetime tempEndDateTime;
                    Boolean considerPST = false;
                    Boolean considerPET = false;
                    DateTime tempTerrHorizonStartDateTime;
                    DateTime tempTerrHorizonEndDateTime;
                    
                    //strLogger += system.now() + ': objWorkOrder.SVMXC__Dispatch_Process__c: '+objWorkOrder.SVMXC__Dispatch_Process__c+', objWorkOrder.Name: '+objWorkOrder.Name+', objWorkOrder.Id: '+objWorkOrder.Id+'\n';
                    List<DateTime> lstHorizonStartAndEndDateTime = WSCH_CommonUtils.getDPHorizonStartAndEndDates(objSVMXProcess, objDefTerritoryBH);
                    if(lstHorizonStartAndEndDateTime != null && lstHorizonStartAndEndDateTime.size() == 2) {
                        tempTerrHorizonStartDateTime = lstHorizonStartAndEndDateTime[0];
                        tempTerrHorizonEndDateTime = lstHorizonStartAndEndDateTime[1];
                    }
                    
                    if(objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL) {
                        //convert the PST territory time zone and compare it with the horizon start and end dates appropriately to find
                        //if they are well within the horizon and determine the start and end dates to be sent to the server.
                                    
                        territoryPrefStartDT = WSCH_DateUtils.doTZConversion(objWorkOrder.SVMXC__Preferred_Start_Time__c, 'GMT' , objDefTerritoryBH.timeZoneSidKey);
                        
                        //territoryHorizonStartDT = WSCH_DateUtils.doTZConversion(tempTerrHorizonStartDateTime, 'GMT' , objDefTerritoryBH.timeZoneSidKey);
                        
                        if(territoryPrefStartDT >= tempTerrHorizonStartDateTime && territoryPrefStartDT <= tempTerrHorizonEndDateTime) {
                            considerPST = true;
                        }
                    }
                    
                    if(objWorkOrder.SVMXC__Preferred_End_Time__c != NULL) {
                        //convert the PET to the territory time zone and compare it with the horizon start and end dates appropriately to find
                        //if they are well within the horizon and determine the start and end dates to be sent to the server.
                                    
                        territoryPrefEndDT = WSCH_DateUtils.doTZConversion(objWorkOrder.SVMXC__Preferred_End_Time__c, 'GMT' , objDefTerritoryBH.timeZoneSidKey);
                        
                        //territoryHorizonEndDT = WSCH_DateUtils.doTZConversion(tempTerrHorizonEndDateTime, 'GMT' , objDefTerritoryBH.timeZoneSidKey);
                        
                        if(territoryPrefEndDT >= tempTerrHorizonStartDateTime && territoryPrefEndDT <= tempTerrHorizonEndDateTime) {
                            considerPET = true;
                        }
                    }
                    
                    if(objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL && objWorkOrder.SVMXC__Preferred_End_Time__c != NULL &&
                            objWorkOrder.SVMXC__Preferred_Start_Time__c < objWorkOrder.SVMXC__Preferred_End_Time__c) {
                                
                        strLogger += system.now() + ' PST != NULL && PET != NULL' + '\n';
                                
                        if(considerPST && considerPET) {
                            tempStartDateTime = objWorkOrder.SVMXC__Preferred_Start_Time__c;
                            tempEndDateTime = objWorkOrder.SVMXC__Preferred_End_Time__c;
                            strLogger += system.now() + ' tempStartDateTime - ' + tempStartDateTime + 'tempEndDateTime ' + tempEndDateTime + '\n';
                            //Construct the execution time windows for the above start and end dates
                            SMAX_OptiMax_EngineUtils.constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder, objDefTerritoryBH);
                            
                        } else if(considerPST == false && considerPET == false) {
                            strLogger += system.now() + ' As both PST and PET are out of the Horizon, skipping this WO - ' + objWorkOrder.Id + '\n';
                            continue;
                            
                        } else if(considerPST && considerPET == false) {
                            tempStartDateTime = objWorkOrder.SVMXC__Preferred_Start_Time__c;
                            tempEndDateTime = WSCH_DateUtils.doTZConversion(tempTerrHorizonEndDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                            strLogger += system.now() + ' tempStartDateTime - ' + tempStartDateTime + 'tempEndDateTime ' + tempEndDateTime + '\n';
                            //Construct the execution time windows for the above start and end dates
                            SMAX_OptiMax_EngineUtils.constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder, objDefTerritoryBH);
                            
                        } else if(considerPST == false && considerPET) {
                            tempStartDateTime = WSCH_DateUtils.doTZConversion(tempTerrHorizonStartDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                            tempEndDateTime = objWorkOrder.SVMXC__Preferred_End_Time__c;
                            strLogger += system.now() + ' tempStartDateTime - ' + tempStartDateTime + 'tempEndDateTime ' + tempEndDateTime + '\n';
                            //Construct the execution time windows for the above start and end dates
                            SMAX_OptiMax_EngineUtils.constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder, objDefTerritoryBH);
                        }
                                
                    } else if(objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL && objWorkOrder.SVMXC__Preferred_End_Time__c == NULL) {
                        strLogger += system.now() + ' PST != NULL && PET == NULL' + '\n';
                        //if PST is not null check if PST has to be considered, else consider horizon start datetime
                        if(considerPST) {
                            tempStartDateTime = objWorkOrder.SVMXC__Preferred_Start_Time__c;
                            tempEndDateTime = WSCH_DateUtils.doTZConversion(tempTerrHorizonEndDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                            strLogger += system.now() + ' tempStartDateTime - ' + tempStartDateTime + 'tempEndDateTime ' + tempEndDateTime + '\n';
                        } else {
                            //tempStartDateTime = tempTerrHorizonStartDateTime;
                            strLogger += system.now() + ' PST is out of the Horizon and PET is null, skipping this WO - ' + objWorkOrder.Id + '\n';
                            continue;
                        }
                        //setting Horizon end datetime as the SLA enddatetime sicne PreferredEndTime is null
                        //tempEndDateTime = tempTerrHorizonEndDateTime;
                        //Construct the execution time windows for the above start and end dates
                        SMAX_OptiMax_EngineUtils.constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder, objDefTerritoryBH);
                        
                    } else if(objWorkOrder.SVMXC__Preferred_Start_Time__c == NULL && objWorkOrder.SVMXC__Preferred_End_Time__c != NULL) {
                        strLogger += system.now() + ' PST == NULL && PET != NULL' + '\n';
                        //setting Horizon start datetime as the SLA startdatetime since PreferredEndTime is null
                        //tempStartDateTime = tempTerrHorizonStartDateTime;
                        if(considerPET) {
                            tempStartDateTime = WSCH_DateUtils.doTZConversion(tempTerrHorizonStartDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                            tempEndDateTime = objWorkOrder.SVMXC__Preferred_End_Time__c;
                            strLogger += system.now() + ' tempStartDateTime - ' + tempStartDateTime + 'tempEndDateTime ' + tempEndDateTime + '\n';
                        } else {
                            //tempEndDateTime = dtmSchedulingHorizonEndDateTime;
                            strLogger += system.now() + ' PET is out of the Horizon and PST is null, skipping this WO - ' + objWorkOrder.Id + '\n';
                            continue;
                        }
                        //Construct the execution time windows for the above start and end dates
                        SMAX_OptiMax_EngineUtils.constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder, objDefTerritoryBH);
                        
                    } else if(objWorkOrder.SVMXC__Preferred_Start_Time__c == NULL && objWorkOrder.SVMXC__Preferred_End_Time__c == NULL) {
                        strLogger += system.now() + ' PST == NULL && PET == NULL' + '\n';
                        //since both PST and PET are null set Horizon start and end datetime as SLA
                        tempStartDateTime = WSCH_DateUtils.doTZConversion(tempTerrHorizonStartDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                        tempEndDateTime = WSCH_DateUtils.doTZConversion(tempTerrHorizonEndDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                        strLogger += system.now() + ' tempStartDateTime - ' + tempStartDateTime + 'tempEndDateTime ' + tempEndDateTime + '\n';
                        //Construct the execution time windows for the above start and end dates
                        SMAX_OptiMax_EngineUtils.constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder, objDefTerritoryBH);
                    }  else if(objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL && objWorkOrder.SVMXC__Preferred_End_Time__c != NULL &&
                            (objWorkOrder.SVMXC__Preferred_Start_Time__c > objWorkOrder.SVMXC__Preferred_End_Time__c || 
                                objWorkOrder.SVMXC__Preferred_Start_Time__c == objWorkOrder.SVMXC__Preferred_End_Time__c)) {
                        strLogger += system.now() + ' PST is greater than PET or PST equals PET. Skipping this WO.' + objWorkOrder.Id +'\n';
                        continue;   
                    }
                }
                
                if(lstWOTimeWindows != NULL && lstWOTimeWindows.size() > 0)
                {
                    List<ExecutionTime_WP> woCOExeTime = new List<ExecutionTime_WP>();
                    for(ExecutionTime_WP exeTime : lstWOTimeWindows)
                    {
                        woCOExeTime.add(new ExecutionTime_WP(exeTime.startDateTime, exeTime.endDateTime));
                    }
                    mapWOTimeWindows.put(objWorkOrder.id, woCOExeTime);
                }
            }
            
            // Add all new external work orders to the available work orders
            //Below code commented due to external work order sent as Techcnian Events(CalendarGeoItem)
            //if(lstAdditionalExternalWorkOrders != NULL && lstAdditionalExternalWorkOrders.size() > 0)
                //lstWorkOrderObj.addAll(lstAdditionalExternalWorkOrders);
            //Heap size issue
            mapReschedWorkOrders.clear();
            lstAdditionalExternalWorkOrders.clear();
            
            //strLogger += system.now() + ': Usage Details: Before building work order wrapper\n\tHeap Size     : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            
            //Dependency Management related code
            Map<Id, List<SVMXC__Service_Order_Dependency__c>> mapOfdepGroupIdLstOfWODependency = new Map<Id, List<SVMXC__Service_Order_Dependency__c>>();
            if(isDependencyEnabled) {
                List<SVMXC__Service_Order__c> manageDependencyWorkOrderList = new List<SVMXC__Service_Order__c>();
                for(SVMXC__Service_Order__c objWorkOrder : lstWorkOrderObj) {
                    if(objWorkOrder.SVMXC__Dependency_Group__c != null) {
                        manageDependencyWorkOrderList.add(objWorkOrder);
                    }
                }
                
                if(manageDependencyWorkOrderList != null){
                    Set<Id> dependencyManagementId = new Set<Id>();
                    for(SVMXC__Service_Order__c dependencyWO: manageDependencyWorkOrderList){
                        dependencyManagementId.add(dependencyWO.SVMXC__Dependency_Group__c);
                    }
                    
                    if(dependencyManagementId.size() > 0){
                        for(Id depGroupId : dependencyManagementId){
                            List<SVMXC__Service_Order_Dependency__c> dependencyGroupList = new List<SVMXC__Service_Order_Dependency__c>();
                            dependencyGroupList = WSCH_CommonUtils.fetchGroupDependency(depGroupId);
                            mapOfdepGroupIdLstOfWODependency.put(depGroupId, dependencyGroupList);
                        }
                    }
                }
                
                //strLogger += system.now() +'InitiateJob method:: mapOfdepGroupIdLstOfWODependency - ' + mapOfdepGroupIdLstOfWODependency + '\n';
            }
            
            // Build the list of work orders: Include only those work orders that have time windows
            Set<Id> setUpdatedWorkOrder = new set<Id>();
            String workOrderType = (isProcessingAdditionalWorkOrders == true) ? 'ASSIGNED' : 'NEW';
            for(SVMXC__Service_Order__c objWorkOrder : lstWorkOrderObj)
            {
                //Get the matching WO from the List of WODependency Objects and get its Secondary WO details to form the Relation_wrapper
                //First get that List of WODependency Objects matching the groupId of this WO, objWorkOrder.
                List<Relation_WP> relation_LWP = new List<Relation_WP>();
                if(isDependencyEnabled && objWorkOrder.SVMXC__Dependency_Group__c != null && mapOfdepGroupIdLstOfWODependency.containsKey(objWorkOrder.SVMXC__Dependency_Group__c)) {
                    List<SVMXC__Service_Order_Dependency__c> lstOfWODependency = mapOfdepGroupIdLstOfWODependency.get(objWorkOrder.SVMXC__Dependency_Group__c);
                    //Iterate the list to get the matching WO(Secondary WO) from the WODependency Object.
                    for(SVMXC__Service_Order_Dependency__c eachWODependencyObj : lstOfWODependency) {
                        if(eachWODependencyObj.SVMXC__Secondary_Work_Order__c == objWorkOrder.Id) {  //changed from primaryWO to secondaryWO
                            //now construct the Relation wrapper for all the relations of this WO with other WOs
                            //for example if WO1 is linked with WO2 and WO4, both these relations are captured here.
                            Relation_WP relationWP = new Relation_WP();
                            if(String.isNotBlank(eachWODependencyObj.SVMXC__Time_Dependency__c)) {
                                relationWP.relationshipType = WSCH_CommonUtils.getServerTimeDepVal((eachWODependencyObj.SVMXC__Time_Dependency__c).trim()); //string
                            }
                            //relationWP.relatedNodeId = eachWODependencyObj.SVMXC__Primary_Work_Order__r.Name;
                            relationWP.masterNodeId = eachWODependencyObj.SVMXC__Primary_Work_Order__r.Name; //string - Changed from Seconday WO to Primary WO
                            //strLogger += system.now() + 'InitiateJob method::eachWODependencyObj.SVMXC__Resource_Dependency__c - ' + eachWODependencyObj.SVMXC__Resource_Dependency__c;
                            if(String.isNotBlank(eachWODependencyObj.SVMXC__Resource_Dependency__c) && eachWODependencyObj.SVMXC__Resource_Dependency__c.equalsIgnoreCase('Same Resource')) {
                                relationWP.resourceDependencyType = 'SAMERESOURCE'; //String - changed from lower case to upper case
                                strLogger += system.now() + 'InitiateJob method:: it is sameResource';
                            } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Resource_Dependency__c) && eachWODependencyObj.SVMXC__Resource_Dependency__c.equalsIgnoreCase('Different Resource')) {
                                relationWP.resourceDependencyType = 'DIFFERENTRESOURCE'; //String - changed from lower case to upper case
                                strLogger += system.now() + 'InitiateJob method:: it is differentResource';
                            } else {
                                relationWP.resourceDependencyType = 'NONE'; //String
                            }
                            
                            //calculate the Maximum deviation values based on the units.
                            if(String.isNotBlank(eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c) && 
                                    eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c.equalsIgnoreCase('Minutes')) {
                                        
                                relationWP.maximalDeviationSec = eachWODependencyObj.SVMXC__Maximum_Time_Deviation__c * 60; //Double
                                        
                            } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c) && 
                                    eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c.equalsIgnoreCase('Hours')) {
                                        
                                relationWP.maximalDeviationSec = eachWODependencyObj.SVMXC__Maximum_Time_Deviation__c * 60 * 60; //Double
                                        
                            } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c) && 
                                    eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c.equalsIgnoreCase('Days')) {
                                        
                                relationWP.maximalDeviationSec = eachWODependencyObj.SVMXC__Maximum_Time_Deviation__c * 24 * 60 * 60; //Double
                                        
                            }
                            
                            //calculate the Minimum deviation values based on the units.
                            if(String.isNotBlank(eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c) && 
                                    eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c.equalsIgnoreCase('Minutes')) {
                                        
                                relationWP.minimalDeviationSec = eachWODependencyObj.SVMXC__Minimum_Time_Deviation__c * 60; //Double
                                        
                            } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c) && 
                                    eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c.equalsIgnoreCase('Hours')) {
                                        
                                relationWP.minimalDeviationSec = eachWODependencyObj.SVMXC__Minimum_Time_Deviation__c * 60 * 60; //Double
                                        
                            } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c) && 
                                    eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c.equalsIgnoreCase('Days')) {
                                        
                                relationWP.minimalDeviationSec = eachWODependencyObj.SVMXC__Minimum_Time_Deviation__c * 24 * 60 * 60; //Double
                                        
                            }
                            
                            relation_LWP.add(relationWP);
                            //strLogger += system.now() +'InitiateJob method:: Relation_WP - ' + relation_LWP + '\n';
                            //need to set this relation wrapper on the WO_WP
                        }
                    }
                }
                if(!(mapExternalWOSchedule).containsKey(objWorkOrder.Id))
                {
                    if(mapWOTimeWindows.containsKey(objWorkOrder.Id) && mapWOTimeWindows.get(objWorkOrder.Id).size() > 0 && !setUpdatedWorkOrder.contains(objWorkOrder.Id))
                    {
                        setUpdatedWorkOrder.add(objWorkOrder.Id);
                        strLogger += system.now() + ': workorder time window added in mapWOTimeWindows.:'+objWorkOrder.Name+'\n';
                        
                        //Begin : Spr17- Sadiya - Overnight, added a new parameter omaxOvernightUtils.buildWorkOrderAddtiionalDetails()
                        WorkOrderAdditionalDetails_WP woAdditionalDetailsWP = omaxOvernightUtils.buildWorkOrderAddtiionalDetails();
                        //setting the dependency data on the relationWP wrapper.
                        if(isDependencyEnabled && objWorkOrder.SVMXC__Dependency_Group__c != null) {
                            woAdditionalDetailsWP.relation_LWP = relation_LWP;
                        }
                        //setting scheduleFix value
                        if(objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c == WSCH_ECO_Constants.SCHEDULE_LOCK_TO_ARRIVALWINDOW){
                            if(objWorkOrder.SVMXC__SM_Appointment_Type__c != null)
                                woAdditionalDetailsWP.workOrderParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('scheduleFixType', 'LOCK_ARRIVAL_WINDOW')); 
                            else
                                woAdditionalDetailsWP.workOrderParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('scheduleFixType', 'LOCK_ARRIVAL_TIME'));                     
                        }
                        //POC:Setting Capacity reservation
                        /*if(objWorkOrder.SVMXC__Purpose_of_Visit__c == 'Maintenance'){
                            woAdditionalDetailsWP.workOrderParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('nodeColor', 'PreventiveMaintenance')); 
                        }else if(objWorkOrder.SVMXC__Purpose_of_Visit__c == 'BreakFix'){
                            woAdditionalDetailsWP.workOrderParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('nodeColor', 'BreakFix'));                     
                        }else if(objWorkOrder.SVMXC__Purpose_of_Visit__c == 'Installation'){
                            woAdditionalDetailsWP.workOrderParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('nodeColor', 'Installation'));                     
                        }*/
                        if(objWorkOrder.SVMXC__SM_Capacity_Rule_Name__c != null){
                            //SVMXC__ServiceMax_Processes__c capacityRule = mapCapacityRules.get(objWorkOrder.SVMXC__SM_Capacity_Rule_Name__c);
                            String strNodeColor = objWorkOrder.SVMXC__SM_Capacity_Rule_Name__c.trim();
                            woAdditionalDetailsWP.workOrderParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('CapacityReservationCategory', strNodeColor));
                        }
                        wo_WPL.add(new WorkOrder_WP(objWorkOrder, mapWOTimeWindows.get(objWorkOrder.Id), workOrderType, woAdditionalDetailsWP));
                        
                        //strLogger += system.now() +'InitiateJob method:: workOrderWP after setting the dependency data - ' + wo_WPL[0] + '\n';
                       //End : Spr17- Sadiya - Overnight,added a new parameter omaxOvernightUtils.buildWorkOrderAddtiionalDetails()
                    }
                    else
                    {
                        strLogger += system.now() + ':  No time window available for work order: ' + objWorkOrder.id + '\n';
                    }
                }
                else
                {
                    // Building the execution time window for Externally scheduled Work Orders
                    if(objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL && objWorkOrder.SVMXC__Preferred_End_Time__c != NULL)
                    {
                        List<ExecutionTime_WP> wrpEventTimeWindow = new List<ExecutionTime_WP>();
                        wrpEventTimeWindow.add(new ExecutionTime_WP(objWorkOrder.SVMXC__Preferred_Start_Time__c, objWorkOrder.SVMXC__Preferred_End_Time__c));
                        //Begin : Spr17- Sadiya - Overnight ,added a new parameter omaxOvernightUtils.buildWorkOrderAddtiionalDetails()
                        WorkOrderAdditionalDetails_WP woAdditionalDetailsWP = omaxOvernightUtils.buildWorkOrderAddtiionalDetails();
                        //setting the dependency data on the relationWP wrapper.
                        if(isDependencyEnabled && objWorkOrder.SVMXC__Dependency_Group__c != null) {
                            woAdditionalDetailsWP.relation_LWP = relation_LWP;
                        }
                        //setting scheduleFix value
                        if(objWorkOrder.SVMXC__SM_Appointment_Type__c != null && objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c == WSCH_ECO_Constants.SCHEDULE_LOCK_TO_ARRIVALWINDOW){
                            woAdditionalDetailsWP.workOrderParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('scheduleFix', 'Lock to arrival window'));                      
                        }
                        //POC:Setting Capacity reservation
                        /*if(objWorkOrder.SVMXC__Purpose_of_Visit__c == 'Maintenance'){
                            woAdditionalDetailsWP.workOrderParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('nodeColor', 'PreventiveMaintenance')); 
                        }else if(objWorkOrder.SVMXC__Purpose_of_Visit__c == 'BreakFix'){
                            woAdditionalDetailsWP.workOrderParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('nodeColor', 'BreakFix'));                     
                        }else if(objWorkOrder.SVMXC__Purpose_of_Visit__c == 'Installation'){
                            woAdditionalDetailsWP.workOrderParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('nodeColor', 'Installation'));                     
                        }*/                        
                        if(objWorkOrder.SVMXC__SM_Capacity_Rule_Name__c != null){
                            //SVMXC__ServiceMax_Processes__c capacityRule = mapCapacityRules.get(objWorkOrder.SVMXC__SM_Capacity_Rule_Name__c);
                            String strNodeColor = objWorkOrder.SVMXC__SM_Capacity_Rule_Name__c.trim();
                            woAdditionalDetailsWP.workOrderParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('CapacityReservationCategory', strNodeColor));
                        }
                        wo_WPL.add(new WorkOrder_WP(objWorkOrder, mapWOTimeWindows.get(objWorkOrder.Id), workOrderType, woAdditionalDetailsWP));
                        
                        //strLogger += system.now() +'InitiateJob method:: workOrderWP after setting the dependency data - ' + wo_WPL[0] + '\n';
                        
                          //End : Spr17- Sadiya - Overnight, added a new parameter omaxOvernightUtils.buildWorkOrderAddtiionalDetails()
                    }
                    else
                    {
                        strLogger += system.now() + ':  No preferred start date time / preferred end date time for external work order: ' + objWorkOrder.id + '\n';
                    }
                }
            }
            //Heap size issue
            lstWorkOrderObj.clear();
            lstWorkOrderToUpdate.clear();
            lstValidWorkOrder.clear();
            // Update the SVMX_Jobs record
            objJob.SVMXC__Sent_Work_Orders__c += wo_WPL.size();
            if(wrapSet.status == 1)
            {
                objJob.SVMXC__Status__c = String.valueof(2);
                objJob.SVMXC__OptiMax_Message__c = 'In Progress';
            }
            else
            {
                objJob.SVMXC__Status__c = String.valueof(10);
                objJob.SVMXC__OptiMax_Message__c = 'Work Orders Being Sent';
            }
            update objJob; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
            //strLogger += system.now() + ': Usage Details: After building work order wrapper\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            if(isDebugEnabled == TRUE)
            {
                try
                {
                    Attachment objDebugLogAttach = [SELECT Body from Attachment where Name = 'Debug Log2' and ParentId = :objJob.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    objDebugLogAttach.Body = Blob.valueOf(objDebugLogAttach.Body.toString() + strLogger);
                    update objDebugLogAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
                catch(QueryException ex)
                {
                    Attachment objDebugLogAttach = new Attachment(Name = 'Debug Log2', ParentId = objJob.Id, Body = Blob.valueOf(strLogger), IsPrivate = TRUE);
                    insert objDebugLogAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    //Heap size issue
                    objDebugLogAttach = null;
                }
                
            }
            
            // Setting up Resultset if there are work orders
            if(wo_WPL.size() > 0 )
            {
                wrapSet.workOrder_LWP = wo_WPL;
                wrapSet.sentWOCount = wo_WPL.size();
                
                // To Save the initiate job log only when OMAX003 setting SET028 is TRUE
                if(mapSettingValues.containsKey('OMAX003_SET028') && mapSettingValues.get('OMAX003_SET028').toUpperCase() == 'TRUE')
                {
                    try
                    {
                        Attachment objInitJobRespAttach = [SELECT Body from Attachment where Name = 'Initiate Job Response2' and ParentId = :objJob.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        objInitJobRespAttach.Body = Blob.valueOf(objInitJobRespAttach.Body.toString() + clsOMaxExtension.logInitiateJob(wrapSet));
                        update objInitJobRespAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    }
                    catch(QueryException ex)
                    {
                        Attachment objInitJobRespAttach = new Attachment(Name = 'Initiate Job Response2', ParentId = objJob.Id, Body = Blob.valueOf(clsOMaxExtension.logInitiateJob(wrapSet)), IsPrivate = TRUE);
                        insert objInitJobRespAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    }
                    
                }
                return wrapSet;
            }
            else
            {
                //Status set to 2 and send empty work order list for handling NBN issue.
                if(wrapSet.status != 1){
                    wrapSet.status = 2;
                }
                wrapSet.workOrder_LWP = wo_WPL;
                return wrapSet;
                //throw new SVMXException('Work orders not available for this dispatch process');
            }
        } // End of if(isFirstInitCall == FALSE)
        
        // end of sadiya investigation isfalse of 
        
        
        //List<Technician_WP> tech_WPL = new List<Technician_WP>();
        ExecutionTime_WP EveTim;
        
        // Create Technician Window 
        Boolean isDailyMode = FALSE;
        Double dblEventTimeWindowPriority = 0;
        Double dblEventPrefResPriority = 0;
        Boolean isOvertimeAllowed = FALSE;
        
        if(mapSettingValues.containsKey('OMAX001_SET003') == TRUE)
        {
            if(String.valueof(mapSettingValues.get('OMAX001_SET003')) == 'DAILY')
            isDailyMode = TRUE;
        }
        if(mapSettingValues.containsKey('OMAX003_SET021') == TRUE)
        {
            dblEventTimeWindowPriority = Double.valueOf(mapSettingValues.get('OMAX003_SET021'));
        }
        if(mapSettingValues.containsKey('OMAX003_SET022') == TRUE)
        {
            dblEventPrefResPriority = Double.valueOf(mapSettingValues.get('OMAX003_SET022'));
        }
        if(mapSettingValues.containsKey('OMAX003_SET024') == TRUE)
        {
            intImportance = Integer.valueof(mapSettingValues.get('OMAX003_SET024'));
        }
        if(dblEventTimeWindowPriority < 1)
            dblEventTimeWindowPriority = 100;
        if(dblEventPrefResPriority < 1)
            dblEventPrefResPriority = 1000;
        if(intImportance < 1)
            intImportance = 100;
            
        
        map<Id, SMAX_OptiMax_EngineUtils.techAddress> mapTechCurrentAddress = new map<Id, SMAX_OptiMax_EngineUtils.techAddress>();
        // If the run type is Intra day then find the technician current address
        if(strRunType == 'JOBTYPE.FULL_INTRADAY' || strRunType == 'JOBTYPE.INCREMENTAL')
            mapTechCurrentAddress = clsEngineUtils.findCurrentTechnicianLocation(lstTechnicians, dtmSchedulingHorizonStartDateTime,mapBusinessHours);
        
        strLogger += system.now() + ': if full intraday run then technician current addresses are updated in the mapTechCurrentAddress size is : ' +mapTechCurrentAddress.size()+'\n';   
        Integer intTechnicianCount = 0;
        Integer intTechOnlyCount = lstTechnicians.size();
        strLogger += system.now() + ': intTechOnlyCount : ' +intTechOnlyCount+'\n';
        String strEventId='';
        // Technician expertise batching - start
        //Fetching technician skills from skill object
        if(mapSettingValues.containsKey('OMAX003_SET053') == FALSE || !Boolean.valueOf(mapSettingValues.get('OMAX003_SET053'))) {
            mapTechSkill = SMAX_OptiMax_EngineUtils.getTechSkillMap(lstTechnicians);
            //strLogger += system.now() + ':After getTechSkillMap()- mapTechSkill : ' + mapTechSkill + '\n';
        }
        // mapTechSkill = SMAX_OptiMax_EngineUtils.getTechSkillMap(lstTechnicians);
        // strLogger += system.now() + ':After getTechSkillMap()- mapTechSkill : ' + mapTechSkill + '\n';
        // Technician expertise batching - end
        
        Boolean techEventCreated = false;
        
        
        //strLogger += system.now() + ' Technician Time Construction - mapTechAvailability : ' + mapTechAvailability + '\n';
        strLogger += system.now() + ': SMAX_Optimax_Engine_WS::mapTechIdBreakEventExecTime size' + mapTechIdBreakEventExecTime.size() +'\n';

        for(SVMXC__Service_Group_Members__c tech : lstTechnicians)
        {
            //system.debug('Usage Details: Inside Technician loop:techId - ' + tech.id + ': Heap Size : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + ' - CPU Time : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime);
            strLogger += system.now() + ': Updating technician: ' + tech.id + '(' + tech.Name + ')\n';

            /*Map<DateTime, Id> mapEndDtTNonWOEventId = NULL;
            if(mapTechIdStrtDtTEventId != NULL && mapTechIdStrtDtTEventId.size() > 0){
                strLogger += system.now() + ':SMAX_Optimax_Engine_WS mapTechIdStrtDtTEventId.get(tech.id)==> : ' + mapTechIdStrtDtTEventId.get(tech.id) + '\n';
                mapEndDtTNonWOEventId = mapTechIdStrtDtTEventId.get(tech.id);
            }*/
            Integer intEventCount = 0;
            if(mapTechAvailability.containsKey(tech.Id) && mapTechAvailability.get(tech.Id).size() > 0)
            {
                lstTechSkill = new List<Expertise_WP>();
                lstTechProduct = new List<Product_WP>();
                Double dblMaxMinutes = 0;
                lstTechSkill = mapTechSkill.get(tech.Id);

                // Do this only if dispatch process requires product match
                if(objSVMXProcess.SVMXC__Product_Match_Enabled__c == TRUE)
                {
                    lstTechProduct = mapTechProduct.get(tech.Id);
                }
                
                // Get the BusinessHours and the Availability time windows of the technician
                Id idTechBH = mapTechWorkHours.get(tech.Id);
                
                BusinessHours objTechBH = mapBusinessHours.get(idTechBH);
                Map<date, list<ExecutionTime_WP>> mapTechTimeWindows = mapTechAvailability.get(tech.Id);
                
                Integer intDayCount = 1;
                
                // Sort the availability time windows map by date (local date)
                List<Date> lstSortedDates = new List<Date>();
                lstSortedDates.addAll(mapTechTimeWindows.keyset());
                lstSortedDates.sort();
                
                //strLogger += system.now() + ':lstSortedDates: ' + lstSortedDates + '\n';
                
                //Map<Integer, Double> mapDayMaxHours = new Map<Integer, Double>();
                Map<Integer, DblLocation_WP> mapDayTechLatLng = new Map<Integer, DblLocation_WP>();
                List<ExecutionTime_WP> lstDailyModeExeTime = new List<ExecutionTime_WP>();
                Double dblOverTimeInSecs=null;
                //strLogger += system.now() + ': Usage Details: Before isDailyMode mode execution \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
                if(isDailyMode == TRUE)
                {
                    //integer holidayEventCount = 1;
                    for(Date datSelectedDate : lstSortedDates)
                    {
                        //system.debug('Usage Details: Inside Date loop:: Heap Size : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + ' - CPU Time : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime);
                        dblMaxMinutes = 0;
                        
                        DateTime currDateTime;
                        DateTime dtmTodaysBHEnd;
                        DateTime dtmTodaysBHStart;
                        Integer intTimeWindCount = 1;
                        
                        // Get the start and end time for the given date using BusinessHours
                        /*dtmTodaysBHStart = BusinessHours.addGmt(idTechBH, dcUtils.getDateTimeInTimezone(datSelectedDate, Time.newInstance(0, 0, 0, 0), objTechBH.timeZoneSidKey), 1L);
                        Time timTodaysBHEnd = SMAX_OptiMax_Engine_Ext.getStartEndTime(objTechBH, dtmTodaysBHStart.format('EEEE', objTechBH.timeZoneSidKey), 'EndTime');
                        dtmTodaysBHEnd = dcUtils.getDateTimeInTimezone(datSelectedDate, timTodaysBHEnd, objTechBH.timeZoneSidKey);*/
                        
                        //Start: Newly added the below code to create the technician execution wrapper.
                        /*currDateTime = BusinessHours.addGmt(idTechBH, dcUtils.getDateTimeInTimezone(datSelectedDate, Time.newInstance(0, 0, 0, 0), objTechBH.timeZoneSidKey), 1L);
                        Time timTodaysBHStart = SMAX_OptiMax_Engine_Ext.getStartEndTime(objTechBH, currDateTime.format('EEEE', objTechBH.timeZoneSidKey), 'StartTime');
                        Time timTodaysBHEnd = SMAX_OptiMax_Engine_Ext.getStartEndTime(objTechBH, currDateTime.format('EEEE', objTechBH.timeZoneSidKey), 'EndTime');
                        dtmTodaysBHStart = dcUtils.getDateTimeInTimezone(datSelectedDate, timTodaysBHStart, objTechBH.timeZoneSidKey);
                        dtmTodaysBHEnd = dcUtils.getDateTimeInTimezone(datSelectedDate, timTodaysBHEnd, objTechBH.timeZoneSidKey);*/
                        
                        //strLogger += system.now() + ':dtmTodaysBHStart: ' + dtmTodaysBHStart + '; dtmTodaysBHEnd: ' + dtmTodaysBHEnd + ')\n';
                        //Start Multi day in Batch
                        if(mapTechTimeWindows != null && mapTechTimeWindows.size() > 0){
                            List<ExecutionTime_WP> lstTechTimeWindow = mapTechTimeWindows.get(datSelectedDate);
                            for(ExecutionTime_WP techTimeWindow : lstTechTimeWindow){
                                lstDailyModeExeTime.add(techTimeWindow);
                            }
                        }
                        //End Multi Day in Batch

                        //lstDailyModeExeTime.add(new ExecutionTime_WP(dtmTodaysBHStart, dtmTodaysBHEnd));
                        //strLogger += system.now() + ':lstDailyModeExeTime: ' + lstDailyModeExeTime + '\n';
                        //End: Newly added the above code to create the technician execution wrapper.
                        
                        //filtering the events which are completely falling outside tech working hours for that day. 
                        //Start: Newly added the below code to create the technician Event wrapper
                        if(mapTechIdExecTimeEventId != null && mapTechIdExecTimeEventId.size() > 0) {
                            Map<Id, ExecutionTime_WP> mapOfEventIdEventExecTime = mapTechIdExecTimeEventId.get(tech.Id);
                            
                            if(mapOfEventIdEventExecTime != null && mapOfEventIdEventExecTime.size() > 0) {
                                for(Id eventId : mapOfEventIdEventExecTime.keySet()) {
                                    ExecutionTime_WP eventExecTime = mapOfEventIdEventExecTime.get(eventId);
                                    
                                    //strLogger += system.now() + 'eventId: ' + eventId +'\n';
                                    //strLogger += system.now() + 'eventExecTime.startDateTime: ' + eventExecTime.startDateTime +'\n';
                                    //strLogger += system.now() + 'eventExecTime.endDateTime' + eventExecTime.endDateTime +'\n';
                                    
                                    Date eventStartDate = eventExecTime.startDateTime.dateGMT();
                                    //strLogger += system.now() + 'eventStartDate in GMT: ' + eventStartDate +'\n';
                                    DateTime eventDatetimeBH = WSCH_DateUtils.doTZConversion(eventExecTime.startDateTime, 'GMT', objTechBH.timeZoneSidKey);
                                    Date eventDate = eventDatetimeBH.dateGmt();
                                    //strLogger += system.now() + 'eventStartDate in TZ: ' + eventDate +'\n';
                                    //strLogger += system.now() + 'datSelectedDate: ' + datSelectedDate +'\n';
                                    if((eventDate == datSelectedDate) && !((eventExecTime.startDateTime < dtmTodaysBHStart && eventExecTime.endDateTime < dtmTodaysBHStart)
                                                     || (eventExecTime.startDateTime > dtmTodaysBHEnd && eventExecTime.endDateTime > dtmTodaysBHEnd))) {
                                        //strLogger += system.now() + ': SMAX_Optimax_Engine_WS:: eventDate' + eventDate +'\n';
                                        String strTechStartDtTime = tech.Id + '_' + eventExecTime.startDateTime;
                                        // strLogger += system.now() + ': SMAX_Optimax_Engine_WS:: Event Id' + eventId +'\n';
                                        // strLogger += system.now() + ': SMAX_Optimax_Engine_WS::Computing the execution time of the day strTechStartDtTime ' + strTechStartDtTime + '\n';
                                        // strLogger += system.now() + ': SMAX_Optimax_Engine_WS::Execution time of the day startDateTime ' + eventExecTime.startDateTime + '\n';
                                        
                                        if(mapTechAdditionalDetails != null && mapTechAdditionalDetails.size() > 0) {
                                            //Technician Event Additional details
                                            TechniciansEventsAdditonalDetails_WP techEventAdditnlDetls = mapTechAdditionalDetails.get(strTechStartDtTime);
                                            //strLogger += system.now() + ': SMAX_Optimax_Engine_WS::techEventAdditnlDetls ' + techEventAdditnlDetls + '\n';
                                            strEventId = 'Event_' + intEventCount + 'for' + tech.Id + '_' + eventId;
                                            strLogger += system.now() + ': SMAX_Optimax_Engine_WS:: strEventId ' + strEventId+'\n';
                                            if(null != techEventAdditnlDetls) {
                                                wrapSet.technicianEvent_LWP.add(new SMAX_OptiMax_Engine_WS.TechniciansEvents_WP
                                                (strTerritoryId, tech.Id+'_'+tech.Name, strEventId, eventExecTime.startDateTime, eventExecTime.endDateTime,
                                                 dblEventTimeWindowPriority, dblEventPrefResPriority, intImportance, techEventAdditnlDetls));
                                                 //strLogger += system.now() + ': SMAX_Optimax_Engine_WS:: Created TechEvent \n';
                                                intEventCount++;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        //End: Newly added the above code to create the technician Event wrapper
                        
                        //Start: Newly added the below code to create the technician Event wrapper for Breaks
                        if(mapTechIdBreakEventExecTime != null && mapTechIdBreakEventExecTime.size() > 0) {
                            Map<Date, ExecutionTime_WP> mapDateBreakEventExecWP = mapTechIdBreakEventExecTime.get(tech.Id);
                            //strLogger += system.now() + ': SMAX_Optimax_Engine_WS::mapDateBreakEventExecWP:' + mapDateBreakEventExecWP +'\n';
                            
                            if(mapDateBreakEventExecWP != null && !mapDateBreakEventExecWP.isEmpty()){
                                ExecutionTime_WP breakEvent = mapDateBreakEventExecWP.get(datSelectedDate);

                                if(breakEvent != null) {
                                    String strTechStartDtTime = tech.Id + '_' + breakEvent.startDateTime;
                                    //strLogger += system.now() + ': SMAX_Optimax_Engine_WS::Computing the execution time of the day strTechStartDtTime ' + strTechStartDtTime + '\n';
                                    
                                    strEventId = 'Break_' + intEventCount + 'for' + tech.Id;
                                    //strLogger += system.now() + ': SMAX_Optimax_Engine_WS:: strEventId ' + strEventId+'\n';
                                    wrapSet.technicianEvent_LWP.add(new SMAX_OptiMax_Engine_WS.TechniciansEvents_WP
                                    (strTerritoryId, tech.Id+'_'+tech.Name, strEventId, breakEvent.startDateTime, breakEvent.endDateTime,
                                                    dblEventTimeWindowPriority, dblEventPrefResPriority, intImportance, null));
                                    intEventCount++;
                                }
                            }
                            //strLogger += system.now() + ': SMAX_Optimax_Engine_WS::breakEvent:' + breakEvent +'\n';                            
                        }
                        //End: Newly added the above code to create the technician Event wrapper for Breaks
                    }
                    //below logic of event creation has been moved out of the dates for loop as the event wrappers for all the horizon days were sent.
                    //Start: Newly added the below code to create the technician Event wrapper for ONS events
                    if(mapTechIdONSExecTimeEventId != null && mapTechIdONSExecTimeEventId.size() > 0) {
                        Map<Id, ExecutionTime_WP> mapOfONSEventIdEventExecTime = mapTechIdONSExecTimeEventId.get(tech.Id);
                        
                        if(mapOfONSEventIdEventExecTime != null && mapOfONSEventIdEventExecTime.size() > 0) {
                            for(Id onsEventId : mapOfONSEventIdEventExecTime.keySet()) {
                                
                                ExecutionTime_WP eventExecTime = mapOfONSEventIdEventExecTime.get(onsEventId);
                                String techStartDtTime = tech.Id + '_' + eventExecTime.startDateTime;
                                strLogger += system.now() + ': SMAX_Optimax_Engine_WS::ONS Event Id'+ onsEventId +'\n';
                                strLogger += system.now() + ': SMAX_Optimax_Engine_WS::Computing the execution time of the day (endDateTime) techStartDtTime '+ techStartDtTime +'\n';
                                strLogger += system.now() + ': SMAX_Optimax_Engine_WS::Execution time of the day startDateTime ' + eventExecTime.startDateTime +'\n';
                                
                                if(mapTechAdditionalDetails != null && mapTechAdditionalDetails.size() > 0) {
                                    TechniciansEventsAdditonalDetails_WP techEventAdditnlDetls = mapTechAdditionalDetails.get(techStartDtTime);
                                    //strLogger += system.now() + ': SMAX_Optimax_Engine_WS::techEventAdditnlDetls ' + techEventAdditnlDetls+'\n';
                                    strEventId = 'Event_' + intEventCount + 'for' + tech.Id + '_' + onsEventId;
                                    strLogger += system.now() + ': SMAX_Optimax_Engine_WS:: strEventId ' + strEventId+'\n';
                                    //Confirmed Event created with following purpose
                                    //1. Event should not spread multiple day
                                    //2. Event endtime should not same as Technician Working hour end otherwise it will be adjusted in the working hours
                                    //3. Event duration should be 15 minutes.
                                    if(null != techEventAdditnlDetls && techEventAdditnlDetls.isForcedStayNode == true){
                                         wrapSet.technicianEvent_LWP.add(new SMAX_OptiMax_Engine_WS.TechniciansEvents_WP
                                         (strTerritoryId, tech.Id+'_'+tech.Name, strEventId, eventExecTime.startDateTime, eventExecTime.endDateTime, 
                                            dblEventTimeWindowPriority, dblEventPrefResPriority, intImportance, techEventAdditnlDetls));
                                         strLogger += system.now() + ': SMAX_Optimax_Engine_WS:: Created TechEvent for the Confirmed Overnight event \n';
                                         intEventCount++;
                                    }
                                }
                            }
                        }
                    }
                    //End: Newly added the above code to create the technician Event wrapper for ONS events
                                                
                    if(tech.SVMXC__Max_Hours__c == null || (tech.SVMXC__Max_Hours__c != null && tech.SVMXC__Max_Hours__c < 0)) {
                        if(tech.SVMXC__Service_Territory__c != null && tech.SVMXC__Service_Territory__r.SVMXC__Max_Hours__c != null) {
                            if(tech.SVMXC__Service_Territory__r.SVMXC__Max_Hours__c < 0 ){
                                tech.SVMXC__Max_Hours__c = 0;
                            } else {
                                tech.SVMXC__Max_Hours__c = tech.SVMXC__Service_Territory__r.SVMXC__Max_Hours__c;
                            }
                        } else {
                            tech.SVMXC__Max_Hours__c = 0;
                        }
                    }
                            
                    List<ExecutionTime_WP> lstCODailyModeExeTime = new List<ExecutionTime_WP>();
                    List<Expertise_WP> lstCOTechSkill = new List<Expertise_WP>();
                    List<Product_WP> lstCOTechProduct = new List<Product_WP>();
                    techAddtionalDetailsWP = new TechnicianAdditonalDetails_WP();
                    
                    // Begin : Spring 17 - Sadiya - Overnight - Update the Execution time here with the overnight policy true or false 
                    lstCODailyModeExeTime = clsOMaxExtension.removeOngoingActivityFromAvailability(tech.Id, lstDailyModeExeTime, intIncrementalRunLeadTime,techniciansAndOvernightPolicyMap);
                    // End : Spring 17 - Sadiya - Overnight - Update the Execution time here with the overnight policy true or false
                    
                    
                    // Don't sent technician if availability is null
                    if(lstCODailyModeExeTime.size() == 0)
                        continue;
                        
                    if(lstTechSkill != NULL && lstTechSkill.size() > 0)
                        lstCOTechSkill.addAll(lstTechSkill);
                    if(lstTechProduct != NULL && lstTechProduct.size() > 0)
                        lstCOTechProduct.addAll(lstTechProduct);
                    //sending overtime tolerance value to optimax engine.
                    if(objSVMXProcess.SVMXC__Tolerance__c != NULL && objSVMXProcess.SVMXC__Tolerance__c > 0){
                        dblOverTimeInSecs = 60 * objSVMXProcess.SVMXC__Tolerance__c.intValue();
                        techAddtionalDetailsWP.techOverTimeSecs=dblOverTimeInSecs;
                    }       
                    
                    //sending drive time before shift start value to optimax engine.
                    if(objSVMXProcess.SVMXC__SM_Drive_Before_Shift_Start__c != NULL && objSVMXProcess.SVMXC__SM_Drive_Before_Shift_Start__c > 0){
                        techAddtionalDetailsWP.techParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('driveBeforeShiftStartInSecs', 60 * objSVMXProcess.SVMXC__SM_Drive_Before_Shift_Start__c.intValue()+''));                      
                    }else{
                        techAddtionalDetailsWP.techParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('driveBeforeShiftStartInSecs', '0'));
                    }
                    if(objSVMXProcess.SVMXC__SM_Drive_After_Shift_End__c != NULL && objSVMXProcess.SVMXC__SM_Drive_After_Shift_End__c > 0){
                        techAddtionalDetailsWP.techParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('driveAfterShiftEndInSecs', 60 * objSVMXProcess.SVMXC__SM_Drive_After_Shift_End__c.intValue()+''));                      
                    }else{
                        techAddtionalDetailsWP.techParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('driveAfterShiftEndInSecs', '0'));                      
                    }
                    
                        // Begin : Spring 17 - Sadiya - Overnight - Update the technician with overnight policy details 
                        techAddtionalDetailsWP = omaxOvernightUtils.updateTechnicianAddtionalWithOvernightPlicy(tech,techniciansAndOvernightPolicyMap,techAddtionalDetailsWP,isMile);
                        //Start of the week
                        SVMXC__SM_Overnight_Stay_Policy__c overnightPolicyObj = techniciansAndOvernightPolicyMap.get(tech.id);
                        if(overnightPolicyObj != null){
                        
                            String selectedDayStr;
                            if(mapSettingValues.containsKey('OMAX001_SET00888') == true && mapSettingValues.get('OMAX001_SET00888') != null) {
                            selectedDayStr = mapSettingValues.get('OMAX001_SET00888');          
                            } else {
                            selectedDayStr = 'Monday';
                            }

                            DateTime startOftheWeek = clsOMaxExtension.getStartOfTheWeekDt(dtmSchedulingHorizonStartDateTime, selectedDayStr);
                            techAddtionalDetailsWP.techParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('startOfTheWeek', startOftheWeek.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')));
                            techAddtionalDetailsWP.techParam.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('cycleOfTheWeek', '7'));
                            
                            if(overnightPolicyObj.SVMXC__SM_Minimum_Recovery_Days__c != null) {
                            techAddtionalDetailsWP.minRecoverHours = overnightPolicyObj.SVMXC__SM_Minimum_Recovery_Days__c * 24 * 60; //converting Days into Hours
                            }
                        
                        }
                        
                        //strLogger += system.now() + 'Technician Addtional Details :-  '+ techAddtionalDetailsWP + '\n';
                    // End : Spring 17 - Sadiya - Overnight -  Update the technician with overnight policy details 
                    
                    Technician_WP tempTechWP = new Technician_WP(tech, lstCODailyModeExeTime, lstCOTechProduct, lstCOTechSkill, NULL,techAddtionalDetailsWP);
                    
                    if((strRunType == 'JOBTYPE.FULL_INTRADAY' || strRunType == 'JOBTYPE.INCREMENTAL') && mapTechCurrentAddress.containsKey(tech.Id))
                    {
                        SMAX_OptiMax_EngineUtils.techAddress techCurrentAddress;
                        techCurrentAddress = mapTechCurrentAddress.get(tech.Id);
                        tempTechWP = clsEngineUtils.updateTechnicianCurrentAddress(tempTechWP, techCurrentAddress);
                    }
                    //tech_WPL.add(tempTechWP);
                    wrapSet.technician_LWP.add(tempTechWP);
                    intTechnicianCount++;
                }
                //strLogger += system.now() + ': Usage Details: After isDailyMode mode execution \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            }
        }

        if(intTechnicianCount == 0)
            throw new SVMXException('Work Orders or Technicians not available for this dispatch process.');

        //Heap size issue
        mapTechAvailability.clear();
        mapTechWorkHours.clear();
                
        //strLogger += system.now() + ': Usage Details: After building technician and event wrapper\n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
        
        String strSchedHorz = '';
        for(Date datSchedHorizDate: setSchedHorizDates)
        {
            if(strSchedHorz != '')
                strSchedHorz += ',';
            strSchedHorz += String.valueof(datSchedHorizDate);
        }
        //Heap size issue
        setSchedHorizDates.clear();
        objJob.SVMXC__Status__c = String.valueof(1);
        objJob.SVMXC__OptiMax_Message__c = 'Resources Sent';
        objJob.SVMXC__Sent_Work_Orders__c = 0;
        objJob.SVMXC__Sent_Resources__c = intTechOnlyCount;
        
        
        if(wrapSet.technicianEvent_LWP != NULL && wrapSet.technicianEvent_LWP.size() > 0){
            objJob.SVMXC__Sent_Events_Count__c = wrapSet.technicianEvent_LWP.size();
            wrapSet.sentEventCount = wrapSet.technicianEvent_LWP.size();
        }
        update objJob; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        Attachment objAdditionalInfoAttach = new Attachment(Name = 'Additional Work Order with Event Details', ParentId = objJob.Id, Body = Blob.valueOf(strWOeventLog + '~|~' + strSchedHorz + '~|~' + String.valueofGmt(dtmSchedulingHorizonStartDateTime) + '~|~' + String.valueofGmt(dtmSchedulingHorizonEndDateTime)), IsPrivate = TRUE);
        insert objAdditionalInfoAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        //Heap size issue
        objAdditionalInfoAttach = null;
        if(isDebugEnabled == TRUE)
        {
            Attachment objDebugLogAttach = new Attachment(Name = 'Debug Log1', ParentId = objJob.Id, Body = Blob.valueOf(strLogger), IsPrivate = TRUE);
            insert objDebugLogAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //Heap size issue
            objDebugLogAttach = null;
        }
        //strLogger += 'APURVA lstTechniciansEvents' +lstTechniciansEvents;
        // Setting up Resultset if there are technicians
        if(intTechnicianCount > 0)
        {
            wrapSet.jobId = objJob.Id;
            wrapSet.jobNo = objJob.Name;
            // TODO: Introduce setting for technician expertise batching. For now, using custom setting 'OptiMax -> Dispatch Calculations -> SET00998'
            // Technician expertise batching - start
            if(mapSettingValues.containsKey('OMAX003_SET053') == TRUE && Boolean.valueOf(mapSettingValues.get('OMAX003_SET053'))) {
                wrapSet.status = 3;
            } else {
                wrapSet.status = 2;
            }
            System.debug(logginglevel.warn,'initJobStatus: '+ wrapSet.status);
            // wrapSet.status = 2;
            // Technician expertise batching - end
            wrapSet.message = objJob.SVMXC__OptiMax_Message__c;
            wrapSet.sentWOCount = 0;
            //wrapSet.technician_LWP = tech_WPL;
            wrapSet.sentTechCount = intTechnicianCount;
            
            //System.debug(logginglevel.warn,'lstTechniciansEvents '+lstTechniciansEvents);
            //System.debug(logginglevel.warn,'lstTechniciansEvents '+wrapSet.technicianEvent_LWP);
            
            String tempValue= String.valueof(mapSettingValues.get('DCON001_SET071'));
            
            wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('Optimax.Geocoding', tempValue));
            
            if(mapSettingValues.containsKey('OMAX001_SET011') == TRUE && mapSettingValues.containsKey('OMAX001_SET012') == TRUE)
            {   // Optimax.debug && Optimax.debugMail
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('Optimax.debug', String.valueof(mapSettingValues.get('OMAX001_SET011')) ));
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('Optimax.debugMail', String.valueof(mapSettingValues.get('OMAX001_SET012')) ));
            }
            if(mapSettingValues.containsKey('OMAX001_SET001') == TRUE)
            {   // JOpt.Assisted
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('JOpt.Assisted', String.valueof(mapSettingValues.get('OMAX001_SET001')) ));
            }
            if(mapSettingValues.containsKey('OMAX001_SET002') == TRUE)
            {   // JOpt.AssistedMode
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('JOpt.AssistedMode', String.valueof(mapSettingValues.get('OMAX001_SET002')) ));
            }
            if(mapSettingValues.containsKey('OMAX001_SET003') == TRUE)
            {   // JOpt.OptimizationRule
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('JOpt.OptimizationRule', String.valueof(mapSettingValues.get('OMAX001_SET003')) ));
            }
            if(mapSettingValues.containsKey('OMAX001_SET007') == TRUE)
            {   // JOptExitCondition.JOptGenerationCount
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('JOptExitCondition.JOptGenerationCount', String.valueof(mapSettingValues.get('OMAX001_SET007')) ));
            }
            if(objSVMXProcess.SVMXC__Route_Type__c != NULL)
            {   // JOpt.RouteType
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('JOpt.RouteType', objSVMXProcess.SVMXC__Route_Type__c ));
            }
            
            //sending objective name to optimax 
            if(objSVMXProcess.SVMXC__Optimization_Goal__c != NULL){
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('Objectives.Name', objSVMXProcess.SVMXC__Optimization_Goal__c));
            }
            
            if(objSVMXProcess.SVMXC__Weight_Time_Window__c != NULL)
            {   // JOptWeight.TimeWindow
                  wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('Objectives.CostBucket.TimeWindow', String.valueof(objSVMXProcess.SVMXC__Weight_Time_Window__c)));
            }
            if(objSVMXProcess.SVMXC__Weight_Route_Distance__c != NULL)
            {   // JOptWeight.TotalDistance
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('Objectives.CostBucket.Distance', String.valueof(objSVMXProcess.SVMXC__Weight_Route_Distance__c)));
            }
            if(objSVMXProcess.SVMXC__Weight_Route_Time__c != NULL)
            {   // JOptWeight.RouteDistance
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('Objectives.CostBucket.Time', String.valueof(objSVMXProcess.SVMXC__Weight_Route_Time__c)));
            }
            if(objSVMXProcess.SVMXC__Weight_Node_Type__c != NULL)
            {   // JOptWeight.RouteTime
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('Objectives.CostBucket.Relations', String.valueof(objSVMXProcess.SVMXC__Weight_Node_Type__c)));
            }
            if(objSVMXProcess.SVMXC__Weight_Total_Distance__c != NULL)
            {   // JOptWeight.NodeType
                 wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('Objectives.CostBucket.WorkDistribution', String.valueof(objSVMXProcess.SVMXC__Weight_Total_Distance__c)));
            }
            // Incremental run settings
            wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('jobType', clsEngineUtils.getRunType(objDefTerritoryBH, isFullRun) ));
            if(!isFullRun)
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('WORKORDERPRIORITY', String.valueof(intIncrWOPriority) ));

            /*if(objSVMXProcess.SVMXC__Weight_Total_Distance__c != NULL)
            {
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('distanceWeightage', String.valueof(objSVMXProcess.SVMXC__Weight_Total_Distance__c)));
            }
            if(objSVMXProcess.SVMXC__Weight_Node_Type__c != NULL)
            {
                 wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('MCTMWeightage', String.valueof(objSVMXProcess.SVMXC__Weight_Node_Type__c)));
            }*/

            if(mapSettingValues.containsKey('OMAX001_SET017') == TRUE)
            {
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('distanceProvider', String.valueof(mapSettingValues.get('OMAX001_SET017')) ));
            }
            if(objTerritory.SVMXC__Mode_Of_Travel__c != NULL)
            {
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('modeOfTravel', String.valueOf(objTerritory.SVMXC__Mode_Of_Travel__c) ));
            }
            else
            {
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('modeOfTravel', 'Driving' ));
            }
            /*if(isFullRun && mapSettingValues.containsKey('OMAX001_SET015') == TRUE)
            {   // Full run.dividePlugin
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('divideplugin.override', mapSettingValues.get('OMAX001_SET015') ));
            }
            if(!isFullRun && mapSettingValues.containsKey('OMAX001_SET016') == TRUE && mapSettingValues.containsKey('OMAX001_SET014'))
            {   // Incremental run.dividePlugin
                if(mapSettingValues.containsKey('OMAX001_SET014') && mapSettingValues.get('OMAX001_SET014').toUpperCase() == 'FALSE')
                    wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('divideplugin.override', 'nearestTechnicianPlugin' ));
                else
                    wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('divideplugin.override', String.valueof(mapSettingValues.get('OMAX001_SET016')) ));
            }*/
            //sending overtime tolerance value to optimax engine.
            if(objSVMXProcess.SVMXC__Tolerance__c != NULL && objSVMXProcess.SVMXC__Tolerance__c > 0){
                wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('overTime', String.valueOf(objSVMXProcess.SVMXC__Tolerance__c) ));
            }
            if(mapCapacityRules != null && mapCapacityRules.size() > 0){
                for(SVMXC__ServiceMax_Processes__c capacityRule : mapCapacityRules.values()){
                    wrapSet.Exec_SettingsMap.add(SMAX_OptiMax_Engine_Ext.setOrganizationParameters('CapacityReservation.Category.'+capacityRule.SVMXC__Name__c+'', String.valueof(capacityRule.SVMXC__SM_Capacity_Threshold__c)));  
                }                      
            }
            
            // To Save the initiate job log only when OMAX003 setting SET028 is TRUE
            if(mapSettingValues.containsKey('OMAX003_SET028') && mapSettingValues.get('OMAX003_SET028').toUpperCase() == 'TRUE')
            {
                Attachment objInitJobRespAttach = new Attachment(Name = 'Initiate Job Response1', ParentId = objJob.Id, Body = Blob.valueOf(clsOMaxExtension.logInitiateJob(wrapSet)), IsPrivate = TRUE);
                insert objInitJobRespAttach; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                //Heap size issue
                objInitJobRespAttach =  null;
            }
        }
        else
        {
            // No technicians available
            throw new SVMXException('Technicians not available for this dispatch process.');
        }
        } // End of try block
        catch(SVMXException ex)
        {
            if(isDebugEnabled == FALSE)
                strLogger = '';
            strLogger += ex.getMessage();
            wrapSet.status = -1;
            if (objJob != NULL && objJob.Id != NULL)
                wrapSet.message = objJob.Id + '~' + strLogger;
            else
                wrapSet.message = strLogger;
            return wrapSet;
        }
        catch(Exception e)
        {
            strLogger += system.now() + ': Usage Details: Just Before Exception\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            //strLogger += ex.getMessage();
            strLogger += system.now()+'Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n';
            wrapSet.status = -1;
            if (objJob != NULL && objJob.Id != NULL)
                wrapSet.message = objJob.Id + '~' + strLogger;
            else
                wrapSet.message = strLogger;
            return wrapSet;
        }
        return wrapSet;
    }
    /* Initiate Job ends */
    
    
    /* Complete Job begins */
    // Wrapper class for the input parameter
    global class ipCompleteJobs_WP
    {
        webservice String dispatchProcessId{ get; set; }
        webservice String territoryId{ get; set; }
        webservice String jobId{ get; set; }
        webservice String jobNo{ get; set; }
        webservice DateTime timeOfComp{ get; set; }
        webservice Double scheduleWOCount { get; set; }
        webservice Double scheduleResourceCount { get; set; }
        //webservice String routewiseCall { get; set; }
        
        webservice List<WorkOrderDetail_WP> workOrder_WPL = new List<WorkOrderDetail_WP>();
        webservice List<TechnicianDetail_WP> technician_WPL = new List<TechnicianDetail_WP>();
        webservice List<TechnicianEventDetail_WP> technicianEvent_WPL = new List<TechnicianEventDetail_WP>();
        webservice List<Status_WP> workOrderError_WPL = new List<Status_WP>();
        webservice List<Status_WP> technicianError_WPL = new List<Status_WP>();
        webservice List<Status_WP> technicianEventError_WPL = new List<Status_WP>();
        webservice TotalRouteTime_WP totalRouteTime_WP = new TotalRouteTime_WP();
        webservice List<Route_WP> route_WPL = new List<Route_WP>();
        webservice List<Statics_WP> statics_WPL = new List<Statics_WP>();
        webservice List<ExeLog_WP> exeLog_WPL = new List<ExeLog_WP>();
        
        public TotalRouteTime_WP gettotalRouteTime_WP(){return totalRouteTime_WP;}
        public void settotalRouteTime_WP(TotalRouteTime_WP value){this.totalRouteTime_WP = value;}
        public List<Route_WP> getroute_WPL(){return route_WPL;}
        public void setroute_WPL(List<Route_WP> value){this.route_WPL = value;}
        public List<Statics_WP> getstatics_WPL(){return statics_WPL;}
        public void setstatics_WPL(List<Statics_WP> value){this.statics_WPL = value;}
        public List<ExeLog_WP> getexeLog_WPL(){return exeLog_WPL;}
        public void setexeLog_WPL(List<ExeLog_WP> value){this.exeLog_WPL = value;}
        
         webservice String errorTest{get;set;}
    }
    
    global class TotalRouteTime_WP
    {
        webservice Double totalRouteTime{ get; set; }
        webservice Double totalDrivingTime{ get; set; }
        webservice Double totalDistance{ get; set; }
        webservice DateTime startTime{ get; set; }
        webservice DateTime endTime{ get; set; }
        webservice Double returnDrivingTime{ get; set; }
        webservice Double returnDistance{ get; set; }          
    }
    
    global class Route_WP
    {
        webservice String routeId{ get; set; }
        webservice String resourceId{ get; set; }
        webservice TotalRouteTime_WP routeTime{ get; set; }
        webservice List<Violations_WP> violations_WPL = new List<Violations_WP>();
        webservice List<DestinationNodes_WP> destinationNodes_WPL = new List<DestinationNodes_WP>();
        public List<Violations_WP> getviolations_WPL(){return violations_WPL;}
        public void setviolations_WPL(List<Violations_WP> t){this.violations_WPL=t;}
        public List<DestinationNodes_WP> getdestinationNodes_WPL(){return destinationNodes_WPL;}
        public void setdestinationNodes_WPL(List<DestinationNodes_WP> t){this.destinationNodes_WPL=t;}
        
        
            //Begin - spring17 - Sadiya - Obernight Stays
        webservice string  startLocationElementId  {get; set;}
        webservice string  endLocationElementId   {get; set;}
        //End - spring17 - Sadiya - Obernight Stays
    }
    
    global class Violations_WP
    {
        webservice String category{ get; set; }
        webservice String attribute{ get; set; }
        webservice String value{ get; set; }
    }
    
    global class DestinationNodes_WP
    {
        webservice Integer sequenceNo{ get; set; }
        webservice String workorderId{ get; set; }
        webservice DateTime arraivalTime{ get; set; }
        webservice DateTime departureTime{ get; set; }
        webservice Integer drivingTime{ get; set; }
        webservice Double idleTime{get; set;}
        //webservice Double returnDrivingTime{get; set;}
        webservice List<Violations_WP> violations_WPL = new List<Violations_WP>();
        
        public List<Violations_WP> getviolations_WP(){return violations_WPL;}
        public void setviolations_WPL(List<Violations_WP> t){this.violations_WPL=t;}
    }
    
    global class Statics_WP
    {
        webservice String statName{ get; set; }
        webservice String value{ get; set; }
        webservice Double units{ get; set; }
        webservice String unit{ get; set; }
    }
    
    global class ExeLog_WP
    {
        webservice DateTime timeStamp{ get; set; }
        webservice Double logLevel{ get; set; }
        webservice String operation{ get; set; }
        webservice String message{ get; set; }
    }

    global class WorkOrderDetail_WP
    {
        webservice String workOrderId{ get; set; }
        webservice Location_WP location{ get; set; }
    }
    
    global class TechnicianDetail_WP
    {
        webservice String technicianId{ get; set; }
        webservice Location_WP location{ get; set; }
    }

    global class TechnicianEventDetail_WP
    {
        webservice String technicianEventId{ get; set; }
        webservice Location_WP location{ get; set; }
    }

    global class Location_WP
    {
        webservice String latitude{ get; set; }
        webservice String longitude{ get; set; }
        
        public Location_WP(String latitude, String longitude)
        {
            this.latitude = latitude;
            this.longitude = longitude;
        } 
    }
     
    global class Status_WP
    {
        webservice String event{ get; set; }
        webservice String message{ get; set; }
        webservice String tag{ get; set; }
    }
    
    global class opCompleteJobs_WP
    {
        webservice Integer status{get; set;}
        webservice String statusMessage{get; set;}
        webservice List<Violations_WP> violations_WPL = new List<Violations_WP>(); // Unused
        
        public List<Violations_WP> getviolations_WP(){return violations_WPL;}
        public void setviolations_WPL(List<Violations_WP> violation){this.violations_WPL = violation;}
    }
    
    /*
     *Type : Webservice Method
     *Used : OptiMax Webservices
     *Dir  : From OptiMax to Customer Org
     *Desc : Once the OptiMax completes a job for a territory, it calls this method
     *     The service resides in Force.com and updates the job status, statistical information,
     *     and logs provided by OptiMax engine into ServiceMax.
     */
    WebService static opCompleteJobs_WP SMAX_Complete_OptiMax_Job_WS(ipCompleteJobs_WP completeJobDetail)
    {
    
        system.debug('Begin SMAX_Complete_OptiMax_Job_WS');
        // Variable definitions
        Map<String, String> mapTechIdSFUserId = new Map<String, String>();
        Map<String, String> mapTechIdServTeamId = new Map<String, String>();
        Map<String, Boolean> mapTechIdIsSchedulingEnabled = new Map<String, Boolean>();
        Map<String, String> mapWOTechIdLat = new Map<String, String>();
        Map<String, String> mapWOTechIdLong = new Map<String, String>();
        Map<String, String> mapNonWOTechIdLat = new Map<String, String>();
        Map<String, String> mapNonWOTechIdLong = new Map<String, String>();        
        Map<String, String> mapInvalidWOErrors = new Map<String, String>(); 
        Map<String, double> mapWrkOrdIdServDuration = new Map<String, double>();
        Map<String, SVMXC__Service_Order__c> mapScheduledWO = new Map<String, SVMXC__Service_Order__c>();
        Map<String, String> mapTechEmail = new Map<String, String>();
        Map<String, String> mapTeamEmail = new Map<String, String>();
        Map<String, BusinessHours> mapBusinessHours = new Map<String, BusinessHours>();
        Map<String, String> mapTechTimeZone = new Map<String, String>();

        set<String> setTechIdForLatLngUpd = new set<String>();
        //set<String> setUnassignedWorkOrders = new set<String>();
        map<String, String> mapUnassignedWorkOrders = new map<String, String>();
        map<String, String> mapUnassignedSFEvents = new map<String, String>();
        map<String, String> mapUnassignedSMAXEvents = new map<String, String>();
        set<String> setSFEventsToBeDeleted = new set<String>();
        set<String> setSvmxEventsToBeDeleted = new set<String>();
        //this is for identify external work order events
        set<String> setNonWOSFEvents = new set<String>();
        set<String> setNonWOSvmxEvents = new set<String>();
                
        set<String> setOvernightSFEventsToBeDeleted = new set<String>();
        set<String> setOvernightSvmxEventsToBeDeleted = new set<String>();

        List<Event> lstSFEvents = new List<Event>();
        list<BusinessHours> lstBusinessHours = new list<BusinessHours>();
        List<SVMXC__SVMX_Event__c> lstSvmxEvents = new List<SVMXC__SVMX_Event__c>();
        List<SVMXC__Service_Order__c> lstOptiMaxOPWrkOrds = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> lstOptiMaxBADWrkOrds = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Group_Members__c> lstOptiMaxOPTechs= new List<SVMXC__Service_Group_Members__c>();
        List<SVMXC__Service_Order__c> lstWOToBeUpdated = new List<SVMXC__Service_Order__c>();
        //List<SVMXC__SVMX_Job_Logs__c> lstSvmxJobLogs = new List<SVMXC__SVMX_Job_Logs__c>();
        List<SVMXC__SVMX_Job_Stats__c> lstSvmxJobStats = new List<SVMXC__SVMX_Job_Stats__c>();
        List<SVMXC__Service_Group_Members__c> lstTechForLatLngUpdate = new List<SVMXC__Service_Group_Members__c>();
        List<SVMXC__SM_Scheduling_Violation__c> lstViolationDetails = new List<SVMXC__SM_Scheduling_Violation__c>();
        List<SVMXC__SM_Scheduling_Violation__c> lstOfViolations = new List<SVMXC__SM_Scheduling_Violation__c>();
        String strHorizonStartTime = '';
        String strHorizonEndTime = '';
            
        Event objSFEvent;
        SVMXC__SVMX_Event__c objSvmxEvent;
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__ServiceMax_Processes__c objSvmxProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__SVMX_Jobs__c objSvmxJob = new SVMXC__SVMX_Jobs__c();
        SVMXC__SVMX_Job_Stats__c objSvmxJobStats;
        SVMXC__SVMX_Job_Logs__c objSvmxJobLogs;
        SVMXC__Territory__c objTerritory;
        BusinessHours objDefTerritoryBH;

        opCompleteJobs_WP wrpComplJobRetObj = new opCompleteJobs_WP();
        SMAX_OptiMax_Engine_Ext clsOMaxExtension = new SMAX_OptiMax_Engine_Ext();
        String TAG007 = System.Label.OMAX002_TAG007; // Work Order
        
        Boolean isFullRun = FALSE;
        Boolean isDebugEnabled = FALSE;
        String strLogger = '';
        String strDeletedWorkOrderDetails = 'Work Order ID , Technician Id , Arrival Time , Departure Time , Driving Time\n';
        Date datToday;
        DateTime dtmCurrentDateTime = System.now();
        Integer intMissingWorkOrderCount = 0;
        
           
        // Begin -Spr17 - Sadiya - Overnight - Initializing a Map of technician Id and businesshours
        Map<String,BusinessHours> mapTechNBusinessHours = new  Map<String,BusinessHours>();
         Map<String,String> mapWOIdNAddress = new  Map<String,String>();
        DestinationNodes_WP lastNodeOfTheRoute = new DestinationNodes_WP();
       
        // End -Spr17 - Sadiya - Overnight - Initializing a Map of technician Id and businesshours
        Map<String, double> mapEventIdDrivingTime = new Map<String, double>();
        String routewiseLogName='Debug Log3';
        String techName ='';
        
        strLogger += system.now() + ': Retrieving all settings\n';
        
        // Retrieve all global, group, and user level settings for OptiMax Engine submodule
        SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSettings = new list<string>();
        lstSettings.add('OMAX001_SET011');
        lstSettings.add('OMAX002_SET003');
        lstSettings.add('OMAX002_SET004');
        lstSettings.add('OMAX003_SET004');
        lstSettings.add('OMAX003_SET018');
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('GLOB001_GBL025');
        map<String, String> mapSettingValues = clsCommSettings.SVMX_getGlobalSettingList(lstSettings);
        
        strLogger += system.now() + ': Settings retrieved sucessfully\n';
        
        //strLogger += system.now() + 'Start of SMAX_Complete_OptiMax_Job_WS  : Limits.getAggregateQueries()==' + Limits.getAggregateQueries()+'\n';
        //strLogger += system.now() + 'Start of SMAX_Complete_OptiMax_Job_WS: No of Queries used in this apex code so far: Limits.getQueries()== ' + Limits.getQueries()+'\n';
        
        system.debug('SMAX_Complete_OptiMax_Job_WS started');
               
        // Retrieve the SVMX_Jobs__c record for the given job ID
        try
        {
            objSvmxJob = [select Id, Name, SVMXC__Message__c, SVMXC__Status__c, SVMXC__End_Time__c, SVMXC__OptiMax_Message__c, SVMXC__Scheduled_Work_Orders__c,
                        SVMXC__Scheduled_Resources__c, SVMXC__Total_Route_Time__c, SVMXC__Total_Driving_Time__c, SVMXC__Total_Distance__c, SVMXC__Territory__c
                        from SVMXC__SVMX_Jobs__c
                        where Id= :completeJobDetail.jobId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        catch(Exception ex)
        {
            throw new SVMXException('Invalid Job Id found.' + ex.getMessage());
        }
        
        system.debug('SMAX_Complete_OptiMax_Job_WS objSvmxJob : '+objSvmxJob);
        System.debug(logginglevel.error,'objSvmxJob.SVMXC__OptiMax_Message__c '+objSvmxJob.SVMXC__OptiMax_Message__c);
        system.debug('route details...'+completeJobDetail.getroute_WPL());
        // If the job has already been canceled as Zombie, do not commit the work order schedules
        if(objSvmxJob.SVMXC__OptiMax_Message__c == 'Canceled - Zombie')
        {
            wrpComplJobRetObj.status = 1;
            wrpComplJobRetObj.statusMessage = 'This is a Zombie Job. This run will not update any records.';
            return wrpComplJobRetObj;
        }
            
        
        // Handling failures that occurred during the OptiMax Job execution - these might be in Initiate Job, OptiMax Processing, or 
        system.debug('Lets check whether Complete Job  has any error');
        //String completeJObDetailsStr = 'conpletejob:- '+completeJobDetail;
        //creatAttachment('CompleteJob-FullRequest',completeJobDetail.jobId,completeJObDetailsStr);
        if(completeJobDetail.scheduleWOCount == -1){
                system.debug('Server has returned Complete Data Failure');
                if(objSvmxJob.SVMXC__Status__c == '3' && objSvmxJob.SVMXC__OptiMax_Message__c == 'Success')
                    return NULL;
                    clsOMaxExtension.handleCJFailureComplete(completeJobDetail,objSvmxJob);
                return null;
        }
        if((completeJobDetail.workOrderError_WPL != NULL && completeJobDetail.workOrderError_WPL.size() > 0)
               || (completeJobDetail.technicianError_WPL != NULL && completeJobDetail.technicianError_WPL.size() > 0)
               || (completeJobDetail.technicianEventError_WPL != NULL && completeJobDetail.technicianEventError_WPL.size() > 0))
        {
            system.debug('Server has returned Partial Data Failure');
            map<String,Map<String,String>> errorMap = clsOMaxExtension.handleCJFailurePartial(completeJobDetail);
            if(errorMap !=null && errorMap.size()>0){
                if(errorMap.containsKey('unassignedwomap')){
                    mapUnassignedWorkOrders = errorMap.get('unassignedwomap');
                }
                if(errorMap.containsKey('invalidwomap')){
                    mapInvalidWOErrors = errorMap.get('invalidwomap');    
                }

                if(errorMap.containsKey('unassignedSFEvents')){
                    mapUnassignedSFEvents = errorMap.get('unassignedSFEvents');
                }
                if(errorMap.containsKey('unassignedSMAXEvents')){
                    mapUnassignedSMAXEvents = errorMap.get('unassignedSMAXEvents');
                }
            }
            system.debug('Handling  WO Error mapInvalidWOErrors '+mapInvalidWOErrors);
            system.debug('Handling  TechEvent Error mapUnassignedSMAXEvents '+mapUnassignedSMAXEvents);
            system.debug('Handling  TechEvent Error mapUnassignedSMAXEvents '+mapUnassignedSMAXEvents);
        }
       
        
        // Split the territoryID received from OptiMax to get the actual territoryGUID and also check whether the run is full run or incremental run
        String strTerritoryId = completeJobDetail.territoryId;
        try
        {
        if(strTerritoryId.contains('_'))
        {
            List<String> lstTerritoryDef = new List<String>();
            lstTerritoryDef = strTerritoryId.split('_');
            strTerritoryId = lstTerritoryDef[0];
            if(lstTerritoryDef.size() > 1)
            {
                if(lstTerritoryDef[1].contains('FULL'))
                    isFullRun = TRUE;
            }
        }
        else
            isFullRun = TRUE;
        }
        catch(Exception e)
        {
            strLogger += system.now()+'Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n';
            throw new SVMXException(e.getMessage());
        }
        
        // Checking if territory exists
        try
        {
            objTerritory = [Select Id, SVMXC__Territory_s_Business_Hours__c,SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey,SVMXC__Territory_s_Business_Hours__r.IsActive, SVMXC__SM_Overnight_Stay_Policy__c from SVMXC__Territory__c where Id = :strTerritoryId];
        }
        catch(Exception ex)
        {
            throw new SVMXException('Invalid territory found.');
        }
        strLogger += system.now() + ': Territory ' + strTerritoryId + ' exists\n';

        //Code fix for HACH customer - BH issue
        String strDefaultBHourId;
        set<String> setBhId = new set<String>();
        try{
            Attachment objBhIdAttach = [SELECT Body from Attachment where Name = 'Valid BusinessHours' and ParentId = :objSvmxJob.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            list<String> lstBHId = new List<String>();
            if(objBhIdAttach != null){
                lstBHId = objBhIdAttach.Body.toString().split(',');
                setBhId = new set<String>(lstBHId);
            }
            strLogger += system.now() + ': setBhId size..before fetching.. ' + setBhId.size() + ' \n';
            // Condition to load only default business hours or those in territory time zone
            //String territoryTZsidKey = objTerritory.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
            // Get the list of all the active Business Hours and put them in a map
            
            lstBusinessHours = [Select Id, Name, IsDefault,IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                                ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
                                from BusinessHours where Id in : setBhId OR IsDefault = TRUE]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                //where IsActive = TRUE AND (IsDefault = TRUE OR TimeZoneSidKey = :territoryTZsidKey)];
            lstBusinessHours = clsOMaxExtension.getCompleteBusinessHour(lstBusinessHours);
            for(BusinessHours bh : lstBusinessHours)
            {
                //strLogger += system.now() + ': BH---in SMAX_Complete_OptiMax_Job_WS---- ' + bh.name + '\n';
                mapBusinessHours.put(bh.Id, bh);
                if(bh.IsDefault == TRUE)
                    strDefaultBHourId=bh.Id;
            }
        }catch(Exception ex){
            
        }
        /*  If Territory business hours is NULL or is not active, set it to the Org's Default business hours.
            This is the default Business Hours to be used for this Dispatch job.
        */
        if(objTerritory.SVMXC__Territory_s_Business_Hours__c == NULL || ( mapBusinessHours.containsKey(objTerritory.SVMXC__Territory_s_Business_Hours__c) == FALSE ))
            objTerritory.SVMXC__Territory_s_Business_Hours__c = strDefaultBHourId;
        objDefTerritoryBH = mapBusinessHours.get(objTerritory.SVMXC__Territory_s_Business_Hours__c);
        
        // If isFullRun = FALSE, get territorys time zone from Business Hours and get the current date in territorys time zone
        if(isFullRun == FALSE)
        {
            datToday = Date.valueOf(dtmCurrentDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        }
        
        // Get the unique 3 character key prefix for SF Event object - Used to check if Work Order event is SF event or SVMX Event
        Map<String, Schema.SObjectType> descAllObjs = Schema.getGlobalDescribe();
        Schema.Describesobjectresult descEventObj = descAllObjs.get('Event').getDescribe();
        strSfEventKeyPrefix = descEventObj.getKeyPrefix();

        // Get the unique 3 character key prefix for Technician object
        Schema.Describesobjectresult descTechnicianObj = descAllObjs.get('SVMXC__Service_Group_Members__c').getDescribe();
        String strTechKeyPrefix = descTechnicianObj.getKeyPrefix();
        // Get the unique 3 character key prefix for Work Order object. This is used to check if destination node is a Work Order or an Event
        /*Schema.Describesobjectresult descWrkOrdObj;
        if (descAllObjs.containsKey('SVMXC__Service_Order__c') == TRUE)
            descWrkOrdObj = descAllObjs.get('SVMXC__Service_Order__c').getDescribe();
        else
            descWrkOrdObj = descAllObjs.get('Service_Order__c').getDescribe();*/
        //Below code commented because we are using work order name instead of id
        //String strWOKeyPrefix = descWrkOrdObj.getKeyPrefix();
        String strWOKeyPrefix = 'WO';
        String strONSKeyPrefix = 'ONS';
        String strONSKeySuffix = 'ReturnDriveHome';
        
        // Do not proceed if the setting Enable Dispatch Optimization is set to FALSE
        /*if(mapSettingValues.containsKey('GLOB001_GBL007') && mapSettingValues.get('GLOB001_GBL007').toUpperCase() == 'FALSE')
            throw new SVMXException('Dispatch Optimization is not enabled for the organization.');*/
        
        if(mapSettingValues.containsKey('OMAX001_SET011') && mapSettingValues.get('OMAX001_SET011').toUpperCase() == 'TRUE')
            isDebugEnabled = TRUE;
        
        // Retrieve the process definition record from ServiceMax_Processes__c by matching the ID with the given dispatch process ID
        try
        {
            objSvmxProcess = [Select Id, SVMXC__Tolerance__c, SVMXC__Product_Match_Enabled__c from SVMXC__ServiceMax_Processes__c where Id =:completeJobDetail.dispatchProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        catch(Exception ex)
        {
            throw new SVMXException('Invalid dispatch process Id found.');
        }
        
        Integer intLimitCpuTime = Limits.getLimitCpuTime();
        Integer intLimitHeapSize = Limits.getLimitHeapSize();
        //strLogger += system.now() + ': Usage Details: After retrieving pre-requisite data such as settings, territory, and dispatch process info\n\tHeap Size     : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';

        try
        {
            //strLogger += system.now() + ': CompleteJob completeJobDetail==>'+completeJobDetail+'\n';
            // Get the list of scheduled work orders & technicians from Route info
            strLogger += system.now() + ': Getting the list of scheduled work orders & technicians\n';
            List<Route_WP> lstRoutes = completeJobDetail.getroute_WPL();
                        
            set<String> setScheduledTechs = new set<String>();
            Map<String, String> mapTechIdName = new Map<String, String>();
            //set<Id> setScheduledWOs = new set<Id>();
            //set<Id> setExternalWOs = new set<Id>();
            set<string> setScheduledWOs = new set<string>();    
            set<string> setExternalWOs = new set<string>();            
            if(lstRoutes == NULL)
                lstRoutes = new List<Route_WP>();
            for(Route_WP route : lstRoutes)
            {
                if(route.resourceId != NULL)
                {
                    // For WEEKLY mode, tech id is sent to OptiMax as <Tech GUID>_DAY<n>. So, get the GUID part of the tech id from OptiMax
                    if(route.resourceId.contains('_'))
                    {
                        List<String> lstTechIdOriginal = route.resourceId.split('_');
                        route.resourceId = lstTechIdOriginal[0];
                        mapTechIdName.put(lstTechIdOriginal[0],lstTechIdOriginal[1]);
                        techName = lstTechIdOriginal[1];
                    }
                    setScheduledTechs.add(route.resourceId);
                }
                for(DestinationNodes_WP destNode : route.destinationNodes_WPL)
                {
                    if(destNode.workorderId != NULL && (destNode.workorderId).startsWith(strWOKeyPrefix))
                    {
                        if(destNode.workorderId.contains('_'))
                        {
                            List<String> lstWorkOrderIdOriginal = destNode.workorderId.split('_');
                            setExternalWOs.add(lstWorkOrderIdOriginal[0]);
                        }
                        else
                        {
                            setScheduledWOs.add(destNode.workorderId);
                        }
                    }
                }
            }
            strLogger += system.now() + ': Scheduled WOs from Result size....'+setScheduledWOs.size()+'\n';
            //strLogger += system.now() + ': Scheduled WOs from Result details....'+setScheduledWOs+'\n';
            if(setExternalWOs.size() > 0) setScheduledWOs.addAll(setExternalWOs);
            
            // From OptiMax output, get the list of unassigned work orders and unassigned events
            strLogger += system.now() + ': Getting the list of unassigned work orders\n';
            
            
            //prcess unassigned events. Updating stats for unassigned events.
            try{
                List<Event> lstUnAssignedSFEvents = [SELECT id, SVMXC__SM_Status__c, WhatId, Subject, OwnerId, startDateTime, EndDateTime, Location, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__Driving_Time__c, SVMXC__SM_Idle_Time__c, SVMXC__Driving_Time_Home__c from event where id IN :mapUnassignedSFEvents.keySet() and isDeleted = false];
                strLogger += system.now() + 'lstUnAssignedSFEvents - ' + lstUnAssignedSFEvents + '\n';
                if(lstUnAssignedSFEvents != null && lstUnAssignedSFEvents.size() > 0){
                    for(Event eventobj :lstUnAssignedSFEvents){
                        eventobj.SVMXC__SM_Status__c='Non-Optimizable';
                        lstSFEvents.add(eventobj);
                    }
                }
                
                List<SVMXC__SVMX_Event__c> lstUnAssignedSMAXEvents = [SELECT id, SVMXC__SM_Status__c, SVMXC__WhatId__c, Name, SVMXC__Technician__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__DurationInMinutes__c, SVMXC__Driving_Time__c, SVMXC__SM_Idle_Time__c, SVMXC__Driving_Time_Home__c from SVMXC__SVMX_Event__c where id IN :mapUnassignedSMAXEvents.keySet() and isDeleted = false];
                strLogger += system.now() + 'lstUnAssignedSMAXEvents - ' + lstUnAssignedSMAXEvents + '\n';
                if(lstUnAssignedSMAXEvents != null && lstUnAssignedSMAXEvents.size() > 0){
                    for(SVMXC__SVMX_Event__c smaxEventobj :lstUnAssignedSMAXEvents){
                        smaxEventobj.SVMXC__SM_Status__c='Non-Optimizable';
                        lstSvmxEvents.add(smaxEventobj);
                    }
                }
            } catch(Exception e) {
                strLogger += system.now()+'Fetching and updating status of unassigned events ::Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n';    
            }               
            
            //strLogger += system.now() + ': Usage Details: After getting the list of scheduled work orders, scheduled technicians, and unassigned work orders\n\tHeap Size     : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            
            // From SVMX Job record, get the list of events related to work orders sent for rescheduling
            strLogger += system.now() + ': Getting the list of events related to work orders sent for rescheduling from SVMX Job record\n';
            
            String strSvmxJobMsg = '';
            try
            {
                Attachment objgetAdditionalInfoAttach = [SELECT Body from Attachment where Name = 'Additional Work Order with Event Details' and ParentId = :objSvmxJob.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                strSvmxJobMsg = objgetAdditionalInfoAttach.Body.toString();
                //delete objgetAdditionalInfoAttach;
            }
            catch(QueryException ex)
            {
                // No attachment available
            }
            
             strLogger += system.now() +'CompleteJob- The String with wo, wo events and overnight events to be deleted :- '+strSvmxJobMsg+'\n'; 
            if(strSvmxJobMsg != NULL && strSvmxJobMsg.length() > 0)
            {
                strSvmxJobMsg = strSvmxJobMsg.replace('~|~', '~');
                List<String> lstReschedWOIdsEvents = new List<String>();
                lstReschedWOIdsEvents = strSvmxJobMsg.split('~');
                if(lstReschedWOIdsEvents != null && lstReschedWOIdsEvents.size() > 0)
                {
                    // Get the list of work order events to be deleted
                    if(lstReschedWOIdsEvents[1] != NULL && lstReschedWOIdsEvents[1].length() > 0)
                    {
                        for(String strWOEvent : lstReschedWOIdsEvents[1].split(',')){
                            String strWOEventTrim = strWOEvent.trim();
                            if(strWOEventTrim.startsWith(strSfEventKeyPrefix))
                                setSFEventsToBeDeleted.add(strWOEventTrim);
                            else
                                setSvmxEventsToBeDeleted.add(strWOEventTrim);
                        }
                    }
                    //Begin : Spring 17 - Overnight - Add overnight event ids to be deleted
                    strLogger += system.now() +': The Overnight Events String to be deleted :- '+lstReschedWOIdsEvents[2]+'\n';
                    if(lstReschedWOIdsEvents[2] != NULL && lstReschedWOIdsEvents[2].length() > 0)
                    {
                        for(String overnightEvent : lstReschedWOIdsEvents[2].split(',')){
                             strLogger += system.now()+': OvernightEvent to Delete '+overnightEvent+'\n';
                             String overNightEventTrim = overnightEvent.trim();
                            if(overNightEventTrim.startsWith(strSfEventKeyPrefix))
                                setOvernightSFEventsToBeDeleted.add(overNightEventTrim);
                            else
                                setOvernightSvmxEventsToBeDeleted.add(overNightEventTrim);
                        }
                    }
                    //End : Spring 17 - Overnight - Add overnight event ids to be deleted
                }
            }
            
            try{
                //retrieve all the Overnight SFEvents and delete it. As the new Overnight events are getting created below in event creation logic
                List<Event> lstOvernightSFEventsToDelete = [SELECT id, WhatId, Subject, OwnerId, startDateTime, EndDateTime, Location, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__Driving_Time__c, SVMXC__SM_Idle_Time__c, SVMXC__Driving_Time_Home__c from event where id IN :setOvernightSFEventsToBeDeleted and isDeleted = false];
                strLogger += system.now() + 'lstOvernightSFEventsToDelete - ' + lstOvernightSFEventsToDelete + '\n';
                if(lstOvernightSFEventsToDelete != null && lstOvernightSFEventsToDelete.size() > 0){
                    //delete lstOvernightSFEventsToDelete;
                    if( COMM_SecurityUtils.getInstance().isDeletableObject('event') ){      //SDL-SVMX-DELETE-FLS-ENFORCED
                       delete lstOvernightSFEventsToDelete;
                    } else {
                       throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
                
                //retrieve all the Overnight SmaxEvents and delete it. As the new Overnight events are getting created below in event creation logic
                List<SVMXC__SVMX_Event__c> lstOvernightSVMXEventsToDelete = [SELECT id, SVMXC__WhatId__c, Name, SVMXC__Technician__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__DurationInMinutes__c, SVMXC__Driving_Time__c, SVMXC__SM_Idle_Time__c, SVMXC__Driving_Time_Home__c from SVMXC__SVMX_Event__c where id IN :setOvernightSvmxEventsToBeDeleted and isDeleted = false];
                strLogger += system.now() + 'lstOvernightSVMXEventsToDelete - ' + lstOvernightSVMXEventsToDelete + '\n';
                if(lstOvernightSVMXEventsToDelete != null && lstOvernightSVMXEventsToDelete.size() > 0){
                    //delete lstOvernightSVMXEventsToDelete;
                    if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c') ){       //SDL-SVMX-DELETE-FLS-ENFORCED
                       delete lstOvernightSVMXEventsToDelete;
                    } else {
                       throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
            } catch(Exception e) {
                strLogger += system.now()+'ONS Events deletion::Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n';    
            }               

            // Get the list of work orders, technicians, and their lat/long where lat/long are found & returned by OptiMax
            strLogger += system.now() + ': Getting Work order latitude longitude from OptiMax\n';
            if(completeJobDetail.workOrder_WPL != NULL && completeJobDetail.workOrder_WPL.size() > 0)
            {
                for(WorkOrderDetail_WP wo : completeJobDetail.workOrder_WPL)
                {
                    if(wo.workOrderId.contains('_'))
                    {
                        try
                        {
                            wo.workOrderId = wo.workOrderId.split('_')[0];
                        }catch(ListException ex){}
                    }
                    // Put the work order lat/long in map - used as Event location later
                    mapWOTechIdLat.put(wo.workOrderId, wo.location.latitude);
                    mapWOTechIdLong.put(wo.workOrderId, wo.location.longitude);
                    //lstWOName.add(wo.workOrderId);
                }
            }
            
            strLogger += system.now() + ': Getting Technician latitude longitude from OptiMax\n';
            if(completeJobDetail.technician_WPL != NULL && completeJobDetail.technician_WPL.size() > 0)
            {
                for(TechnicianDetail_WP tech : completeJobDetail.technician_WPL)
                {
                    // For WEEKLY mode of JOpt, technician ID is sent as TechnicianGUID_DAY<n>
                    String technicianActualId = tech.technicianId;

                    if(technicianActualId.contains('_'))
                    {
                            try
                            {
                                technicianActualId = technicianActualId.split('_')[0];
                            }catch(ListException ex){}
                    }
                            
                    if(!setTechIdForLatLngUpd.contains(technicianActualId))
                    {
                        setTechIdForLatLngUpd.add(technicianActualId);
                        mapWOTechIdLat.put(technicianActualId, tech.location.latitude);
                        mapWOTechIdLong.put(technicianActualId, tech.location.longitude);
                    }
                }
            }
            
            //TODO: Get the list of technician events and their lat/long where lat/long are found & returned by OptiMax
            strLogger += system.now() + ': Getting TechnicianEvent latitude longitude from OptiMax\n';
            if(completeJobDetail.technicianEvent_WPL != NULL && completeJobDetail.technicianEvent_WPL.size() > 0)
            {
                for(TechnicianEventDetail_WP techEvntDtl : completeJobDetail.technicianEvent_WPL){
                    String techEventFullId = techEvntDtl.technicianEventId;
                    strLogger += system.now() + ' Before split techEventFullId==> ' + techEventFullId + '\n';
                    if(techEventFullId != NULL && techEventFullId.contains('_'))
                    {
                        try{
                            //old ONS event - ONS_2_a1i1700000033XjAAI_Tech1
                            //NonWO event - Event_0fora1i1700000033XjAAI_aKl1900000033XjAAI
                            //new ONS - ONS_Lat:30.639233_Long:-97.687813                            
                            String techEventId = techEventFullId.split('_')[2];
                            strLogger += system.now() + ' After split techEventFullId[2]==> ' + techEventId + '\n';
                            //If ONS event, store full id into the map so that
                            //we can update lat and long during ONS event creation.
                            if(techEventId.startsWith('Long')){
                                mapWOTechIdLat.put(techEventFullId, techEvntDtl.location.latitude);
                                mapWOTechIdLong.put(techEventFullId, techEvntDtl.location.longitude);
                                continue;
                            }
                            //for old ONS event
                            //if (techEventId.startsWith(strTechKeyPrefix)){
                            //    mapWOTechIdLat.put(techEventFullId, techEvntDtl.location.latitude);
                            //    mapWOTechIdLong.put(techEventFullId, techEvntDtl.location.longitude);
                            //    continue;                               
                            //}
                            //if Non workorder event, store event id into the map
                            /*if(techEventId.contains(strSfEventKeyPrefix)){
                                setSFEventsToBeDeleted.add(techEventId);
                            }else{
                                setSvmxEventsToBeDeleted.add(techEventId);
                            }*/
                            if(techEventFullId.startsWith('Event')){
                                mapNonWOTechIdLat.put(techEventId, techEvntDtl.location.latitude);
                                mapNonWOTechIdLong.put(techEventId, techEvntDtl.location.longitude);
                            }
                        }catch(ListException ex){}
                    }
                }
            }
            
            // For the scheduled technicians, retrieve the details from Service_Group_Members__c
            strLogger += system.now() + ': Retrieving the details of scheduled technicians\n';
            //strLogger += system.now() + ': setScheduledTechs-----'+setScheduledTechs+'\n';
            lstOptiMaxOPTechs = [Select Id, Name, SVMXC__Working_Hours__c, SVMXC__Service_Group__r.SVMXC__Email__c, SVMXC__Salesforce_User__c, SVMXC__Enable_Scheduling__c,
                                SVMXC__Service_Group__c, SVMXC__Email__c, SVMXC__Street__c, SVMXC__City__c
                                from SVMXC__Service_Group_Members__c
                                where Id IN :setScheduledTechs AND SVMXC__Active__c = TRUE];
                                
            Map<Id, List<SVMXC__Service_Group_Skills__c>> mapTechIdSkills = new Map<Id, List<SVMXC__Service_Group_Skills__c>>();
            SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils omaxViltnUtls = new SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils();
            mapTechIdSkills = omaxViltnUtls.skillsPerTech(setScheduledTechs);
            
            Map<Id, String> mapTechIdProduct = new  Map<Id, String>();
            mapTechIdProduct = omaxViltnUtls.expertisePerTech(setScheduledTechs);
            if(lstOptiMaxOPTechs != NULL && lstOptiMaxOPTechs.size() > 0)
            {
                for(SVMXC__Service_Group_Members__c opTech : lstOptiMaxOPTechs)
                {
                    //strLogger += system.now() + ': opTech.name-----'+opTech.name+'\n';
                    mapTechIdSFUserId.put(opTech.Id, opTech.SVMXC__Salesforce_User__c);
                    mapTechIdIsSchedulingEnabled.put(opTech.Id, opTech.SVMXC__Enable_Scheduling__c);
                    mapTechIdServTeamId.put(opTech.Id, opTech.SVMXC__Service_Group__c);
                    mapTechEmail.put(opTech.Id, opTech.SVMXC__Email__c);
                    mapTeamEmail.put(opTech.Id, opTech.SVMXC__Service_Group__r.SVMXC__Email__c);
                    if(opTech.SVMXC__Working_Hours__c != NULL && mapBusinessHours.containsKey(opTech.SVMXC__Working_Hours__c))
                    {
                        mapTechTimeZone.put(opTech.Id, mapBusinessHours.get(opTech.SVMXC__Working_Hours__c).timeZoneSidKey);
                        //  Begin -Spr17 - Sadiya - Overnight - Put the technician id and business hours
                        mapTechNBusinessHours.put(opTech.Id,mapBusinessHours.get(opTech.SVMXC__Working_Hours__c));
                        //  Begin -Spr17 - Sadiya - Overnight - Put the technician id and business hours
                    }
                    else
                        mapTechTimeZone.put(opTech.Id, objDefTerritoryBH.timeZoneSidKey);
                        //  Begin -Spr17 - Sadiya - Overnight - Put the technician id and  the teritory's business hours
                        mapTechNBusinessHours.put(opTech.Id,objDefTerritoryBH);
                        //  Begin -Spr17 - Sadiya - Overnight - Put the technician id and  the teritory's business hours
                }
            }
            
            //strLogger += system.now() + ': Usage Details: After getting the details of scheduled technicians\n\tHeap Size     : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            
            // For all the sent work orders (scheduled or unassigned), retrieve the details from Service_Order__c
            strLogger += system.now() + ': Retrieving the details of all the sent work orders\n';
            //Below code is commented because we are using work order name instead id.
            lstOptiMaxOPWrkOrds = [Select Id, Name, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__OptiMax_status__c, SVMXC__Skill_Set__c, SVMXC__Product__c, SVMXC__Product__r.Name, SVMXC__Group_Member__c, SVMXC__Group_Member__r.Id, SVMXC__Group_Member__r.Name, SVMXC__Qualified_Technicians__c, SVMXC__Scheduled_Date_Time__c,
                                    SVMXC__Driving_Time__c, SVMXC__Idle_Time__c, SVMXC__Member_Email__c, SVMXC__Group_Email__c, SVMXC__Last_Dispatch_Event__c, SVMXC__Service_Duration__c,
                                    SVMXC__Service_Group__c,SVMXC__Violation_Message__c,SVMXC__Violation_Status2__c,SVMXC__Locked_By_DC__c, SVMXC__SM_Lock_Appointment_Schedule__c, SVMXC__SM_Appointment_Type__c, SVMXC__Group_Member__r.SVMXC__Working_Hours__c, 
                                    SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Preferred_Start_Time__c, SVMXC__Preferred_End_Time__c, SVMXC__Preferred_Business_hours__c,SVMXC__Street__c,SVMXC__City__c, SVMXC__Dependency_Group__c, SVMXC__First_Assigned_DateTime__c, SVMXC__FirstScheduledDateTime__c from SVMXC__Service_Order__c
                                    where Name in : setScheduledWOs or Name in : mapUnassignedWorkOrders.keySet()];     

            strLogger += system.now() + ': Retrieving the details of all the invalid/bad work orders\n';   
            if(mapInvalidWOErrors != null && mapInvalidWOErrors.size() > 0){
                lstOptiMaxBADWrkOrds = [Select Id, Name, SVMXC__OptiMax_Error_Text__c from SVMXC__Service_Order__c where Name in : mapInvalidWOErrors.keyset()];    
            }    
            //strLogger += system.now() + ': Usage Details: After getting the details of scheduled work orders\n\tHeap Size     : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            
            // Get the default Work Order Service Duration
            Double dblDefaultWOServiceDuration = 0;
            if(mapSettingValues.containsKey('OMAX003_SET004') == TRUE)
                dblDefaultWOServiceDuration = decimal.valueof(mapSettingValues.get('OMAX003_SET004'));
            if (dblDefaultWOServiceDuration < 1)
                dblDefaultWOServiceDuration = 3600;
            
            Set<Id> unAssingedWOIds = new Set<Id>();
            // Build separate lists of scheduled and unassigned work orders, with relevant details
            if(lstOptiMaxOPWrkOrds != NULL && lstOptiMaxOPWrkOrds.size() > 0)
            {
                for(SVMXC__Service_Order__c omaxOpWO : lstOptiMaxOPWrkOrds)
                {
                    if(omaxOpWO.SVMXC__Service_Duration__c == NULL)
                        omaxOpWO.SVMXC__Service_Duration__c = dblDefaultWOServiceDuration;
                    //Below code commented because we are using WO name instead id.
                    //if(setScheduledWOs.contains(omaxOpWO.Id))// Scheduled work orders
                    if(setScheduledWOs.contains(omaxOpWO.Name))// Scheduled work orders
                    {
                        //mapWrkOrdIdServDuration.put(omaxOpWO.Id, omaxOpWO.SVMXC__Service_Duration__c);
                        //mapScheduledWO.put(omaxOpWO.Id, omaxOpWO);
                        mapWrkOrdIdServDuration.put(omaxOpWO.Name, omaxOpWO.SVMXC__Service_Duration__c);
                        mapScheduledWO.put(omaxOpWO.Name, omaxOpWO);
                        if(omaxOpWO.SVMXC__Latitude__c != NULL)
                            mapWOTechIdLat.put(omaxOpWO.Name, String.valueof(omaxOpWO.SVMXC__Latitude__c));
                        if(omaxOpWO.SVMXC__Longitude__c != NULL)
                            mapWOTechIdLong.put(omaxOpWO.Name, String.valueof(omaxOpWO.SVMXC__Longitude__c));
                            
                        mapWOIdNAddress.put(omaxOpWO.Name,omaxOpWO.SVMXC__Street__c+', '+omaxOpWO.SVMXC__City__c);
                    }
                    else// Unassigned work orders, possible in STRICT mode; reset them
                    {
                        omaxOpWO.SVMXC__OptiMax_status__c = NULL;
                        omaxOpWO.SVMXC__Group_Member__c = NULL;
                        omaxOpWO.SVMXC__Scheduled_Date_Time__c = NULL;
                        omaxOpWO.SVMXC__Driving_Time__c = NULL;
                        omaxOpWO.SVMXC__Idle_Time__c = NULL;
                        omaxOpWO.SVMXC__Member_Email__c = NULL;
                        omaxOpWO.SVMXC__Group_Email__c = NULL;
                        omaxOpWO.SVMXC__Last_Dispatch_Event__c = NULL;
                        omaxOpWO.SVMXC__Service_Group__c = NULL;
                        omaxOpWO.SVMXC__Locked_By_DC__c = false;
                        omaxOpWO.SVMXC__SM_Lock_Appointment_Schedule__c = NULL;
                        
                        
                        if(omaxOpWO.SVMXC__Latitude__c == NULL && mapWOTechIdLat.containsKey(omaxOpWO.Name) && mapWOTechIdLat.get(omaxOpWO.Name) != NULL)
                            omaxOpWO.SVMXC__Latitude__c = Decimal.valueOf(mapWOTechIdLat.get(omaxOpWO.Name));
                        if(omaxOpWO.SVMXC__Longitude__c == NULL && mapWOTechIdLong.containsKey(omaxOpWO.Name) && mapWOTechIdLong.get(omaxOpWO.Name) != NULL)
                            omaxOpWO.SVMXC__Longitude__c = Decimal.valueOf(mapWOTechIdLong.get(omaxOpWO.Name));
                        //if(omaxOpWO.SVMXC__Last_Dispatch_Event__c == 'Scheduled')
                        //    omaxOpWO.SVMXC__Last_Dispatch_Event__c = 'UnScheduled';
                            
                        //reset violations
                        omaxOpWO.SVMXC__Violation_Message__c = mapUnassignedWorkOrders.get(omaxOpWO.Name);
                        omaxOpWO.SVMXC__OptiMax_Error_Text__c = mapUnassignedWorkOrders.get(omaxOpWO.Name);
                        omaxOpWO.SVMXC__Violation_Status2__c ='Unresourced';                                                
                        //handling dependency work orders to update the violation message
                        if(omaxOpWO.SVMXC__Dependency_Group__c != null){
                            omaxOpWO.SVMXC__Violation_Message__c = 'Dependency relationship violations occurred.';
                            omaxOpWO.SVMXC__Violation_Status2__c ='Dependency Relationship Violation';
                        }
                        lstWOToBeUpdated.add(omaxOpWO);
                        //create set of un assigned work order ids
                        unAssingedWOIds.add(omaxOpWO.Id);
                    }
                }
            }
            
            //TODO : sadiya - Private to updte WO
            // Bad Workorders
            if(lstOptiMaxBADWrkOrds != NULL && lstOptiMaxBADWrkOrds.size() > 0)
            {
                String errType = system.label.OMAX002_TAG029;//Dispatch Parameter Error.;
                for(SVMXC__Service_Order__c badpWO : lstOptiMaxBADWrkOrds)
                {                        
                    String errMsg = mapInvalidWOErrors.get(badpWO.Name);
                    if(errMsg != null && errMsg.equalsIgnoreCase('Unaffected')){
                        String errTypeUnaffected = 'Divide and Conquer';
                        String errMsgUnaffected = 'Unaffected work order during division';
                        badpWO.SVMXC__OptiMax_Error_Text__c = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm') + ' - ' + errTypeUnaffected +': '+errMsgUnaffected + '\n';
                        badpWO.SVMXC__Violation_Message__c = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm') + ' - ' + errTypeUnaffected +': '+errMsgUnaffected + '\n';
                        badpWO.SVMXC__Violation_Status2__c = 'Unscheduled - DCO';
                    }else{
                        badpWO.SVMXC__OptiMax_Error_Text__c = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm') + ' - ' + errType +': '+errMsg + '\n';
                        badpWO.SVMXC__Violation_Message__c = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm') + ' - ' + errType +': '+errMsg + '\n';
                        badpWO.SVMXC__Violation_Status2__c = 'Unscheduled - Bad Data';
                    }
                    lstWOToBeUpdated.add(badpWO);                    
                }
            }
            
            //setting the violation message and error text for BAD workorders
            //lstWOToBeUpdated.addAll(SMAX_OptiMax_Engine_Ext.setErrorAndViolationMsg(lstOptiMaxBADWrkOrds, mapInvalidWOErrors));
            
            //strLogger += system.now() + ': Usage Details: After building separate lists of scheduled and unassigned work orders\n\tHeap Size      : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            
            // Preparing the list of Events to be created and Work Orders to be updated
            strLogger += system.now() + ': Preparing the list of Events to be created and Work Orders to be updated\n';
            
            //set<Id> setUpdatedWorkOrder = new set<Id>();
            set<string> setUpdatedWorkOrder = new set<string>();
            list<Route_WP> lstTempRoutes = new list<Route_WP>(); 
            
            //Retrieves the violations of all the scheduled WOs and deletes it.
            List<SVMXC__SM_Scheduling_Violation__c>  listViolations = new List<SVMXC__SM_Scheduling_Violation__c>();
            listViolations = [Select Name from SVMXC__SM_Scheduling_Violation__c where SVMXC__SM_Work_Order__r.Name in : setScheduledWOs];
            if(listViolations.size() > 0)
                //delete listViolations;
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SM_Scheduling_Violation__c') ){  //SDL-SVMX-DELETE-FLS-ENFORCED
                   delete listViolations;
                } else {
                   throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
                
            //Begin : Sadiya : Fetch all the sf svmx  overnight events on each day 
             Map<String,Set<Date>> technicianOvernightEventsMap = clsOMaxExtension.getTechnicianConfirmedOvernightEventDates(setScheduledTechs);
             Set<Date> overnightEventDatesList = new Set<Date>();
            //Begin : Sadiya : Fetch all the sf svmx  overnight events on each day 
            
                         
            for(Route_WP route: lstRoutes)
            {
                Integer intDrivingTimeBeforeEvent = 0;
                Route_WP wpTmpRoute = new Route_WP();
                list<DestinationNodes_WP> lstDestinationNodes = new list<DestinationNodes_WP>();
                // If incremental run and work order is scheduled for other than today, unschedule the work order
                if(isFullRun == FALSE)
                {
                    strLogger += system.now() + ': Incremental run and work order is scheduled for other than today\n';
                    List<DestinationNodes_WP> allowedWrkOrdrDestNodes = new List<DestinationNodes_WP>();
                    for(DestinationNodes_WP destNode : route.destinationNodes_WPL)
                    {
                        system.debug('destNode...'+destNode);
                        Date datRouteStartLocal;
                        if(isFullRun == FALSE)
                        {
                            if(mapTechTimeZone.containsKey(route.resourceId) && mapTechTimeZone.get(route.resourceId) != NULL)
                            {
                                datRouteStartLocal = Date.valueOf((destNode.arraivalTime).format('yyyy-MM-dd', mapTechTimeZone.get(route.resourceId)));
                            }
                            else
                            {
                                datRouteStartLocal = Date.valueOf((destNode.arraivalTime).format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
                            }
                        }
                        if(datRouteStartLocal > datToday)
                        {
                            if((destNode.workorderId).startsWith(strWOKeyPrefix) && mapScheduledWO.containsKey(destNode.workorderId) && mapScheduledWO.get(destNode.workorderId) != NULL)
                            {
                                // Ensure that a work order is updated only once. Also prevent externally scheduled work orders from getting upated.
                                if(!setUpdatedWorkOrder.contains(destNode.workorderId) && !destNode.workorderId.contains('_'))
                                {
                                    objWorkOrder = new SVMXC__Service_Order__c();
                                    setUpdatedWorkOrder.add(destNode.workorderId);
                                    objWorkOrder = mapScheduledWO.get(destNode.workorderId);
                                    if(objWorkOrder.SVMXC__Latitude__c == NULL && mapWOTechIdLat.containsKey(destNode.workorderId) && mapWOTechIdLat.get(destNode.workorderId) != NULL)
                                        objWorkOrder.SVMXC__Latitude__c = Decimal.valueOf(mapWOTechIdLat.get(destNode.workorderId));
                                    if(objWorkOrder.SVMXC__Longitude__c == NULL && mapWOTechIdLong.containsKey(destNode.workorderId) && mapWOTechIdLong.get(destNode.workorderId) != NULL)
                                        objWorkOrder.SVMXC__Longitude__c = Decimal.valueOf(mapWOTechIdLong.get(destNode.workorderId));
                                    objWorkOrder.SVMXC__Group_Member__c = NULL;
                                    objWorkOrder.SVMXC__Service_Group__c = NULL;
                                    objWorkOrder.SVMXC__OptiMax_Status__c = '';
                                    objWorkOrder.SVMXC__Scheduled_Date_Time__c = NULL;
                                    objWorkOrder.SVMXC__Driving_Time__c = NULL;
                                    objWorkOrder.SVMXC__Idle_Time__c = NULL;
                                    objWorkOrder.SVMXC__Group_Email__c = '';
                                    objWorkOrder.SVMXC__Member_Email__c = '';
                                    objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c = NULL;
                                    objWorkOrder.SVMXC__Locked_By_DC__c = false;
                                    
                                    //if(objWorkOrder.SVMXC__Last_Dispatch_Event__c == 'Scheduled')
                                    //    objWorkOrder.SVMXC__Last_Dispatch_Event__c = 'UnScheduled';
                                    
                                    //reset violations
                                    objWorkOrder.SVMXC__Violation_Message__c = '';
                                    objWorkOrder.SVMXC__Violation_Status2__c ='--None--';
                                    
                                    lstWOToBeUpdated.add(objWorkOrder);
                                }
                               
                            }
                            continue;
                        }
                        else
                        {
                            lstDestinationNodes.add(destNode);
                        }
                    }
                }
                //if FULL RUN collect the non work order event details for latitude, longitude and drive time update purpose.
                else {
                    for(DestinationNodes_WP destNode : route.destinationNodes_WPL)
                    {
                        if((destNode.workorderId).startsWith('Event'))
                        {
                            String techEvntId = destNode.workorderId.split('_')[2];
                            strLogger += system.now() + 'SMAX_Complete_OptiMax_Job_WS::Adding this non WO event Id into set for query the record to update lat long and drivetime ' + techEvntId+'\n';
                            if(techEvntId.contains(strSfEventKeyPrefix)){
                                setSFEventsToBeDeleted.add(techEvntId);
                                setNonWOSFEvents.add(techEvntId);
                            }else{
                                setSvmxEventsToBeDeleted.add(techEvntId);
                                setNonWOSvmxEvents.add(techEvntId);
                            }                            
                        }
                    }                       
                }
                if(lstDestinationNodes.size() > 0)
                {
                    wpTmpRoute.destinationNodes_WPL = lstDestinationNodes;
                    wpTmpRoute.resourceId = route.resourceId;
                    lstTempRoutes.add(wpTmpRoute);
                }
            }
            
            //create two maps of WOid-> Event and WOid-> SMAXEvent
            Map<String, Event> sfEventsMap = new Map<String, Event>();
            Map<String, SVMXC__SVMX_Event__c> smaxEventsMap = new Map<String, SVMXC__SVMX_Event__c>();
            Map<String, Event> sfNonWOEventsMap = new Map<String, Event>();
            Map<String, SVMXC__SVMX_Event__c> smaxNonWOEventsMap = new Map<String, SVMXC__SVMX_Event__c>();
            
            List<Event> lstUnassignedWOSFEvents = new List<Event>();
            List<SVMXC__SVMX_Event__c> lstUnassignedWOSVMXEvents = new List<SVMXC__SVMX_Event__c>();
            
            List<Event> lstSFEventsToDelete = [SELECT id, WhatId, Subject, OwnerId, startDateTime, EndDateTime, Location, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__Driving_Time__c, SVMXC__SM_Idle_Time__c, SVMXC__Driving_Time_Home__c,SVMXC__SM_Status__c, Type from event where id IN :setSFEventsToBeDeleted and isDeleted = false];
            if(lstSFEventsToDelete != null && lstSFEventsToDelete.size() > 0){
                for(Event event : lstSFEventsToDelete){
                    if(unAssingedWOIds != null && unAssingedWOIds.size() >0 && unAssingedWOIds.contains(event.WhatId)){
                        lstUnassignedWOSFEvents.add(event);
                    }else{
                        if(event.WhatId != null && !String.valueOf(event.get('WhatId')).contains(strTechKeyPrefix) && !setNonWOSFEvents.contains(event.Id))
                            sfEventsMap.put(event.get('WhatId') + '', event);   
                        else
                            sfNonWOEventsMap.put(event.get('Id') + '', event);
                    }
                }
            }
            strLogger += system.now() + 'sfEventsMap.size() - ' + sfEventsMap.size() + '\n';
            strLogger += system.now() + 'sfNonWOEventsMap - ' + sfNonWOEventsMap + '\n';
            
            //fetch the existing servicemax events for the workorder
            List<SVMXC__SVMX_Event__c> lstSVMXEventsToDelete = [SELECT id, SVMXC__WhatId__c, Name, SVMXC__Technician__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__DurationInMinutes__c, SVMXC__Driving_Time__c, SVMXC__SM_Idle_Time__c, SVMXC__Driving_Time_Home__c, SVMXC__SM_Status__c, SVMXC__Type__c from SVMXC__SVMX_Event__c where id IN :setSvmxEventsToBeDeleted and isDeleted = false];
            if(lstSVMXEventsToDelete != null && lstSVMXEventsToDelete.size() > 0){
                for(SVMXC__SVMX_Event__c event : lstSVMXEventsToDelete){
                    if(unAssingedWOIds != null && unAssingedWOIds.size() >0 && unAssingedWOIds.contains(event.SVMXC__WhatId__c)){
                        lstUnassignedWOSVMXEvents.add(event);
                    }else{
                        if(event.SVMXC__WhatId__c != null && !setNonWOSvmxEvents.contains(event.Id))
                            smaxEventsMap.put(event.get('SVMXC__WhatId__c') + '', event);
                        else
                            smaxNonWOEventsMap.put(event.get('Id') + '', event);
                    }
                }
            }
            strLogger += system.now() + 'Unassigned workorder SF events size.. - ' + lstUnassignedWOSFEvents.size() + '\n';
            strLogger += system.now() + 'Unassigned workorder SVMX events size...- ' + lstUnassignedWOSVMXEvents.size() + '\n';         
            strLogger += system.now() + 'smaxEventsMap.size() - ' + smaxEventsMap.size() + '\n';
            //strLogger += system.now() + 'smaxEventsMap - ' + smaxEventsMap + '\n';
            strLogger += system.now() + 'smaxNonWOEventsMap - ' + smaxNonWOEventsMap + '\n';
            
            //TODO: delete unassigned work order events 
            if(lstUnassignedWOSFEvents != null && lstUnassignedWOSFEvents.size() > 0){
                 if(COMM_SecurityUtils.getInstance().isDeletableObject('Event') ){  //SDL-SVMX-DELETE-FLS-ENFORCED
                   delete lstUnassignedWOSFEvents;
                } else {
                   throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            
            if(lstUnassignedWOSVMXEvents != null && lstUnassignedWOSVMXEvents.size() > 0){
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c') ){  //SDL-SVMX-DELETE-FLS-ENFORCED
                   delete lstUnassignedWOSVMXEvents;
                } else {
                   throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }                       
            
            // If incremental run remove all next days schedules
            if(isFullRun == FALSE)
                lstRoutes = lstTempRoutes;
                
            //strLogger += system.now() + ':Heap size before executing constraint violation code: ' + Limits.getHeapSize() + '\n';
            List<Datetime> listHorizontalDateTime = new List<Datetime>();
            for(Route_WP route: lstRoutes)
            {
                Integer intDrivingTimeBeforeEvent = 0;
                integer i=1;
                Double returnDriveTime=0;
                if(route.routeTime != null )
                 returnDriveTime = route.routeTime.returnDrivingTime;
                
                strLogger += system.now() + ': Return Drive Time of the Route: ' + i+'is: '+ returnDriveTime + ' [Hrs] \n';
                list<DestinationNodes_WP> lstDestinationNodes = new list<DestinationNodes_WP>();
                lstDestinationNodes = route.destinationNodes_WPL;
                strLogger += system.now() + ': Size of the Route: ' + lstDestinationNodes.size() + '\n';
                
                List<SVMXC__SVMX_Event__c> lstSmaxEventsToDel = new List<SVMXC__SVMX_Event__c>();
                List<Event> lstSFEventsToDel = new List<Event>();
                
                //Added the below logic to check if the setting GBL025 is set to smaxEvent or SalesforceEvent
                //Based on this setting either create a smaxEvent or salesforceEvent
                boolean isSFEvent = false;
                String strGBL025;
                if(mapSettingValues.containsKey('GLOB001_GBL025')) {
                    strGBL025 = mapSettingValues.get('GLOB001_GBL025');
                }
                strLogger += system.now() + ':The setting value of strGBL025 - ' + strGBL025 + '\n';
                if(String.isNotEmpty(strGBL025) && strGBL025.equalsIgnoreCase('ServiceMax Event')) {
                    isSFEvent = false;
                } else if(String.isNotEmpty(strGBL025) && strGBL025.equalsIgnoreCase('Salesforce Event')) {
                    isSFEvent = true;
                }
                
                // Tech associated with Salesforce User
                if(mapTechIdSFUserId.containsKey(route.ResourceId) && mapTechIdSFUserId.get(route.ResourceId)!=NULL)
                {
                    strLogger += system.now() + ': Setting up events and updating work orders for technician: ' + route.ResourceId + '\n';
                    strLogger += system.now() + ': route.destinationNodes_WPL.size() -  ' + route.destinationNodes_WPL.size() + '\n';
                    for(DestinationNodes_WP destNode : route.destinationNodes_WPL)
                    {
                        strLogger += system.now() + 'destNode - ' + destNode + '\n';
                        strLogger += system.now() + 'strWOKeyPrefix - ' + strWOKeyPrefix + '\n';
                        
                        if((destNode.workorderId).startsWith(strWOKeyPrefix))
                        {
                            if(destNode.workorderId.contains('_'))
                            {
                                try
                                {
                                    destNode.workorderId = destNode.workorderId.split('_')[0];
                                }catch(ListException ex){}
                            }
                            
                            //strLogger += system.now() + ':mapScheduledWO....: ' + mapScheduledWO + '\n';
                            strLogger += system.now() + ':destNode.workorderId....: ' + destNode.workorderId + '\n';
                            // If the work order doesn't exist, skip the event creation 
                            if(!mapScheduledWO.containsKey(destNode.workorderId))
                            {
                                intMissingWorkOrderCount++;
                                strDeletedWorkOrderDetails += destNode.workorderId + ',' + route.resourceId +',' + destNode.arraivalTime + ',' + destNode.departureTime + ',' + destNode.drivingTime + '\n';
                                i++;
                                continue;
                            }
                            
                            strLogger += system.now() + ' isSFEvent : ' + isSFEvent + '\n';
                            system.debug('isSFEvent : ' + isSFEvent);
                            if(isSFEvent) {
                                
                                //if this WO already has a SMAXEvent, delete it before creating a new SFEvent
                                strLogger += system.now() + 'smaxEventsMap.containsKey(mapScheduledWO.get(destNode.workorderId).Id) - ' + smaxEventsMap.containsKey(mapScheduledWO.get(destNode.workorderId).Id) + '\n';
                                if(smaxEventsMap.containsKey(mapScheduledWO.get(destNode.workorderId).Id)) {
                                    strLogger += system.now() + ' This WO ' + destNode.workorderId + ' also contains SMAX Event. Hence deleting it.' + '\n';
                                    SVMXC__SVMX_Event__c smaxEvent = smaxEventsMap.get(mapScheduledWO.get(destNode.workorderId).Id);
                                    strLogger += system.now() + ' smaxEvent - ' + smaxEvent.Id + '\n';
                                    if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c') ){  //SDL-SVMX-DELETE-FLS-ENFORCED
                                        lstSmaxEventsToDel.add(smaxEvent); //add the SmaxEvent to the list. This list will be deleted below
                                    } else {
                                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                                    }
                                    smaxEventsMap.remove(mapScheduledWO.get(destNode.workorderId).Id);
                                }
                                
                                //Calculate Drivetime
                                Double dblDrivingTimeMins = (destNode.drivingTime + intDrivingTimeBeforeEvent) / 60;
                                strLogger += system.now() + ':Before setting subject for the event....WO ID: ' + destNode.workorderId + '\n'; 
                                
                                // Set up the event
                                //if the WO already has a SFEvent, update it
                                objSFEvent = sfEventsMap.get(mapScheduledWO.get(destNode.workorderId).Id);
                                strLogger += system.now() + ' Does the event already exists - objSFEvent : ' + objSFEvent + '\n';
                                //If it a new event, then instantiate one.
                                if(objSFEvent == null) {
                                    strLogger += system.now() + 'This is a new event. Hence creating it' + '\n';
                                    objSFEvent = new Event();
                                }
                                objSFEvent.Subject = TAG007 + ' ' + mapScheduledWO.get(destNode.workorderId).Name;
                                objSFEvent.OwnerId = mapTechIdSFUserId.get(route.ResourceId);
                                //objSFEvent.WhatId = destNode.workorderId;
                                objSFEvent.WhatId = mapScheduledWO.get(destNode.workorderId).Id;
                                strLogger += system.now()+': destNode.ArraivalTime: ' +destNode.ArraivalTime + ' , destNode.ArraivalTime.getTime(): '+destNode.ArraivalTime.getTime()+ ' , destNode.drivingTime: '+destNode.drivingTime;
                                objSFEvent.startDateTime = datetime.newInstance(destNode.ArraivalTime.getTime() - ((destNode.drivingTime + intDrivingTimeBeforeEvent) * 1000));
                                objSFEvent.EndDateTime =destNode.DepartureTime;
                                //reset the status from non-optimizable to none
                                objSFEvent.SVMXC__SM_Status__c = '';
                                //Server side calculation is Date startDateTime = new Date (destination.getArrivalTime().getTime() - (long)(Math.floor(destination.getDrivingTime()) * 1000));
                                
                                if(mapWOTechIdLat.get(destNode.workorderId) != NULL && mapWOTechIdLong.get(destNode.workorderId) != NULL){
                                    //objSFEvent.Location = mapWOTechIdLat.get(destNode.workorderId) + ',' + mapWOTechIdLong.get(destNode.workorderId);
                                    //update the lattitude and longitude fields for the technician event additional details
                                    objSFEvent.SVMXC__SM_Latitude__c = Decimal.valueOf(mapWOTechIdLat.get(destNode.workorderId)); 
                                    objSFEvent.SVMXC__SM_Longitude__c = Decimal.valueOf(mapWOTechIdLong.get(destNode.workorderId));
                                }
                                objSFEvent.ActivityDateTime = objSFEvent.startDateTime;
                                objSFEvent.ActivityDate = objSFEvent.startDateTime.dateGMT();
                                objSFEvent.SVMXC__Driving_Time__c=dblDrivingTimeMins;
                                objSFEvent.SVMXC__SM_Idle_Time__c = Integer.valueOf(destNode.idleTime / 60);
                                strLogger += system.now() + ': SMAX_Complete_OptiMax_Job_WS SF event idle time :- '+ objSFEvent.SVMXC__SM_Idle_Time__c+'\n';
                                objSFEvent.SVMXC__Driving_Time_Home__c=0;
                              //identify the last work order event and update the return drive time is available in the route level.
                                if(i==lstDestinationNodes.size()){
                                    objSFEvent.SVMXC__Driving_Time_Home__c=returnDriveTime * 60;
                                    strLogger += system.now() + ':Return drivetime for the last work order event in the route....: ' + destNode.workorderId + ' is: '+objSFEvent.SVMXC__Driving_Time_Home__c+'[min.] \n';
                            
                                    Double dblReturnTime = returnDriveTime * 3600; // in seconds
                                    strLogger += system.now() + ': End datetime for the last work order SF event in the route....: ' + destNode.workorderId + ' is: '+objSFEvent.EndDateTime+' \n';
                                   
                                    objSFEvent.EndDateTime = datetime.newInstance(destNode.DepartureTime.getTime() + ((Integer.valueOf(dblReturnTime)) * 1000));
                                    strLogger += system.now() + ': End datetime for the last work order SF event after adding return drivetime....: ' + destNode.workorderId + ' is: '+objSFEvent.EndDateTime+' \n';
                                     
                                    destNode.DepartureTime = objSFEvent.EndDateTime;
                                    strLogger += system.now() + ':Lastnode departuretime updated with return drivetime....: ' + destNode.workorderId + ' is: '+destNode.DepartureTime+' \n';
                                }
                                lstSFEvents.add(objSFEvent);
                            } else {
                                //if this WO already has a SFEvent, delete it before creating a new SMAXEvent
                                strLogger += system.now() + ' sfEventsMap.containsKey(mapScheduledWO.get(destNode.workorderId).Id) - ' + sfEventsMap.containsKey(mapScheduledWO.get(destNode.workorderId).Id) + '\n';
                                if(sfEventsMap.containsKey(mapScheduledWO.get(destNode.workorderId).Id)) {
                                    strLogger += system.now() + ' This WO ' + destNode.workorderId + ' also contains SF Event. Hence deleting it.' + '\n';
                                    Event sfEvent = sfEventsMap.get(mapScheduledWO.get(destNode.workorderId).Id);
                                    strLogger += system.now() + ' sfEvent - ' + sfEvent.Id + '\n';
                                    lstSFEventsToDel.add(sfEvent); //add the SFEvent to the list. This list will be deleted below
                                    sfEventsMap.remove(mapScheduledWO.get(destNode.workorderId).Id);
                                }
                                
                                //Calculate Drivetime
                                Double dblDrivingTimeMins = (destNode.drivingTime + intDrivingTimeBeforeEvent) / 60;
                                //strLogger += system.now() + 'SMAX_Complete_OptiMax_Job_WS dblDrivingTimeMins' + dblDrivingTimeMins+'\n';
                                
                                // Set up the event
                                //if the WO already has a SMAXEvent, update it
                                strLogger += system.now() + 'Before creating smaxEvent, : destNode.workorderId' + destNode.workorderId + '\n';
                                system.debug('Before creating smaxEvent, : destNode.workorderId - ' + destNode.workorderId);
                                objSvmxEvent = smaxEventsMap.get(mapScheduledWO.get(destNode.workorderId).Id);
                                strLogger += system.now() + 'Does the event already exists - objSvmxEvent : ' + objSvmxEvent + '\n';
                                system.debug('Does the event already exists - objSvmxEvent : ' + objSvmxEvent);
                                //If it a new event, then instantiate one.
                                if(objSvmxEvent == null) {
                                    strLogger += system.now() + 'This is a new event. Hence creating it' + '\n';
                                    system.debug('This is a new event. Hence creating it');
                                    objSvmxEvent = new SVMXC__SVMX_Event__c();
                                }
                                objSvmxEvent.Name = TAG007+ ' ' + mapScheduledWO.get(destNode.workorderId).Name;
                                objSvmxEvent.SVMXC__Technician__c = route.resourceId;
                                //objSvmxEvent.SVMXC__WhatId__c = destNode.workorderId;
                                objSvmxEvent.SVMXC__WhatId__c = mapScheduledWO.get(destNode.workorderId).Id;
                                strLogger += system.now()+': destNode.ArraivalTime: ' +destNode.ArraivalTime + ' , destNode.ArraivalTime.getTime(): '+destNode.ArraivalTime.getTime()+ ' , destNode.drivingTime: '+destNode.drivingTime + '\n';
                                strLogger += system.now() + 'SMAX_Complete_OptiMax_Job_WS drivetime to minus from arrival time' + ((destNode.drivingTime + intDrivingTimeBeforeEvent) * 1000) +'\n';
                                objSvmxEvent.SVMXC__StartDateTime__c = datetime.newInstance(destNode.arraivalTime.getTime() - ((destNode.drivingTime + intDrivingTimeBeforeEvent) * 1000));
                                strLogger += system.now() + 'SMAX_Complete_OptiMax_Job_WS Calculated Start Time' +  objSvmxEvent.SVMXC__StartDateTime__c+'\n';
                                 
                                objSvmxEvent.SVMXC__EndDateTime__c = destNode.departureTime;
                                //reset the status from non-optimizable to none
                                objSvmxEvent.SVMXC__SM_Status__c = '';                                
                                if(mapWOTechIdLat.get(destNode.workorderId) != NULL && mapWOTechIdLong.get(destNode.workorderId) != NULL){
                                    //objSvmxEvent.SVMXC__Location__c = mapWOTechIdLat.get(destNode.workorderId) + ',' + mapWOTechIdLong.get(destNode.workorderId);
                                    //update the lattitude and longitude fields for the technician event additional details
                                    objSvmxEvent.SVMXC__SM_Latitude__c = Decimal.valueOf(mapWOTechIdLat.get(destNode.workorderId));
                                    objSvmxEvent.SVMXC__SM_Longitude__c = Decimal.valueOf(mapWOTechIdLong.get(destNode.workorderId));
                                }
                                objSvmxEvent.SVMXC__ActivityDateTime__c = objSvmxEvent.SVMXC__StartDateTime__c;
                                objSvmxEvent.SVMXC__ActivityDate__c = objSvmxEvent.SVMXC__StartDateTime__c.dateGMT();
                                //Double dblDrivingTimeMins = (destNode.drivingTime + intDrivingTimeBeforeEvent) / 60;
                                //Double dblServiceAndIdleTimeMins = (destNode.DepartureTime.gettime() - destNode.arraivalTime.gettime() ) / 60000;
                                //objSvmxEvent.SVMXC__DurationInMinutes__c = dblDrivingTimeMins.intValue() + dblServiceAndIdleTimeMins.intValue();
                                
                                objSvmxEvent.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                objSvmxEvent.SVMXC__SM_Idle_Time__c = Integer.valueOf(destNode.idleTime / 60);
                                strLogger += system.now() + ': SMAX_Complete_OptiMax_Job_WS SF SvmxEvent idle time :- '+ objSvmxEvent.SVMXC__SM_Idle_Time__c+'\n';
                                objSvmxEvent.SVMXC__Driving_Time_Home__c=0;
                                //identify the last work order event and update the return drive time is available in the route level.
                                if(i==lstDestinationNodes.size()){ 
                                    objSvmxEvent.SVMXC__Driving_Time_Home__c=returnDriveTime * 60;
                                    strLogger += system.now() + ':Return drivetime for the last work order event in the route....: ' + destNode.workorderId + ' is: '+objSvmxEvent.SVMXC__Driving_Time_Home__c+'[min.] \n';

                                    Double dblReturnTime = returnDriveTime * 3600; //in seconds
                                    strLogger += system.now() + ':End datetime for the last work order event in the route....: ' + destNode.workorderId + ' is: '+objSvmxEvent.SVMXC__EndDateTime__c+' \n';
                                    objSvmxEvent.SVMXC__EndDateTime__c = datetime.newInstance(destNode.DepartureTime.getTime() + ((Integer.valueOf(dblReturnTime)) * 1000));
                                    strLogger += system.now() + ':End datetime for the last work order event after adding return drivetime....: ' + destNode.workorderId + ' is: '+objSvmxEvent.SVMXC__EndDateTime__c+' \n';
                                    
                                    //set the destNade.DepartureTime with return time
                                    destNode.DepartureTime = objSvmxEvent.SVMXC__EndDateTime__c;
                                    strLogger += system.now() + ':Lastnode departuretime updated with return drivetime....: ' + destNode.workorderId + ' is: '+destNode.DepartureTime+' \n';
                                }
                                lstSvmxEvents.add(objSvmxEvent);
                            }
                            
                            strLogger += system.now() + 'ALL SF Events added to list ' +lstSFEvents.size()+ ' \n';
                            //system.debug('ALL SF Events added to list ' +lstSFEvents);
                            strLogger += system.now() + 'ALL SVMX Events added to list in case if GBL025 is set to smaxEvents' +lstSvmxEvents.size()+ ' \n';
                            //system.debug('ALL SVMX Events added to list in case if GBL025 is set to smaxEvents' +lstSvmxEvents);
                            //strLogger += system.now() + ':Ensure that a work order is updated only once. Also prevent externally scheduled work orders from getting upated: ' + destNode.workorderId + '\n';
                            // Ensure that a work order is updated only once. Also prevent externally scheduled work orders from getting upated.
                            if(!setUpdatedWorkOrder.contains(destNode.workorderId) && !setExternalWOs.contains(destNode.workorderId) && mapScheduledWO.containsKey(destNode.workorderId))
                            {
                                setUpdatedWorkOrder.add(destNode.workorderId);
                                objWorkOrder = new SVMXC__Service_Order__c();
                                objWorkOrder = mapScheduledWO.get(destNode.workorderId);
                                objWorkOrder.SVMXC__OptiMax_status__c = 'Processing Complete';
                                //objWorkOrder.SVMXC__Last_Dispatch_Event__c = 'Scheduled';
                                objWorkOrder.SVMXC__Group_Member__c = route.resourceId;
                                //objWorkOrder.SVMXC__Group_Member__r.Name = mapTechIdName.get(route.resourceId);
                                objWorkOrder.SVMXC__OptiMax_Error_Text__c='';
                                //strLogger += system.now() + ': 3333 route.resourceId----in SMAX_Complete_OptiMax_Job_WS----- ' + route.ResourceId + '\n';
                                
                                //sync Locked by DC and SVMXC__SM_Lock_Appointment_Schedule__c field 
                                if(objWorkOrder.SVMXC__Locked_By_DC__c == true){
                                    objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c =WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
                                }else if(objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c == WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE){
                                    objWorkOrder.SVMXC__Locked_By_DC__c = true;
                                }
    
                                if(mapSettingValues.get('OMAX002_SET003').toUpperCase() == 'TRUE') {
                                    //added the below check to ensure that this part of code gets executed
                                    //only in case of SFEvent when SET025 is set to SFEvent
                                    objWorkOrder.OwnerId = mapTechIdSFUserId.get(route.ResourceId);
                                }
                                    //objWorkOrder.OwnerId = objSFEvent.OwnerId;
                                if(mapTechIdServTeamId.containsKey(route.resourceId))
                                    objWorkOrder.SVMXC__Service_Group__c = mapTechIdServTeamId.get(route.ResourceId);
                                if(mapTeamEmail.containsKey(route.resourceId))
                                    objWorkOrder.SVMXC__Group_Email__c = mapTeamEmail.get(route.resourceId);
                                if(mapTechEmail.containsKey(route.resourceId))
                                    objWorkOrder.SVMXC__Member_Email__c = mapTechEmail.get(route.resourceId);
                                if(objWorkOrder.SVMXC__Latitude__c == NULL && mapWOTechIdLat.get(objWorkOrder.Name) != NULL)
                                    objWorkOrder.SVMXC__Latitude__c = Decimal.valueOf(mapWOTechIdLat.get(objWorkOrder.Name));
                                if(objWorkOrder.SVMXC__Longitude__c == NULL && mapWOTechIdLong.get(objWorkOrder.Name) != NULL)
                                    objWorkOrder.SVMXC__Longitude__c = Decimal.valueOf(mapWOTechIdLong.get(objWorkOrder.Name));                                    
                                    
                                Double dblDrivingTimeMins = (destNode.drivingTime + intDrivingTimeBeforeEvent) / 60;
                                objWorkOrder.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                //objWorkOrder.SVMXC__Idle_Time__c = clsOMaxExtension.computeIdleTime(destNode.arraivalTime, destNode.departureTime, mapWrkOrdIdServDuration.get(destNode.workorderId));
                                //objWorkOrder.SVMXC__Scheduled_Date_Time__c = destNode.arraivalTime.addMinutes((objWorkOrder.SVMXC__Idle_Time__c).intValue());
                                objWorkOrder.SVMXC__Scheduled_Date_Time__c = destNode.arraivalTime;
                                strLogger += system.now() + ':SMAX_Complete_OptiMax_Job_WS:: SVMXC__FirstScheduledDateTime__c value in existing work order...' + objWorkOrder.SVMXC__FirstScheduledDateTime__c + '\n';
                                if(objWorkOrder.SVMXC__FirstScheduledDateTime__c == NULL){
                                    //objWorkOrder.SVMXC__FirstScheduledDateTime__c = objWorkOrder.SVMXC__Scheduled_Date_Time__c;
                                    objWorkOrder.SVMXC__FirstScheduledDateTime__c = system.now();
                                }
                                    
                                    
                                // Technician Violation
                                SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils omaxViolationUtils = new SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils();
                                String strTechnicianViolations = omaxViolationUtils.checkViolations(objWorkOrder, completeJobDetail.jobId, mapBusinessHours, objSvmxProcess, lstOptiMaxOPTechs, strLogger, strDefaultBHourId);
                                
                                //Following case occurs when the WO which was scheduled earlier with violation msg. We need to clear
                                //the msg for next run.
                                if(objWorkOrder.SVMXC__Violation_Message__c != null || objWorkOrder.SVMXC__Violation_Status2__c != null) {
                                    objWorkOrder.SVMXC__Violation_Message__c = '';
                                    objWorkOrder.SVMXC__Violation_Status2__c = null;
                                }
                                             
                                //strLogger += system.now() + ': strTechnicianViolations-1111---in SMAX_Complete_OptiMax_Job_WS----- ' + strTechnicianViolations + '\n';
                                                                                                                                
                                if(strTechnicianViolations!=null && strTechnicianViolations.length()>0 && !strTechnicianViolations.equalsIgnoreCase('null'))
                                {
                                    strTechnicianViolations = strTechnicianViolations.replace(';','\n');
                                    objWorkOrder.SVMXC__Violation_Message__c = strTechnicianViolations;
                                    objWorkOrder.SVMXC__Violation_Status2__c = 'Constraints Violation'; 
                                }
                                                                                                                                
                                //TODO update violation details into workorder
                                List<Violations_WP> lstViolations = destNode.getviolations_WP();
                                if(lstViolations != null && lstViolations.size() > 0){
                                    strLogger +=  system.now() + 'Violaton size() : ' + lstViolations.size() + '\n';
                                    //strLogger +=  system.now() + 'Violatons : ' + lstViolations + '\n';
                                    Violations_WP woViolation = lstViolations[0];
                                    //strLogger +=  system.now() + 'WO Violation : ' + woViolation + '\n';
                                    
                                    if(objWorkOrder.SVMXC__Violation_Message__c == null && (woViolation.value!='LATE' || woViolation.value!='EARLY')){
                                        objWorkOrder.SVMXC__Violation_Message__c =  woViolation.category+':'+woViolation.attribute+':'+woViolation.value;
                                    }else if((woViolation.value != 'LATE' || woViolation.value != 'EARLY')){
                                        objWorkOrder.SVMXC__Violation_Message__c = objWorkOrder.SVMXC__Violation_Message__c +'\n'+ woViolation.category+':'+woViolation.attribute+':'+woViolation.value;
                                    }
                                    //objWorkOrder.SVMXC__Violation_Message__c = objWorkOrder.SVMXC__Violation_Message__c +'\n'+ woViolation.category+':'+woViolation.attribute+':'+woViolation.value;
                                    objWorkOrder.SVMXC__Violation_Status2__c = 'Jeopardy';
                                }
                                                                                                                                
                                if(objWorkOrder.SVMXC__Skill_Set__c != null){
                                    lstOfViolations = omaxViolationUtils.checkSkillViolations(mapTechIdSkills, objWorkOrder, strLogger, completeJobDetail.jobId);                                     
                                    if(lstOfViolations != null && lstOfViolations.size() > 0)
                                    lstViolationDetails.addAll(lstOfViolations);
                                }
                                                                
                                if(objWorkOrder.SVMXC__Preferred_Start_Time__c != null && objWorkOrder.SVMXC__Preferred_End_Time__c != null){
                                    lstOfViolations = omaxViolationUtils.checkSLAViolations(objWorkOrder, mapBusinessHours, completeJobDetail.jobId, strLogger);
                                    
                                    if(lstOfViolations != null && lstOfViolations.size() > 0)
                                    lstViolationDetails.addAll(lstOfViolations); 
                                }
                                
                                if(objWorkOrder.SVMXC__Product__c != null){                              
                                    lstOfViolations = omaxViolationUtils.checkProductExprtseViolations(mapTechIdProduct, objWorkOrder, completeJobDetail.jobId, strLogger);
                                 
                                    if(lstOfViolations != null && lstOfViolations.size() > 0)
                                    lstViolationDetails.addAll(lstOfViolations);
                                }
                                 
                                if(objWorkOrder.SVMXC__Qualified_Technicians__c != null){ 
                                    lstOfViolations = omaxViolationUtils.checkEligibilityRuleViolations(objWorkOrder, completeJobDetail.jobId, strLogger);
                                    if(lstOfViolations != null && lstOfViolations.size() > 0)
                                    lstViolationDetails.addAll(lstOfViolations);
                                    lstOfViolations = omaxViolationUtils.checkPrefrdMandtProhbtTechViolations(objWorkOrder, completeJobDetail.jobId, strLogger, mapTechIdName.get(route.resourceId));
                                    if(lstOfViolations != null && lstOfViolations.size() > 0)
                                    lstViolationDetails.addAll(lstOfViolations);
                                }
                                
                                lstOfViolations.clear();
                                
                                listHorizontalDateTime.add(objWorkOrder.SVMXC__Scheduled_Date_Time__c);
                                
                                lstWOToBeUpdated.add(objWorkOrder);
                            }
                            // Reseting the driving time before event
                            intDrivingTimeBeforeEvent = 0;
                        }
                        else if((destNode.workorderId).startsWith(strONSKeyPrefix)){
                            //1. Query the Overnight Event add it to map (ServerONSId, EventObject);
                            //2. if present set values from destination and update
                            //3. if not present set values from destination and create it.
                            //if strONSKeySuffix is "ReturnDriveHome", set drivetime to previous event driving to home.
                                if((destNode.workorderId).endsWith(strONSKeySuffix)){
                                    strLogger += system.now() + ': Adding Driving to Home in previous Overnight SFEvent..\n';
                                    Event onsPreviousSFEvent = lstSFEvents.get(lstSFEvents.size()-1);
                                    //Double dblDrivingTimeinMin = destNode.drivingTime /60;
                                    Decimal dmlDrivingTimeSec = destNode.drivingTime;
                                    Double dblDrivingTimeinMin = dmlDrivingTimeSec.divide(60,3);
                                    onsPreviousSFEvent.SVMXC__Driving_Time_Home__c=dblDrivingTimeinMin;
                                    onsPreviousSFEvent.EndDateTime=datetime.newInstance(onsPreviousSFEvent.EndDateTime.getTime() + (destNode.drivingTime * 1000));
                                    continue;                                   
                                }
                                
                                // if there are other schedules in the route and return drive time at route level > 0
                                // technician is travelling to another location before stay. Add return drive time
                                // to previous WO event created
                                boolean addDriveTimeBeforeStay = (lstSFEvents.size() > 0 && returnDriveTime > 0);
                                if (addDriveTimeBeforeStay) {
                                   strLogger += system.now() + ': Adding Driving to Home from route data to previous WO SFEvent..\n';
                                   Event previousWoSfEvent = lstSFEvents.get(lstSFEvents.size() - 1);
                                   // Set return drive time to event in minutes
                                   previousWoSfEvent.SVMXC__Driving_Time_Home__c = returnDriveTime * 60;
                                   strLogger += system.now() + ':Return drivetime for the last work order event in the route....: ' + previousWoSfEvent.Subject + ' is: ' + previousWoSfEvent.SVMXC__Driving_Time_Home__c + '[min.] \n';
                                   // Add return drive time in millis to end time to get new end time including return drive time
                                   previousWoSfEvent.EndDateTime = datetime.newInstance(previousWoSfEvent.EndDateTime.getTime() + ((Integer.valueOf(returnDriveTime * 3600)) * 1000)); 
                                   strLogger += system.now() + ': End datetime for the last work order SF event after adding return drivetime....: ' + previousWoSfEvent.Subject + ' is: ' + previousWoSfEvent.EndDateTime + ' \n';
                                }
                                strLogger += system.now() + ': Creating an Overnight SF Event \n';
                                Integer maxLength = SObjectType.Event.Fields.Subject.Length;
                                Event  onsSFEvent = new Event();
                                onsSFEvent.Type = 'Overnight Stay';
                                String subjectAppend = destNode.workorderId;
                                if(subjectAppend.length() > maxLength){
                                    subjectAppend = subjectAppend.substring(0, maxLength);
                                }
                                onsSFEvent.Subject = subjectAppend;
                                onsSFEvent.OwnerId = mapTechIdSFUserId.get(route.ResourceId);
                                String techId = route.ResourceId.split('_')[0];
                                strLogger += system.now() + ': techId '+techId+'\n';
                                onsSFEvent.WhatId = techId;
                                onsSFEvent.SVMXC__SM_Status__c = 'Pending';
                                onsSFEvent.startDateTime = datetime.newInstance(destNode.ArraivalTime.getTime() - (destNode.drivingTime * 1000));
                                onsSFEvent.EndDateTime = destNode.departureTime;
                                if(mapWOTechIdLat.get(destNode.workorderId)!= null && mapWOTechIdLong.get(destNode.workorderId) != null){
                                    onsSFEvent.SVMXC__SM_Latitude__c = Decimal.valueOf(mapWOTechIdLat.get(destNode.workorderId)); 
                                    onsSFEvent.SVMXC__SM_Longitude__c = Decimal.valueOf(mapWOTechIdLong.get(destNode.workorderId));
                                }
                                objSFEvent.ActivityDateTime = objSFEvent.startDateTime;
                                objSFEvent.ActivityDate = objSFEvent.startDateTime.dateGMT();
                                if(!addDriveTimeBeforeStay){
                                    Double dblDrivingTimeMins = destNode.drivingTime / 60;        
                                    onsSFEvent.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                }
                                onsSFEvent.SVMXC__Driving_Time_Home__c=0;
                                lstSFEvents.add(onsSFEvent);
                        }
                        else if((destNode.workorderId).startsWith('Event'))
                        {
                            if(isSFEvent) {
                                strLogger += system.now() + ': SMAX_Complete_OptiMax_Job_WS destNode Non WO Event(SF) ' + destNode.workorderId+'\n';
                                if((destNode.workorderId).endsWith(strONSKeySuffix)){
                                    strLogger += system.now() + ': Adding Driving to Home in previous Confirmed SFEvent..\n';
                                    Event onsPreviousSFEvent = lstSFEvents.get(lstSFEvents.size()-1);
                                    if(onsPreviousSFEvent != null){
                                        //Double dblDrivingTimeinMin = destNode.drivingTime /60;
                                        Decimal dmlDrivingTimeSec = destNode.drivingTime;
                                        Double dblDrivingTimeinMin = dmlDrivingTimeSec.divide(60,3);
                                        onsPreviousSFEvent.SVMXC__Driving_Time_Home__c=dblDrivingTimeinMin;
                                        onsPreviousSFEvent.EndDateTime=datetime.newInstance(onsPreviousSFEvent.EndDateTime.getTime() + (destNode.drivingTime * 1000));
                                    }
                                    continue;                                   
                                }
                                String techEvntId = destNode.workorderId.split('_')[2];
                                strLogger += system.now() + ': SMAX_Complete_OptiMax_Job_WS destNode.workorderId.split(_)[2] ' + techEvntId+'\n';
                                //This null check required if events sent without salesforceId - for break hours no events so no Id.
                                if(techEvntId != null){
                                    Event nonWOSFEvent = sfNonWOEventsMap.get(techEvntId);
                                    if(nonWOSFEvent != null){
                                        //update Non WO event, only drivetime and return drive time with existing start datetime and end datetime
                                        if(nonWOSFEvent.SVMXC__SM_Status__c != 'Confirmed' && nonWOSFEvent.Type != 'Overnight Stay'){
                                            strLogger += system.now() + ': SMAX_Complete_OptiMax_Job_WS::Need to reset the Driving back to home and also reset the Start datetime of the nonWO SF event..\n';
        
                                            //if existing return drivetime is >0  then before reset the return drive time update the enddatetime
                                            if(nonWOSFEvent.SVMXC__Driving_Time_Home__c > 0){
                                                Double dblReturnTimeMinsOld = Double.valueOf(nonWOSFEvent.SVMXC__Driving_Time_Home__c);
                                                Decimal endDTinMilSec = nonWOSFEvent.EndDateTime.getTime() - (dblReturnTimeMinsOld * 60 * 1000);
                                                nonWOSFEvent.EndDateTime=datetime.newInstance(endDTinMilSec.longValue());
                                            }
                                            nonWOSFEvent.SVMXC__Driving_Time_Home__c=0.0;
                                            strLogger += system.now() + ': New End datetime of SFEvent in GMT..'+nonWOSFEvent.EndDateTime+'\n';
                                            
                                            //need to find the drive time difference and update the start datetime
                                            Double dblDrivingTimeMins = destNode.drivingTime / 60;
                                            Double dblDrivingTimeMinsOld = Double.valueOf(nonWOSFEvent.SVMXC__Driving_Time__c);
                                            strLogger += system.now() + ': Existing drive time of SFEvent in minutes..'+dblDrivingTimeMinsOld+'\n';
                                            strLogger += system.now() + ': New drive time of SFEvent in minutes..'+dblDrivingTimeMins+'\n';
                                            Decimal startDTinMilSec;
                                            if(dblDrivingTimeMinsOld > dblDrivingTimeMins){
                                                Double diffInMinutes = dblDrivingTimeMinsOld - dblDrivingTimeMins;
                                                startDTinMilSec = nonWOSFEvent.StartDateTime.getTime() + (diffInMinutes * 60 * 1000);
                                            }else{
                                                Double diffInMinutes = dblDrivingTimeMins - dblDrivingTimeMinsOld;
                                                startDTinMilSec = nonWOSFEvent.StartDateTime.getTime() - (diffInMinutes * 60 * 1000);
                                            }
                                            nonWOSFEvent.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                            //Decimal startDTinMilSec = nonWOSFEvent.StartDateTime.getTime() - (destNode.drivingTime * 1000);
                                            strLogger += system.now() + ': Existing start datetime of SFEvent in GMT..'+nonWOSFEvent.StartDateTime+'\n';
                                            nonWOSFEvent.StartDateTime=datetime.newInstance(startDTinMilSec.longValue());
                                            strLogger += system.now() + ': New start datetime of SFEvent in GMT..'+nonWOSFEvent.StartDateTime+'\n';                                 
                                            if(mapNonWOTechIdLong != null && mapNonWOTechIdLat != null && mapNonWOTechIdLat.get(techEvntId)!= null && mapNonWOTechIdLat.get(techEvntId) != null){
                                                nonWOSFEvent.SVMXC__SM_Latitude__c = Decimal.valueOf(mapNonWOTechIdLat.get(techEvntId)); 
                                                nonWOSFEvent.SVMXC__SM_Longitude__c = Decimal.valueOf(mapNonWOTechIdLong.get(techEvntId));
                                            }
                                            nonWOSFEvent.ActivityDateTime = nonWOSFEvent.startDateTime;
                                            nonWOSFEvent.ActivityDate = nonWOSFEvent.startDateTime.dateGMT();
                                            lstSFEvents.add(nonWOSFEvent);
                                        }else{
                                            //TODO update the ONS confirmed event.
                                            strLogger += system.now() + ':SMAX_Complete_OptiMax_Job_WS::Resetting the confirmed ONS SF Event:drivetime to minus from arrival time' + ((destNode.drivingTime + intDrivingTimeBeforeEvent) * 1000) +'\n';
                                            nonWOSFEvent.StartDateTime = datetime.newInstance(destNode.arraivalTime.getTime() - ((destNode.drivingTime + intDrivingTimeBeforeEvent) * 1000));
                                            strLogger += system.now() + ':SMAX_Complete_OptiMax_Job_WS::Resetting the confirmed ONS SF Event:Calculated Start Time' +  nonWOSFEvent.StartDateTime+'\n';
                                            Double dblDrivingTimeMins = destNode.drivingTime / 60;
                                            nonWOSFEvent.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                            strLogger += system.now() + ':SMAX_Complete_OptiMax_Job_WS::Resetting the confirmed ONS SF Event:updated driving time :- '+ nonWOSFEvent.SVMXC__Driving_Time__c+'\n';
                                            nonWOSFEvent.EndDateTime =destNode.DepartureTime;
                                            nonWOSFEvent.SVMXC__Driving_Time_Home__c=0;
                                            nonWOSFEvent.ActivityDateTime = nonWOSFEvent.startDateTime;
                                            nonWOSFEvent.ActivityDate = nonWOSFEvent.startDateTime.dateGMT();
                                            lstSFEvents.add(nonWOSFEvent);
                                        }
                                    }
                                }
                            } else {
                                strLogger += system.now() + ': SMAX_Complete_OptiMax_Job_WS destNode Non WO SVMX Event for SF Technician ' + destNode.workorderId+'\n';
                                if((destNode.workorderId).endsWith(strONSKeySuffix)){
                                    strLogger += system.now() + ': Adding Driving to Home in Conformed Event..\n';
                                    SVMXC__SVMX_Event__c onsPreviousSvmxEvent = lstSvmxEvents.get(lstSvmxEvents.size()-1);
                                    //Double dblDrivingTimeinMin = destNode.drivingTime /60;
                                    Decimal dmlDrivingTimeSec = destNode.drivingTime;
                                    Double dblDrivingTimeinMin = dmlDrivingTimeSec.divide(60,3);
                                    onsPreviousSvmxEvent.SVMXC__Driving_Time_Home__c=dblDrivingTimeinMin;
                                    onsPreviousSvmxEvent.SVMXC__EndDateTime__c=datetime.newInstance(onsPreviousSvmxEvent.SVMXC__EndDateTime__c.getTime() + (destNode.drivingTime * 1000));
                                    continue;                                   
                                }
                                
                                String techEvntId = destNode.workorderId.split('_')[2]; //Event_0fora1Jq0000001zwK4EAI_EventId
                                strLogger += system.now() + ': SMAX_Complete_OptiMax_Job_WS::SVMX Event for SF Technician:: destNode.workorderId.split(_)[2]' + techEvntId+'\n';
                                //This null check required if events sent without salesforceId - for break hours no events so no Id.
                                if(techEvntId != null){
                                    SVMXC__SVMX_Event__c nonWOSvmxEvent = smaxNonWOEventsMap.get(techEvntId);
                                    if(nonWOSvmxEvent != null){
                                        if(nonWOSvmxEvent.SVMXC__SM_Status__c != 'Confirmed' && nonWOSvmxEvent.SVMXC__Type__c != 'Overnight Stay'){
                                            strLogger += system.now() + ':SMAX_Complete_OptiMax_Job_WS::SVMX Event for SF Technician::Need to reset the Driving back to home and also reset the Start datetime of the event..\n';
                                            
                                            //if existing return drivetime is >0  then before reset the return drive time update the enddatetime
                                            if(nonWOSvmxEvent.SVMXC__Driving_Time_Home__c > 0){
                                                Double dblReturnTimeMinsOld = Double.valueOf(nonWOSvmxEvent.SVMXC__Driving_Time_Home__c);
                                                Decimal endDTinMilSec = nonWOSvmxEvent.SVMXC__EndDateTime__c.getTime() - (dblReturnTimeMinsOld * 60 * 1000);
                                                nonWOSvmxEvent.SVMXC__EndDateTime__c=datetime.newInstance(endDTinMilSec.longValue());
                                            }
                                            nonWOSvmxEvent.SVMXC__Driving_Time_Home__c = 0.0;
                                            strLogger += system.now() + ': New End datetime of SMAXEvent in GMT..'+nonWOSvmxEvent.SVMXC__EndDateTime__c+'\n';
                                            //need to find the drivetime difference and update the startdatetime
                                            Double dblDrivingTimeMins = destNode.drivingTime / 60;
                                            Double dblDrivingTimeMinsOld = Double.valueOf(nonWOSvmxEvent.SVMXC__Driving_Time__c);
                                            strLogger += system.now() + ': Existing drive time of SMAXEvent in minutes..'+dblDrivingTimeMinsOld+'\n';
                                            strLogger += system.now() + ': New drive time of SMAXEvent in minutes..'+dblDrivingTimeMins+'\n';
                                            Decimal startDTinMilSec=0;
                                            if(dblDrivingTimeMinsOld > dblDrivingTimeMins){
                                                Double diffInMinutes = dblDrivingTimeMinsOld - dblDrivingTimeMins;
                                                startDTinMilSec = nonWOSvmxEvent.SVMXC__StartDateTime__c.getTime() + (diffInMinutes * 60 * 1000);
                                            }else{
                                                Double diffInMinutes = dblDrivingTimeMins - dblDrivingTimeMinsOld;
                                                startDTinMilSec = nonWOSvmxEvent.SVMXC__StartDateTime__c.getTime() - (diffInMinutes * 60 * 1000);
                                            }
                                            nonWOSvmxEvent.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                            //Decimal startDtInMilSec =nonWOSvmxEvent.SVMXC__StartDateTime__c.getTime() - (destNode.drivingTime * 1000);
                                            strLogger += system.now() + ': Existing start datetime of SMAXEvent in GMT..'+nonWOSvmxEvent.SVMXC__StartDateTime__c+'\n';
                                            nonWOSvmxEvent.SVMXC__StartDateTime__c=datetime.newInstance(startDtInMilSec.longValue());
                                            strLogger += system.now() + ': New start datetime of SMAXEvent in GMT..'+nonWOSvmxEvent.SVMXC__StartDateTime__c+'\n';                                 
                                            
                                            if(mapNonWOTechIdLong != null && mapNonWOTechIdLat != null && mapNonWOTechIdLat.get(techEvntId)!= null && mapNonWOTechIdLat.get(techEvntId) != null){
                                                nonWOSvmxEvent.SVMXC__SM_Latitude__c = Decimal.valueOf(mapNonWOTechIdLat.get(techEvntId)); 
                                                nonWOSvmxEvent.SVMXC__SM_Longitude__c = Decimal.valueOf(mapNonWOTechIdLong.get(techEvntId));
                                            }
                                            lstSvmxEvents.add(nonWOSvmxEvent);
                                        }else{
                                            //TODO update the ONS confirmed event.
                                            strLogger += system.now() + ':SMAX_Complete_OptiMax_Job_WS::SVMX Event for SF Technician::Resetting the confirmed ONS SVMX Event:drivetime to minus from arrival time' + ((destNode.drivingTime + intDrivingTimeBeforeEvent) * 1000) +'\n';
                                            nonWOSvmxEvent.SVMXC__StartDateTime__c = datetime.newInstance(destNode.arraivalTime.getTime() - ((destNode.drivingTime + intDrivingTimeBeforeEvent) * 1000));
                                             strLogger += system.now() + ':SMAX_Complete_OptiMax_Job_WS::Resetting the confirmed ONS SVMX Event:Calculated Start Time' +  nonWOSvmxEvent.SVMXC__StartDateTime__c+'\n';
                                            nonWOSvmxEvent.SVMXC__ActivityDateTime__c = objSvmxEvent.SVMXC__StartDateTime__c;
                                            nonWOSvmxEvent.SVMXC__ActivityDate__c = objSvmxEvent.SVMXC__StartDateTime__c.dateGMT();
                                            Double dblDrivingTimeMins = destNode.drivingTime / 60;
                                            nonWOSvmxEvent.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                            strLogger += system.now() + ':SMAX_Complete_OptiMax_Job_WS::SVMX Event for SF Technician::Resetting the confirmed ONS SVMX Event:updated driving time :- '+ nonWOSvmxEvent.SVMXC__Driving_Time__c+'\n';
                                            nonWOSvmxEvent.SVMXC__EndDateTime__c =destNode.DepartureTime;
                                            nonWOSvmxEvent.SVMXC__Driving_Time_Home__c=0;
                                            lstSvmxEvents.add(nonWOSvmxEvent);
                                        }
                                    }
                                }
                            }
                        }
                        i++;
                    }
                    
                    //Deleting the SMAXEvents that were added to the list above
                    if(lstSmaxEventsToDel != null && lstSmaxEventsToDel.size() > 0) {
                        if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c') ){   //SDL-SVMX-DELETE-FLS-ENFORCED
                           delete lstSmaxEventsToDel;
                        } else {
                           throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }
                    }
                }
                else // Tech not associated with Salesforce User
                {
                    if(mapTechIdIsSchedulingEnabled.get(route.ResourceId) == TRUE) // Scheduling enabled for tech
                    {
                        strLogger += system.now() + ': Setting up events and updating work orders for technician: ' + route.ResourceId + '\n';
                        for(DestinationNodes_WP destNode : route.destinationNodes_WPL)
                        {
                            if((destNode.workorderId).startsWith(strWOKeyPrefix))
                            {
                                if(destNode.workorderId.contains('_'))
                                {
                                    try
                                    {
                                        destNode.workorderId = destNode.workorderId.split('_')[0];
                                    }catch(ListException ex){}
                                }
                                
                                // If the work order doesn't exist, skip the event creation 
                                if(!mapScheduledWO.containsKey(destNode.workorderId))
                                {
                                    intMissingWorkOrderCount++;
                                    strDeletedWorkOrderDetails += destNode.workorderId + ',' + route.resourceId +',' + destNode.arraivalTime + ',' + destNode.departureTime + ',' + destNode.drivingTime + '\n';
                                    i++;
                                    continue;
                                }
                                
                                //if this WO already has a SFEvent, delete it before creating a new SMAXEvent
                                strLogger += system.now() + ' sfEventsMap.containsKey(mapScheduledWO.get(destNode.workorderId).Id) - ' + sfEventsMap.containsKey(mapScheduledWO.get(destNode.workorderId).Id) + '\n';
                                if(sfEventsMap.containsKey(mapScheduledWO.get(destNode.workorderId).Id)) {
                                    strLogger += system.now() + ' This WO ' + destNode.workorderId + ' also contains SF Event. Hence deleting it.' + '\n';
                                    Event sfEvent = sfEventsMap.get(mapScheduledWO.get(destNode.workorderId).Id);
                                    strLogger += system.now() + ' sfEvent - ' + sfEvent.Id + '\n';
                                    lstSFEventsToDel.add(sfEvent); //add the SFEvent to the list. This list will be deleted below
                                    sfEventsMap.remove(mapScheduledWO.get(destNode.workorderId).Id);
                                }
                                
                                //Calculate Drivetime
                                Double dblDrivingTimeMins = (destNode.drivingTime + intDrivingTimeBeforeEvent) / 60;
                                strLogger += system.now() + 'SMAX_Complete_OptiMax_Job_WS dblDrivingTimeMins' + dblDrivingTimeMins+'\n';
                                 
                                // Set up the event
                                //if the WO already has a SMAXEvent, update it
                                strLogger += system.now() + 'Before creating smaxEvent, : destNode.workorderId' + destNode.workorderId + '\n';
                                objSvmxEvent = smaxEventsMap.get(mapScheduledWO.get(destNode.workorderId).Id);
                                strLogger += system.now() + 'Does the event already exists - objSvmxEvent : ' + objSvmxEvent + '\n';
                                //If it a new event, then instantiate one.
                                if(objSvmxEvent == null) {
                                    strLogger += system.now() + 'This is a new event. Hence creating it' + '\n';
                                    objSvmxEvent = new SVMXC__SVMX_Event__c();
                                }
                                objSvmxEvent.Name = TAG007+ ' ' + mapScheduledWO.get(destNode.workorderId).Name;
                                objSvmxEvent.SVMXC__Technician__c = route.resourceId;
                                //objSvmxEvent.SVMXC__WhatId__c = destNode.workorderId;
                                objSvmxEvent.SVMXC__WhatId__c = mapScheduledWO.get(destNode.workorderId).Id;
                                strLogger += system.now()+': destNode.ArraivalTime: ' +destNode.ArraivalTime + ' , destNode.ArraivalTime.getTime(): '+destNode.ArraivalTime.getTime()+ ' , destNode.drivingTime: '+destNode.drivingTime + '\n';
                                strLogger += system.now() + 'SMAX_Complete_OptiMax_Job_WS drivetime to minus from arrival time' + ((destNode.drivingTime + intDrivingTimeBeforeEvent) * 1000) +'\n';
                                objSvmxEvent.SVMXC__StartDateTime__c = datetime.newInstance(destNode.arraivalTime.getTime() - ((destNode.drivingTime + intDrivingTimeBeforeEvent) * 1000));
                                 strLogger += system.now() + 'SMAX_Complete_OptiMax_Job_WS Calculated Start Time' +  objSvmxEvent.SVMXC__StartDateTime__c+'\n';
                                 
                                objSvmxEvent.SVMXC__EndDateTime__c = destNode.departureTime;
                                //reset the status from non-optimizable to none
                                objSvmxEvent.SVMXC__SM_Status__c = '';                                
                                 
                                if(mapWOTechIdLat.get(destNode.workorderId) != NULL && mapWOTechIdLong.get(destNode.workorderId) != NULL){
                                    //objSvmxEvent.SVMXC__Location__c = mapWOTechIdLat.get(destNode.workorderId) + ',' + mapWOTechIdLong.get(destNode.workorderId);
                                    //update the lattitude and longitude fields for the technician event additional details
                                    objSvmxEvent.SVMXC__SM_Latitude__c = Decimal.valueOf(mapWOTechIdLat.get(destNode.workorderId));
                                    objSvmxEvent.SVMXC__SM_Longitude__c = Decimal.valueOf(mapWOTechIdLong.get(destNode.workorderId));
                                }
                                objSvmxEvent.SVMXC__ActivityDateTime__c = objSvmxEvent.SVMXC__StartDateTime__c;
                                objSvmxEvent.SVMXC__ActivityDate__c = objSvmxEvent.SVMXC__StartDateTime__c.dateGMT();
                                //Double dblDrivingTimeMins = (destNode.drivingTime + intDrivingTimeBeforeEvent) / 60;
                                //Double dblServiceAndIdleTimeMins = (destNode.DepartureTime.gettime() - destNode.arraivalTime.gettime() ) / 60000;
                                //objSvmxEvent.SVMXC__DurationInMinutes__c = dblDrivingTimeMins.intValue() + dblServiceAndIdleTimeMins.intValue();
                                
                                objSvmxEvent.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                objSvmxEvent.SVMXC__SM_Idle_Time__c = Integer.valueOf(destNode.idleTime / 60);
                                strLogger += system.now() + ': SMAX_Complete_OptiMax_Job_WS SF SvmxEvent idle time :- '+ objSvmxEvent.SVMXC__SM_Idle_Time__c+'\n';
                                objSvmxEvent.SVMXC__Driving_Time_Home__c=0;
                                //identify the last work order event and update the return drive time is available in the route level.
                                if(i==lstDestinationNodes.size()){ 
                                    objSvmxEvent.SVMXC__Driving_Time_Home__c=returnDriveTime * 60;
                                    strLogger += system.now() + ':Return drivetime for the last work order event in the route....: ' + destNode.workorderId + ' is: '+objSvmxEvent.SVMXC__Driving_Time_Home__c+'[min.] \n';

                                    Double dblReturnTime = returnDriveTime * 3600; //in seconds
                                    strLogger += system.now() + ':End datetime for the last work order event in the route....: ' + destNode.workorderId + ' is: '+objSvmxEvent.SVMXC__EndDateTime__c+' \n';
                                    objSvmxEvent.SVMXC__EndDateTime__c = datetime.newInstance(destNode.DepartureTime.getTime() + ((Integer.valueOf(dblReturnTime)) * 1000));
                                    strLogger += system.now() + ':End datetime for the last work order event after adding return drivetime....: ' + destNode.workorderId + ' is: '+objSvmxEvent.SVMXC__EndDateTime__c+' \n';
                                    
                                    //set the destNade.DepartureTime with return time
                                    destNode.DepartureTime = objSvmxEvent.SVMXC__EndDateTime__c;
                                    strLogger += system.now() + ':Lastnode departuretime updated with return drivetime....: ' + destNode.workorderId + ' is: '+destNode.DepartureTime+' \n';
                                }
                                lstSvmxEvents.add(objSvmxEvent);
                                strLogger += system.now() + 'ALL SVMX Events added to list ' +lstSvmxEvents+ ' \n';
                                
                                // Ensure that a work order is updated only once. Also prevent externally scheduled work orders from getting upated.
                                if(!setUpdatedWorkOrder.contains(destNode.workorderId) && !setExternalWOs.contains(destNode.workorderId) && mapScheduledWO.containsKey(destNode.workorderId))
                                {
                                    setUpdatedWorkOrder.add(destNode.workorderId);
                                    objWorkOrder = new SVMXC__Service_Order__c();
                                    objWorkOrder = mapScheduledWO.get(destNode.workorderId);
                                    objWorkOrder.SVMXC__OptiMax_status__c = 'Processing Complete'; // Processing Complete
                                    //objWorkOrder.SVMXC__Last_Dispatch_Event__c = 'Scheduled';
                                    objWorkOrder.SVMXC__Group_Member__c = route.resourceId;
                                    //objWorkOrder.SVMXC__Group_Member__r.Name = mapTechIdName.get(route.resourceId);
                                    objWorkOrder.SVMXC__OptiMax_Error_Text__c='';
                                    
                                    //strLogger += system.now() + ': 1111 route.resourceId----in SMAX_Complete_OptiMax_Job_WS----- ' + route.ResourceId + '\n';
        
                                    //sync Locked by DC and SVMXC__SM_Lock_Appointment_Schedule__c field 
                                    if(objWorkOrder.SVMXC__Locked_By_DC__c == true){
                                        objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c =WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
                                    }else if(objWorkOrder.SVMXC__SM_Lock_Appointment_Schedule__c == WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE){
                                        objWorkOrder.SVMXC__Locked_By_DC__c = true;
                                    }
                                
                                    if(mapTechIdServTeamId.containsKey(route.resourceId))
                                        objWorkOrder.SVMXC__Service_Group__c = mapTechIdServTeamId.get(route.ResourceId);
                                    if(mapTeamEmail.containsKey(route.resourceId))
                                        objWorkOrder.SVMXC__Group_Email__c = mapTeamEmail.get(route.resourceId);
                                    if(mapTechEmail.containsKey(route.resourceId))
                                        objWorkOrder.SVMXC__Member_Email__c = mapTechEmail.get(route.resourceId);
        
                                    if(objWorkOrder.SVMXC__Latitude__c == NULL && mapWOTechIdLat.get(objWorkOrder.Name) != NULL)
                                        objWorkOrder.SVMXC__Latitude__c = Decimal.valueOf(mapWOTechIdLat.get(objWorkOrder.Name));
                                    if(objWorkOrder.SVMXC__Longitude__c == NULL && mapWOTechIdLong.get(objWorkOrder.Name) != NULL)
                                        objWorkOrder.SVMXC__Longitude__c = Decimal.valueOf(mapWOTechIdLong.get(objWorkOrder.Name));
                                    objWorkOrder.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                    //objWorkOrder.SVMXC__Idle_Time__c = clsOMaxExtension.computeIdleTime(destNode.arraivalTime, destNode.departureTime, mapWrkOrdIdServDuration.get(destNode.workorderId));
                                    //objWorkOrder.SVMXC__Scheduled_Date_Time__c = destNode.arraivalTime.addMinutes((objWorkOrder.SVMXC__Idle_Time__c).intValue());
                                    objWorkOrder.SVMXC__Scheduled_Date_Time__c = destNode.arraivalTime;
                                    strLogger += system.now() + ':SMAX_Complete_OptiMax_Job_WS:: SVMXC__FirstScheduledDateTime__c value in existing work order...' + objWorkOrder.SVMXC__FirstScheduledDateTime__c + '\n';

                                    if(objWorkOrder.SVMXC__FirstScheduledDateTime__c == NULL){
                                        //objWorkOrder.SVMXC__FirstScheduledDateTime__c = objWorkOrder.SVMXC__Scheduled_Date_Time__c;
                                        objWorkOrder.SVMXC__FirstScheduledDateTime__c = system.now();
                                    }
                                    
                                    // Technician Violation
                                    
                                    SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils omaxViolationUtils = new SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils();
                                    String strTechnicianViolations = omaxViolationUtils.checkViolations(objWorkOrder, completeJobDetail.jobId, mapBusinessHours, objSvmxProcess, lstOptiMaxOPTechs, strLogger, strDefaultBHourId);
                                    
                                    //Following case occurs when the WO which was scheduled earlier with violation msg. We need to clear
                                    //the msg for next run.
                                    if(objWorkOrder.SVMXC__Violation_Message__c != null || objWorkOrder.SVMXC__Violation_Status2__c != null) {
                                        objWorkOrder.SVMXC__Violation_Message__c = '';
                                        objWorkOrder.SVMXC__Violation_Status2__c = null;
                                    }
                                                                                                      
                                    strLogger += system.now() + ': strTechnicianViolations--2222--in SMAX_Complete_OptiMax_Job_WS----- ' + strTechnicianViolations + '\n';
                                                                                                            
                                    if(strTechnicianViolations!=null && strTechnicianViolations.length()>0 && !strTechnicianViolations.equalsIgnoreCase('null'))
                                    {
                                        strTechnicianViolations = strTechnicianViolations.replace(';','\n');
                                        objWorkOrder.SVMXC__Violation_Message__c = strTechnicianViolations;
                                        objWorkOrder.SVMXC__Violation_Status2__c = 'Constraints Violation';
                                    }
                                                                            
                                    //TODO update violation details into workorder
                                    List<Violations_WP> lstViolations = destNode.getviolations_WP();
                                    if(lstViolations != null && lstViolations.size() > 0){
                                        strLogger +=  system.now() + ': SMAX_Complete_OptiMax_Job_WS::Violaton size() : ' + lstViolations.size() + '\n';
                                        //strLogger +=  system.now() + ': SMAX_Complete_OptiMax_Job_WS::Violatons : ' + lstViolations + '\n';
                                        Violations_WP woViolation = lstViolations[0];
                                        //strLogger +=  system.now() + ': SMAX_Complete_OptiMax_Job_WS::WO Violation : ' + woViolation + '\n';
                                        
                                        if(objWorkOrder.SVMXC__Violation_Message__c == null && (woViolation.value!='LATE' || woViolation.value!='EARLY')){
                                            objWorkOrder.SVMXC__Violation_Message__c =  woViolation.category+':'+woViolation.attribute+':'+woViolation.value;
                                        }else if((woViolation.value != 'LATE' || woViolation.value != 'EARLY')){
                                            objWorkOrder.SVMXC__Violation_Message__c = objWorkOrder.SVMXC__Violation_Message__c +'\n'+ woViolation.category+':'+woViolation.attribute+':'+woViolation.value;
                                        }
                                        //objWorkOrder.SVMXC__Violation_Message__c = objWorkOrder.SVMXC__Violation_Message__c +'\n'+ woViolation.category+':'+woViolation.attribute+':'+woViolation.value;
                                        objWorkOrder.SVMXC__Violation_Status2__c = 'Jeopardy';
                                    }
                                                                                                                                    
                                    if(objWorkOrder.SVMXC__Skill_Set__c != null){
                                        lstOfViolations = omaxViolationUtils.checkSkillViolations(mapTechIdSkills, objWorkOrder, strLogger, completeJobDetail.jobId);                                     
                                        if(lstOfViolations != null && lstOfViolations.size() > 0)
                                        lstViolationDetails.addAll(lstOfViolations);
                                    }
                                                                    
                                    if(objWorkOrder.SVMXC__Preferred_Start_Time__c != null && objWorkOrder.SVMXC__Preferred_End_Time__c != null){
                                        lstOfViolations = omaxViolationUtils.checkSLAViolations(objWorkOrder, mapBusinessHours, completeJobDetail.jobId, strLogger);
                                        
                                        if(lstOfViolations != null && lstOfViolations.size() > 0)
                                        lstViolationDetails.addAll(lstOfViolations); 
                                    }
                                    
                                    if(objWorkOrder.SVMXC__Product__c != null){                              
                                        lstOfViolations = omaxViolationUtils.checkProductExprtseViolations(mapTechIdProduct, objWorkOrder, completeJobDetail.jobId, strLogger);
                                     
                                        if(lstOfViolations != null && lstOfViolations.size() > 0)
                                        lstViolationDetails.addAll(lstOfViolations);
                                    }
                                     
                                    if(objWorkOrder.SVMXC__Qualified_Technicians__c != null){ 
                                        lstOfViolations = omaxViolationUtils.checkEligibilityRuleViolations(objWorkOrder, completeJobDetail.jobId, strLogger);
                                        if(lstOfViolations != null && lstOfViolations.size() > 0)
                                        lstViolationDetails.addAll(lstOfViolations);
                                        
                                        lstOfViolations = omaxViolationUtils.checkPrefrdMandtProhbtTechViolations(objWorkOrder, completeJobDetail.jobId, strLogger, mapTechIdName.get(route.resourceId));
                                        if(lstOfViolations != null && lstOfViolations.size() > 0)
                                        lstViolationDetails.addAll(lstOfViolations);
                                    }
                                    
                                    lstOfViolations.clear();
                                    
                                    listHorizontalDateTime.add(objWorkOrder.SVMXC__Scheduled_Date_Time__c);
                                    
                                    lstWOToBeUpdated.add(objWorkOrder);
                                }
                                // Reseting the driving time before event
                                intDrivingTimeBeforeEvent = 0;
                            }
                            else if((destNode.workorderId).startsWith(strONSKeyPrefix)){
                                //1. Query the Overnight Event add it to map (ServerONSId, EventObject);
                                //2. if present set values from destination and update
                                //3. if not present set values from destination and create it.
                                //if strONSKeySuffix is "ReturnDriveHome", set drivetime to previous event driving to home.
                                strLogger += system.now() + ': Destination Node... '+destNode +'\n';
                                    if((destNode.workorderId).endsWith(strONSKeySuffix)){
                                        strLogger += system.now() + ': Adding Driving to Home in previous Overnight Event..\n';
                                        SVMXC__SVMX_Event__c onsPreviousSvmxEvent = lstSvmxEvents.get(lstSvmxEvents.size()-1);
                                        if(onsPreviousSvmxEvent != null){
                                            //Double dblDrivingTimeinMin = destNode.drivingTime /60;
                                            Decimal dmlDrivingTimeSec = destNode.drivingTime;
                                            Double dblDrivingTimeinMin = dmlDrivingTimeSec.divide(60,3);
                                            onsPreviousSvmxEvent.SVMXC__Driving_Time_Home__c=dblDrivingTimeinMin;
                                            onsPreviousSvmxEvent.SVMXC__EndDateTime__c=datetime.newInstance(onsPreviousSvmxEvent.SVMXC__EndDateTime__c.getTime() + (destNode.drivingTime * 1000));
                                        }
                                        continue;                                   
                                    }

                                    // if there are other schedules in the route and return drive time at route level > 0
                                    // technician is travelling to another location before stay. Add return drive time
                                    // to previous WO event created
                                    boolean addDriveTimeBeforeStay = (lstSvmxEvents.size() > 0  && returnDriveTime > 0);
                                    if (addDriveTimeBeforeStay) {
                                       strLogger += system.now() + ': Adding Driving to Home from route data to previous WO SVMX Event..\n';
                                       SVMXC__SVMX_Event__c previousWoSvmxEvent = lstSvmxEvents.get(lstSvmxEvents.size() - 1);
                                       // Set return drive time to event in minutes
                                       previousWoSvmxEvent.SVMXC__Driving_Time_Home__c = returnDriveTime * 60;
                                       strLogger += system.now() + ':Return drivetime for the last work order event in the route....: ' + previousWoSvmxEvent.Name + ' is: ' + previousWoSvmxEvent.SVMXC__Driving_Time_Home__c + '[min.] \n';
                                       // Add return drive time in millis to end time to get new end time including return drive time
                                       previousWoSvmxEvent.SVMXC__EndDateTime__c = datetime.newInstance(previousWoSvmxEvent.SVMXC__EndDateTime__c.getTime() + ((Integer.valueOf(returnDriveTime * 3600)) * 1000)); 
                                       strLogger += system.now() + ': End datetime for the last work order SVMX event after adding return drivetime....: ' + previousWoSvmxEvent.Name + ' is: ' + previousWoSvmxEvent.SVMXC__EndDateTime__c + ' \n';
                                    }
                                    strLogger += system.now() + ': Creating an Overnight SMAX Event \n';
                                    Integer maxLength = SObjectType.SVMXC__SVMX_Event__c.Fields.Name.Length;
                                    SVMXC__SVMX_Event__c  onsSvmxEvent = new SVMXC__SVMX_Event__c();
                                    onsSvmxEvent.SVMXC__Type__c = 'Overnight Stay';
                                    String subjectAppend = destNode.workorderId;
                                    if(subjectAppend.length() > maxLength){
                                        subjectAppend = subjectAppend.substring(0, maxLength);
                                    }
                                    onsSvmxEvent.Name = subjectAppend;
                                    onsSvmxEvent.SVMXC__Technician__c = route.ResourceId;
                                    onsSvmxEvent.SVMXC__SM_Status__c = 'Pending';
                                    onsSvmxEvent.SVMXC__StartDateTime__c = datetime.newInstance(destNode.arraivalTime.getTime() - (destNode.drivingTime * 1000));
                                    onsSvmxEvent.SVMXC__EndDateTime__c = destNode.departureTime;      
                                    onsSvmxEvent.SVMXC__ActivityDateTime__c = onsSvmxEvent.SVMXC__StartDateTime__c;
                                    onsSvmxEvent.SVMXC__ActivityDate__c = onsSvmxEvent.SVMXC__StartDateTime__c.dateGMT();
                                    if(mapWOTechIdLat.get(destNode.workorderId)!= null && mapWOTechIdLong.get(destNode.workorderId) != null){
                                        onsSvmxEvent.SVMXC__SM_Latitude__c = Decimal.valueOf(mapWOTechIdLat.get(destNode.workorderId)); 
                                        onsSvmxEvent.SVMXC__SM_Longitude__c = Decimal.valueOf(mapWOTechIdLong.get(destNode.workorderId));
                                    }
                                    if (!addDriveTimeBeforeStay) {
                                        Double dblDrivingTimeMins = destNode.drivingTime / 60;
                                        onsSvmxEvent.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                    }
                                    onsSvmxEvent.SVMXC__Driving_Time_Home__c=0;
                                    lstSvmxEvents.add(onsSvmxEvent);
                            }
                            else if((destNode.workorderId).startsWith('Event'))
                            {
                                strLogger += system.now() + ': SMAX_Complete_OptiMax_Job_WS destNode Non WO Event ' + destNode.workorderId+'\n';
                                if((destNode.workorderId).endsWith(strONSKeySuffix)){
                                    strLogger += system.now() + ': Adding Driving to Home in Conformed Event..\n';
                                    SVMXC__SVMX_Event__c onsPreviousSvmxEvent = lstSvmxEvents.get(lstSvmxEvents.size()-1);
                                    //Double dblDrivingTimeinMin = destNode.drivingTime /60;
                                    Decimal dmlDrivingTimeSec = destNode.drivingTime;
                                    Double dblDrivingTimeinMin = dmlDrivingTimeSec.divide(60,3);
                                    onsPreviousSvmxEvent.SVMXC__Driving_Time_Home__c=dblDrivingTimeinMin;
                                    onsPreviousSvmxEvent.SVMXC__EndDateTime__c=datetime.newInstance(onsPreviousSvmxEvent.SVMXC__EndDateTime__c.getTime() + (destNode.drivingTime * 1000));
                                    continue;                                   
                                }
                                
                                String techEvntId = destNode.workorderId.split('_')[2]; //Event_0fora1Jq0000001zwK4EAI_EventId
                                strLogger += system.now() + ': SMAX_Complete_OptiMax_Job_WS destNode.workorderId.split(_)[2]' + techEvntId+'\n';
                                //This null check required if events sent without salesforceId - for break hours no events so no Id.
                                if(techEvntId != null){
                                    SVMXC__SVMX_Event__c nonWOSvmxEvent = smaxNonWOEventsMap.get(techEvntId);
                                    if(nonWOSvmxEvent != null){
                                        if(nonWOSvmxEvent.SVMXC__SM_Status__c != 'Confirmed' && nonWOSvmxEvent.SVMXC__Type__c != 'Overnight Stay'){
                                            strLogger += system.now() + ': SMAX_Complete_OptiMax_Job_WS::Need to reset the Driving back to home and also reset the Start datetime of the event..\n';
                                            
                                            //if existing return drivetime is >0  then before reset the return drive time update the enddatetime
                                            if(nonWOSvmxEvent.SVMXC__Driving_Time_Home__c > 0){
                                                Double dblReturnTimeMinsOld = Double.valueOf(nonWOSvmxEvent.SVMXC__Driving_Time_Home__c);
                                                Decimal endDTinMilSec = nonWOSvmxEvent.SVMXC__EndDateTime__c.getTime() - (dblReturnTimeMinsOld * 60 * 1000);
                                                nonWOSvmxEvent.SVMXC__EndDateTime__c=datetime.newInstance(endDTinMilSec.longValue());
                                            }
                                            nonWOSvmxEvent.SVMXC__Driving_Time_Home__c = 0.0;
                                            strLogger += system.now() + ': New End datetime of SMAXEvent in GMT..'+nonWOSvmxEvent.SVMXC__EndDateTime__c+'\n';
                                            //need to find the drivetime difference and update the startdatetime
                                            Double dblDrivingTimeMins = destNode.drivingTime / 60;
                                            Double dblDrivingTimeMinsOld = Double.valueOf(nonWOSvmxEvent.SVMXC__Driving_Time__c);
                                            strLogger += system.now() + ': Existing drive time of SMAXEvent in minutes..'+dblDrivingTimeMinsOld+'\n';
                                            strLogger += system.now() + ': New drive time of SMAXEvent in minutes..'+dblDrivingTimeMins+'\n';
                                            Decimal startDTinMilSec=0;
                                            if(dblDrivingTimeMinsOld > dblDrivingTimeMins){
                                                Double diffInMinutes = dblDrivingTimeMinsOld - dblDrivingTimeMins;
                                                startDTinMilSec = nonWOSvmxEvent.SVMXC__StartDateTime__c.getTime() + (diffInMinutes * 60 * 1000);
                                            }else{
                                                Double diffInMinutes = dblDrivingTimeMins - dblDrivingTimeMinsOld;
                                                startDTinMilSec = nonWOSvmxEvent.SVMXC__StartDateTime__c.getTime() - (diffInMinutes * 60 * 1000);
                                            }
                                            nonWOSvmxEvent.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                            //Decimal startDtInMilSec =nonWOSvmxEvent.SVMXC__StartDateTime__c.getTime() - (destNode.drivingTime * 1000);
                                            strLogger += system.now() + ': Existing start datetime of SMAXEvent in GMT..'+nonWOSvmxEvent.SVMXC__StartDateTime__c+'\n';
                                            nonWOSvmxEvent.SVMXC__StartDateTime__c=datetime.newInstance(startDtInMilSec.longValue());
                                            strLogger += system.now() + ': New start datetime of SMAXEvent in GMT..'+nonWOSvmxEvent.SVMXC__StartDateTime__c+'\n';                                 
                                            
                                            if(mapNonWOTechIdLong != null && mapNonWOTechIdLat != null && mapNonWOTechIdLat.get(techEvntId)!= null && mapNonWOTechIdLat.get(techEvntId) != null){
                                                nonWOSvmxEvent.SVMXC__SM_Latitude__c = Decimal.valueOf(mapNonWOTechIdLat.get(techEvntId)); 
                                                nonWOSvmxEvent.SVMXC__SM_Longitude__c = Decimal.valueOf(mapNonWOTechIdLong.get(techEvntId));
                                            }
                                            lstSvmxEvents.add(nonWOSvmxEvent);
                                        }else{
                                            //TODO update the ONS confirmed event.
                                            strLogger += system.now() + ':SMAX_Complete_OptiMax_Job_WS::Resetting the confirmed ONS SVMX Event:drivetime to minus from arrival time' + ((destNode.drivingTime + intDrivingTimeBeforeEvent) * 1000) +'\n';
                                            nonWOSvmxEvent.SVMXC__StartDateTime__c = datetime.newInstance(destNode.arraivalTime.getTime() - ((destNode.drivingTime + intDrivingTimeBeforeEvent) * 1000));
                                             strLogger += system.now() + ':SMAX_Complete_OptiMax_Job_WS::Resetting the confirmed ONS SVMX Event:Calculated Start Time' +  nonWOSvmxEvent.SVMXC__StartDateTime__c+'\n';
                                            nonWOSvmxEvent.SVMXC__ActivityDateTime__c = objSvmxEvent.SVMXC__StartDateTime__c;
                                            nonWOSvmxEvent.SVMXC__ActivityDate__c = objSvmxEvent.SVMXC__StartDateTime__c.dateGMT();
                                            Double dblDrivingTimeMins = destNode.drivingTime / 60;
                                            nonWOSvmxEvent.SVMXC__Driving_Time__c = dblDrivingTimeMins;
                                            strLogger += system.now() + ':SMAX_Complete_OptiMax_Job_WS::Resetting the confirmed ONS SVMX Event:updated driving time :- '+ nonWOSvmxEvent.SVMXC__Driving_Time__c+'\n';
                                            nonWOSvmxEvent.SVMXC__EndDateTime__c =destNode.DepartureTime;
                                            nonWOSvmxEvent.SVMXC__Driving_Time_Home__c=0;
                                            lstSvmxEvents.add(nonWOSvmxEvent);
                                        }
                                    }
                                }
                            }
                            i++;
                        }
                          
                       
                    }
                    else// Scheduling not enabled for tech - assign tech, but don't create events
                    {   // very unlikely scenario as only Technician records with Salesforce_User__c non-NULL or Enable_Scheduling__c = TRUE are sent to OptiMax from InitateJob WS
                        strLogger += system.now() + ': Scheduling not enabled for technician: ' + route.ResourceId + '\n';
                        for(DestinationNodes_WP destNode : route.destinationNodes_WPL)
                        {
                            // If it is not an externally scheduled work order, update it
                            if(!setUpdatedWorkOrder.contains(destNode.workorderId) && (destNode.workorderId).startsWith(strWOKeyPrefix) && !setExternalWOs.contains(destNode.workorderId)  && mapScheduledWO.containsKey(destNode.workorderId))
                            {
                                setUpdatedWorkOrder.add(destNode.workorderId);
                                objWorkOrder = new SVMXC__Service_Order__c();
                                objWorkOrder = mapScheduledWO.get(destNode.workorderId);
                                objWorkOrder.SVMXC__OptiMax_status__c = 'Processing Complete'; // Processing Complete
                                //objWorkOrder.SVMXC__Last_Dispatch_Event__c = 'Assigned';
                                objWorkOrder.SVMXC__Group_Member__c = route.resourceId;
                                //objWorkOrder.SVMXC__Group_Member__r.Name = mapTechIdName.get(route.resourceId);
                                objWorkOrder.SVMXC__OptiMax_Error_Text__c='';
                                
                                //strLogger += system.now() + ': 2222 route.resourceId----in SMAX_Complete_OptiMax_Job_WS----- ' + route.ResourceId + '\n';
                                
                                if(mapTechIdServTeamId.containsKey(route.resourceId))
                                    objWorkOrder.SVMXC__Service_Group__c = mapTechIdServTeamId.get(route.ResourceId);
                                if(mapTeamEmail.containsKey(route.resourceId))
                                    objWorkOrder.SVMXC__Group_Email__c = mapTeamEmail.get(route.resourceId);
                                if(mapTechEmail.containsKey(route.ResourceId))
                                    objWorkOrder.SVMXC__Member_Email__c = mapTechEmail.get(route.ResourceId);

                                if(objWorkOrder.SVMXC__Latitude__c == NULL && mapWOTechIdLat.get(objWorkOrder.Name) != NULL)
                                    objWorkOrder.SVMXC__Latitude__c = Decimal.valueOf(mapWOTechIdLat.get(objWorkOrder.Name));
                                if(objWorkOrder.SVMXC__Longitude__c == NULL && mapWOTechIdLong.get(objWorkOrder.Name) != NULL)
                                    objWorkOrder.SVMXC__Longitude__c = Decimal.valueOf(mapWOTechIdLong.get(objWorkOrder.Name));                                    
                                if(objWorkOrder.SVMXC__First_Assigned_DateTime__c == NULL)
                                {
                                    //objWorkOrder.SVMXC__Idle_Time__c = clsOMaxExtension.computeIdleTime(destNode.arraivalTime, destNode.departureTime, mapWrkOrdIdServDuration.get(destNode.workorderId));
                                    //objWorkOrder.SVMXC__First_Assigned_DateTime__c = destNode.arraivalTime.addMinutes((objWorkOrder.SVMXC__Idle_Time__c).intValue());
                                    //objWorkOrder.SVMXC__First_Assigned_DateTime__c = destNode.arraivalTime;
                                    objWorkOrder.SVMXC__First_Assigned_DateTime__c = system.now();
                                }
                                
                                // Technician Violation
                                
                                SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils omaxViolationUtils = new SMAX_OptiMax_EngineUtils.OMAX_ViolationsUtils();
                                String strTechnicianViolations = omaxViolationUtils.checkViolations(objWorkOrder, completeJobDetail.jobId, mapBusinessHours, objSvmxProcess, lstOptiMaxOPTechs, strLogger, strDefaultBHourId);
                                
                                //Following case occurs when the WO which was scheduled earlier with violation msg. We need to clear
                                //the msg for next run.
                                if(objWorkOrder.SVMXC__Violation_Message__c != null || objWorkOrder.SVMXC__Violation_Status2__c != null) {
                                    objWorkOrder.SVMXC__Violation_Message__c = '';
                                    objWorkOrder.SVMXC__Violation_Status2__c = null;
                                }
                                
                                //strLogger += system.now() + ': strTechnicianViolations--3333--in SMAX_Complete_OptiMax_Job_WS----- ' + strTechnicianViolations + '\n';
                                
                                if(strTechnicianViolations!=null && strTechnicianViolations.length()>0 && !strTechnicianViolations.equalsIgnoreCase('null'))
                                {
                                    strTechnicianViolations = strTechnicianViolations.replace(';','\n');
                                    objWorkOrder.SVMXC__Violation_Message__c = strTechnicianViolations;
                                    objWorkOrder.SVMXC__Violation_Status2__c = 'Constraints Violation';
                                }
                                                                
                                //TODO update violation details into workorder
                                List<Violations_WP> lstViolations = destNode.getviolations_WP();
                                if(lstViolations != null && lstViolations.size() > 0){
                                    strLogger +=  system.now() + ': SMAX_Complete_OptiMax_Job_WS::Violaton size() : ' + lstViolations.size() + '\n';
                                    //strLogger +=  system.now() + ': SMAX_Complete_OptiMax_Job_WS::Violatons : ' + lstViolations + '\n';
                                    Violations_WP woViolation = lstViolations[0];
                                    //strLogger +=  system.now() + ': SMAX_Complete_OptiMax_Job_WS::WO Violation : ' + woViolation + '\n';
                                    
                                    if(objWorkOrder.SVMXC__Violation_Message__c == null && (woViolation.value!='LATE' || woViolation.value!='EARLY')){
                                        objWorkOrder.SVMXC__Violation_Message__c =  woViolation.category+':'+woViolation.attribute+':'+woViolation.value;
                                    }else if((woViolation.value != 'LATE' || woViolation.value != 'EARLY')){
                                        objWorkOrder.SVMXC__Violation_Message__c = objWorkOrder.SVMXC__Violation_Message__c +'\n'+ woViolation.category+':'+woViolation.attribute+':'+woViolation.value;
                                    }
                                    //objWorkOrder.SVMXC__Violation_Message__c = objWorkOrder.SVMXC__Violation_Message__c +'\n'+ woViolation.category+':'+woViolation.attribute+':'+woViolation.value;
                                    objWorkOrder.SVMXC__Violation_Status2__c = 'Jeopardy';
                                }
                                                                                                                                
                                if(objWorkOrder.SVMXC__Skill_Set__c != null){
                                    lstOfViolations = omaxViolationUtils.checkSkillViolations(mapTechIdSkills, objWorkOrder, strLogger, completeJobDetail.jobId);                                     
                                    if(lstOfViolations != null && lstOfViolations.size() > 0)
                                    lstViolationDetails.addAll(lstOfViolations);
                                }
                                                                
                                if(objWorkOrder.SVMXC__Preferred_Start_Time__c != null && objWorkOrder.SVMXC__Preferred_End_Time__c != null){
                                    lstOfViolations = omaxViolationUtils.checkSLAViolations(objWorkOrder, mapBusinessHours, completeJobDetail.jobId, strLogger);
                                    
                                    if(lstOfViolations != null && lstOfViolations.size() > 0)
                                    lstViolationDetails.addAll(lstOfViolations); 
                                }
                                                                                                
                                if(objWorkOrder.SVMXC__Product__c != null){                              
                                    lstOfViolations = omaxViolationUtils.checkProductExprtseViolations(mapTechIdProduct, objWorkOrder, completeJobDetail.jobId, strLogger);
                                 
                                    if(lstOfViolations != null && lstOfViolations.size() > 0)
                                    lstViolationDetails.addAll(lstOfViolations);
                                }
                                 
                                if(objWorkOrder.SVMXC__Qualified_Technicians__c != null){ 
                                    lstOfViolations = omaxViolationUtils.checkEligibilityRuleViolations(objWorkOrder, completeJobDetail.jobId, strLogger);
                                    if(lstOfViolations != null && lstOfViolations.size() > 0)
                                    lstViolationDetails.addAll(lstOfViolations);
                                    
                                    //strLogger += system.now() + ': -3333---in SMAX_Complete_OptiMax_Job_WS--******---objWorkOrder.SVMXC__Group_Member__r.Id== ' + objWorkOrder.SVMXC__Group_Member__r.Id + '\n';
                                    //strLogger += system.now() + ': -3333---in SMAX_Complete_OptiMax_Job_WS---*******--objWorkOrder.SVMXC__Group_Member__r.Name== ' + objWorkOrder.SVMXC__Group_Member__r.Name + '\n';
                                
                                    lstOfViolations = omaxViolationUtils.checkPrefrdMandtProhbtTechViolations(objWorkOrder, completeJobDetail.jobId, strLogger, mapTechIdName.get(route.resourceId));
                                    if(lstOfViolations != null && lstOfViolations.size() > 0)
                                    lstViolationDetails.addAll(lstOfViolations);
                                }
                                
                                lstOfViolations.clear();
                                
                                listHorizontalDateTime.add(objWorkOrder.SVMXC__Scheduled_Date_Time__c);
                                
                                lstWOToBeUpdated.add(objWorkOrder);
                            }
                        }
                    }
                    //Deleting the SFEvents that were added to the list above
                    if(lstSFEventsToDel != null && lstSFEventsToDel.size() > 0) {
                        //calling CRUD_Helper method instead of deleting the SF event directly
                        //WSCH_CRUD_Helper.deleteListEvents(lstSFEventsToDel);
                        delete lstSFEventsToDel;
                    }
                }
                try
                {
                    if(lstWOToBeUpdated.size() > 500)
                    {
                        if(lstSFEvents.size() > 0)
                        {
                            WSCH_OptimizedSchedulingService.triggerExecuted = true;
                            //insert lstSFEvents;
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSFEvents, COMM_SecurityUtils.Access.Upsertable)){  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                upsert lstSFEvents;
                            } else {
                                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                            }
                            lstSFEvents.clear();
                        }
                        if(lstSvmxEvents.size() > 0)
                        {
                            WSCH_OptimizedSchedulingService.triggerExecuted = true;
                            //insert lstSvmxEvents;
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSvmxEvents, COMM_SecurityUtils.Access.Upsertable)){    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                upsert lstSvmxEvents;
                            } else {
                                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                            }
                            lstSvmxEvents.clear();
                        }
                        if(isDebugEnabled)
                        {
                            for(SVMXC__Service_Order__c wotoBeUpdated : lstWOToBeUpdated)
                            {
                                strLogger +=  system.now() + ': ' + wotoBeUpdated.Id + ';' + wotoBeUpdated.Name + ';' + wotoBeUpdated.SVMXC__Latitude__c + ';' + wotoBeUpdated.SVMXC__Longitude__c + ';' +  wotoBeUpdated.SVMXC__OptiMax_status__c + ';' + wotoBeUpdated.SVMXC__Group_Member__c + ';' + wotoBeUpdated.SVMXC__Scheduled_Date_Time__c + ';' + wotoBeUpdated.SVMXC__Driving_Time__c + ';' + wotoBeUpdated.SVMXC__Idle_Time__c + ';' + wotoBeUpdated.SVMXC__Member_Email__c + ';' + wotoBeUpdated.SVMXC__Group_Email__c + ';' + wotoBeUpdated.SVMXC__Last_Dispatch_Event__c + ';' + wotoBeUpdated.SVMXC__Service_Duration__c + ';' +  wotoBeUpdated.SVMXC__Service_Group__c + '\n';
                                
                            }
                        }
                        if(lstWOToBeUpdated.size() > 0)
                        {
                            WSCH_OptimizedSchedulingService.triggerExecuted = true;
                            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWOToBeUpdated, COMM_SecurityUtils.Access.Updateable)){ //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                update lstWOToBeUpdated;
                            } else {
                                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                            }
                            lstWOToBeUpdated.clear();
                        }
                    }
                    
                    if(lstViolationDetails != null && lstViolationDetails.size() > 0){
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstViolationDetails, COMM_SecurityUtils.Access.Upsertable)){  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            upsert lstViolationDetails;
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }
                        lstViolationDetails.clear();
                        lstOfViolations.clear();
                    }
                    
                }
                catch(Exception e)
                {
                    strLogger += system.now()+'Error: while updating SFDC with Salesforce and ServiceMax events::Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n';
                    //strLogger += system.now() + ': Error: while updating SFDC with Salesforce and ServiceMax events:\n' + ex.getMessage();
                    throw new SVMXException(strLogger);
                }
            }
            

            //strLogger += system.now() + ': Heap size after executing constraint violation code: ' + Limits.getHeapSize() + '\n';
            //strLogger += system.now() + ': Usage Details: After preparing the events to be created and work orders to be updated\n\tHeap Size     : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
        }
        catch(Exception e)
        {
            //strLogger += system.now() + ': Error in Complete Job WS while preparing events and work orders:\n' + ex.getMessage();
            strLogger += system.now()+'Error in Complete Job WS while preparing events and work orders::Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n';
            throw new SVMXException(strLogger);
        }
        
        //strLogger += system.now() + ': SMAX_Complete_OptiMax_Job_WS mapEventIdDrivingTime : ' + mapEventIdDrivingTime + '\n';
        
        //Update non workorder events
        //TODO: need to refactor update of non workorder event 
        //SMAX_OptiMax_EngineUtils.OMAX_NonWOEventUpdate omaxNonWOEvents = new SMAX_OptiMax_EngineUtils.OMAX_NonWOEventUpdate();
        //omaxNonWOEvents.nonWOEventLatLongUpdate(completeJobDetail.technicianEvent_WPL, mapEventIdDrivingTime, completeJobDetail.jobId, strLogger);
        
        try
        {
            // Create the events and update the work orders with schedule information
            if(lstSFEvents.size() > 0) {
                WSCH_OptimizedSchedulingService.triggerExecuted = true;
                //insert lstSFEvents;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSFEvents, COMM_SecurityUtils.Access.Upsertable)){  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert lstSFEvents;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            
            if(lstSvmxEvents.size() > 0) {
                WSCH_OptimizedSchedulingService.triggerExecuted = true;
                //insert lstSvmxEvents;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSvmxEvents, COMM_SecurityUtils.Access.Upsertable)){    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert lstSvmxEvents;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
             
            if(isDebugEnabled)
            {
                for(SVMXC__Service_Order__c wotoBeUpdated : lstWOToBeUpdated)
                {
                    strLogger +=  system.now() + ': ' + wotoBeUpdated.Id + ';' + wotoBeUpdated.Name + ';' + wotoBeUpdated.SVMXC__Latitude__c + ';' + wotoBeUpdated.SVMXC__Longitude__c + ';' +  wotoBeUpdated.SVMXC__OptiMax_status__c + ';' + wotoBeUpdated.SVMXC__Group_Member__c + ';' + wotoBeUpdated.SVMXC__Scheduled_Date_Time__c + ';' + wotoBeUpdated.SVMXC__Driving_Time__c + ';' + wotoBeUpdated.SVMXC__Idle_Time__c + ';' + wotoBeUpdated.SVMXC__Member_Email__c + ';' + wotoBeUpdated.SVMXC__Group_Email__c + ';' + wotoBeUpdated.SVMXC__Last_Dispatch_Event__c + ';' + wotoBeUpdated.SVMXC__Service_Duration__c + ';' +  wotoBeUpdated.SVMXC__Service_Group__c + '\n';
                    
                }
            }
            if(lstWOToBeUpdated.size() > 0) {
                WSCH_OptimizedSchedulingService.triggerExecuted = true;
                WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWOToBeUpdated, COMM_SecurityUtils.Access.Updateable)){ //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    update lstWOToBeUpdated;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            } 

            if(setTechIdForLatLngUpd.size() > 0)
            {
                strLogger += system.now() + ': Updating technicians latitude & longitude\n';
                lstTechForLatLngUpdate = [Select Id, Name, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c from SVMXC__Service_Group_Members__c where Id IN :setTechIdForLatLngUpd];
                for(SVMXC__Service_Group_Members__c tech : lstTechForLatLngUpdate)
                {
                    tech.SVMXC__Latitude_Home__c = Decimal.valueOf(mapWOTechIdLat.get(tech.id));
                    tech.SVMXC__Longitude_Home__c = Decimal.valueOf(mapWOTechIdLong.get(tech.id));
                }
                if(lstTechForLatLngUpdate.size() > 0){ 
                 if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstTechForLatLngUpdate, COMM_SecurityUtils.Access.Updateable)){  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        update lstTechForLatLngUpdate;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }    
            }
            
            boolean strFailedElement = false;
            // Store OptiMax job's statistical information
            if(completeJobDetail.statics_WPL != NULL)
            {
                strLogger += system.now() + ': Setting up stats\n';
                for(Statics_WP jobStats : completeJobDetail.statics_WPL)
                {
                     strLogger += system.now() + ': HorizondatateTime jobStats.statName=='+jobStats.statName+'\n';
                     strLogger += system.now() + ': HorizondatateTime jobStats.value=='+jobStats.value+'\n';
                     
                    if(!String.isBlank(jobStats.value))
                    {
                        if(jobStats.value.length() > 255)
                        {
                            jobStats.value = jobStats.value.replace(jobStats.value.substring(0,3),'');
                            if(jobStats.value.length() > 255)
                                jobStats.value = jobStats.value.substring(0, 255);
                        }
                    }
                    //TODO:Check if the stats name is 'Update failed element IDs' and its having value set the failure flag.
                    if(jobStats.statName.equalsIgnoreCase('Update failed element IDs') && !String.isBlank(jobStats.value))
                        strFailedElement = true;
                        
                    //Apurva - Need to check how is the creation of OptiMax job's statistical information
                    objSvmxJobStats = new SVMXC__SVMX_Job_Stats__c(Name = jobStats.statName, SVMXC__SVMX_Job__c = objSvmxJob.Id, SVMXC__Value__c = jobStats.value, SVMXC__Units__c = jobStats.unit);
                    lstSvmxJobStats.add(objSvmxJobStats);
                    
                }
            }
            

            // Store execution log information
            if(completeJobDetail.exeLog_WPL != NULL && completeJobDetail.exeLog_WPL.size() > 0)
            {
                strLogger += system.now() + ': Setting up execution log\n';
                String strExecLogMsgEncoded = '';
                List<Attachment> listToInsert = new List<Attachment>();
                integer i=1;
                for(ExeLog_WP exeLog : completeJobDetail.exeLog_WPL)
                {
                    //strExecLogMsgEncoded += EncodingUtil.base64Encode(Blob.valueOf(String.valueof(exeLog.timeStamp) + String.valueof(exeLog.logLevel) + String.valueof(exeLog.operation) + String.valueof(exeLog.message)));
                    strExecLogMsgEncoded = String.valueof(exeLog.timeStamp) + String.valueof(exeLog.logLevel) + String.valueof(exeLog.operation) + String.valueof(exeLog.message);
                    listToInsert.add(new Attachment(Name = 'ExecutionLog_'+i, ParentId = completeJobDetail.jobId, Body = Blob.valueOf(strExecLogMsgEncoded), IsPrivate = TRUE));
                    i++;
                }
                insert listToInsert; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                //Attachment objAttachment = new Attachment(Name = 'Execution Log', ParentId = completeJobDetail.jobId, Body = Blob.valueOf(strExecLogMsgEncoded), IsPrivate = TRUE);
                //insert objAttachment; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            
            // Update Jobs
            //During routewise complete call, update "success" only when last route which is contains scheduleResourceCount is -1.
            if(completeJobDetail.scheduleResourceCount != NULL && completeJobDetail.scheduleResourceCount < 0){
                if(strFailedElement){
                    objSvmxJob.SVMXC__OptiMax_Message__c = 'Complete Error';
                    objSvmxJob.SVMXC__Status__c = String.valueof(-3);
                }else{
                    objSvmxJob.SVMXC__OptiMax_Message__c = 'Success';
                    objSvmxJob.SVMXC__Status__c = String.valueof(3);
                }
                
            if(completeJobDetail.timeOfComp != NULL)
                objSvmxJob.SVMXC__End_Time__c = completeJobDetail.timeOfComp;
            if(completeJobDetail.scheduleWOCount != NULL)
                objSvmxJob.SVMXC__Scheduled_Work_Orders__c = completeJobDetail.scheduleWOCount;
            if(completeJobDetail.scheduleResourceCount != NULL && completeJobDetail.scheduleResourceCount > 0)
                objSvmxJob.SVMXC__Scheduled_Resources__c = completeJobDetail.scheduleResourceCount;
            if(completeJobDetail.totalRouteTime_WP != NULL)
            {
                if(completeJobDetail.totalRouteTime_WP.totalRouteTime != NULL)
                    objSvmxJob.SVMXC__Total_Route_Time__c = completeJobDetail.totalRouteTime_WP.totalRouteTime;
                if(completeJobDetail.totalRouteTime_WP.totalDrivingTime != NULL)
                    objSvmxJob.SVMXC__Total_Driving_Time__c = completeJobDetail.totalRouteTime_WP.totalDrivingTime;
                if(completeJobDetail.totalRouteTime_WP.totalDistance != NULL)
                    objSvmxJob.SVMXC__Total_Distance__c = completeJobDetail.totalRouteTime_WP.totalDistance;
            }
            
            //TODO: set the flag to false in optimizer transaction for the territory.
            if(objSvmxJob.SVMXC__OptiMax_Message__c == 'Success'){
                List<SVMXC__SVMX_Optimizer__c> lstBatchOptimizer = [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__WhatId__c,SVMXC__Optimizer_Connection_ID__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatType__c ='BATCH_TECHNICIAN' AND SVMXC__Optimizer_Connection_ID__c =: objSvmxJob.SVMXC__Territory__c];
                if(lstBatchOptimizer != null && lstBatchOptimizer.size() > 0 && lstBatchOptimizer[0].SVMXC__Optimizer_Change_Token__c.equalsIgnoreCase('TRUE')){
                    lstBatchOptimizer[0].SVMXC__Optimizer_Change_Token__c = 'FALSE';
                    update lstBatchOptimizer;
                }
            }
            update objSvmxJob; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            strLogger += system.now() + ': Updated job details\n';
            //invoke Analytics method
            //strLogger += system.now() + ': HorizondatateTime lstSvmxJobStats====='+lstSvmxJobStats+'\n';
            if(lstSvmxJobStats != null && lstSvmxJobStats.size() > 0){            
                for(SVMXC__SVMX_Job_Stats__c jobStatss : lstSvmxJobStats){                
                    if(jobStatss.Name.equalsIgnoreCase('startHorizonDateTimeValue')){
                        strHorizonStartTime = jobStatss.SVMXC__Value__c;
                    }
                    if(jobStatss.Name.equalsIgnoreCase('endHorizonDateTimeValue')){
                        strHorizonEndTime = jobStatss.SVMXC__Value__c;
                    }               
                }
            }
            
            if(String.isBlank(strHorizonStartTime)){
                List<SVMXC__SVMX_Job_Stats__c>  lstJobs = [select Name, SVMXC__Value__c from SVMXC__SVMX_Job_Stats__c where SVMXC__SVMX_Job__c = :objSvmxJob.Id and Name LIKE '%HorizonDateTimeValue%']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                //strLogger += system.now() + ': HorizondatateTime lstJobs>>====='+lstJobs+'\n';
                for(SVMXC__SVMX_Job_Stats__c jobStatss : lstJobs){                
                    if(jobStatss.Name.equalsIgnoreCase('startHorizonDateTimeValue')){
                            strHorizonStartTime = jobStatss.SVMXC__Value__c;
                    }
                }
            }
            strLogger += system.now() + ': HorizondatateTime strHorizonStartTime>>====='+strHorizonStartTime + '\n';
            strLogger += system.now() + ': HorizondatateTime strHorizonEndTime>>====='+strHorizonEndTime + '\n';
            
            //SPM_Optimax_Action actionAna = new SPM_Optimax_Action(); 
            SPM_Scheduling_Action actionAna = new SPM_Scheduling_Action(); 
            if((strHorizonStartTime != null && strHorizonStartTime.length() > 0) && (strHorizonEndTime != null && strHorizonEndTime.length() > 0)){ 
                Datetime dateTimeStart = Datetime.valueOfGmt(strHorizonStartTime);
                Datetime dateTimeEnd = Datetime.valueOfGmt(strHorizonEndTime);
                actionAna.sourceSchedulingData(completeJobDetail.jobId, dateTimeStart, dateTimeEnd);
            }
          }
        }
        catch(Exception e)
        {
            //strLogger += system.now() + ': Error: while updating SFDC with OptiMax CompleteJob WS response:\n' + ex.getMessage();
            strLogger += system.now()+'Error: while updating SFDC with OptiMax CompleteJob WS response::Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n';
            throw new SVMXException(strLogger);
        }
        
        //strLogger += system.now() + ': Usage Details: After updating the work orders and creating the events\n\tHeap Size     : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
        strLogger += system.now() + 'End of SMAX_Complete_OptiMax_Job_WS  : Limits.getAggregateQueries()==' + Limits.getAggregateQueries()+'\n';
        strLogger += system.now() + 'End of SMAX_Complete_OptiMax_Job_WS: No of Queries used in this apex code so far: Limits.getQueries()== ' + Limits.getQueries()+'\n';
        
        List<Attachment> lstAttachment = new List<Attachment>();
        // Attaching debug log to the job
        if(mapSettingValues.containsKey('OMAX003_SET018') && mapSettingValues.get('OMAX003_SET018').toUpperCase() == 'TRUE')
        {
            List<Route_WP> lstRoutes1 = completeJobDetail.getroute_WPL();
            //set the technician and date of the route as name of the attachment
            if(lstRoutes1 != null && lstRoutes1.size() == 1){
                Route_WP route = lstRoutes1[0];
                DestinationNodes_WP destNode = route.destinationNodes_WPL[0];
                if(destNode.arraivalTime != null)
                    routewiseLogName = techName+'_'+destNode.arraivalTime;
                else
                    routewiseLogName = techName+'_'+'Event-Drive To Home';
            }
            strLogger += system.now() + ': CompleteJob Attachment Name...'+routewiseLogName + '\n';
            Attachment objDebugLogAttach = new Attachment(Name = routewiseLogName, ParentId = objSvmxJob.Id, Body = Blob.valueOf(strLogger), IsPrivate = TRUE);
            lstAttachment.add(objDebugLogAttach);
        }
        
        // Attache missing work order details to job
        if(intMissingWorkOrderCount > 0)
        {
            Attachment objDebugLogAttach = new Attachment(Name = 'Missing Work Orders', ParentId = objSvmxJob.Id, Body = Blob.valueOf(strDeletedWorkOrderDetails), IsPrivate = TRUE);
            lstAttachment.add(objDebugLogAttach);
            objSvmxJobStats = new SVMXC__SVMX_Job_Stats__c(Name = 'Missing Work Order Count', SVMXC__SVMX_Job__c = objSvmxJob.Id, SVMXC__Value__c = String.valueOf(intMissingWorkOrderCount), SVMXC__Units__c = 'Count');
            lstSvmxJobStats.add(objSvmxJobStats);
        }
        
        if(lstSvmxJobStats.size() > 0) insert lstSvmxJobStats;//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
        //if(lstAttachment.size() > 0) insert lstAttachment;
        // Setting up wrpComplJobRetObj
        wrpComplJobRetObj.status = 1;
        wrpComplJobRetObj.statusMessage = 'CompleteJob WS call completed successfully in SF org';
            
        if(lstAttachment.size() > 0) insert lstAttachment;//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        return wrpComplJobRetObj;
    }
    // Ends SMAX_Complete_OptiMax_Job_WS
}