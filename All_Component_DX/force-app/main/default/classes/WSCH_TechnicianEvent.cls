public with sharing class WSCH_TechnicianEvent {

    private String workOrderID;
    private String technicianExternalID;
    private String dispatchStatus;
    private DateTime startDateTime;
    private DateTime arrivalDateTime;
    private DateTime finishDateTime;
    private String violationMessage;
    private Boolean isFixed;
    //Below data-member introduced as part of ECO Implementation.
    private String technicianID;
    private String eventId;
    private Double dblLatitude;
    private Double dblLongitude;
    private String errorMsg;
    private Double driveDuration;
    private Double idleDuration;
    private Double visitDuration;
    private Double returnHomeDrivingTime;    
    

    public String getWorkOrderID() {
        return workOrderID;
    }

    public void setWorkOrderID(String workOrderID) {
        this.workOrderID = workOrderID;
    }

    public String getTechnicianExternalID() {
        return technicianExternalID;
    }

    public void setTechnicianExternalID(String technicianExternalID) {
        this.technicianExternalID = technicianExternalID;
    }

    public String getDispatchStatus() {
        return dispatchStatus;
    }

    public void setDispatchStatus(String dispatchStatus) {
        this.dispatchStatus = dispatchStatus;
    }

    public DateTime getStartDateTime() {
        return startDateTime;
    }

    public void setStartDateTime(DateTime startDateTime) {
        this.startDateTime = startDateTime;
    }

    public DateTime getStartDateTimeGmt() {
        return DateTime.newInstanceGmt(startDateTime.date(), startDateTime.time());
    }

    public DateTime getArrivalDateTime() {
        return arrivalDateTime;
    }

    public DateTime getArrivalDateTimeGmt() {
        return DateTime.newInstanceGmt(arrivalDateTime.date(), arrivalDateTime.time());
    }

    public void setArrivalDateTime(DateTime arrivalDateTime) {
        this.arrivalDateTime = arrivalDateTime;
    }

    public DateTime getFinishDateTime() {
        return finishDateTime;
    }

    public void setFinishDateTime(DateTime finishDateTime) {
        this.finishDateTime = finishDateTime;
    }

    public String getViolationMessage () {
       return violationMessage;
    }
    public void setViolationMessage(String violationMessage) {
        this.violationMessage = violationMessage;
    }

    public DateTime getFinishDateTimeGmt() {
        return DateTime.newInstanceGmt(finishDateTime.date(), finishDateTime.time());
    }
    
    public Boolean getIsFixed() {
        return isFixed;
    }

    public void setIsFixed(Boolean isFixed) {
        this.isFixed = isFixed;
    }
    
    public String getTechnicianID() {
        return technicianID;
    }

    public void setTechnicianID(String technicianID) {
        this.technicianID = technicianID;
    }
    
    public String getEventId() {
        return eventId;
    }

    public void setEventId(String eventId) {
        this.eventId = eventId;
    }
    
    public Double getDblLatitude() {
        return dblLatitude;
    }

    public void setDblLatitude(Double dblLatitude) {
        this.dblLatitude = dblLatitude;
    }  
    
    public Double getDblLongitude() {
        return dblLongitude;
    }

    public void setDblLongitude(Double dblLongitude) {
        this.dblLongitude = dblLongitude;
    } 
    
    public String getErrorMsg() {
        return errorMsg;
    }

    public void setErrorMsg(String errorMsg) {
        this.errorMsg = errorMsg;
    }                  

    public Double getDriveDuration() {
        return driveDuration;
    }

    public void setDriveDuration(Double driveDuration) {
        this.driveDuration = driveDuration;
    } 
    
    public Double getIdleDuration() {
        return idleDuration;
    }

    public void setIdleDuration(Double idleDuration) {
        this.idleDuration = idleDuration;
    } 

    public Double getVisitDuration() {
        return visitDuration;
    }

    public void setVisitDuration(Double visitDuration) {
        this.visitDuration = visitDuration;
    }
    
    public Double getReturnHomeDrivingTime() {
        return returnHomeDrivingTime;
    }

    public void setReturnHomeDrivingTime(Double returnHomeDrivingTime) {
        this.returnHomeDrivingTime = returnHomeDrivingTime;
    }            
}