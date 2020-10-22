import {
  CREATE_EVENT,
  CREATE_EVENT_FOR_TEAM,
  CREATE_EVENT_FOR_TECH,
  CREAT_LJS_EVENT,
  FETCH_EVENT_WO_INFO,
  HTTP_GET,
  GET_EVENTS_AFTER_LAUNCH,
  GET_EVENTS_ON_LAUNCH,
  GET_EVENT_SUBJECT_ENDPOINT,
  GET_EVENTS_HOVER_ON_LAUNCH,
  HTTP_POST,
  UPDATE_EVENT,
  UPDATE_EVENT_ON_TECH_CHANGE,
  UNASSIGN_WO,
  DELETE_EVENTS,
  DELETE_JDM_EVENTS,
  GET_ALL_WORKORDER_EVENTS_ENDPOINT,
  GET_WORKORDER_EVENTS_ENDPOINT,
  SCHEDULE_MULTIPLE_EVENTS_ENDPOINT,
  GET_EVENT_BUSINESS_HOUR_ENDPOINT,
  FETCH_DELTA_EVENTS,
  FETCH_EVENT_IDS_ENDPOINT,
  EVENTDATA_WOINFO_IDS_ENDPOINT,
  EVENTDATA_IDS_ENDPOINT,
  WOINFO_IDS_ENDPOINT
} from "constants/ServiceConstants";
import fetchData from "./service";

const EventService = {};

EventService.getEventsOnlaunch = () => {
  const config = {
    method: HTTP_GET,
    url: GET_EVENTS_ON_LAUNCH
  };
  return fetchData(config);
};

EventService.getEventHoverOnlaunch = () => {
  const config = {
    method: HTTP_GET,
    url: GET_EVENTS_HOVER_ON_LAUNCH
  };
  return fetchData(config);
};

EventService.getEventBusinessHours = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: GET_EVENT_BUSINESS_HOUR_ENDPOINT
  };
  return fetchData(config);
};

EventService.getEventAfterLaunch = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: GET_EVENTS_AFTER_LAUNCH
  };
  return fetchData(config);
};

EventService.fetchDeltaEvents = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: FETCH_DELTA_EVENTS
  };
  return fetchData(config);
};

EventService.createNonWoEvent = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: CREATE_EVENT
  };
  return fetchData(config);
};

EventService.createEvent = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: CREATE_EVENT
  };
  return fetchData(config);
};

EventService.createEventForTree = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: payload.isTech ? CREATE_EVENT_FOR_TECH : CREATE_EVENT_FOR_TEAM
  };
  return fetchData(config);
};

EventService.createLJSEvent = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: CREAT_LJS_EVENT
  };
  return fetchData(config);
};

EventService.unAssignWO = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: UNASSIGN_WO
  };
  return fetchData(config);
};

EventService.fetchEventWoInfo = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: FETCH_EVENT_WO_INFO
  };
  return fetchData(config);
};

EventService.updateEvent = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: UPDATE_EVENT
  };
  return fetchData(config);
};

EventService.deleteEvents = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: DELETE_EVENTS
  };
  return fetchData(config);
};

EventService.deleteJDMEvents = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: DELETE_JDM_EVENTS
  };
  return fetchData(config);
};

EventService.updateEventOnTechChange = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: UPDATE_EVENT_ON_TECH_CHANGE
  };
  return fetchData(config);
};

EventService.fetchAllEvents = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: GET_ALL_WORKORDER_EVENTS_ENDPOINT
  };
  return fetchData(config);
};

EventService.getEventSubject = payload => {
  const config = {
    method: HTTP_GET,
    url: `${GET_EVENT_SUBJECT_ENDPOINT}?woId=${payload}`
  };
  return fetchData(config);
};

EventService.fetchWOEvents = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: GET_WORKORDER_EVENTS_ENDPOINT
  };
  return fetchData(config);
};

EventService.scheduleMultipleEvents = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: SCHEDULE_MULTIPLE_EVENTS_ENDPOINT
  };
  return fetchData(config);
};

EventService.fetchEventIds = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: FETCH_EVENT_IDS_ENDPOINT
  };
  return fetchData(config);
};

EventService.eventDataAndWOInfoForIds = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: EVENTDATA_WOINFO_IDS_ENDPOINT
  };
  return fetchData(config);
};

EventService.eventDataForIds = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: EVENTDATA_IDS_ENDPOINT
  };
  return fetchData(config);
};

EventService.woInfoDataForIds = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: WOINFO_IDS_ENDPOINT
  };
  return fetchData(config);
};

export default EventService;
