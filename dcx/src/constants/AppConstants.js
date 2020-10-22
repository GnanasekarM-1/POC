let DEFAULT_NAMESPACE = "SVMXDEV";
if (!(window.configData && window.configData.namespace)) {
  require("dotenv").config({ path: ".env.development" });
  const env = process.env;
  DEFAULT_NAMESPACE = env.REACT_APP_SFDC_ORG_NAMESPACE;
}
export const Title = "ServiceMax Dispatch Console";
export const LFSettings = "Loading Configuration";
export const LUISettings = "Loading User Preferences";
export const LWO = "Loading WorkOrders";
export const LTeam = "Loading Teams & Territories";
export const LTech = "Loading Technicians";
export const LEvent = "Loading Calendar Events";
export const FALSE = "False";
export const REQUEST_PASS = true;
export const REQUEST_FAIL = false;
export const USE_PAGINATION = true;
export const FIELD_WO_VIEW_TYPE = "woViewType";
export const DEFAULT_SORT_ORDER = "asc";
export const DESC_SORT_ORDER = "desc";
export const DEFAULT_SORT_BY = "Name";
export const DEFAULT_LOCALE = "en_US";
export const STATUS_NEW = "NEW";
export const STATUS_QUEUED = "QUEUED";

export const FIELD_VALUE = "Value";
export const FIELD_VALUE_VIEW = "VIEW";

export const TIME_FIELD_TYPE = "TIME";
export const DATE_FIELD_TYPE = "DATE";
export const DATETIME_FIELD_TYPE = "DATETIME";
export const BOOLEAN_FIELD_TYPE = "BOOLEAN";

export const HOURS = "Hours";
export const DURATION = "Duration";
export const AM = "AM";
export const PM = "PM";

export const MAX_RETRY_ATTEMPT = 3;
export const HTTP_CONCURRENT_REQUEST = 6;
export const WIDE_RANGE_EVENT_BATCH = 1500;
export const WIDE_RANGE_REFRESH_DURATION = 365;
export const WIDE_RANGE_TECHNICIAN_BATCH = 500;
export const APPLY_TECHNICIAN_BATCH_FOR_WIDE_RANGE = true;

export const PROPERTY_PICKLIST = "property-picklist";
export const EXPRESSION_PICKLIST = "expression-picklist";
export const EXPRESSION_INPUT = "expression-input";
export const CLOSE = "close";
export const RULE_EXPRESSIONS = "rule-expressions";
export const DISPLAY = "display";
export const VIEW_PICKLIST_1 = "view-picklist-1";
export const VIEW_PICKLIST_2 = "view-picklist-2";
export const VIEW_PICKLIST_3 = "view-picklist-3";
export const NONE = "None";
export const SUPER_DISPATCHER = "Super Dispatcher";
export const HOVER_COLOR = "Hovered Color";
export const SELECTION_COLOR = "Selection Color";

export const REFRESH = "Refresh";
export const DATE_UNCHANGE = "DateUnChange";
export const END_TIME_CHANGE = "EndTimeChange";
export const END_TIME_CHANGE_WITH_DRIVE = "EndTimeChangeWithDrive";
export const SHOW_MARKER = "ShowMarker";
export const HIGHLIGHT_TECH_COLOR = "HighlightTechColor";
export const MARKER_COLOR = "MarkerColor";

/* const for workorder color rules */
export const STATUS_ACTIVE = "activ";
export const STATUS_INACTIVE = "inactiv";
export const CONDITION_LESS = "less";
export const CONDITION_MATCHES = "matches";
export const CONDITION_MATCHES_NOT = "!matches";
export const CONDITION_GREATER = "greater";
export const CONDITION_GE = "ge";
export const CONDITION_LE = "le";
export const CONDITION_NULL = "null";
export const CONDITION_NOT_NULL = "!null";
export const CONDITION_CONTAINS = "con";
export const CONDITION_CONTAINS_NOT = "!con";
export const CONDITION_IN = "in";
export const CONDITION_NOT_IN = "!in";
export const CONDITION_STARTS_WITH = "sw";

/* const for const technican view */
export const CONFIGURE_TECH_VIEW = "Configure Technican View";
export const CONFIGURE_TECH_TEAM_SEARCH =
  "Configure Technican and Team Search View";

export const ID = "Id";
export const NAME = "Name";
export const NAME1 = "name";
export const WO_EXP_TYPE = "WO";
export const EVENT_EXP_TYPE = "EVENT";
export const PARENT_ID = "parentId";
export const REFERENCE = "REFERENCE";
export const PICKLIST = "PICKLIST";
export const DELETED_EVENT_IDS = "DELETED_EVENT_IDS";
export const MAX_AUTO_REFRESH_DURATION_IN_MINUTES = 15;
export const ARRAY_TO_TREE_CONFIG = { customID: ID, parentProperty: PARENT_ID };

