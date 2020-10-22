import {
  CREAT_EVENT,
  CREAT_EVENT_FOR_TREE,
  CREAT_LJS_EVENT,
  CREAT_EVENT_ERROR,
  FETCH_WO_EVENT_INFO,
  GET_EVENTS,
  GET_EVENT_HOVER_RULES,
  EVENTS_REQUESTED,
  KEY_CREAT_EVENT,
  KEY_UPDATE_EVENT,
  EVENTS_LOADED,
  EVENTS_API_ERRORED,
  EVENTS_HOVER_REQUESTED,
  EVENTS_HOVER_LOADED,
  EVENT_BUSINESS_HOUR_LOADED,
  EVENT_BUSINESS_HOUR_REQUESTED,
  EVENT_BUSINESS_HOUR_ERRORED,
  EVENTS_HOVER_API_ERRORED,
  EVENTS_LOADING_COMPLETE,
  API_NOT_INVOKED,
  API_INVOKED,
  API_DATA_LOADED,
  API_ERRORED,
  KEY_EVENTS,
  START_EVENTS_AFTER_LAUNCH,
  UPDATE_EVENT,
  UPDATE_TECH_CHANGE_EVENT,
  FILTER_WORKORDER_EVENTS,
  GET_WORKORDER_EVENTS,
  KEY_EVENT_BUSINESS_HOUR,
  GET_EVENT_BUSINESS_HOUR,
  WORKORDER_EVENTS_LOADED,
  WORKORDER_EVENTS_REQUESTED,
  WORKORDER_EVENTS_ERRORED,
  GET_EVENT_SUBJECT,
  EVENT_SUBJECT_REQUESTED,
  EVENT_SUBJECT_LOADED,
  EVENT_SUBJECT_ERRORED,
  SCHEDULE_MULTIPLE_EVENTS,
  REMOVE_WORKORDER_EVENTS,
  KEY_WORKORDER_EVENTS,
  KEY_EVENT_SUBJECT,
  MULTIASSIGN_EVENTS_REQUESTED,
  MULTIASSIGN_EVENTS_COMPLETED,
  MULTIASSIGN_EVENTS_ERRORED,
  MULTIASSIGN_EVENTS_UPDATED,
  TECHNICIAN_SCHEDULING_ERROR,
  MAP_TECHWO_LOCATION_ERROR,
  STATUS_DATA_CLEAR,
  FETCH_DELTA_EVENTS,
  EVENTS_FETCH_DELTA_EVENTS,
  EVENTS_LAST_MODIFIED_EVENT,
  DELETE_DELTA_EVENTS,
  KEY_FETCH_DELTA_EVENTS,
  GET_EVENT_IDS_REQUESTED,
  LOAD_EVENT_IDS_REQUESTED,
  GET_EVENT_IDS_LOADED,
  LOAD_EVENT_IDS_COMPLETE,
  LOAD_WIDE_RANGE_EVENTS,
  SERACH_MMA_TECHNICIAN
} from "constants/ActionConstants";
import { HTTP_OK, SERVER_ERROR } from "constants/ServiceConstants";

export function multiAssignActions() {
  return {
    cleanEventStore: keys => ({ keys, type: REMOVE_WORKORDER_EVENTS }),
    searchTechnicians: config => ({ ...config, type: SERACH_MMA_TECHNICIAN }),
    getEventSubjectDefn: woId => ({
      key: KEY_EVENT_SUBJECT,
      payload: woId,
      type: GET_EVENT_SUBJECT
    }),
    getWorkorderEvents: woId => ({
      key: KEY_WORKORDER_EVENTS,
      type: GET_WORKORDER_EVENTS,
      woId
    }),
    scheduleMultipleEvents: (
      editEvent,
      events,
      subject,
      editFields,
      deletedEvents,
      ownerId
    ) => ({
      deletedEvents,
      editEvent,
      editFields,
      events,
      ownerId,
      subject,
      type: SCHEDULE_MULTIPLE_EVENTS
    })
  };
}
export function eventActions() {
  return {
    cleanEventStore: keys => ({ keys, type: REMOVE_WORKORDER_EVENTS }),
    createEventCall: (callback, payload) => ({
      callback,
      key: KEY_CREAT_EVENT,
      payload,
      type: CREAT_EVENT
    }),
    createEventForTreeCall: (callback, payload) => ({
      callback,
      key: KEY_CREAT_EVENT,
      payload,
      type: CREAT_EVENT_FOR_TREE
    }),
    createLJSeventCall: (callback, payload, isCalculateEndTime) => ({
      callback,
      isCalculateEndTime,
      key: KEY_CREAT_EVENT,
      payload,
      type: CREAT_LJS_EVENT
    }),
    createMapError: (data, message) => ({
      data,
      message,
      type: MAP_TECHWO_LOCATION_ERROR
    }),
    createSchedulingError: message => ({
      message,
      type: TECHNICIAN_SCHEDULING_ERROR
    }),
    eventsRefreshed: message => ({
      message,
      type: EVENTS_LOADING_COMPLETE
    }),
    fetchEventWoInfoCall: (callback, payload) => ({
      callback,
      key: KEY_CREAT_EVENT,
      payload,
      type: FETCH_WO_EVENT_INFO
    }),
    getEventBusinessHour: (callback, payload, isBasicWH) => ({
      callback,
      key: KEY_EVENT_BUSINESS_HOUR,
      payload,
      isBasicWH,
      type: GET_EVENT_BUSINESS_HOUR
    }),
    getEventSubjectCall: (woId, callback) => ({
      callback,
      key: KEY_EVENT_SUBJECT,
      payload: woId,
      type: GET_EVENT_SUBJECT
    }),
    startEventCall: (callback, techniciansIds, isEventRefresh) => ({
      callback,
      isEventRefresh,
      key: KEY_EVENTS,
      techniciansIds,
      // type: START_EVENTS_AFTER_LAUNCH
      type: LOAD_WIDE_RANGE_EVENTS
    }),
    startFilterEvents: (workOrders, projectView) => ({
      type: FILTER_WORKORDER_EVENTS,
      workOrders,
      projectView
    }),
    statusBarClearTxt: message => ({
      message,
      type: STATUS_DATA_CLEAR
    }),
    updateEvent: (callback, payload) => ({
      callback,
      key: KEY_UPDATE_EVENT,
      payload,
      type: UPDATE_EVENT
    }),
    updateEventOnTechChange: (callback, payload) => ({
      callback,
      key: KEY_UPDATE_EVENT,
      payload,
      type: UPDATE_TECH_CHANGE_EVENT
    }),
    fetchDeltaEvents: payload => ({
      payload,
      type: FETCH_DELTA_EVENTS
    }),
    deleteDeltaEvents: () => ({
      type: DELETE_DELTA_EVENTS,
      key: KEY_FETCH_DELTA_EVENTS
    })
  };
}

