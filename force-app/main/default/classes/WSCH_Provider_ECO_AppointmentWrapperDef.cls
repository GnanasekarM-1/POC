public with sharing class WSCH_Provider_ECO_AppointmentWrapperDef {

    public class WSCH_Provider_ECO_Appointment_Settings{
        public String numberOfDays;
        public String numberOfOfferAppts;
        public String considerCostOrDates;        
        public String considerPoorSlots;
        public String territoryTimezoneOffset;
        public String territoryTimezone;
        public String startDate;  
        public String endDate;
        public String horizonStartDate;  
        public String horizonEndDate;
        public String isOutSideHorizonDate;                  
        public String outSideHzDtWarningMsg;
        public String bookedApptSlotCost;        
        public String bookedApptSlotCategory;
        public String bookedApptSlot;  
        public String startDateTime;  
        public String endDateTime;
        public String showPoorCheckBoxSettingVal;
        public String jobStatus;                                  
        public String jobStatusWarningMsg;
        public String territoryId;
        public String dispatchProcessId;
        public WSCH_Provider_ECO_Appointment_Settings(){

        }
    }

    public class WSCH_Provider_ECO_Appointment_Request {
        public String headerId ;        
        public WSCH_Provider_ECO_Appointment_Settings appointmentSettings;
        public StartOptimaxJob_WP startOptimaxJobReq;
        public BookAppointmentRequest_WP bookAppointmentReq;
        public WSCH_Provider_ECO_Appointment_Request(){
           
        }
    }

    public class WSCH_Provider_ECO_Appointment_HeaderRecord{
        public String recordID ;
        public String recordName ;
        public String accountName ;
        public String contactName ;
        public String productName;
        public String bookApptResponseCode;
        public String isPoorSlotsAvailable;        
        public Map<String,List<WSCH_Provider_ECO_Appointment_OfferAppointments>> offerAppointmentMap;        
        public Map<String,List<WSCH_Provider_ECO_Appointment_OfferAppointments>> offerApptMapWithPoorMap;
        public WSCH_Provider_ECO_Appointment_HeaderRecord(){}
    }

    public class WSCH_Provider_ECO_Appointment_Response {
        
        public Boolean success ;
        public Boolean warning ;
        public List<String> messageList ;  
        public WSCH_Provider_ECO_Appointment_HeaderRecord headerRecord ;       
        public WSCH_Provider_ECO_Appointment_Settings appointmentSettings;
        public WSCH_Provider_ECO_Appointment_Response(){ 
            messageList = new List<String>();
        }
    }
    
    public class WSCH_Provider_ECO_Appointment_OfferAppointments {
        public string recordName;
        public string recordId;
        public string apptOfferDay;
        public string apptOfferTime;        
        public string technician;
        public string costRange;
        public String slotCost;
        public String offerApptStDateTime;
        public String offerApptEndDateTime;
        public String slotCategoryCost;        
        public String slotCategory;
        public WSCH_Provider_ECO_Appointment_OfferAppointments() {

        }
    }
    
    public class BookAppointmentRequest_WP {        
        //public String slotCost;
        public String offerApptStDateTime;
        public String offerApptEndDateTime;
        //public String costRange;
        //public String slotCategoryCost;        
        public String slotCategory;
        public String goAhead;
    }    
    
    public class StartOptimaxJob_WP {
        public String territoryId;
        public String dispatchProcessId;
    }

}