export const OWNER = "Owner";
export const OWNERID = "OwnerId";
export const IS_ACTIVE = "IsActive";
export const CREATEDBY = "CreatedBy";
export const CREATEDBYID = "CreatedById";
export const LASTMODIFIEDBY = "LastModifiedBy";
export const LASTMODIFIEDBYID = "LastModifiedById";
export const DEFAULT_TIME_FORMAT = "yyyy/MM/dd+H:mm";

export const HTTP_FORBIDDIN = 403;
export const HTTP_UNAUTHORIZED = 401;
export const INVALID_SESSION_ID = "INVALID_SESSION_ID";
export const ONUNDERSCHEDULING = "OnUnderScheduling";

const namespace = window.configData && window.configData.namespace;
export const ORG_NAMESPACE = namespace || DEFAULT_NAMESPACE || "SVMXC";
// export const ORG_NAMESPACE = 'SVMXC';
export const WORKORDER_API_NAME = `${ORG_NAMESPACE}__Service_Order__c`;
export const TECHNICIAN_API_NAME = `${ORG_NAMESPACE}__Service_Group_Members__c`;
export const TECHNICIAN_API_REF = `${ORG_NAMESPACE}__Service_Group_Members__r`;
export const WORKORDER_TECHNICIAN_API_NAME = `${ORG_NAMESPACE}__Group_Member__c`;
export const WORKORDER_TECHNICIAN_API_REF = `${ORG_NAMESPACE}__Group_Member__r`;
export const TEAM_API_NAME = `${ORG_NAMESPACE}__Service_Group__c`;
export const TEAM_API_REF = `${ORG_NAMESPACE}__Service_Group__r`;
export const PARENT_TERRITORY_API_NAME = `${ORG_NAMESPACE}__Parent_Territory__c`;
export const TERRITORY_API_NAME = `${ORG_NAMESPACE}__Service_Territory__c`;
export const TERRITORY_PARENT = `${ORG_NAMESPACE}__Parent_Territory__c`;
export const TERRITORY_API_REF = `${ORG_NAMESPACE}__Service_Territory__r`;
export const QUALIFIED_TECHNICIANS_API_REF = `${ORG_NAMESPACE}__Qualified_Technicians__c`;
export const EVENT_API_NAME = `${ORG_NAMESPACE}__SVMX_Event__c`;
export const ACCOUNT_API_NAME = "Account";
export const LOCATION_API_NAME = `${ORG_NAMESPACE}__Site__c`;
export const TECH_LATITUDE_PROPERTY = `${ORG_NAMESPACE}__Latitude__c`;
export const TECH_LONGITUDE_PROPERTY = `${ORG_NAMESPACE}__Longitude__c`;
export const TECH_HOME_LATITUDE_PROPERTY = `${ORG_NAMESPACE}__Latitude_Home__c`;
export const TECH_HOME_LONGITUDE_PROPERTY = `${ORG_NAMESPACE}__Longitude_Home__c`;

export const STREET_PROPERTY = `${ORG_NAMESPACE}__Street__c`;
export const CITY_PROPERTY = `${ORG_NAMESPACE}__City__c`;
export const STATE_PROPERTY = `${ORG_NAMESPACE}__State__c`;
export const ZIP_PROPERTY = `${ORG_NAMESPACE}__Zip__c`;
export const COUNTRY_PROPERTY = `${ORG_NAMESPACE}__Country__c`;
export const ADDRESS_FIELDS = [
  STREET_PROPERTY,
  CITY_PROPERTY,
  STATE_PROPERTY,
  ZIP_PROPERTY,
  COUNTRY_PROPERTY
];

export const WO_PRODUCT_PROPERTY = `${ORG_NAMESPACE}__Product__r`;

