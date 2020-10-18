public with sharing class WSCH_Provider_ECO_Stubs {
/**
    This is the stub class required to create request and parsing into json for Rest webservice invoke.
**/
    public static DCON_Utils dcUtils = new DCON_Utils();
    
    public class InitJobRequest_WP
    { 
        public String dispatchProcessId{ get; set; }
        public String territoryId{ get; set; }
        public String orgId{ get; set; }
        public String svmxVersion{get; set;}
        public String geoCodingEnabled{get; set;}
        public List<WorkOrder_WP> workOrders = new List<WorkOrder_WP>();
        public List<Technician_WP> resources = new List<Technician_WP>();
        public List<ExcSetting_WP> parameters = new List<ExcSetting_WP>();
        public List<TechniciansEvent_WP> technicianEvents = new List<TechniciansEvent_WP>();
    }

    public class ManageWorkOrderRequest_WP
    { 
        public String dispatchProcessId{ get; set; }
        public String territoryId{ get; set; }
        public String orgId{ get; set; }
        public String svmxVersion{get; set;}
        public String geoCodingEnabled{get; set;}
        public List<WorkOrder_WP> workOrders = new List<WorkOrder_WP>();
    }
        
    public class ManageTechnicianRequest_WP
    { 
        public String dispatchProcessId{ get; set; }
        public String territoryId{ get; set; }
        public String orgId{ get; set; }
        public String svmxVersion{get; set;}
        public String geoCodingEnabled{get; set;}
        public List<Technician_WP> resources = new List<Technician_WP>();
    }
    
    public class ManageTechnicianEventRequest_WP
    { 
        public String dispatchProcessId{ get; set; }
        public String territoryId{ get; set; }
        public String orgId{ get; set; }
        public String svmxVersion{get; set;}
        public boolean geoCodingEnabled{get; set;}
        public List<TechniciansEvent_WP> technicianEvents= new List<TechniciansEvent_WP>();
    }
    
    public class ManageWorkOrdersResultRequest_WP
    { 
        public String dispatchProcessGuid{ get; set; }
        public String territoryGuid{ get; set; }
        public String orgGuid{ get; set; }
    }
    
    public class AppointmentOfferRequest_WP
    { 
        public String dispatchProcessId{ get; set; }
        public String territoryId{ get; set; }
        public String orgId{ get; set; }
        public WorkOrder_WP workOrder{ get; set; }
        public ApptOfferType_WP appointmentOfferType{get; set;}
    } 
    
    public class ApptOfferType_WP
    { 
        public String appointmentOfferTypeName{ get; set; } 
        public List<ArrivalWindow_WP> arrivalWindows = new List<ArrivalWindow_WP>();
    }
    
    public class ArrivalWindow_WP
    { 
        public String arrivalWindowName{ get; set; }
        public String startTime{ get; set; }
        public String endTime{ get; set; }
    }
    
    public class AppointmentOfferResponse_WP
    { 
        public String dispatchProcessId{ get; set; }
        public String territoryId{ get; set; }
        public String orgId{ get; set; }
        public List<Offer_WP> appointmentOffers = new List<Offer_WP>();
        public String errorMessage;
        public integer statusCode{ get; set; }
        public Response_WP responseWP = new Response_WP();
    } 
    
    public class Offer_WP
    {
        public String startDateTime{ get; set; }
        public String endDateTime{ get; set; }
        public Double slotCost{ get; set; } // actual cost computed by opticore
        public String slotType{ get; set; } // cost category {Low, Medium, High, VeryHigh}
        public String slotCategory{ get; set; } // slot category {Recommended, Medium, Poor}
        public List<String> technicians = new List<String>();// technician names
        //public ApptOfferType_WP apptOfferType{get; set;}
        //public String TechId{ get; set; }
    }
    
    public class BookAppointmentRequest_WP 
    {
        public String dispatchProcessId{ get; set; }
        public String territoryId{ get; set; }
        public String orgId{ get; set; }
        public WorkOrder_WP workOrder{ get; set; }
        public double slotCost{ get; set; }
        public String slotCategory{ get; set; } // slot category {Recommended, Medium, Poor}
        public boolean goAhead{ get; set; }
    }
    
    public class BookAppointmentResponse_WP
    {
        public String dispatchProcessId{ get; set; }
        public String territoryId{ get; set; }
        public String orgId{ get; set; }
        public String workOrderId{ get; set; }
        public integer statusCode{ get; set; }
        public Response_WP responseWP = new Response_WP();
    }
    
    
    /*
     *Type : Wrapper Class
     *Used :  Initiate 
     *Desc : Generic parameter used as work order Relation details
     */
    public class Relation_WP
    {
        public String relationshipType {get; set;}
        public String masterNodeId { get; set;}
        public String resourceDependencyType {get; set;}
        public Long minimalDeviationSec { get; set;}
        public Long maximalDeviationSec { get; set;}
    }

    /*
     *Type : Wrapper Class
     *Used : "InitJobRequest_WP" and "ManageWorkOrderRequest_WP" Wrapper Class
     *Desc : Holds work order information in required format
     */
    public class WorkOrder_WP
    {
        public String workOrderId{ get; set; }
        public Boolean requiredProduct{ get; set; }
        public List<Expertise_WP> requiredExpertise = new List<Expertise_WP>();
        public String address{ get; set; }
        public String preferredResourceId{ get; set; }
        public Double preferredResourcePriority{ get; set; }
        public Double priority{ get; set; }
        public Double visitDuration{ get; set; }
        public Integer importance{ get; set; }
        public String workOrderType{ get; set; }
        public String operationType{ get; set; }
        public Double scheduleViolationPenalty{ get; set;}
        public Location_WP location = new Location_WP();
        public List<ExecutionTime_WP> serviceTimes = new List<ExecutionTime_WP>();
        public List<QualifiedTechnician_WP> qualifiedTechnicians = new List<QualifiedTechnician_WP>();
        public List<BannedTechnician_WP> bannedTechnicians = new List<BannedTechnician_WP>();
        public List<MandatoryTechnician_WP> mandatoryTechnicians = new List<MandatoryTechnician_WP>();
        public Boolean isForceFix{ get; set; }
        public String scheduleFixType{ get; set; }
        public String capacityReservationCategory{ get; set; }
        public List<Relation_WP> relations = new List<Relation_WP>();
        public Map<String, String> parameters = new Map<String, String>();
        
        public WorkOrder_WP(){}
        public WorkOrder_WP(SVMXC__Service_Order__c objWorkOrder, List<ExecutionTime_WP> woExeTime, String strWorkOrderType, String strOperationType)
        {
            if('remove'.equalsIgnoreCase(strOperationType)){
                operationType = strOperationType;
                workOrderId = objWorkOrder.Name;
            }else{
                workOrderType = strWorkOrderType;
                operationType = strOperationType;
                workOrderId = objWorkOrder.Name;
                isForceFix = false;
                if(objWorkOrder.SVMXC__Product__c != NULL)
                    //requiredProduct = True;
                    //TODO: Need to add product from work order and also include the same into technician wrapper also. Temporerly we send null value to required product.
                    requiredProduct = null;
                    
                if(objWorkOrder.SVMXC__Skill_Set__c != NULL){
                    //requiredExpertise = True;
                    //TODO: need to parse the skill set field from work order and send the skills to OptiMax.
                    //requiredExpertise=fetchSkills(objWorkOrder);
                    requiredExpertise = fetchSkills(objWorkOrder);
                }
                //check if the work order qualify for forcefix
                if(WSCH_Eco_Constants.FORCEFIXJOB_SCHDL_CHANGE_TOKENS.contains(objWorkOrder.SVMXC__Scheduling_Change_Token__c)){
                    isForceFix = true;
                }                
                //preferredResourceId = objWorkOrder.SVMXC__Preferred_Technician__c;
                //adding technican name into the preferred resource id
                if('ASSIGNED'.equalsIgnoreCase(strWorkOrderType)){
                    String techNewId = objWorkOrder.SVMXC__Group_Member__r.Id + '_'+objWorkOrder.SVMXC__Group_Member__r.Name;
                    preferredResourceId = techNewId;
                }
    
                if(objWorkOrder.SVMXC__Service_Duration__c != NULL)
                    visitDuration = objWorkOrder.SVMXC__Service_Duration__c;
                
                if(objWorkOrder.SVMXC__SM_Schedule_Violation_Penalty__c != null)
                    scheduleViolationPenalty = objWorkOrder.SVMXC__SM_Schedule_Violation_Penalty__c;
                
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
                location.latitude = objWorkOrder.SVMXC__Latitude__c;
                location.longitude = objWorkOrder.SVMXC__Longitude__c;
                
                if(woExeTime != NULL)
                    serviceTimes = woExeTime;
                    
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
                                qualifiedTechnicians.add(new QualifiedTechnician_WP(qualifiedTechNewId, objQTL.stackRank));
                            }else if(objQTL.valid == true && objQTL.prefType=='Prohibited'){
                                qualifiedTechNewId = objQTL.tech + '_'+objQTL.tName;
                                bannedTechnicians.add(new BannedTechnician_WP(qualifiedTechNewId));
                            }else if(objQTL.valid == true && objQTL.prefType=='Mandatory'){
                                qualifiedTechNewId = objQTL.tech + '_'+objQTL.tName;
                                mandatoryTechnicians.add(new MandatoryTechnician_WP(qualifiedTechNewId, objQTL.stackRank));
                            }
                                
                        }
                    }catch(Exception e){
                        WSCH_AuditLogger.error('Exception occured::WSCH_Provider_ECO_Stubs::WorkOrder_WP(): - '+e.getMessage());
                    }
                }       
                //Capacity Limitation in RTO
                if(objWorkOrder.SVMXC__SM_Capacity_Rule_Name__c != null){
                    capacityReservationCategory = objWorkOrder.SVMXC__SM_Capacity_Rule_Name__c.trim();
                }         
            }
        }
        
        public WorkOrder_WP(SVMXC__Service_Order__c objWorkOrder, List<ExecutionTime_WP> woExeTime, String strWorkOrderType, String strOperationType, String scheduleFixType)
        {
            this(objWorkOrder, woExeTime, strWorkOrderType, strOperationType);
            this.scheduleFixType = scheduleFixType;
        }  
        public WorkOrder_WP(SVMXC__Service_Order__c objWorkOrder, List<ExecutionTime_WP> woExeTime, String strWorkOrderType, String strOperationType, String scheduleFixType, Map<String, String> parameters)
        {
            this(objWorkOrder, woExeTime, strWorkOrderType, strOperationType);
            this.scheduleFixType = scheduleFixType;
            this.parameters = parameters;
        }  
             
    }
    
    
    /*
     *Type : Wrapper Class
     *Used : "InitJobRequest_WP" and "ManageWorkOrderRequest_WP" Wrapper Class
     *Desc : Holds qualified technicians information in required format
     */
    public class QualifiedTechnician_WP{
        public String preferredResourceId { get; set; }
        public Integer priority{ get; set; }
        public QualifiedTechnician_WP(String preferredResourceId, Integer priority){
            this.preferredResourceId = preferredResourceId;
            this.priority = priority;
        }
    }
    
    /*
     *Type : Wrapper Class
     *Used : "InitJobRequest_WP" and "ManageWorkOrderRequest_WP" Wrapper Class
     *Desc : Holds banned technicians information in required format
     */
    public class BannedTechnician_WP{
        public String bannedResourceId { get; set; }
        public BannedTechnician_WP(String bannedResourceId){
            this.bannedResourceId = bannedResourceId;
        }
    }

    /*
     *Type : Wrapper Class
     *Used : "InitJobRequest_WP" and "ManageWorkOrderRequest_WP" Wrapper Class
     *Desc : Holds Mandatory technicians information in required format
     */
    public class MandatoryTechnician_WP{
        public String mandatoryResourceId { get; set; }
        public Integer priority{ get; set; }
        public MandatoryTechnician_WP(String mandatoryResourceId, Integer priority){
            this.mandatoryResourceId = mandatoryResourceId;
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
        public String territoryGuid{ get; set; }
        public String address{ get; set; }
        public String currentAddress{ get; set; }
        public Double fixedCost{ get; set; }
        public Double hourlyCost{ get; set; }
        public Double travelUnitCost{ get; set; }
        public Double avgTravelSpeed{ get; set; }
        //public Double maxWeeklyHours{ get; set; }
        public Double maxHours{ get; set; }
        public Double maxDistance{ get; set; }
        public String operationType{ get; set; }
        public String permittedNodeTypesStr{ get; set;}
        public Double techOverTimeSecs{get; set;}
        //public Double driveBeforeShiftStartInSecs{get; set;}
        //public Double driveAfterShiftStartInSecs{get; set;}
        public Location_WP currentLocation = new Location_WP();
        public Location_WP location = new Location_WP();
        public List<ExecutionTime_WP> workingHours = new List<ExecutionTime_WP>();
        public List<ExcSetting_WP> techParameters = new List<ExcSetting_WP>();
        public List<Expertise_WP> expertise = new List<Expertise_WP>();
        
        public Technician_WP(){}
        
        //public Technician_WP(SVMXC__Service_Group_Members__c objTechnician, List<ExecutionTime_WP> eventTime, List<String> lstTechSkill, String strOperationType, Double dblTechOverTimeSecs, Double dblDriveBeforeShiftStartInSecs, Double dblDriveAfterShiftStartInSecs)
        public Technician_WP(SVMXC__Service_Group_Members__c objTechnician, List<ExecutionTime_WP> eventTime, List<Expertise_WP> lstTechSkill, String strOperationType, Double dblTechOverTimeSecs)
        {
            operationType=strOperationType;
            resourceId = objTechnician.Id + '_' + objTechnician.Name;
            fixedCost = objTechnician.SVMXC__Fixed_Cost__c;
            //perHourCost = objTechnician.SVMXC__Per_hour_Cost__c;
            //perMileCost = objTechnician.SVMXC__Per_Mile_Cost__c;
            avgTravelSpeed = objTechnician.SVMXC__Average_Speed__c;
            maxDistance = objTechnician.SVMXC__Max_Distance__c;
            maxHours = objTechnician.SVMXC__Max_Hours__c;
            if(objTechnician.SVMXC__Per_hour_Cost__c != null){
                hourlyCost = objTechnician.SVMXC__Per_hour_Cost__c;
            }
            
            if(objTechnician.SVMXC__Per_Mile_Cost__c != null){
                travelUnitCost = objTechnician.SVMXC__Per_Mile_Cost__c;
            }
            //maxWeeklyHours = NULL;
            //maxDailyHours = NULL;
            location.latitude = objTechnician.SVMXC__Latitude_Home__c;
            location.longitude = objTechnician.SVMXC__Longitude_Home__c;
            currentLocation = location; // assigned for demo.
            territoryGuid = objTechnician.SVMXC__Service_Territory__c;
            workingHours = eventTime;
            String strTechAddress = ((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0) ? objTechnician.SVMXC__Street__c : '') + ((objTechnician.SVMXC__City__c != NULL && objTechnician.SVMXC__City__c.length() > 0) ?  (((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0)) ? ', ' : '') + objTechnician.SVMXC__City__c : '') + ((objTechnician.SVMXC__State__c != NULL && objTechnician.SVMXC__State__c.length() > 0) ?  (((objTechnician.SVMXC__City__c != NULL && objTechnician.SVMXC__City__c.length() > 0) || ((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objTechnician.SVMXC__State__c : '') + ((objTechnician.SVMXC__Zip__c != NULL && objTechnician.SVMXC__Zip__c.length() > 0) ?  (((objTechnician.SVMXC__State__c != NULL && objTechnician.SVMXC__State__c.length() > 0) || (objTechnician.SVMXC__City__c != NULL && objTechnician.SVMXC__City__c.length() > 0) || ((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objTechnician.SVMXC__Zip__c : '') + ((objTechnician.SVMXC__Country__c != NULL && objTechnician.SVMXC__Country__c.length() > 0) ?  (((objTechnician.SVMXC__Zip__c != NULL && objTechnician.SVMXC__Zip__c.length() > 0) || (objTechnician.SVMXC__State__c != NULL && objTechnician.SVMXC__State__c.length() > 0) || (objTechnician.SVMXC__City__c != NULL && objTechnician.SVMXC__City__c.length() > 0) || ((objTechnician.SVMXC__Street__c != NULL && objTechnician.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objTechnician.SVMXC__Country__c : '');
            Address = strTechAddress;
            String strSkill;
            //expertise = new List<Expertise_WP>();
            if(lstTechSkill != null && lstTechSkill.size() > 0){
                expertise=lstTechSkill;
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Stubs::Technician_WP():: lstTechSkill: ' + lstTechSkill);
                // for(Integer i=0; i< lstTechSkill.size(); i++){
                //     Expertise_WP expts = new Expertise_WP();
                //     List<String> lstStr =  lstTechSkill[i].split('_');
                //     //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Stubs::Technician_WP():: lstStr: ' + lstStr);
                //     Date validFromDt= null;
                //     Date validToDt = null;
                //     if(lstStr[1] != null && !lstStr[1].equalsIgnoreCase('null')){
                //        validFromDt = Date.valueOf(lstStr[1].trim());
                //     }
                //     if(lstStr[2] != null && !lstStr[2].equalsIgnoreCase('null')){   
                //        validToDt = Date.valueOf(lstStr[2].trim());
                //     }  
                //     expts.id = lstTechSkill[i].split('_')[0]; // only sfdc id
                //     expts.validFrom = validFromDt;
                //     expts.validTo = validToDt;
                //     //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Stubs::Technician_WP():: expts: ' + expts);
                //     expertise.add(expts);
                // }
            }
            permittedNodeTypesStr = strSkill;
            techOverTimeSecs = dblTechOverTimeSecs;            
        }
        
        public Technician_WP(SVMXC__Service_Group_Members__c objTechnician, List<ExecutionTime_WP> eventTime, List<Expertise_WP> lstTechSkill, String strOperationType, Double dblTechOverTimeSecs, List<ExcSetting_WP> techParams)
        {
            this(objTechnician, eventTime, lstTechSkill, strOperationType, dblTechOverTimeSecs);
            techParameters = techParams;
        }
    }
    
    /*
     *Type : Wrapper Class
     *Used : "InitJobRequest_WP" and "ManageTechnicianRequest_WP" Wrapper Class
     *Desc : Holds technicians event details in required format
     */
    public class TechniciansEvent_WP
    {
        public String territoryId{ get; set; }
        public String preferredResourceId{ get; set; }
        public String eventId{ get; set; }
        public Integer importance{ get; set; }
        public List<executionTime_WP> serviceTimes{ get; set; }
        public Double eventDuration{ get; set; }
        public Double timeWindowPriority{ get; set; }
        public Double preferredResourcePriority{ get; set; }
        public String operationType;
        //public TechniciansEventsAdditonalDetails_WP techEventsAddtionalDetailsWP = new TechniciansEventsAdditonalDetails_WP();
        public Location_WP location = new Location_WP();
        public String address{ get; set; }
        public String eventType{ get; set; }          
        public TechniciansEvent_WP(){}
        public Map<String, String> parameters = new Map<String, String>();

        public TechniciansEvent_WP(String strTerritoryId, String strPreferedResource, String strEventId, DateTime dtmStartTime, DateTime dtmEndTime, Double dblTimeWindowPriority, Double dblPreferredResourcePriority, Integer importance,String operationType,Location_WP location,String address)
        {
            this.importance = importance;
            this.serviceTimes = new List<executionTime_WP>();
            this.eventId = strEventId;
            this.preferredResourceId = strPreferedResource;
            this.serviceTimes.add(new executionTime_WP(dtmStartTime, dtmEndTime));
            this.territoryId = strTerritoryId;
            if(null != dtmEndTime && null !=dtmStartTime ){
                this.eventDuration = ( (dtmEndTime.getTime() - dtmStartTime.getTime()) / 1000);
            }
            this.timeWindowPriority = dblTimeWindowPriority;
            this.preferredResourcePriority = dblPreferredResourcePriority;
            this.operationType = operationType;
            if(location != null){
                this.eventType='CalendarGeoItem';
                this.location = location;
            }
            if(String.isNotEmpty(address)){
                this.eventType='CalendarGeoItem';
                this.address = address;
            }
            if(location == null && String.isEmpty(address)){
                this.eventType='CalendarItem';
            }
            
        }
        
        public TechniciansEvent_WP(String strTerritoryId, String strPreferedResource, String strEventId, DateTime dtmStartTime, DateTime dtmEndTime, Double dblTimeWindowPriority, Double dblPreferredResourcePriority, Integer importance,String operationType,Location_WP location,String address, Map<String,String> parameters)
        {
            this(strTerritoryId, strPreferedResource, strEventId, dtmStartTime, dtmEndTime, dblTimeWindowPriority, dblPreferredResourcePriority, importance, operationType,location, address);
            this.parameters = parameters;
        }   
    }
    
    public class Location_WP
    {
        /*  latitude and longitudee have been introduced for better code readability.
        */
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
        /*  startDateTime & endDateTime have been introduced for better code readability.
            startDate & endDate have been retained for avoiding changes in WSDL.
            This is to avoid changes to OptiMax Java code
        */
        public DateTime workingHoursBegin{ get; set; }
        public DateTIme workingHoursEnd{ get; set; }
        
        public void setworkingHoursBegin(DateTime dtmStartDateTime)
        {
            this.workingHoursBegin = dtmStartDateTime;
        }
        
        public void setworkingHoursEnd(DateTime dtmEndDateTime)
        {
            this.workingHoursEnd = dtmEndDateTime;
        }
        
        public ExecutionTime_WP()
        {}
        
        public ExecutionTime_WP(DateTime dtmStartDateTime, DateTime dtmEndDateTime)
        {
            this.workingHoursBegin = dtmStartDateTime;
            this.workingHoursEnd = dtmEndDateTime;
        }
        
        // If a time window spans across multiple days, split it into multiple time windows based on the given time zone, 1 per day
        public List<ExecutionTime_WP> doSplitDays(String strTimeZoneSidKey, Set<Date> setAllowedDates)
        {
            List<ExecutionTime_WP> lstExeTime = new List<ExecutionTime_WP>();
            Date datStartDate = Date.valueOf(this.workingHoursBegin.format('yyyy-MM-dd', strTimeZoneSidKey));
            Date datEndDate = Date.valueOf(this.workingHoursEnd.format('yyyy-MM-dd', strTimeZoneSidKey));
            
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
                        wrpExeTime.workingHoursBegin = this.workingHoursBegin;
                    else
                        wrpExeTime.workingHoursBegin = dcUtils.getDateTimeInTimezone(tempDate, Time.newInstance(0,0,0,0), strTimeZoneSidKey);
                    if (tempDate == datEndDate)
                        wrpExeTime.workingHoursEnd = this.workingHoursEnd;
                    else
                        wrpExeTime.workingHoursEnd = dcUtils.getDateTimeInTimezone(tempDate, Time.newInstance(23,59,59,999), strTimeZoneSidKey);
                    if(wrpExeTime.workingHoursBegin != wrpExeTime.workingHoursEnd)
                        lstExeTime.add(wrpExeTime);
                }
            }
            return lstExeTime;
        }        
        
    }

    /*
     *Type : Wrapper Class
     *Used : "InitJobRequest_WP" Wrapper Class
     *Desc : This is an additional parameter
     */
     
    public class Setting_WP
    {
        public List<ExcSetting_WP> Exec_SettingsMap = new List<ExcSetting_WP>();
    }
    
    public class ExcSetting_WP
    {
        public String name{ get; set; }
        public String value{ get; set; }
    }
    
    public class Response_WP
    {
        public String status{ get; set; }
        public String message{ get; set; }
    }
    
/*    private static String fetchSkills(SVMXC__Service_Order__c workOrder)
    {
        //Parse the skillSet which is in JSON format and extract the skillName and skillLevel from it
        String skills;
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
                        skillRequired = parser.getText(); //only skill id
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
                    if(String.isNotEmpty(skills)){
                        skills=skills+','+skill;
                    }else{
                        skills=skill;
                    }
                }
            }
        }
        //WSCH_AuditLogger.error('WSCH_Provider_ECO_Stubs::fetchSkills(): - '+skills);
        return skills;
    } */ 
    
    private static List<Expertise_WP> fetchSkills(SVMXC__Service_Order__c workOrder)
    {
        List<Expertise_WP> lstSkills = new List<Expertise_WP>();
        if(workOrder != null && String.isNotEmpty(workOrder.SVMXC__Skill_Set__c)) {
            WSCH_Provider_ECO_Stubs.Skill[] skills = (List<WSCH_Provider_ECO_Stubs.Skill>)JSON.deserialize(workOrder.SVMXC__Skill_Set__c,List<WSCH_Provider_ECO_Stubs.Skill>.class);
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
    
    public class ResumeJobRequest_WP
    { 
        public String dispatchProcessGuid{ get; set; }
        public String territoryGuid{ get; set; }
        public String orgGuid{ get; set; }
    }
    
    public class SuspendJobRequest_WP
    { 
        public String dispatchProcessGuid{ get; set; }
        public String territoryGuid{ get; set; }
        public String orgGuid{ get; set; }
    }  
    
     public class DeleteScheduleRequest_WP
    { 
        public String dispatchProcessGuid{ get; set; }
        public String territoryGuid{ get; set; }
        public String orgGuid{ get; set; }
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