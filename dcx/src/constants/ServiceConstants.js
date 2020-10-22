export const HTTP_POST = "POST";
export const HTTP_GET = "GET";
export const HTTP_DELETE = "DELETE";
export const HTTP_PUT = "PUT";

export const HTTP_OK = 200;
export const SERVER_ERROR = 500;

export const HTTP_ACCEPT = "Accept";
export const APPLICATION_JSON = "application/json";
export const CONTENT_TYPE = "Content-Type";
export const ACCEPT_ENCODING = "Accept-Encoding";
export const GZIP_DEFLATE_BR = "gzip, deflate, br";
export const APPLICATION_JSON_UTF8 = "application/json; charset=UTF-8";
export const SFORCE_QUERY_OPTIONS = "sforce-query-options";
export const BATCH_SIZE = "batchSize";

export const DISPLAY_TAGS_ENDPOINT = "/getTags";
export const APP_SETTINGS_ENDPOINT = "/fetchDCXSetting";
export const USER_SETTINGS_ENDPOINT = "/fetchUserSettings";
export const SAVE_USER_SETTINGS_ENDPOINT = "/saveUserSettings";
export const TECHNICIAN_SKILLS_ENDPOINT = "/getSkills";
export const WO_MATCHING_TECH_SKILLS_ENDPOINT = "/MCTMDetail";
export const ADVANCED_TECHNICIAN_SEARCH_ENDPOINT = "/getQualifiedTechList";
export const ADVANCED_TECHNICIAN_ENDPOINT = "/advTechSearch";
export const META_DATA_ENDPOINT = "/metaData";

export const WORK_ORDER_ENDPOINT = "/singleWODetails";
export const PAGINATION_WORK_ORDERS_ENDPOINT = "/pageOfWorkOrders";
export const VIEW_WORKORDER_COUNT_ENDPOINT = "/getViewWOCount";
export const VIEW_DEFINITION_ENDPOINT = "/getViewDefinition";
export const MAP_VIEW_DATA_ENDPOINT = "/getViewData";
export const LOCALDATE_ENDPOINT = "/DCON_GetLocalDate_WS";

// Scheduler
export const TECHNICIANS_ENDPOINT = "/schedulerDataNew";
export const TECHNICIANS_DETAILS = "/technicianDetails";
export const TECHNICIANS_WORKING_HOURS_ENDPOINT = "/getTechWorkingHours";
// export const GET_EVENTS_AFTER_LAUNCH = '/eventData';
export const GET_EVENTS_AFTER_LAUNCH = "/eventDataAndWOInfo";
export const GET_EVENTS_ON_LAUNCH = "/eventDataOnLaunch";
export const GET_EVENTS_HOVER_ON_LAUNCH = "/getEventHoverRules";
export const CREATE_EVENT = "/createEvents";
export const CREATE_EVENT_FOR_TECH = "/assignWOTech";
export const CREATE_EVENT_FOR_TEAM = "/assignWOTeam";
export const CREAT_LJS_EVENT = "/createLJSEvent";
export const FETCH_EVENT_WO_INFO = "/fetchEventWorkOrderInfo";
export const FETCH_DELTA_EVENTS = "/deltaEvents";

export const UPDATE_EVENT = "/unassignWOTOMutliTech";
export const UPDATE_EVENT_ON_TECH_CHANGE = "/unassignWOTOMutliTech";
export const GET_LIST_OF_TECH_SCHEDULED_ENDPOINT = "/getListOfTechScheduled";
export const GET_ALL_WORKORDER_EVENTS_ENDPOINT = "/fetchAllEvents";
export const GET_WORKORDER_EVENTS_ENDPOINT = "/fetchWorkOrderEvents";
export const GET_EVENT_SUBJECT_ENDPOINT = "/eventSubjectDefinition";
export const SCHEDULE_MULTIPLE_EVENTS_ENDPOINT = "/getWOforMutliAssign";
export const GET_EVENT_BUSINESS_HOUR_ENDPOINT = "/fetchEventWarnings";
export const GET_WO_DEPENDENCY_DETAILS = "/DCON_WO_Get_Dependency_Details_WS";

export const FETCH_EVENT_IDS_ENDPOINT = "/fetchEventIds";
export const EVENTDATA_WOINFO_IDS_ENDPOINT = "/eventDataAndWOInfoForIds";
export const EVENTDATA_IDS_ENDPOINT = "/retrieveEventForIds";
export const WOINFO_IDS_ENDPOINT = "/retrieveWOForIds";

export const UNASSIGN_WO = "/unassignWO";
export const DELETE_EVENTS = "/deleteEvents";
export const DELETE_JDM_EVENTS = "/deleteAESEvent";

// Scheduler Filter
export const GET_SEARCH_TECH = "/keywordSearch";
export const GET_DELTA_WORK_ORDER = "/retrieveWOForIds";

// Deploy Usersettings
export const GET_DISPATCHER_LIST = "/listDispatcher";
export const POST_DEPLOY_USER_SETTINGS = "/deployUserSetting";

// Reset User Settings
export const RESTORE_USER_SETTINGS_ENDPOINT = "/restoreUserSetting";