// WO field names ;
export const WO_PREFERRED_START_TIME = `${ORG_NAMESPACE}__Preferred_Start_Time__c`;
export const WO_SCHEDULING_OPTIONS = `${ORG_NAMESPACE}__SM_Scheduling_Options__c`;
export const WO_UNSCHEDULED_DURATIONS = `${ORG_NAMESPACE}__SM_Unscheduled_Duration__c`;
export const WO_ESTIMATED_DURATION_FIELD = `${ORG_NAMESPACE}__SM_Estimated_Duration__c`;
export const WO_SCOPE_CHANGE_FIELD = `${ORG_NAMESPACE}__SM_Scope_Change__c`;
export const WO_VARIANCE_FIELD = `${ORG_NAMESPACE}__SM_Variance__c`;
export const WO_REVISED_DURATION_FIELD = `${ORG_NAMESPACE}__SM_Revised_Duration__c`;
export const WO_ONSITE_RESPONCE_CUSTOMER_BY_FIELD = `${ORG_NAMESPACE}__Onsite_Response_Customer_By__c`;
export const WO_RESTRORATION_CUSTOMER_BY_FIELD = `${ORG_NAMESPACE}__Restoration_Customer_By__c`;
export const WO_RESOLUTION_CUSTOMER_BY_FIELD = `${ORG_NAMESPACE}__Resolution_Customer_By__c`;
export const WO_ONSITE_RESPONCE_INTERNAL_BY_FIELD = `${ORG_NAMESPACE}__Onsite_Response_Internal_By__c`;
export const WO_RESTRORATION_INTERNAL_BY_FIELD = `${ORG_NAMESPACE}__Restoration_Internal_By__c`;
export const WO_RESOLUTION_INTERNAL_BY_FIELD = `${ORG_NAMESPACE}__Resolution_Internal_By__c`;

export const WO_SERVICE_DURATION_FIELD = `${ORG_NAMESPACE}__Service_Duration__c`;
export const WO_OVERHEAD_TIME_BEFORE_FIELD = `${ORG_NAMESPACE}__Overhead_Time_Before__c`;
export const WO_OVERHEAD_TIME_AFTER_FIELD = `${ORG_NAMESPACE}__Overhead_Time_After__c`;
export const WO_BREAK_TIME_FIELD = `${ORG_NAMESPACE}__Break_Time_Total__c`;
export const WO_DRIVING_TIME_FIELD = `${ORG_NAMESPACE}__Driving_Time__c`;
export const WO_DISPATCH_STATUS_FIELD = `${ORG_NAMESPACE}__Dispatch_Status__c`;
export const WO_DRIVING_TIME_HOME_FIELD = `${ORG_NAMESPACE}__Driving_Time_Home__c`;
export const WO_VIOLATION_MESSAGE = `${ORG_NAMESPACE}__Violation_Message__c`;
export const WO_VIOLATION_STATUS = `${ORG_NAMESPACE}__Violation_Status2__c`;
export const WO_IDLE_TIME_FIELD = `${ORG_NAMESPACE}__Idle_Time__c`;
export const WO_MINIMUM_SCHEDULE_DURATION_FIELD = `${ORG_NAMESPACE}__SM_LJS_Minimum_Schedule_Duration__c`;
export const WO_PREFERRED_BUSINESS_HOURS_FIELD = `${ORG_NAMESPACE}__Preferred_Business_Hours__c`;
export const WO_SCHEDULED_DURATION_FIELD = `${ORG_NAMESPACE}__SM_Scheduled_Duration__c`;
export const TECH_ENABLE_SCHEDULING_FIELD = `${ORG_NAMESPACE}__Enable_Scheduling__c`;

// technician field
export const TECH_SALESFORCE_USER_FIELD = `${ORG_NAMESPACE}__Salesforce_User__c`;
export const TECH_SALESFORCE_USER_INFO = `${ORG_NAMESPACE}__Salesforce_User__r`;
export const WO_SCHEDULED_DATE_FIELD = `${ORG_NAMESPACE}__Scheduled_Date__c`;
export const WO_SCHEDULED_DATE_TIME_FIELD = `${ORG_NAMESPACE}__Scheduled_Date_Time__c`;

export const KEY = "key";
export const VALUE = "value";
export const DEFAULT_VALUE = "defaultValue";

export const MANAGE_MULTIPLE_ASSIGNMENTS = 1;
export const SHOW_RECORD = 2;
export const UNASSIGN_THIS_WORK_ORDER = 3;
export const RANKED_APPOINTMENT_BOOKING = 4;
export const VIOLATION_VIEW_WORK_ORDER = 5;

export const VIOLATION_VIEW_WORK_ORDER_STATUS = "Constraint Violation";

/* const for Scheduler */
export const DEFAULT_TEAM = "Team";
export const SCHEDULER_DEFAULT_VIEW = "teamView";
export const DEFAULT_TERRITORY = "";
export const TEAM_INDEX = 0;
export const TERRITORY_INDEX = 1;

export const MULTI_ASSIGN_EVENT_UPDATE = -7;
export const TERRITORY_SEQUENCE_CHANGED = -4;
export const TEAM_SEQUENCE_CHANGED = -3;
export const TECHNICIAN_COLUMN_ADDED = -2;
export const INITIAL_TREE_DATA = -1;
export const DEFAULT_TREE_DATA = 0;
export const TECH_SEARCH_RESULT = 1;
export const TEAM_SEARCH_RESULT = 2;
export const ADV_SEARCH_RESULT = 3;
export const FILTER_TECHNICIAN_RESULT = 4;
export const FILTER_EVENTS_RESULT = 5;
export const FILTER_RESULTS = [FILTER_TECHNICIAN_RESULT, FILTER_EVENTS_RESULT];
export const SCHEDULER_SETTINGS_UPDATED = 6;