export function reducer(state = null, action) {
  const { count, data, key, keys, type, id, request } = action;
  switch (type) {
    case GET_EVENTS:
    case GET_EVENT_SUBJECT:
    case GET_WORKORDER_EVENTS:
    case GET_EVENT_HOVER_RULES:
      return { ...state, [key]: { status: { api: API_NOT_INVOKED } } };

    case EVENTS_REQUESTED:
    case WORKORDER_EVENTS_REQUESTED:
    case EVENT_SUBJECT_REQUESTED:
    case EVENTS_HOVER_REQUESTED:
    case MULTIASSIGN_EVENTS_REQUESTED:
    case EVENT_BUSINESS_HOUR_REQUESTED:
      return { ...state, [key]: { status: { api: API_INVOKED } } };

    case GET_EVENT_IDS_REQUESTED:
    case LOAD_EVENT_IDS_REQUESTED:
      const newState1 = { ...state };
      let content = newState1[key];
      if (request) {
        const { id } = request;
        if (!content) {
          content = {};
        }
        const { pendingRequests = {} } = content;
        pendingRequests[id] = request;
        content.pendingRequests = pendingRequests;
      }
      return { ...state, [key]: { ...content, status: { api: API_INVOKED } } };

    case GET_EVENT_IDS_LOADED:
    case LOAD_EVENT_IDS_COMPLETE:
      const newState2 = { ...state };
      const content1 = newState2[key];
      if (id) {
        const { total = 0 } = content1;
        content1.total = total + count;
        const { pendingRequests = {} } = content1;
        delete pendingRequests[id];
      }
      return {
        ...state,
        [key]: {
          ...content1,
          data,
          status: { api: API_DATA_LOADED, code: HTTP_OK }
        }
      };

    case EVENTS_LOADED:
    case EVENTS_HOVER_LOADED:
    case EVENT_SUBJECT_LOADED:
    case WORKORDER_EVENTS_LOADED:
    case MULTIASSIGN_EVENTS_UPDATED:
    case MULTIASSIGN_EVENTS_COMPLETED:
    case EVENT_BUSINESS_HOUR_LOADED:
      return {
        ...state,
        [key]: { data, status: { api: API_DATA_LOADED, code: HTTP_OK } }
      };

    case REMOVE_WORKORDER_EVENTS:
      const newState = { ...state };
      if (keys && keys.length) {
        keys.map(key1 => {
          delete newState[key1];
          return undefined;
        });
      }
      return newState;

    case CREAT_EVENT_ERROR:
    case EVENTS_API_ERRORED:
    case WORKORDER_EVENTS_ERRORED:
    case EVENT_SUBJECT_ERRORED:
    case EVENTS_HOVER_API_ERRORED:
    case MULTIASSIGN_EVENTS_ERRORED:
    case EVENT_BUSINESS_HOUR_ERRORED:
      return {
        ...state,
        [key]: {
          status: {
            api: API_ERRORED,
            code: SERVER_ERROR,
            error: data,
            message: data.message
          }
        }
      };

    case EVENTS_FETCH_DELTA_EVENTS:
      return {
        ...state,
        [key]: {
          events: data,
          status: { api: API_DATA_LOADED, code: HTTP_OK }
        }
      };
    case EVENTS_LAST_MODIFIED_EVENT:
      return {
        ...state,
        [key]: {
          event: data,
          status: { api: API_DATA_LOADED, code: HTTP_OK }
        }
      };
    case DELETE_DELTA_EVENTS:
      return {
        ...state,
        [key]: {
          events: {}
        }
      };
    default:
      return state;
  }
}
