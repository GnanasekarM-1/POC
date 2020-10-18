public with sharing class DCX_CommonServiceManager {
    public class UserSetting {
        //values are strings
        public String wo_autorefresh {get; set;}
        public String wo_isAlldayEvent {get; set;}
        public String wo_isAdvMode {get; set;}
        public String wo_refreshtime {get; set;}
        public String wo_sortColumn {get; set;}
        public String wo_sortOrder {get; set;}
        public String wo_columnIndex {get; set;}
        public String wo_filterColumn {get; set;}
        public String wo_woHoverColor {get; set;}
        public String wo_defaultView {get; set;}
        public String wo_woSelectionColor {get; set;}
        public String wo_resetTime {get; set;}
        public String wo_unassignWO {get; set;}
        public String wo_deleteEventForTech {get; set;}
        public String wo_deleteEventWo {get; set;}
        public String wo_schedulingAsLongJob {get; set;}
        public String wo_respectTechnincianWorkHours {get; set;}
        public String wo_respectMachineAccessHours {get; set;}
        public String wo_doNotOverlapExistingEvents {get; set;}
        public List<Views> wo_views {get; set;}
        public List<ViewCounter> wo_viewCounter {get; set;}
        public List<WoCol> wo_woCol {get; set;}
        public List<WoRules> wo_woRules {get; set;}
        public String tech_view {get; set;}
        public String tech_enableGoogleMapApi {get; set;}
        public String tech_dcmap {get; set;}
        public String tech_mapDefaultZoomLevel {get; set;}
        public String tech_mapDefaultLat {get; set;}
        public String tech_mapDefaultLng {get; set;}
        public String tech_loglevel {get; set;}
        public String tech_noOfDays {get; set;}
        public String tech_condition {get; set;}
        public String tech_refreshEventsOnChange {get; set;}
        public String tech_retainDateOnShowRoute {get; set;}
        public String tech_autoCalculateEndDate {get; set;}
        public String tech_eventRowColor {get; set;}
        public String tech_driveColor {get; set;}
        public String tech_overheadColor {get; set;}
        public String tech_defaultEventColor {get; set;}
        public String tech_defaultWOEventColor {get; set;}
        public String tech_relatedEventColor {get; set;}
        public String tech_workingHoursColor {get; set;}
        public String tech_holidayHoursColor {get; set;}
        public String tech_overNightStayColor {get; set;}
        public String tech_viewAllEventsForToday {get; set;}
        public String tech_toolTipShowDelay {get; set;}
        public String tech_toolTipHideDelay {get; set;}
        public String tech_pinMapActionBar {get; set;}
        public String tech_showFieldUpdates {get; set;}
        public String tech_showTimeIndicator {get; set;}
        public String tech_timeIndicatorColor {get; set;}
        public String tech_autoSyncServiceDuration {get; set;}
        public String tech_locationBase {get; set;}
        public String tech_dataTipOnClick {get; set;}
        public String tech_showOptionMenu {get; set;}
        public String tech_showSkills {get; set;}
        public String tech_showProductExpertise {get; set;}
        public String tech_showEligibility {get; set;}
        public String tech_showPrefTech {get; set;}
        public String tech_searchSkills {get; set;}
        public String tech_searchProductExpertise {get; set;}
        public String tech_searchEligibility {get; set;}
        public String tech_searchPrefTech {get; set;}
        public String tech_favouriteTeam {get; set;}
        public List<String> tech_ExpandedTeam {get; set;}
        public String tech_favouriteTerritory {get; set;}
        public List<String> tech_expandedTerritory {get; set;}
        public AtsSkills adv_atsSkills {get; set;}
        public AtsExpertise adv_atsExpertise {get; set;}
        public AtsEligibility adv_atsEligibility {get; set;}
        public AtsPrefTech adv_atsPrefTech {get; set;}
        public List<String> tech_teamSequence {get; set;}
        public List<String> tech_territorySequence {get; set;}
        public List<TechCol> tech_techCol {get; set;}
        public List<TechRules> tech_techRules {get; set;}
        public Keyword search_keyword {get; set;}
        public TechKeyword search_techKeyword {get; set;}
        public TeamKeyword search_teamKeyword {get; set;}
        public String map_mapViewportWidth {get; set;}
        public List<String> wo_grid_conf_fields {get; set;}
        public List<String> wo_grid_col_fields {get; set;}
        public List<String> wo_sch_col_fields {get; set;} 
    }
    
    public class Views {
        public String name {get; set;}
        public String id {get; set;}
        public String column {get; set;}
        public String sortOrder {get; set;}
        public String columnIndex {get; set;}
    }
    
    public class ViewCounter {
        public String color {get; set;}
        public String name {get; set;}
        public String id {get; set;}
        public String column {get; set;}
        public String sortOrder {get; set;}
        public String columnIndex {get; set;}
    }
    
    public class  WoCol {
        public String name {get; set;}
        public String width {get; set;}
    }
    
    public class WoRules {
        public String name {get; set;}
        public String status {get; set;}
        public String expression {get; set;}
        public String color {get; set;}
        public List<Operand> operand {get; set;}
    }
    
    public class TechCol {
        public String name {get; set;}
        public String width {get; set;}
    }
    
    public class TechRules {
        public String name {get; set;}
        public String status {get; set;}
        public String expression {get; set;}
        public String color {get; set;}
        public String ruleType{get;set;}
        public List<Operand> operand {get; set;}
    }
    
    public class Operand {
        public String property {get; set;}
        public String type {get; set;}
        public String fieldType {get; set;}
        public String compare {get; set;}
        public String value {get; set;}
    }

    public class Keyword {
        public String matchcriteria {get; set;}
        public List<Col> col {get; set;}
    }
    
    public class TechKeyword {
        public String matchcriteria {get; set;}
        public List<Col> col {get; set;}
    }
    
    public class TeamKeyword {
        public String matchcriteria {get; set;}
        public List<Col> col {get; set;}
    }
    
    public class Col {
        public String name {get; set;}
        public String width {get; set;}
    }
    
    public class AtsSkills {
        public String show {get; set;}
        public String search {get; set;}
    }
    
    public class AtsExpertise {
        public String show {get; set;}
        public String search {get; set;}
    }
    
    public class AtsEligibility {
        public String show {get; set;}
        public String search {get; set;}
    }
    
    public class AtsPrefTech {
        public String show {get; set;}
        public String search {get; set;}
    }
    
    public class testSetting{
        public String autorefresh {get; set;}
        public String isAlldayEvent {get; set;}
        public String isAdvMode {get; set;}
    }

    public class DCEvent_WO_WP
    {
        public list<Events_WP> lstEvent;
        public dcx_wrapper.workorder_WP objWorkOrder;
        public String strWOAction;
        public List<String> deletedEventIds;
        public Map<String,String> settingvalues;
    }

    public class Events_WP {
        public DCEvent_WP event_WP {get;set;}
        public long lastSyncedTime;
        public boolean isEventThresholdMet {get; set;}
        public Events_WP(){}
        public Events_WP(DCEvent_WP e){
            event_WP = e;
        }
    }
    
    public class fetchAllEventsResp {
        public List<Events_WP> allEvents;
        public Map<Id,SVMXC__Service_Order__c> woInfoMap;
        
        public fetchAllEventsResp(){}
    }

    public class DCEvent_WP {
        public String id{get; set;}
        public String subject {get; set;}
        public String durationInMinutes {get; set;}
        public String description {get; set;}
        public String whatId {get; set;}
        public String whoId {get; set;}
        public String activityDate {get; set;}
        public String activityDateTime {get; set;}
        public String startDateTime {get; set;}
        public String endDateTime {get; set;}
        public String location {get; set;}
        public String ownerId {get; set;}
        public String TechId {get; set;}
        public Boolean isWorkOrder {get; set;}// To find is it WO event
        public String additionalInfo {get; set;}// Provides find is it WO event
        public DateTime lastModifiedDateTime {get; set;}
        public list<KeyValuePair_WP> lstKeyValuePair{get; set;}
        public list<string> EvntHovrAdditionalInfo{get; set;}

        // These below fields are being introduced or being moved from WO (2 fields)
        public String Driving_Time {get; set;}
        public String Overhead_Time_Before {get; set;}
        public String Overhead_Time_After {get; set;}
        public String Driving_Time_Home {get; set;}
        public String Service_Duration {get; set;} //from WO
        public String Break_Time_Total {get; set;} //from WO
        public String Type {get; set;}
        public boolean IsAllDayEvent {get; set;}
        public String latitude {get; set;}
        public String longitude {get; set;}
        public String techName{get; set;}
        public Boolean isDeleted{get; set;}
    }

    public class KeyValuePair_WP {
        public String keyType{get; set;}
        public String key{get; set;}
        public String value{get; set;}
        public KeyValuePair_WP(){}
        public KeyValuePair_WP(String keyType, String key, String value) {
            this.keyType = keyType;
            this.key = key;
            this.value = value;
        }   
    }

    public class DCxException extends Exception {
        
    }

}