export const DEFAULT_CANCEL = "Cancel";
export const DEFAULT_DONE = "Done";

export const ERROR_TYPE = "error";
export const WARNING_TYPE = "warning";
export const INFO_TYPE = "info";
export const PROGRESS_TYPE = "progress";
export const CLEAR_TYPE = "clear";

export const TYPE_NEUTRAL_GRAY = "neutral-gray";
export const DISPLAY_SIZE_SMALL = "small";
export const EVENT_KEY_1 = "1";
export const EVENT_KEY_2 = "2";
export const EVENT_KEY_3 = "3";
export const SEARCH_NONE = "None";
export const SEARCH_TEAM = "Team";
export const SEARCH_TECH = "Technician";
export const TEAM_KEYWORD = "Team";
export const TECH_KEYWORD = "Technician";
export const SEARCH_KEYWORD = "search_keyword";

export const COLLAPSE_ALL = "Collapse All";
export const EXPAND_ALL = "Expand All";
export const LAST_SAVED = "Last saved";
export const RESET_LABEL = "Reset";
export const MAP_CONFIG = "tech_dcmap";

export const LST_SKILL = "lstSkill";
export const SKILLS_ENABLED = "isSkillsEnabled";
export const PRODUCT_EXPERTISE = "productExpertise";
export const PRODUCT_EXPERTISE_ENABLED = "isproductExpertiseEnabled";
export const LST_ELIGIBILITY = "lstEligibility";
export const ELIGIBILITY_ENABLED = "isEligibilityEnabled";
export const PREFERRED_TECH_ENABLED = "isPreferredTechEnabled";
export const PREFERRED_TECH_LIST = "preferredTechList";

export const JDM_LJS_ENABLED = "JDM and LJS Enabled";
export const JDM_ENABLED_LJS_DISABELD = "JDM Enabled, LJS Disabled";
export const ALL_OPTION_DISABLED = "All options disabled";
export const CUSTOMER_COMMITMENT = "Customer Commitment";
export const DISABLED = "Disabled";
export const ENABLED = "Enabled";
export const EVENT_START_TIME = "08:00 AM";
export const MULTI_ASSIGN_READ_ONLY = [
  ENABLED,
  JDM_LJS_ENABLED,
  JDM_ENABLED_LJS_DISABELD
];

export const RESET_DEFAULT_SETTINGS = "Reset to Default Settings";
export const DEPLOY_SETTINGS = "Deploy UI Settings";
export const LOGGED_IN = "You are logged in as";

export const START_DATE_TIME = "START_DATE_TIME";
export const END_DATE_TIME = "END_DATE_TIME";
export const SERVICE_TIME_DURATION = "SERVICE_TIME_DURATION";
export const DRIVE_TIME_START = "DRIVE_TIME_START";
export const DRIVE_TIME_END = "DRIVE_TIME_END";
export const OVERHEAD_TIME_START = "OVERHEAD_TIME_START";
export const OVERHEAD_TIME_END = "OVERHEAD_TIME_END";
export const BUSINESS_HOUR_ALLOW = "Allow";
export const BUSINESS_HOUR_RESTRICT = "Disallow";
export const BUSINESS_HOUR_WARN = "Warn";
export const MACHINE_HOUR_ALLOW = "Allow";
export const MACHINE_HOUR_RESTRICT = "Disallow";
export const MACHINE_HOUR_WARN = "Warn";
export const DOUBLE_BOOKING_ALLOW = "Allow";

export const ASK_USER = "Ask User";
export const SHOW_PROJECT_VIEW =
  "List as the only work order & Show Project View";
export const LIST_WO = "Just list as the only work order";
export const DO_NOTHING = "Do not list as the only work order";
export const SALESFORCE_EVENT = "Salesforce Event";

// Hardcoded Labels
export const GLOB001_GBL025_ERROR =
  "An event cant last longer than 14 days duration";
export const DELETING_IN_PROGRESS = "Deleting...";
export const ASSIGNING_IN_PROGRESS = "Assigning...";
export const EXPAND_TEAM_TERRITORY =
  "Please expand at least one service team or territory to view the events";
export const MANAGE_MULTIPLE_ASSIGN_DISABLED =
  "Manage Multiple Assignment has been disabled due to JDM/LJS being enabled at workorder or group or org Settings";
export const EMPTY_TECHNICIAN_LIST =
  "Technician list is empty for selected Team/Territory";
export const CONTINUE_WITHOUT_ADDING =
  "Do you want to continue without adding them ?";
