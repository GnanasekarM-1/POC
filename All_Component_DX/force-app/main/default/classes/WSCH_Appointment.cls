global with sharing class WSCH_Appointment implements Comparable{

    private String strStartDateTime;
    private String strEndDateTime;
    private DateTime startDateTime;
    private DateTime endDateTime;
    private String promBand;
    private String promType;
    private String day;
    private String offerToken;
    private String offerText;
    private Integer travelTime;
    private String DRU;
    private String FRU;
    private String IRU;
    private String techExternalId;
    private List<String> technicians;
    private SVMXC__Service_Group_Members__c technician;
    private String siteIndicator;
    private String territoryTimeZone;    
    // group
    private Integer groupNumber;
    private Integer groupDuration;
    private String groupType;
    private Integer intTimeZoneOffset;
    private Double slotCost;
    private String slotType;
    private Boolean goAhead;
    private Double violationPenalty;
    private String dateOrCost;        
    private Double slotCategoryCost;
    private String slotCategory;
    
    public static String sortBy;
    

    public void setStrStartDateTime(String startDateTime) {
        this.strStartDateTime = startDateTime;
        //setStartDateTime(WSCH_DateUtils.parseSPDateTime(startDateTime));
        setStartDateTime(WSCH_DateUtils.parseSPDateTimeNew(startDateTime));
    }
    
    public void setStrEndDateTime(String endDateTime) {
        this.strEndDateTime = endDateTime;
        //setStartDateTime(WSCH_DateUtils.parseSPDateTime(startDateTime));
        setEndDateTime(WSCH_DateUtils.parseSPDateTimeNew(endDateTime));
    }

    global String getStrStartDateTime(){
        return strStartDateTime;
    }
    
    global String getStrEndDateTime(){
        return strEndDateTime;
    }

    global Datetime getStartDateTime() {
        return startDateTime;
    }

    global Datetime getStartDateTimeGmt() {
        return Datetime.newInstanceGmt(startDateTime.date(), startDateTime.time());
    }

    public void setStartDateTime(Datetime startDateTime) {
        this.startDateTime = startDateTime;
    }

    global Datetime getEndDateTime() {
        return endDateTime;
    }

    global Datetime getEndDateTimeGmt() {
        return Datetime.newInstanceGmt(endDateTime.date(), endDateTime.time());
    }

    public void setEndDateTime(Datetime endDateTime) {
        this.endDateTime = endDateTime;
    }

    global String getPromBand() {
        return promBand;
    }

    public void setPromBand(String promBand) {
        this.promBand = promBand;
    }

    global String getPromType() {
        return promType;
    }

    public void setPromType(String promType) {
        this.promType = promType;
    }

    global String getDay() {
        return day;
    }

    public void setDay(String day) {
        this.day = day;
    }

    global String getOfferToken() {
        return offerToken;
    }

    public void setOfferToken(String offerToken) {
        this.offerToken = offerToken;
    }

    global String getOfferText() {
        return offerText;
    }

    public void setOfferText(String offerText) {
        this.offerText = offerText;
    }

    global Integer getTravelTime() {
        return travelTime;
    }

    public void setTravelTime(Integer travelTime) {
        this.travelTime = travelTime;
    }

    global String getDRU() {
        return DRU;
    }

    public void setDRU(String dRU) {
        this.DRU = dRU;
    }

    global String getFRU() {
        return FRU;
    }

    public void setFRU(String fRU) {
        this.FRU = fRU;
    }

    global String getIRU() {
        return IRU;
    }

    public void setIRU(String iRU) {
        this.IRU = iRU;
    }

    global String getTechExternalId() {
        return techExternalId;
    }

    public void setTechExternalId(String techExternalId) {
        this.techExternalId = techExternalId;
    }

    global SVMXC__Service_Group_Members__c getTechnician() {
        return technician;
    }
    public void setTechnician(SVMXC__Service_Group_Members__c technician) {
        this.technician = technician;
    }

    global String getSiteIndicator() {
        return siteIndicator;
    }

    public void setSiteIndicator(String siteIndicator) {
        this.siteIndicator = siteIndicator;
    }

    global Integer getGroupNumber() {
        return groupNumber;
    }

    public void setGroupNumber(Integer groupNumber) {
        this.groupNumber = groupNumber;
    }

    global Integer getGroupDuration() {
        return groupDuration;
    }

    public void setGroupDuration(Integer groupDuration) {
        this.groupDuration = groupDuration;
    }

    global String getGroupType() {
        return groupType;
    }

    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }
    
    public void setIntTimeZoneOffset(Integer offset) {
        this.intTimeZoneOffset = offset;
    }
    
    public Integer getIntTimeZoneOffset() {
        return intTimeZoneOffset;
    }
    
    public void setSlotCost(Double slotCost) {
        this.slotCost = slotCost;
    }
    
    public Double getSlotCost() {
        return slotCost;
    }
    
    public void setSlotType(String slotType) {
        this.slotType = slotType;
    }

    public String getSlotType() {
        return slotType;
    }   
    
    public void setTechnicians(List<String> technicians) {
        this.technicians = technicians;
    }

    public List<String> getTechnicians() {
        return technicians;
    }
    
    public void setGoAhead(Boolean goAhead) {
        this.goAhead = goAhead;
    }
    
    public Boolean getGoAhead() {
        return goAhead;
    }
    
    public void setViolationPenalty(Double violationPenalty) {
        this.violationPenalty = violationPenalty;
    }
    
    public Double getViolationPenalty() {
        return violationPenalty;
    }
    
    global String getDateOrCost(){
        return dateOrCost;
    }
    
    public void setDateOrCost(String dateOrCost) {
        this.dateOrCost = dateOrCost;
    }
    
    public void setTerritoryTimeZone(String territoryTimeZone) {
        this.territoryTimeZone = territoryTimeZone;
    }
    
    public String getTerritoryTimeZone() {
        return territoryTimeZone;
    }
    
    public void setSlotCategoryCost(Double slotCategoryCost) {
        this.slotCategoryCost = slotCategoryCost;
    }
    
    public Double getSlotCategoryCost() {
        return slotCategoryCost;
    }   
    
    
    public void setSlotCategory(String slotCategory) {
        this.slotCategory = slotCategory;
    }
    
    public String getSlotCategory() {
        return slotCategory;
    }
    
    
    global Integer compareTo( Object compareTo ) {
        if( compareTo != null && compareTo instanceof WSCH_Appointment) {
            WSCH_Appointment appointmentResponse = (WSCH_Appointment) compareTo;
            if( appointmentResponse != this ) {
                if(!String.isEmpty(sortBy) && 'Date'.equalsIgnoreCase(sortBy)){
                    if (startDateTime == appointmentResponse.startDateTime) return 0;
                    if (startDateTime > appointmentResponse.startDateTime) return 1;
                    return -1;
                }else if(!String.isEmpty(sortBy) && 'Cost'.equalsIgnoreCase(sortBy)){
                    if (slotCost == appointmentResponse.slotCost) return 0;
                    if (slotCost > appointmentResponse.slotCost) return 1;
                    return -1;
                }
            }
            return 0;
        }
        return -1;
    }
}