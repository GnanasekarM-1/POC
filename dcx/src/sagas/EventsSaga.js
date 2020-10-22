import {
  delay,
  takeLatest,
  takeEvery,
  select,
  call,
  put,
  all
} from "redux-saga/effects";
import {
  omit,
  compact,
  cloneDeep,
  difference,
  orderBy,
  uniq,
  chunk,
  isEmpty,
  isUndefined,
  sum,
  isArray,
  groupBy,
  flatMap,
  uniqueId
} from "lodash";
import arrayToTree from "array-to-tree";
import moment from "moment";
import momentTimezone from "moment-timezone";
import {
  GET_WORKORDER_EVENTS,
  FILTER_WORKORDER_EVENTS,
  CREAT_EVENT,
  CREAT_EVENT_FOR_TREE,
  CREAT_LJS_EVENT,
  CREAT_EVENT_ERROR,
  ASSIGN_TO_TREE_REQUESTED,
  ASSIGN_TO_TREE_COMPLETED,
  ASSIGN_TO_TREE_ERRORED,
  GET_EVENTS,
  GET_EVENTS_AFTER_LAUNCH,
  GET_TECHNICIANS_WORKING_HOURS,
  GET_EVENT_BUSINESS_HOUR,
  KEY_CREAT_EVENT,
  KEY_EVENTS,
  KEY_TECHNICIAN_WORKING_HOURS,
  KEY_TECHNICIANS_WORKING_HOURS,
  KEY_UPDATE_EVENT,
  KEY_EVENTS_HOVER,
  KEY_EVENT_BUSINESS_HOUR,
  GET_EVENT_HOVER_RULES,
  START_EVENTS_AFTER_LAUNCH,
  EVENT_SAVING_COMPLETE,
  EVENTS_REQUESTED,
  EVENTS_LOADED,
  EVENTS_API_ERRORED,
  EVENTS_HOVER_REQUESTED,
  EVENTS_HOVER_LOADED,
  EVENTS_HOVER_API_ERRORED,
  EVENT_BUSINESS_HOUR_REQUESTED,
  EVENT_BUSINESS_HOUR_LOADED,
  EVENT_BUSINESS_HOUR_ERRORED,
  UPDATE_SCHEDULER_STATE,
  UPDATE_EVENT,
  UPDATE_TECH_CHANGE_EVENT,
  UPDATE_EVENT_ERROR,
  TECHNICIANS_WORKING_HOURS_REQUESTED,
  TECHNICIANS_WORKING_HOURS_LOADED,
  TECHNICIANS_WORKING_HOURS_API_ERRORED,
  KEY_WORKORDER_EVENTS,
  WORKORDER_EVENTS_LOADED,
  WORKORDER_EVENTS_REQUESTED,
  WORKORDER_EVENTS_ERRORED,
  KEY_EVENT_SUBJECT,
  GET_EVENT_SUBJECT,
  EVENT_SUBJECT_REQUESTED,
  EVENT_SUBJECT_LOADED,
  EVENT_SUBJECT_ERRORED,
  SCHEDULE_MULTIPLE_EVENTS,
  WO_UNASSIGN_NO,
  KEY_MULTIASSIGN_EVENTS,
  MULTIASSIGN_EVENTS_REQUESTED,
  MULTIASSIGN_EVENTS_COMPLETED,
  MULTIASSIGN_EVENTS_ERRORED,
  EXPAND_TEAM_AFTER_EVENT_REFRESH,
  EVENTS_LOADING_COMPLETE,
  EVENTS_LOADING_STARTED,
  EVENTS_LOADING_IN_PROGRESS,
  EVENTS_LOADING_ERRORED,
  KEY_MULTIASSIGN_UPDATE,
  MULTIASSIGN_EVENTS_UPDATED,
  UPDATE_GRID_STATE,
  VIEW_SELECTION_CHANGED,
  FILTERING_EVENTS_FAILED,
  FILTERING_EVENTS_STARTED,
  FILTERING_EVENTS_ERRORED,
  CREAT_EVENT_REQUESTED,
  UPDATE_EVENT_REQUESTED,
  UPDATE_TECHNICIAN_WORKING_HOURS,
  FETCH_DELTA_EVENTS,
  KEY_FETCH_DELTA_EVENTS,
  EVENTS_FETCH_DELTA_EVENTS,
  EVENTS_LAST_MODIFIED_EVENT,
  KEY_EVENTS_LAST_MODIFIED_EVENT,
  LOAD_WIDE_RANGE_EVENTS,
  KEY_EVENT_IDS,
  GET_EVENT_IDS,
  GET_EVENT_IDS_ERRORED,
  LOAD_EVENT_IDS,
  LOAD_ALL_EVENT_IDS,
  KEY_LOAD_EVENT_IDS,
  GET_EVENT_IDS_REQUESTED,
  LOAD_EVENT_IDS_REQUESTED,
  LOAD_EVENT_IDS_COMPLETE,
  GET_EVENT_IDS_LOADED,
  REMOVE_WORKORDER_EVENTS,
  FILTER_WORKORDER_TECHNICIANS,
  REMOVE_WORKORDER
} from "constants/ActionConstants";
import {
  TECH_WORKINGHOURS_COLOR,
  TECH_HOLIDAYHOURS_COLOR
} from "constants/UserSettingConstants";
import {
  ALL,
  DCON001_SET009,
  SET033,
  SET034,
  SET072,
  SET0235,
  SET051,
  SET010,
  SET074,
  SET075,
  GLOB001_GBL025,
  getSettingValue,
  ASSIGNED,
  QUEUED
} from "constants/AppSettings";
import { TAG033, TAG103 } from "constants/DisplayTagConstants";
import {
  getEventsData,
  createSchedulerTreeNode,
  getTechnicianWorkingHoursData,
  modifyDeltaEvents
} from "utils/SchedulerUtils";
import { schedulerStateChanged } from "actions/SchedulerAction";
import EventsService from "services/EventsService";
import TechnicianService from "services/TechnicianService";
import {
  addDaysTo,
  differenceDaysIn,
  sortEvents
} from "utils/DateAndTimeUtils";
import {
  getFieldValue,
  getDisplayValue,
  stringToBoolean,
  convertUint2Hex,
  getUserSetting,
  convertErrorToObject
} from "utils/DCUtils";
import { isView } from "utils/ViewUtils";
import {
  getEventCallRequested,
  setEventCallRequested,
  setEventCallDone,
  getEventCallDone,
  initiateEventCall
} from "utils/MapUtils";
import { createMultiAssignmentEvent } from "utils/GridUtils";
import {
  YODA_DATE_TIME_24_HR_FORMAT,
  YODA_DATE_TIME_ZONE_24_HR_FORMAT,
  DATE_FORMAT,
  TIME_FORMAT,
  DATE_TIME_FORMAT
} from "constants/DateTimeConstants";
import {
  ID,
  NAME,
  FALSE,
  TEAM_API_REF,
  TEAM_API_NAME,
  TEAM_INDEX,
  COLLAPSE_ALL,
  LAST_SAVED,
  TERRITORY_INDEX,
  DELETED_EVENT_IDS,
  FILTER_EVENTS_RESULT,
  FILTER_TECHNICIAN_RESULT,
  MULTI_ASSIGN_EVENT_UPDATE,
  TECH_SALESFORCE_USER_FIELD,
  ARRAY_TO_TREE_CONFIG,
  TERRITORY_API_NAME,
  WO_DISPATCH_STATUS_FIELD,
  EXPAND_TEAM_TERRITORY,
  WORKORDER_TECHNICIAN_API_NAME,
  WIDE_RANGE_REFRESH_DURATION,
  APPLY_TECHNICIAN_BATCH_FOR_WIDE_RANGE,
  WIDE_RANGE_TECHNICIAN_BATCH,
  WIDE_RANGE_EVENT_BATCH,
  HTTP_CONCURRENT_REQUEST
} from "constants/AppConstants";
import {
  TAG238,
  EVENTSTAG154,
  UNKNOWN,
  TAG280
} from "constants/DisplayTagConstants";
import { LOAD_EVENT_IDS_ERRORED } from "../constants/ActionConstants";

const getEventsOnlaunch = () =>
  EventsService.getEventsOnlaunch().then(response => response.json());

const getEventHoverOnlaunch = () =>
  EventsService.getEventHoverOnlaunch().then(response => response.json());

const getEventAfterLaunch = payload =>
  EventsService.getEventAfterLaunch(payload).then(response => response.json());

const fetchDeltaEvents = (payload, techIds) =>
  EventsService.fetchDeltaEvents(
    Object.assign(payload, { techIds })
  ).then(response => response.json());

// const fetchDeltaEvents = payload =>
//   EventsService.fetchDeltaEvents(payload).then(response => response.json());

const geteEventSubject = payload =>
  EventsService.getEventSubject(payload).then(response => response.json());

const createEvent = payload =>
  EventsService.createEvent(payload).then(response => response.json());

const createEventForTree = payload =>
  EventsService.createEventForTree(payload).then(response => response.json());

const createLJSEvent = payload =>
  EventsService.createLJSEvent(payload).then(response => response.json());

const fetchEventWoInfo = payload =>
  EventsService.fetchEventWoInfo(payload).then(response => response.json());

const updateEvent = payload =>
  EventsService.updateEvent(payload).then(response => response.json());

const updateEventOnTechChange = payload =>
  EventsService.updateEventOnTechChange(payload).then(response =>
    response.json()
  );

const fetchAllEvents = payload =>
  EventsService.fetchAllEvents(payload).then(response => response.json());

const fetchWOEvents = payload =>
  EventsService.fetchWOEvents(payload).then(response => response.json());

const scheduleMultipleEvents = payload =>
  EventsService.scheduleMultipleEvents(payload).then(response =>
    response.json()
  );

const getEventBusinessHours = payload =>
  EventsService.getEventBusinessHours(payload).then(response =>
    response.json()
  );

const fetchEventIds = payload =>
  EventsService.fetchEventIds(payload).then(response => response.json());

const eventDataAndWOInfoForIds = payload =>
  EventsService.eventDataAndWOInfoForIds(payload).then(response =>
    response.json()
  );
const eventDataForIds = payload =>
  EventsService.eventDataForIds(payload).then(response => response.json());

const woInfoDataForIds = payload =>
  EventsService.woInfoDataForIds(payload).then(response => response.json());

const getWorkOrderById = ({ workOrderData }, Id) => {
  const { workOrders } = workOrderData;
  const { content } = workOrders;
  const { records } = content;
  return records.find(record => record.Id === Id);
};

const getWorkOrders = ({ workOrderData }) => {
  const { workOrders } = workOrderData;
  const { content } = workOrders;
  const { records } = content;
  return records || [];
};

const isSingleWOLaunch = ({ gridState }) => {
  const { view } = gridState;
  const { type } = view;
  return type === "WO";
};

const getSelectedWO = ({ gridState }) => {
  const { row } = gridState;
  return row;
};

const getTechnicianData = ({ technicianData }) => technicianData;

const getAllTechnicianIds = ({ technicianData }) => {
  const { technicians } = technicianData;
  const { data } = technicians;
  const { techniciansIds } = data;
  return Array.from(techniciansIds);
};

const getAllTechnicians = ({ technicianData }) => {
  const { technicians: technicianContent } = technicianData;
  const { data } = technicianContent;
  const { technicians } = data;
  return technicians;
};

const getEventsTimings = ({ schedulerState }) => {
  const { eventsEndDate, eventsStartDate } = schedulerState;
  return { eventsEndDate, eventsStartDate };
};

const getTimeZone = ({ schedulerState }) => {
  const { timeZone } = schedulerState;
  return timeZone;
};

const getSchedularState = ({ schedulerState }) => schedulerState;

const getTechnicianWorkingHours = action =>
  TechnicianService.getTechniciansWorkingHours(action).then(response =>
    response.json()
  );

const getUserTimeZone = ({ metaData }) => {
  const { userTimezone } = metaData;
  const { content } = userTimezone;
  const { id, name } = content;
  return id || name;
};

const getSupportedTimeZones = ({ metaData }) => {
  const { timeZones } = metaData;
  const { content } = timeZones;
  return content;
};

const getLoggedInUserId = ({ metaData }) => {
  const { userInfo } = metaData;
  const { userId } = userInfo || {};
  return userId;
};

const getExpandedTeam = ({ userSettings }) => {
  const { tech_ExpandedTeam } = userSettings;
  return tech_ExpandedTeam;
};

const getExpandedTerritory = ({ userSettings }) => {
  const { tech_expandedTerritory } = userSettings;
  return tech_expandedTerritory;
};

const getSchedulerActiveView = ({ schedulerState }) => {
  const { activeView } = schedulerState;
  return activeView;
};

const getSelectedView = ({ gridState }) => {
  const { view } = gridState;
  return view;
};

const getSchedulerViewState = ({ schedulerState }) => {
  const { newViewState } = schedulerState;
  return newViewState;
};

const getTechWorkingHours = ({ technicianData }) => {
  const { technicianWorkingHours = {} } = technicianData;
  const { data } = technicianWorkingHours || {};
  return data;
};

const getHoverRules = ({ eventsData }) => {
  const { eventsHoverInfo } = eventsData;
  const { data } = eventsHoverInfo || {};
  const { content } = data || {};
  return content || [];
};

const getLastModifiedEvent = ({ eventsData }) => {
  const { lastModifiedEvent } = eventsData;
  const { event } = lastModifiedEvent || {};
  return event || {};
};

const getStatus = ({ gridState }) => {
  const { status } = gridState;
  return status;
};

const isOwnerChanged = (OwnerId, loggedInUserId) =>
  OwnerId && loggedInUserId && OwnerId !== loggedInUserId;

const getView = ({ gridState }) => {
  const { view } = gridState;
  return view;
};

const getTotalEventCount = ({ eventsData }) => {
  const { eventIds = {} } = eventsData || {};
  const { total = 0 } = eventIds;
  return total;
};

const getLoadedEventCount = ({ eventsData }) => {
  const { loadEventIds = {} } = eventsData || {};
  const { total = 0 } = loadEventIds;
  return total;
};

const sortLastModifiedEvent = events => {
  const eventList = orderBy(
    events,
    eventObj => moment(eventObj.lastModifiedDateTime),
    ["desc"]
  );
  return eventList[0] || [];
};

export function* eventsWorker() {
  try {
    yield put({ key: KEY_EVENTS, type: EVENTS_REQUESTED });
    const response = yield call(getEventsOnlaunch);
    const { content } = response;
    const { endDate: eventsEndDate, startDate: eventsStartDate } = content;
    yield put({
      data: { eventsEndDate, eventsStartDate },
      key: KEY_EVENTS,
      type: EVENTS_LOADED
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_EVENTS,
      type: EVENTS_API_ERRORED
    });
  }
}

export function* eventsWorkerStartEventsAfterLaunch(action) {
  try {
    const { callback, isEventRefresh } = action;
    let { technicianIds } = action;
    if (!technicianIds) {
      technicianIds = yield select(getAllTechnicianIds);
      if (!technicianIds || !technicianIds.length) {
        return;
      }
    }

    yield put({ type: EVENTS_LOADING_STARTED });
    const eventsTimings = yield select(getEventsTimings);
    const { eventsEndDate, eventsStartDate } = eventsTimings;
    const techBatchSize = getSettingValue(SET033);
    const daysBatchSize = getSettingValue(SET034);
    const technicianChunks = chunk(technicianIds, techBatchSize);
    const techTotalBatch = technicianChunks.length;
    const totalDays = differenceDaysIn(eventsEndDate, eventsStartDate);
    const dayTotalBatch = Math.ceil(totalDays / daysBatchSize);
    const techWorkingHours = getSettingValue(SET072);
    if (stringToBoolean(techWorkingHours)) {
      yield put({
        key: KEY_TECHNICIANS_WORKING_HOURS,
        type: GET_TECHNICIANS_WORKING_HOURS
      });
    }

    const defaultTZ = yield select(getUserTimeZone);
    const totalRequests = dayTotalBatch * techTotalBatch;
    for (let jDayCount = 0; jDayCount < dayTotalBatch; jDayCount += 1) {
      for (let iTechCount = 0; iTechCount < techTotalBatch; iTechCount += 1) {
        let eStartDate = addDaysTo(jDayCount * daysBatchSize, eventsStartDate);
        const eEndDate = addDaysTo(
          (jDayCount + 1) * daysBatchSize,
          eventsStartDate
        );
        // Handle TimeZone change.
        eStartDate = momentTimezone.tz(
          eStartDate.format(moment.HTML5_FMT.DATETIME_LOCAL_SECONDS),
          defaultTZ
        );

        setEventCallRequested();
        yield put({
          callback,
          eventsTimings: {
            eEndDate: eEndDate
              .endOf("day")
              .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT),
            eStartDate: moment
              .utc(eStartDate)
              .startOf("day")
              .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT)
          },
          isEventRefresh,
          key: KEY_EVENTS,
          technicianIds: technicianChunks[iTechCount],
          requestCount: (jDayCount + 1) * (iTechCount + 1),
          totalRequests,
          type: GET_EVENTS_AFTER_LAUNCH
        });
      }
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_EVENTS,
      type: EVENTS_API_ERRORED
    });
  }
}

export function* loadWideRangeEventsWorker(action) {
  try {
    const { callback, isEventRefresh } = action;
    let { technicianIds } = action;
    if (!technicianIds) {
      technicianIds = yield select(getAllTechnicianIds);
      if (!technicianIds || !technicianIds.length) {
        return;
      }
    }

    yield put({ type: EVENTS_LOADING_STARTED });
    // Clear Previous Event Refresh contents
    yield put({
      type: REMOVE_WORKORDER_EVENTS,
      keys: [KEY_EVENT_IDS, KEY_LOAD_EVENT_IDS]
    });

    const techWorkingHours = getSettingValue(SET072);
    if (stringToBoolean(techWorkingHours)) {
      yield put({
        key: KEY_TECHNICIANS_WORKING_HOURS,
        type: GET_TECHNICIANS_WORKING_HOURS
      });
    }

    const daysBatchSize = WIDE_RANGE_REFRESH_DURATION;
    const techBatchSize = APPLY_TECHNICIAN_BATCH_FOR_WIDE_RANGE
      ? getSettingValue(SET074, WIDE_RANGE_TECHNICIAN_BATCH)
      : technicianIds.length;
    const eventsTimings = yield select(getEventsTimings);
    const { eventsEndDate, eventsStartDate } = eventsTimings;
    const technicianChunks = chunk(technicianIds, techBatchSize);
    const techTotalBatch = technicianChunks.length;
    const totalDays = differenceDaysIn(eventsEndDate, eventsStartDate);
    const dayTotalBatch = Math.ceil(totalDays / daysBatchSize);

    const requests = [];
    const defaultTZ = yield select(getUserTimeZone);
    for (let jDayCount = 0; jDayCount < dayTotalBatch; jDayCount += 1) {
      for (let iTechCount = 0; iTechCount < techTotalBatch; iTechCount += 1) {
        const startDays = jDayCount * daysBatchSize;
        const endDays = (jDayCount + 1) * daysBatchSize;
        let eStartDate = addDaysTo(startDays, eventsStartDate);
        const eEndDate = addDaysTo(
          totalDays < endDays ? totalDays : endDays,
          eventsStartDate
        );
        // Handle TimeZone change.
        eStartDate = momentTimezone.tz(
          eStartDate.format(moment.HTML5_FMT.DATETIME_LOCAL_SECONDS),
          defaultTZ
        );
        const startDate = moment
          .utc(eStartDate)
          .startOf("day")
          .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
        const endDate = eEndDate
          .endOf("day")
          .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
        requests.push({
          eventsTimings: {
            endDate,
            startDate
          },
          techIds: [...technicianChunks[iTechCount]]
        });
      }
    }
    yield put({
      requests,
      callback,
      isEventRefresh,
      key: KEY_EVENT_IDS,
      type: GET_EVENT_IDS
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_EVENT_IDS,
      type: LOAD_EVENT_IDS_ERRORED
    });
  }
}

export function* getEventIDsWorker(action) {
  try {
    let reqError;
    let totalEventIds = [];

    const tzDtFormat = yield select(getTimeZone);
    const { callback, isEventRefresh, requests = [] } = action;
    for (let i = 0; i < requests.length; i += 1) {
      const requestBatch = requests[i];
      const id = uniqueId();
      const { eventsTimings, techIds } = requestBatch;
      const { startDate, endDate } = eventsTimings;
      const request = {
        endDate,
        startDate,
        techIds,
        tzDtFormat
      };

      yield put({
        type: GET_EVENT_IDS_REQUESTED,
        key: KEY_EVENT_IDS,
        request: { id, request }
      });

      const response = yield call(fetchEventIds, request);
      const { content, message, success } = response;
      if (!success) {
        reqError = { error: convertErrorToObject(response), message };
        continue;
      }

      const eventIds = new Set(content || []);
      yield put({
        id,
        count: eventIds.size,
        key: KEY_EVENT_IDS,
        type: GET_EVENT_IDS_LOADED
      });
      totalEventIds = totalEventIds.concat([...eventIds]);
    }

    if (reqError) {
      const { error, message } = reqError;
      yield put({
        data: { error, ...error },
        message,
        type: GET_EVENT_IDS_ERRORED
      });
      return;
    }

    const eventBatches = [];
    const chunks = chunk(
      totalEventIds,
      getSettingValue(SET075, WIDE_RANGE_EVENT_BATCH)
    );
    chunks.map(chunk => {
      eventBatches.push({
        eventIds: [...chunk]
      });
      return undefined;
    });

    yield put({
      callback,
      eventBatches,
      isEventRefresh,
      tzDtFormat,
      type: LOAD_ALL_EVENT_IDS
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_EVENT_IDS,
      type: GET_EVENT_IDS_ERRORED
    });
  }
}

export function* loadEventIDsWorker(action) {
  try {
    let reqError;
    let loadedEvents = 0;
    const totalEvents = yield select(getTotalEventCount);
    const { callback, eventBatches = [], tzDtFormat, isEventRefresh } = action;
    for (let i = 0; i < eventBatches.length; i += 1) {
      const eventBatch = eventBatches[i];
      const { eventIds } = eventBatch;
      const request = {
        eventIds,
        tzDtFormat
      };

      const id = uniqueId();
      yield put({
        type: LOAD_EVENT_IDS_REQUESTED,
        key: KEY_LOAD_EVENT_IDS,
        request: { id, request }
      });

      const response = yield call(eventDataAndWOInfoForIds, request);
      const { content, message, success } = response;
      if (!success) {
        reqError = { error: convertErrorToObject(response), message };
        continue;
      }

      const { events: events1 } = content;
      yield put({
        id,
        count: events1 ? events1.length : 0,
        key: KEY_LOAD_EVENT_IDS,
        type: LOAD_EVENT_IDS_COMPLETE
      });

      loadedEvents += events1.length;
      yield put({
        type: EVENTS_LOADING_IN_PROGRESS,
        message: `${getDisplayValue(
          TAG033
        )}... ( ${loadedEvents} / ${totalEvents} ).`
      });

      const hoverRules = yield select(getHoverRules);
      const events = getEventsData(content, hoverRules);
      callback(events, true);

      const lastModifiedEvent = yield select(getLastModifiedEvent);
      const eventsList = isEmpty(lastModifiedEvent)
        ? events
        : [...events, lastModifiedEvent];

      yield put({
        type: EVENTS_LAST_MODIFIED_EVENT,
        key: KEY_EVENTS_LAST_MODIFIED_EVENT,
        data: sortLastModifiedEvent(eventsList)
      });
    }

    // In case if there are any errors, Show in the status Bar
    if (reqError) {
      const { error, message } = reqError;
      yield put({
        data: { error, ...error },
        message,
        type: LOAD_EVENT_IDS_ERRORED
      });
    } else {
      // Update Status Bar with Refresh Complete Message
      const activeView = yield select(getSchedulerActiveView);
      const expandedTeams = yield select(getExpandedTeam);
      const expandedTerritory = yield select(getExpandedTerritory);
      // On launch, look into custom settings SET0235 and show informative message accordingly.
      if (!isEventRefresh) {
        const SET0235Value = getSettingValue(SET0235, LAST_SAVED);
        if (
          SET0235Value === COLLAPSE_ALL ||
          (SET0235Value === LAST_SAVED &&
            ((activeView === TEAM_INDEX && !expandedTeams.length) ||
              (activeView === TERRITORY_INDEX && !expandedTerritory.length)))
        ) {
          yield put({
            message: getDisplayValue("TAG519", EXPAND_TEAM_TERRITORY),
            type: EXPAND_TEAM_AFTER_EVENT_REFRESH
          });
        } else {
          yield put({ type: EVENTS_LOADING_COMPLETE });
        }
      } else if (
        (activeView === TEAM_INDEX && !expandedTeams.length) ||
        (activeView === TERRITORY_INDEX && !expandedTerritory.length)
      ) {
        yield put({
          message: getDisplayValue(EVENTSTAG154),
          type: EXPAND_TEAM_AFTER_EVENT_REFRESH
        });
      } else {
        yield put({ type: EVENTS_LOADING_COMPLETE });
      }
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      type: EVENTS_LOADING_ERRORED
    });
  }
}

export function* loadConcurrentEventIDsWorker(action) {
  try {
    let reqError;
    let loadedEvents = 0;
    const totalEvents = yield select(getTotalEventCount);
    const { callback, eventBatches = [], tzDtFormat, isEventRefresh } = action;
    const batchRequestChunks = chunk(eventBatches, HTTP_CONCURRENT_REQUEST);
    for (let i = 0; i < batchRequestChunks.length; i += 1) {
      const requests = {};
      const blockingHttpRequests = [];
      const blockingEventDataHttpRequests = [];
      const blockingWOInfoFOrEventsRequests = [];
      const blockingWoInfoHttpRequests = [];
      const batchRequestChunk = batchRequestChunks[i];
      for (let j = 0; j < batchRequestChunk.length; j += 1) {
        const eventBatch = batchRequestChunk[j];
        const { eventIds } = eventBatch;
        const request = {
          eventIds,
          tzDtFormat
        };
        const id = uniqueId();
        yield put({
          type: LOAD_EVENT_IDS_REQUESTED,
          key: KEY_LOAD_EVENT_IDS,
          request: { id, request }
        });
        requests[j] = { id, request };
        blockingEventDataHttpRequests.push(call(eventDataForIds, request));
        blockingHttpRequests.push(call(eventDataAndWOInfoForIds, request));
      }

      const hoverRules = yield select(getHoverRules);
      //const responseArray = yield all(blockingHttpRequests);
      const responseEventDataArray = yield all(blockingEventDataHttpRequests);
      let eventsSet = [];
      for (let k = 0; k < responseEventDataArray.length; k++) {
        const response = responseEventDataArray[k];
        const { content, message, success } = response;
        if (!success) {
          reqError = { error: convertErrorToObject(response), message };
          continue;
        }
        const request = requests[k];
        const { id } = request;
        const { events: events1 } = content;
        eventsSet = [...eventsSet, ...events1];
        yield put({
          id,
          count: events1 ? events1.length : 0,
          key: KEY_LOAD_EVENT_IDS,
          type: LOAD_EVENT_IDS_COMPLETE
        });

        loadedEvents += events1.length;
        yield put({
          type: EVENTS_LOADING_IN_PROGRESS,
          message: `${getDisplayValue(
            TAG033
          )}... ( ${loadedEvents} / ${totalEvents} ).`
        });

        let workorderIds = [];
        events1.forEach(eventItem => {
          const { event_WP: eventObject } = eventItem;
          if (eventObject) {
            const { id, whatId: WOId } = eventObject;
            if (id && WOId) {
              workorderIds.push(WOId);
            }
          }
        });
        const requestForWoInfoMap = {
          workorderIds,
          tzDtFormat
        };
        blockingWOInfoFOrEventsRequests.push(
          call(woInfoDataForIds, requestForWoInfoMap)
        );
      }
      const responseWOInfoForEventsArray = yield all(
        blockingWOInfoFOrEventsRequests
      );
      let mergedWOInfo = {};
      for (let m = 0; m < responseWOInfoForEventsArray.length; m++) {
        const woInforeponse = responseWOInfoForEventsArray[m];
        const {
          content: woInfoContent,
          message: woInfoMessage,
          success: woInfoSuccess
        } = woInforeponse;
        if (!woInfoSuccess) {
          reqError = {
            error: convertErrorToObject(woInforeponse),
            woInfoMessage
          };
          continue;
        }
        mergedWOInfo = { ...mergedWOInfo, ...woInfoContent };
      }
      const events = getEventsData(
        { events: eventsSet, woInfoMap: mergedWOInfo },
        hoverRules
      );
      callback(events, true);
      // setTimeout(() => callback(events, true), 0);

      const lastModifiedEvent = yield select(getLastModifiedEvent);
      const eventsList = isEmpty(lastModifiedEvent)
        ? events
        : [...events, lastModifiedEvent];

      yield put({
        type: EVENTS_LAST_MODIFIED_EVENT,
        key: KEY_EVENTS_LAST_MODIFIED_EVENT,
        data: sortLastModifiedEvent(eventsList)
      });
    }

    // In case if there are any errors, Show in the status Bar
    if (reqError) {
      const { error, message } = reqError;
      yield put({
        data: { error, ...error },
        message,
        type: LOAD_EVENT_IDS_ERRORED
      });
    } else {
      // Update Status Bar with Refresh Complete Message
      const activeView = yield select(getSchedulerActiveView);
      const expandedTeams = yield select(getExpandedTeam);
      const expandedTerritory = yield select(getExpandedTerritory);
      // On launch, look into custom settings SET0235 and show informative message accordingly.
      if (!isEventRefresh) {
        const SET0235Value = getSettingValue(SET0235, LAST_SAVED);
        if (
          SET0235Value === COLLAPSE_ALL ||
          (SET0235Value === LAST_SAVED &&
            ((activeView === TEAM_INDEX && !expandedTeams.length) ||
              (activeView === TERRITORY_INDEX && !expandedTerritory.length)))
        ) {
          yield put({
            message: getDisplayValue("TAG519", EXPAND_TEAM_TERRITORY),
            type: EXPAND_TEAM_AFTER_EVENT_REFRESH
          });
        } else {
          // yield put({ type: EVENTS_LOADING_COMPLETE });
          yield put({
            type: EVENTS_LOADING_COMPLETE,
            message: `${getDisplayValue(
              TAG103
            )} ( ${loadedEvents} / ${totalEvents} )`
          });
        }
      } else if (
        (activeView === TEAM_INDEX && !expandedTeams.length) ||
        (activeView === TERRITORY_INDEX && !expandedTerritory.length)
      ) {
        yield put({
          message: getDisplayValue(EVENTSTAG154),
          type: EXPAND_TEAM_AFTER_EVENT_REFRESH
        });
      } else {
        // yield put({ type: EVENTS_LOADING_COMPLETE });
        yield put({
          type: EVENTS_LOADING_COMPLETE,
          message: `${getDisplayValue(
            TAG103
          )} ( ${loadedEvents} / ${totalEvents} )`
        });
      }
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      type: EVENTS_LOADING_ERRORED
    });
  }
}

export function* eventsWorkerGetEventAfterLaunch(action) {
  try {
    const { callback, isEventRefresh, requestCount, totalRequests } = action;
    const { eventsTimings, technicianIds } = action;
    const tzDtFormat = yield select(getTimeZone);
    const payload = {
      endDate: eventsTimings.eEndDate,
      startDate: eventsTimings.eStartDate,
      techIds: technicianIds,
      tzDtFormat
    };

    const isProgressive = totalRequests > 50;
    if (requestCount > 6) {
      yield delay(
        Math.round(Math.random() * Math.ceil(requestCount / 100)) * 500
      );
    }
    const response = yield call(getEventAfterLaunch, payload);
    const { content } = response;
    if (!content) {
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        type: EVENTS_LOADING_ERRORED
      });
      return;
    }
    const hoverRules = yield select(getHoverRules);
    const events = getEventsData(content, hoverRules);
    setEventCallDone();
    const eventRequestCount = getEventCallRequested();
    const eventResponseCount = getEventCallDone();
    if (isProgressive) {
      yield put({
        type: EVENTS_LOADING_IN_PROGRESS,
        message: `${getDisplayValue(
          TAG033
        )}... ( ${eventResponseCount} / ${totalRequests} ) requests completed.`
      });
    }
    let allEventCallDone = false;
    if (eventRequestCount === eventResponseCount) {
      allEventCallDone = true;
      initiateEventCall();
      const activeView = yield select(getSchedulerActiveView);
      const expandedTeams = yield select(getExpandedTeam);
      const expandedTerritory = yield select(getExpandedTerritory);
      // On launch look into custom settings SET0235 and show informative message accordingly.
      if (!isEventRefresh) {
        const SET0235Value = getSettingValue(SET0235, LAST_SAVED);
        if (
          (SET0235Value === LAST_SAVED &&
            ((activeView === TEAM_INDEX && !expandedTeams.length) ||
              (activeView === TERRITORY_INDEX && !expandedTerritory.length))) ||
          SET0235Value === COLLAPSE_ALL
        ) {
          yield put({
            message: getDisplayValue("TAG519", EXPAND_TEAM_TERRITORY),
            type: EXPAND_TEAM_AFTER_EVENT_REFRESH
          });
        } else {
          yield put({ type: EVENTS_LOADING_COMPLETE });
        }
      } else if (
        (activeView === TEAM_INDEX && !expandedTeams.length) ||
        (activeView === TERRITORY_INDEX && !expandedTerritory.length)
      ) {
        yield put({
          message: getDisplayValue(EVENTSTAG154),
          type: EXPAND_TEAM_AFTER_EVENT_REFRESH
        });
      } else {
        yield put({ type: EVENTS_LOADING_COMPLETE });
      }
    }
    const lastModifiedEvent = yield select(getLastModifiedEvent);
    const eventsList = isEmpty(lastModifiedEvent)
      ? events
      : [...events, lastModifiedEvent];
    yield put({
      type: EVENTS_LAST_MODIFIED_EVENT,
      key: KEY_EVENTS_LAST_MODIFIED_EVENT,
      data: sortLastModifiedEvent(eventsList)
    });
    callback(events, allEventCallDone);
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      type: EVENTS_LOADING_ERRORED
    });
  }
}

export function* getEventSubjectWorker(action) {
  try {
    yield put({ key: KEY_EVENT_SUBJECT, type: EVENT_SUBJECT_REQUESTED });
    const { callback } = action;
    const { payload } = action;
    const response = yield call(geteEventSubject, payload);
    const { content, message, success } = response;
    if (!success) {
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        message,
        key: KEY_EVENT_SUBJECT,
        type: EVENT_SUBJECT_ERRORED
      });
      return;
    }
    yield put({
      data: content,
      key: KEY_EVENT_SUBJECT,
      type: EVENT_SUBJECT_LOADED
    });
    if (callback) {
      callback(response);
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_EVENT_SUBJECT,
      type: EVENT_SUBJECT_ERRORED
    });
  }
}

export function* createEventForTreeWorker(action) {
  const { dummy = false, callback } = action;
  try {
    yield put({ type: ASSIGN_TO_TREE_REQUESTED });
    const { payload } = action;
    const { woDispatchStatus } = payload;
    const response = yield call(createEventForTree, payload);
    const { content, message, success } = response;
    if (!success) {
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        message,
        type: ASSIGN_TO_TREE_ERRORED
      });
      return;
    }
    const { statusMessage, woInfo } = content;
    const { deletedEventIds } = statusMessage;
    const eventIds = deletedEventIds && deletedEventIds.split(",");
    const [woId] = Object.keys(woInfo);
    const workOrder = woInfo[woId];
    if (eventIds && eventIds.length) {
      yield put(
        schedulerStateChanged(
          { WOUnAssigned: { eventIds: [...eventIds] } },
          UPDATE_SCHEDULER_STATE
        )
      );
    }
    const isSET051 = JSON.parse(getSettingValue(SET051, FALSE).toLowerCase());
    const isSET010 = JSON.parse(getSettingValue(SET010, FALSE).toLowerCase());
    const view = yield select(getView);

    if (
      isSET051 ||
      (woDispatchStatus !== workOrder[WO_DISPATCH_STATUS_FIELD] && isSET010)
    ) {
      yield put({ type: ASSIGN_TO_TREE_COMPLETED });
      yield put({
        changed: { reload: true, view },
        type: VIEW_SELECTION_CHANGED
      });
    } else if (workOrder) {
      let selectedWO = yield select(getSelectedWO);
      const selectedId = getFieldValue(selectedWO, ID);
      const [WhatId] = payload.WorkOrderIds;
      if (selectedId !== WhatId) {
        selectedWO = yield select(getWorkOrderById, WhatId);
      }
      if (selectedWO) {
        const { OwnerId } = workOrder;
        const status = yield select(getStatus);
        // const loggedInUserId = yield select(getLoggedInUserId);
        const { OwnerId: loggedInUserId } = selectedWO;
        const singleWOView = yield select(isSingleWOLaunch);
        const ownerChanged = isOwnerChanged(OwnerId, loggedInUserId);

        if (singleWOView) {
          // Update Grid WorkOrder row with all the fields returned in the response
          Object.assign(selectedWO, workOrder);
          // In case if SET009 is true and workorder is been assigned to salesforce user, remove it from dispatcher Queue.
        } else if (ownerChanged && !isView(view)) {
          yield put({ type: REMOVE_WORKORDER, deleteWO: workOrder });
        } else if (
          status === ALL ||
          status.includes(workOrder[WO_DISPATCH_STATUS_FIELD])
        ) {
          // Update Grid WorkOrder row with all the fields returned in the response
          Object.assign(selectedWO, workOrder);
        } else {
          // Based on Dispatch Status, either remove the workorder or update the status.
          yield put({ type: REMOVE_WORKORDER, deleteWO: workOrder });
        }

        yield put({ type: UPDATE_GRID_STATE });
        yield put({ type: ASSIGN_TO_TREE_COMPLETED });
      }
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      type: ASSIGN_TO_TREE_ERRORED
    });
  }
}

export function* createEventWorker(action) {
  const { dummy = false, callback } = action;
  try {
    yield put({ type: CREAT_EVENT_REQUESTED });
    const { payload } = action;
    const { woDispatchStatus } = payload;
    const response = yield call(createEvent, payload);
    const { content, success, message } = response;
    if (!success && !dummy) {
      callback(message, true);
      if (message !== getDisplayValue(TAG238)) {
        const error = convertErrorToObject(response);
        yield put({
          data: { error, ...error },
          message,
          type: CREAT_EVENT_ERROR
        });
      }
      return;
    }

    // Get the Dragged workorder object.
    let selectedWO = yield select(getSelectedWO);
    const selectedId = getFieldValue(selectedWO, ID);
    const { events: reqEvents } = payload;
    const [event] = reqEvents;
    const { WhatId } = event;
    if (selectedId !== WhatId) {
      selectedWO = yield select(getWorkOrderById, WhatId);
    }

    const {
      deletedEventIds = [],
      lstEvent: events = [],
      objWorkOrder = {}
    } = content;
    const { workorder_O: workOrder } = objWorkOrder || {};
    // Invoke registered callback with event details.
    if (callback) {
      const hoverRules = yield select(getHoverRules);
      const lstEvent = getEventsData(
        {
          events: events || [],
          // Update WorkOrder object with latest updated fields and pass it to hover rules
          woInfoMap: workOrder
            ? { [workOrder.Id]: Object.assign({}, selectedWO || {}, workOrder) }
            : selectedWO || {}
        },
        hoverRules
      );
      callback({ deletedEventIds: deletedEventIds || [], lstEvent });
    }
    const isSET010 = JSON.parse(getSettingValue(SET010, FALSE).toLowerCase());
    const isSET051 = JSON.parse(getSettingValue(SET051, FALSE).toLowerCase());

    const view = yield select(getSelectedView);
    if (
      isSET051 ||
      (woDispatchStatus !== workOrder[WO_DISPATCH_STATUS_FIELD] && isSET010)
    ) {
      yield put({ type: EVENT_SAVING_COMPLETE });
      yield put({
        changed: { reload: true, view },
        type: VIEW_SELECTION_CHANGED
      });
    } else if (workOrder && selectedWO) {
      // Get the Owner Technician from the last event detail sent in the request and update the grid workorder row.
      const { OwnerId } = workOrder;
      const status = yield select(getStatus);
      // const loggedInUserId = yield select(getLoggedInUserId);
      const { OwnerId: loggedInUserId } = selectedWO;
      const singleWOView = yield select(isSingleWOLaunch);
      const ownerChanged = isOwnerChanged(OwnerId, loggedInUserId);

      if (singleWOView) {
        // Update Grid WorkOrder row with all the fields returned in the response
        Object.assign(selectedWO, workOrder);
        // In case if SET009 is true and workorder is been assigned to salesforce user, remove it from dispatcher Queue.
      } else if (ownerChanged && !isView(view)) {
        yield put({ type: REMOVE_WORKORDER, deleteWO: workOrder });
      } else if (
        status === ALL ||
        status.includes(workOrder[WO_DISPATCH_STATUS_FIELD])
      ) {
        // Update Grid WorkOrder row with all the fields returned in the response
        Object.assign(selectedWO, workOrder);
      } else {
        // Based on Dispatch Status, either remove the workorder or update the status.
        yield put({ type: REMOVE_WORKORDER, deleteWO: workOrder });
      }
      yield put({ type: UPDATE_GRID_STATE });
      yield put({ type: EVENT_SAVING_COMPLETE });
    }
  } catch (e) {
    if (!dummy) {
      const { name: errorCode, stack: message } = e;
      if (message !== getDisplayValue(TAG238)) {
        yield put({
          data: { error: { errorCode, message } },
          key: KEY_CREAT_EVENT,
          type: CREAT_EVENT_ERROR
        });
      }
    }
  }
}

export function* createNonWOEventWorker(action) {
  try {
    yield put({ type: CREAT_EVENT_REQUESTED });
    const { callback } = action;
    const { payload } = action;
    const response = yield call(createEvent, payload);

    const { content, success, message } = response;
    if (!success) {
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        message,
        type: CREAT_EVENT_ERROR
      });
      return;
    }

    const { deletedEventIds = [], lstEvent: events = [] } = content;
    const lstEvent = getEventsData({ events: events || [] });
    if (callback) {
      callback({ deletedEventIds: deletedEventIds || [], lstEvent });
    }
    yield put({ type: EVENT_SAVING_COMPLETE });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_CREAT_EVENT,
      type: CREAT_EVENT_ERROR
    });
  }
}

export function* createLJSeventWorker(action) {
  try {
    yield put({ type: CREAT_EVENT_REQUESTED });
    const { callback, isCalculateEndTime } = action;
    const { payload } = action;
    const { woDispatchStatus } = payload;
    const response = yield call(createLJSEvent, payload);

    const { content, success, message } = response;
    if (!success) {
      callback(message, true);
      if (!message.includes(getDisplayValue("EVENTSTAG064"))) {
        const error = convertErrorToObject(response);
        yield put({
          data: { error, ...error },
          message,
          type: CREAT_EVENT_ERROR
        });
      } else {
        yield put(
          schedulerStateChanged({ loading: false }, UPDATE_SCHEDULER_STATE)
        );
      }
      return;
    }

    if (isCalculateEndTime) {
      callback(response);
    } else {
      const {
        deletedEvents,
        lstEvent: events = [],
        objWorkOrder = {}
      } = content;
      const { workorder_O: workOrder } = objWorkOrder || {};
      const { Id, OwnerId } = workOrder;
      const selectedWO = yield select(getWorkOrderById, Id);
      // Invoke registered callback with event details.
      if (callback) {
        const hoverRules = yield select(getHoverRules);
        const lstEvent = getEventsData(
          {
            events: events || [],
            // Update WorkOrder object with latest updated fields and pass it to hover rules
            woInfoMap: workOrder
              ? {
                  [workOrder.Id]: Object.assign({}, selectedWO || {}, workOrder)
                }
              : selectedWO || {}
          },
          hoverRules
        );
        callback({
          deletedEventIds: deletedEvents ? deletedEvents.split(",") : [],
          lstEvent
        });
      }

      const isSET051 = JSON.parse(getSettingValue(SET051, FALSE).toLowerCase());
      const isSET010 = JSON.parse(getSettingValue(SET010, FALSE).toLowerCase());
      const view = yield select(getSelectedView);
      if (
        isSET051 ||
        (woDispatchStatus !== workOrder[WO_DISPATCH_STATUS_FIELD] && isSET010)
      ) {
        yield put({
          changed: { reload: true, view },
          type: VIEW_SELECTION_CHANGED
        });
      } else if (workOrder && selectedWO) {
        const status = yield select(getStatus);
        // const loggedInUserId = yield select(getLoggedInUserId);
        const { OwnerId: loggedInUserId } = selectedWO;
        const singleWOView = yield select(isSingleWOLaunch);
        const ownerChanged = isOwnerChanged(OwnerId, loggedInUserId);

        if (singleWOView) {
          // Update Grid WorkOrder row with all the fields returned in the response
          Object.assign(selectedWO, workOrder);
          // In case if SET009 is true and workorder is been assigned to salesforce user, remove it from dispatcher Queue.
        } else if (ownerChanged && !isView(view)) {
          yield put({ type: REMOVE_WORKORDER, deleteWO: workOrder });
        } else if (
          status === ALL ||
          status.includes(workOrder[WO_DISPATCH_STATUS_FIELD])
        ) {
          // Update Grid WorkOrder row with all the fields returned in the response
          Object.assign(selectedWO, workOrder);
        } else {
          // Based on Dispatch Status, either remove the workorder or update the status.
          yield put({ type: REMOVE_WORKORDER, deleteWO: workOrder });
        }
        yield put({ type: UPDATE_GRID_STATE });
      }
    }
    yield put({ type: EVENT_SAVING_COMPLETE });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_CREAT_EVENT,
      type: CREAT_EVENT_ERROR
    });
  }
}

const convertToActualViewState = newViewState => {
  let newStateValue = newViewState;
  const sign = Math.sign(newViewState);
  if (sign < 0) {
    if (newViewState < -100) {
      newStateValue = newViewState + 100;
    }
  } else if (newViewState > 100) {
    newStateValue = newViewState - 100;
  }
  return newStateValue;
};

export function* updateEventWorker(action) {
  try {
    yield put({ type: UPDATE_EVENT_REQUESTED });
    const { callback, payload } = action;
    const { woDispatchStatus } = payload;

    const { EventList = [], updateWorkOrder } = payload;

    // Hack to make edit workorder work.
    if (isUndefined(updateWorkOrder)) {
      payload.updateWorkOrder = false;
    }
    const [firstEvent] = EventList;
    const isWorkOrderEvent = firstEvent && !isEmpty(firstEvent.WhatId);
    const response = yield call(updateEvent, payload);
    const { content, success, message } = response;
    if (!success) {
      callback(message, true);
      if (message !== getDisplayValue(TAG238)) {
        const error = convertErrorToObject(response);
        yield put({
          data: { error, ...error },
          message,
          type: CREAT_EVENT_ERROR
        });
      } else if (!message.includes(getDisplayValue("EVENTSTAG064"))) {
        yield put({
          data: { error: { ...response } },
          message,
          type: UPDATE_EVENT_ERROR
        });
      }
      return;
    }

    const {
      deletedEventIds = [],
      lstEvent: events = [],
      objWorkOrder = {}
    } = content;
    const { workorder_O: workOrder } = objWorkOrder || {};
    const { Id, OwnerId } = workOrder || {};
    const selectedWO = yield select(getWorkOrderById, Id);
    // Invoke registered callback with event details.
    if (callback) {
      const hoverRules = yield select(getHoverRules);
      const lstEvent = getEventsData(
        {
          events: events || [],
          // Update WorkOrder object with latest updated fields and pass it to hover rules
          woInfoMap: workOrder
            ? {
                [workOrder.Id]: Object.assign({}, selectedWO || {}, workOrder)
              }
            : selectedWO || {}
        },
        hoverRules
      );
      callback({
        deletedEventIds: deletedEventIds || [],
        lstEvent,
        workOrder
      });
    }

    if (isWorkOrderEvent) {
      const view = yield select(getSelectedView);
      const isSET051 = JSON.parse(getSettingValue(SET051, FALSE).toLowerCase());
      const isSET010 = JSON.parse(getSettingValue(SET010, FALSE).toLowerCase());
      if (
        isSET051 ||
        (woDispatchStatus !== workOrder[WO_DISPATCH_STATUS_FIELD] && isSET010)
      ) {
        yield put({ type: EVENT_SAVING_COMPLETE });
        yield put({
          changed: { reload: true, view },
          type: VIEW_SELECTION_CHANGED
        });
      } else if (workOrder && selectedWO) {
        const status = yield select(getStatus);
        // const loggedInUserId = yield select(getLoggedInUserId);
        const { OwnerId: loggedInUserId } = selectedWO;
        const singleWOView = yield select(isSingleWOLaunch);
        const ownerChanged = isOwnerChanged(OwnerId, loggedInUserId);

        // Update Grid WorkOrder row with all the fields returned in the response
        if (singleWOView) {
          Object.assign(selectedWO, workOrder);
          // In case if SET009 is true and workorder is been assigned to salesforce user, remove it from dispatcher Queue.
        } else if (ownerChanged && !isView(view)) {
          yield put({ type: REMOVE_WORKORDER, deleteWO: workOrder });
        } else if (
          status === ALL ||
          status.includes(workOrder[WO_DISPATCH_STATUS_FIELD])
        ) {
          // Update Grid WorkOrder row with all the fields returned in the response
          Object.assign(selectedWO, workOrder);
        } else {
          // Based on Dispatch Status, either remove the workorder or update the status.
          yield put({ type: REMOVE_WORKORDER, deleteWO: workOrder });
        }
        yield put({ type: UPDATE_GRID_STATE });
      }

      const viewState = yield select(getSchedulerViewState);
      // if (updatePrimaryTech) {
      // Re-Filter events if there is change in event primary technician
      if (FILTER_EVENTS_RESULT === convertToActualViewState(viewState)) {
        yield put({ type: FILTER_WORKORDER_EVENTS });
      }
      // Re-Filter technicians if there is change in event primary technician
      if (FILTER_TECHNICIAN_RESULT === convertToActualViewState(viewState)) {
        yield put({ type: FILTER_WORKORDER_TECHNICIANS });
      }
      // }
    }
    yield put({ type: EVENT_SAVING_COMPLETE });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    if (message !== getDisplayValue(TAG238)) {
      yield put({
        data: { error: { errorCode, message } },
        key: KEY_UPDATE_EVENT,
        type: UPDATE_EVENT_ERROR
      });
    }
  }
}

export function* updateTechChangeEventWorker(action) {
  try {
    yield put({ type: UPDATE_EVENT_REQUESTED });
    const { callback } = action;
    const { payload } = action;
    const response = yield call(updateEventOnTechChange, payload);
    callback(response);
    yield put({ type: EVENT_SAVING_COMPLETE });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_UPDATE_EVENT,
      type: UPDATE_EVENT_ERROR
    });
  }
}

export function* getTechnicianWorkingHourWorker(action) {
  try {
    yield put({
      key: KEY_TECHNICIANS_WORKING_HOURS,
      type: TECHNICIANS_WORKING_HOURS_REQUESTED
    });
    const technicianIds = yield select(getAllTechnicianIds);
    const eventsTimings = yield select(getEventsTimings);
    const { eventsEndDate, eventsStartDate } = eventsTimings;
    const tzDtFormat = yield select(getUserTimeZone);
    const eventsStartDateFormatted = moment
      .tz(eventsStartDate, tzDtFormat)
      .format();
    const eventsEndDateFormatted = moment
      .tz(eventsEndDate, tzDtFormat)
      .format();
    const payload = {
      enddate: eventsEndDateFormatted,
      lsttechId: technicianIds,
      startdate: eventsStartDateFormatted
    };
    const response = yield call(getTechnicianWorkingHours, payload);
    const { content } = response;
    yield put({
      data: content,
      key: KEY_TECHNICIAN_WORKING_HOURS,
      type: TECHNICIANS_WORKING_HOURS_LOADED
    });
    yield put({ type: UPDATE_TECHNICIAN_WORKING_HOURS });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_TECHNICIANS_WORKING_HOURS,
      type: TECHNICIANS_WORKING_HOURS_API_ERRORED
    });
  }
}

export function* updateTechWorkingHoursWorker() {
  try {
    const technicianIds = yield select(getAllTechnicianIds);
    const eventsTimings = yield select(getEventsTimings);
    const { eventsEndDate, eventsStartDate } = eventsTimings;
    const tzDtFormat = yield select(getUserTimeZone);
    const eventsStartDateFormatted = moment(eventsStartDate).format();
    const eventsEndDateFormatted = moment(eventsEndDate).format();
    const supportedTimeZones = yield select(getSupportedTimeZones);
    const workingHoursColor = convertUint2Hex(
      getUserSetting(TECH_WORKINGHOURS_COLOR)
    );
    const holidayHoursColor = convertUint2Hex(
      getUserSetting(TECH_HOLIDAYHOURS_COLOR)
    );
    const workingHoursProcessData = {
      eventsEndDateFormatted,
      eventsStartDateFormatted,
      holidayHoursColor,
      supportedTimeZones,
      tzDtFormat,
      workingHoursColor
    };
    const content = yield select(getTechWorkingHours);
    const techniciansWorkingHours = getTechnicianWorkingHoursData(
      content,
      workingHoursProcessData,
      technicianIds
    );
    yield put({
      data: techniciansWorkingHours,
      key: KEY_TECHNICIANS_WORKING_HOURS,
      type: TECHNICIANS_WORKING_HOURS_LOADED
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_TECHNICIANS_WORKING_HOURS,
      type: TECHNICIANS_WORKING_HOURS_API_ERRORED
    });
  }
}

export function* eventsHoverRulesWorker() {
  try {
    yield put({ key: KEY_EVENTS, type: EVENTS_HOVER_REQUESTED });
    const response = yield call(getEventHoverOnlaunch);
    const { content } = response;
    yield put({
      data: { content },
      key: KEY_EVENTS_HOVER,
      type: EVENTS_HOVER_LOADED
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_EVENTS,
      type: EVENTS_HOVER_API_ERRORED
    });
  }
}

const buildFilterTechTree = (
  scheduledTechIds,
  technicians,
  teamIds,
  territoryList,
  isTeamView
) => {
  const scheduledTechnicians = [];
  uniq(scheduledTechIds).map(schTechId => {
    const technician = technicians[schTechId];
    if (technician) {
      const { technician_O: techObj } = technician;
      scheduledTechnicians.push(techObj);
    }
  });
  const treeNodes = [];
  if (isTeamView) {
    const inclusions = {};
    scheduledTechnicians.map(scheduledTechnician => {
      const teamId = getFieldValue(scheduledTechnician, TEAM_API_NAME);
      if (teamIds.includes(teamId)) {
        treeNodes.push({ isTech: true, ...scheduledTechnician });
        if (!inclusions[teamId]) {
          const serviceTeam = getFieldValue(scheduledTechnician, TEAM_API_REF);
          const serviceTeamCpy = cloneDeep(serviceTeam);
          inclusions[teamId] = serviceTeamCpy;
          serviceTeamCpy.expanded = true;
          treeNodes.push(serviceTeamCpy);
        }
      }
    });
  } else {
    const inclusions = {};
    const territoryIdMap = {};
    territoryList.map(territory => {
      const { Id } = territory;
      territoryIdMap[Id] = territory;
      return undefined;
    });
    scheduledTechnicians.map(scheduledTechnician => {
      const territoryId = getFieldValue(
        scheduledTechnician,
        TERRITORY_API_NAME
      );
      if (territoryIdMap[territoryId]) {
        treeNodes.push({ isTech: true, ...scheduledTechnician });
        if (!inclusions[territoryId]) {
          const territory = territoryIdMap[territoryId];
          const territoryCpy = cloneDeep(territory);
          inclusions[territoryId] = territoryCpy;
          territoryCpy.expanded = true;
          treeNodes.push(territoryCpy);
        }
      }
    });
  }
  const results = flatMap(orderBy(treeNodes, [NAME]), treeNode =>
    createSchedulerTreeNode(treeNode, isTeamView, treeNode.isTech)
  );
  return arrayToTree(results, ARRAY_TO_TREE_CONFIG);
};

export function* filterWorkOrderEventsWorker(action) {
  try {
    const { projectView = false } = action;
    let { workOrders: records } = action;
    if (!records || records.length <= 0) {
      records = yield select(getWorkOrders);
    }
    if (records && records.length) {
      yield put({ type: FILTERING_EVENTS_STARTED });
      const filterWOMap = {};
      const workOrderTechMap = {};
      records.map(record => {
        const { Id } = record;
        filterWOMap[Id] = record;
        workOrderTechMap[Id] = getFieldValue(
          record,
          WORKORDER_TECHNICIAN_API_NAME,
          null
        );
        return undefined;
      });
      const woIds = Object.keys(filterWOMap);
      const technicianIds = yield select(getAllTechnicianIds);
      const timeZoneDateTimeFormat = yield select(getTimeZone);
      const response = yield call(fetchAllEvents, {
        technicianIds,
        timeZoneDateTimeFormat,
        woIds
      });
      const { content, success, message } = response;
      if (!success) {
        const error = convertErrorToObject(response);
        yield put({
          data: { error, ...error },
          message,
          type: FILTERING_EVENTS_FAILED
        });
        return;
      }
      const { allEvents: events, woInfoMap } = content;
      const techEventGroup = groupBy(events, event => {
        const { event_WP: eventObject } = event;
        const { TechId } = eventObject || {};
        return TechId;
      });

      const scheduledTechIds = Object.keys(omit(techEventGroup, [undefined]));
      const schedulerState = yield select(getSchedularState);
      const { activeView } = schedulerState;
      let { teamView, territoryView } = schedulerState;
      const technicianData = yield select(getTechnicianData);
      const { technicians: techContent } = technicianData;
      const { data: datContent } = techContent;
      const { teamIds, technicians, territoryList } = datContent;

      let filteredTechIds = [...scheduledTechIds];
      if (filteredTechIds.length) {
        const assignedTechs = compact(Object.values(workOrderTechMap));
        const diffTechIds = difference(assignedTechs, filteredTechIds);
        if (diffTechIds.length) {
          filteredTechIds = filteredTechIds.concat(diffTechIds);
        }
      }

      const isTeamView = activeView === TEAM_INDEX;
      const tree = buildFilterTechTree(
        filteredTechIds,
        technicians,
        teamIds,
        territoryList,
        isTeamView
      );
      if (isTeamView) {
        teamView = tree;
      } else {
        territoryView = tree;
      }

      yield put({ type: EVENTS_LOADING_STARTED });
      const hoverRules = yield select(getHoverRules);
      const filterEvents = getEventsData({ events, woInfoMap }, hoverRules);
      yield put(
        schedulerStateChanged(
          {
            teamView,
            projectView,
            filterEvents,
            territoryView,
            newViewState: FILTER_EVENTS_RESULT
          },
          UPDATE_SCHEDULER_STATE
        )
      );
      yield put({ type: EVENTS_LOADING_COMPLETE });
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      type: FILTERING_EVENTS_ERRORED
    });
  }
}

export function* getWorkerOrderEventsWorker(action) {
  try {
    yield put({ key: KEY_WORKORDER_EVENTS, type: WORKORDER_EVENTS_REQUESTED });
    const { woId } = action;
    const timeZone = yield select(getUserTimeZone);
    const response = yield call(fetchWOEvents, {
      endDate: "",
      startDate: "",
      timeZone,
      woId
    });

    const { content, success, message } = response;
    if (!success) {
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        message,
        key: KEY_WORKORDER_EVENTS,
        type: WORKORDER_EVENTS_ERRORED
      });
      return;
    }

    yield put({
      data: content,
      key: KEY_WORKORDER_EVENTS,
      type: WORKORDER_EVENTS_LOADED
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_WORKORDER_EVENTS,
      type: WORKORDER_EVENTS_ERRORED
    });
  }
}

const getMultiAssignEvents = (payload, selectedWO, hoverRules) => {
  const multiAssignResult = {};
  const { eventWorkOrderInfo = {}, lstTechEventDetails = [] } = payload;
  if (lstTechEventDetails.length) {
    const deletedTechEventDetails = lstTechEventDetails.find(
      techEventDetail => {
        const { key } = techEventDetail;
        return key === DELETED_EVENT_IDS;
      }
    );
    if (deletedTechEventDetails) {
      const { valueList = [] } = deletedTechEventDetails;
      const [deletedEvents] = valueList;
      const deletedEventIds = deletedEvents ? deletedEvents.split(",") : [];
      if (deletedEventIds.length) {
        deletedEventIds.shift();
      }
      multiAssignResult.deletedEventIds = deletedEventIds;
    }
  }
  const { lstEvent: events = [], objWorkOrder } = eventWorkOrderInfo || {};
  const { workorder_O: workorder } = objWorkOrder || {};

  const { Id } = selectedWO;
  const woInfoMap = { [Id]: Object.assign({}, selectedWO, workorder || {}) };
  multiAssignResult.lstEvent = getEventsData({ events, woInfoMap }, hoverRules);
  return multiAssignResult;
};

export function* scheduleMultipleEventsWorker(action) {
  try {
    const {
      deletedEvents = [],
      editEvent,
      editFields,
      events,
      ownerId,
      subject
    } = action;
    if (!events || !events.length) {
      return;
    }

    yield put({
      key: KEY_MULTIASSIGN_EVENTS,
      type: MULTIASSIGN_EVENTS_REQUESTED
    });
    // Send always the technicain Id of the primary owner technician
    const technicianIds = [];
    const { Id } = events[events.length - 1];
    technicianIds.push(ownerId || Id);

    let techSFId = null;
    const selectedWO = yield select(getSelectedWO);
    const technicians = yield select(getAllTechnicians);
    const selectedWODispatchStatus = selectedWO[WO_DISPATCH_STATUS_FIELD];

    if (technicians[ownerId || Id]) {
      const { technician_O: technicianObj } = technicians[ownerId || Id];
      techSFId = getFieldValue(technicianObj, TECH_SALESFORCE_USER_FIELD, null);
    }

    const Eventlist = [];
    events.map(event => {
      Eventlist.push(
        createMultiAssignmentEvent(event, selectedWO, subject, technicians)
      );
      return undefined;
    });

    const EventIds = deletedEvents.filter(
      deletedId => !deletedId.includes("_")
    );
    const {
      afterDriveTime = 0,
      afterOHTime = 0,
      beforeDriveTime = 0,
      beforeOHTime = 0,
      serviceDuration = 0
    } = editEvent || events[0];
    const lstKeyValue = [
      {
        Key: `DRIVE_${selectedWO.Id}`,
        Value: beforeDriveTime
      },
      {
        Key: `OVERHEAD_${selectedWO.Id}`,
        Value: sum([beforeOHTime, afterOHTime])
      },
      {
        Key: `SERVICE_${selectedWO.Id}`,
        Value: serviceDuration * 60
      }
    ];

    // Add Updated Fields to the Request payload
    const updateFields = Object.keys(editFields);
    if (updateFields.length) {
      const editFieldKeyValues = updateFields.map(keyItem => {
        let Value = editFields[keyItem];
        const tokens = keyItem.split("_");
        const Key = tokens.length > 1 ? tokens[1] : tokens[0];
        if (isArray(Value)) {
          [Value] = Value;
          Value = Value === getDisplayValue(TAG280) ? "" : Value;
        } else if (Value instanceof moment) {
          Value = moment
            .utc(
              `${Value.format(DATE_FORMAT)} ${Value.format(TIME_FORMAT)}`,
              DATE_TIME_FORMAT
            )
            .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
          return { DateTimeValue: Value, Key, Value: "datetime" };
        }
        return { Key, Value };
      });
      lstKeyValue.push(...editFieldKeyValues);
    }

    const timezone = yield select(getUserTimeZone);
    const response = yield call(scheduleMultipleEvents, {
      EventIds,
      Eventlist,
      lstKeyValue,
      operationType: WO_UNASSIGN_NO,
      technicianIds,
      techSFId,
      timezone,
      workOrderIds: [selectedWO.Id]
    });

    const { content, message, success } = response;
    if (success) {
      yield put({
        data: content || {},
        key: KEY_MULTIASSIGN_EVENTS,
        type: MULTIASSIGN_EVENTS_COMPLETED
      });
      yield put({ type: EVENTS_LOADING_STARTED });
      const { eventWorkOrderInfo = {}, lstTechEventDetails = [] } = content;
      const { lstEvent, objWorkOrder } = eventWorkOrderInfo || {};
      const isSET051 = JSON.parse(getSettingValue(SET051, FALSE).toLowerCase());
      const isSET010 = JSON.parse(getSettingValue(SET010, FALSE).toLowerCase());
      if (objWorkOrder) {
        const view = yield select(getSelectedView);
        const { workorder_O: workorder } = objWorkOrder;
        if (
          isSET051 ||
          (selectedWODispatchStatus !==
            objWorkOrder[WO_DISPATCH_STATUS_FIELD] &&
            isSET010)
        ) {
          yield put({
            changed: { reload: true, view },
            type: VIEW_SELECTION_CHANGED
          });
        } else {
          // Get the Owner Technician from the last event detail sent in the request and update the grid workorder row.
          const { OwnerId } = workorder;
          const status = yield select(getStatus);
          // const loggedInUserId = yield select(getLoggedInUserId);
          const { OwnerId: loggedInUserId } = selectedWO;
          const WOSFMLaunch = yield select(isSingleWOLaunch);
          const ownerChanged = isOwnerChanged(OwnerId, loggedInUserId);

          // In case if SET009 is true and workorder is been assigned to salesforce user, remove it from dispatcher Queue.
          if (!WOSFMLaunch && ownerChanged && !isView(view)) {
            yield put({ type: REMOVE_WORKORDER, deleteWO: workorder });
          } else if (
            status === ALL ||
            status.includes(workorder[WO_DISPATCH_STATUS_FIELD])
          ) {
            // Update Grid WorkOrder row with all the fields returned in the response
            Object.assign(selectedWO, workorder);
          } else {
            // Based on Dispatch Status, either remove the workorder or update the status.
            yield put({ type: REMOVE_WORKORDER, deleteWO: workorder });
          }
          yield put({ type: UPDATE_GRID_STATE });
        }
      }
      const hoverRules = yield select(getHoverRules);
      yield put({
        data: getMultiAssignEvents(content, selectedWO, hoverRules),
        key: KEY_MULTIASSIGN_UPDATE,
        type: MULTIASSIGN_EVENTS_UPDATED
      });
      yield put(
        schedulerStateChanged(
          { newViewState: MULTI_ASSIGN_EVENT_UPDATE },
          UPDATE_SCHEDULER_STATE
        )
      );
      try {
        const [lstTechEventDetail] = lstTechEventDetails || [];
        const { valueList } = lstTechEventDetail || {};
        const deletedEvents =
          valueList && valueList.length
            ? compact(JSON.parse(valueList[0])).length
            : 0;
        yield put({
          type: EVENTS_LOADING_COMPLETE,
          content: {
            created: (lstEvent && lstEvent.length) || 0,
            updated: events.filter(event => event.scheduledEvent).length || 0,
            deleted: deletedEvents,
            dayEvent: events.filter(event => event.dayEvent).length || 0,
            eventType: getSettingValue(GLOB001_GBL025),
            mode: "Manage Multiple Assignment",
            workOrderEvent: true
          }
        });
      } catch (e) {}
      yield put({
        type: EVENTS_LOADING_COMPLETE
      });
    } else {
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        message,
        key: KEY_MULTIASSIGN_EVENTS,
        type: MULTIASSIGN_EVENTS_ERRORED
      });
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_MULTIASSIGN_EVENTS,
      type: MULTIASSIGN_EVENTS_ERRORED
    });
  }
}

export function* eventBusinessHoursWorker(action) {
  const { payload, callback, isBasicWH } = action;
  try {
    yield put({
      key: KEY_EVENT_BUSINESS_HOUR,
      type: EVENT_BUSINESS_HOUR_REQUESTED
    });
    const { EventEndDateTime, EventStartDateTime, timeZone } = payload;
    if (EventStartDateTime) {
      const withoutTimeZone = moment(
        EventStartDateTime,
        YODA_DATE_TIME_24_HR_FORMAT
      ).format(YODA_DATE_TIME_24_HR_FORMAT);

      payload.EventStartDateTime = momentTimezone
        .tz(withoutTimeZone, timeZone)
        .format(YODA_DATE_TIME_24_HR_FORMAT);
    }
    if (EventEndDateTime) {
      const withoutTimeZone1 = moment(
        EventEndDateTime,
        YODA_DATE_TIME_24_HR_FORMAT
      );
      payload.EventEndDateTime = momentTimezone
        .tz(withoutTimeZone1, timeZone)
        .format(YODA_DATE_TIME_24_HR_FORMAT);
    }
    const response = yield call(getEventBusinessHours, payload);
    const { content, message, success } = response;
    if (!success) {
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        message,
        type: EVENT_BUSINESS_HOUR_ERRORED
      });
      return;
    }
    const { EventExistinBusinessHour, advancedBusinessHours } = content;
    if (isBasicWH) {
      callback(EventExistinBusinessHour, isBasicWH);
    } else {
      callback(advancedBusinessHours, isBasicWH);
    }
    yield put({
      data: { content },
      key: KEY_EVENT_BUSINESS_HOUR,
      type: EVENT_BUSINESS_HOUR_LOADED
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_EVENT_BUSINESS_HOUR,
      type: EVENT_BUSINESS_HOUR_ERRORED
    });
  }
}

export function* fetchDeltaEventsWorker(action) {
  try {
    const technicianIds = yield select(getAllTechnicianIds);
    const techBatchSize = WIDE_RANGE_TECHNICIAN_BATCH;
    const { eventsEndDate, eventsStartDate } = yield select(getEventsTimings);
    const { lastModifiedDateTime } = yield select(getLastModifiedEvent);
    const tzDtFormat = yield select(getTimeZone);
    const technicianChunks = chunk(technicianIds, techBatchSize);
    const payload = {
      endDate: moment(eventsEndDate)
        .endOf("day")
        .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT),
      startDate: moment(eventsStartDate)
        .startOf("day")
        .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT),
      techIds: [],
      lastFetchedDateTime: lastModifiedDateTime,
      tzDtFormat
    };

    yield put({ type: UPDATE_EVENT_REQUESTED });
    const responseArray = yield all(
      technicianChunks.map(techIds => call(fetchDeltaEvents, payload, techIds))
    );

    let allEventsArr = [];
    let createEventArr = [];
    let deleteEventArrIds = [];
    const hoverRules = yield select(getHoverRules);
    responseArray.forEach(response => {
      const { content, success } = response;
      if (success) {
        const { createdEvents, deletedEventIds, allEvents } = modifyDeltaEvents(
          content,
          hoverRules
        );
        allEventsArr = allEventsArr.concat(allEvents);
        createEventArr = createEventArr.concat(createdEvents);
        deleteEventArrIds = deleteEventArrIds.concat(deletedEventIds);
      }
    });

    yield put({
      data: { createEventArr, deleteEventArrIds },
      key: KEY_FETCH_DELTA_EVENTS,
      type: EVENTS_FETCH_DELTA_EVENTS
    });

    const lastModifiedEvent = yield select(getLastModifiedEvent);

    if (!isEmpty(allEventsArr)) {
      const eventsList = isEmpty(lastModifiedEvent)
        ? allEventsArr
        : [...allEventsArr, lastModifiedEvent];

      yield put({
        type: EVENTS_LAST_MODIFIED_EVENT,
        key: KEY_EVENTS_LAST_MODIFIED_EVENT,
        data: sortLastModifiedEvent(eventsList)
      });
    }
    yield put({ type: EVENTS_LOADING_COMPLETE });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      type: EVENTS_LOADING_ERRORED
    });
  }
}

export function* removeWorkOrderWorker(action) {
  const { deleteWO } = action;
  if (!deleteWO || !deleteWO.Id) {
    return;
  }

  const { Id } = deleteWO;
  const selectedWO = yield select(getSelectedWO);
  if (selectedWO && selectedWO.Id === Id) {
    yield put({ type: UPDATE_GRID_STATE, config: { "-": ["row"] } });
  }

  const workorders = yield select(getWorkOrders);
  const index = workorders.findIndex(workOrder => workOrder.Id === Id);
  if (index !== -1 && index < workorders.length) {
    workorders.splice(index, 1);
  }
}

export function* eventsWatcher() {
  yield takeLatest(GET_EVENTS, eventsWorker);
  yield takeLatest(GET_EVENT_HOVER_RULES, eventsHoverRulesWorker);
  yield takeLatest(
    START_EVENTS_AFTER_LAUNCH,
    eventsWorkerStartEventsAfterLaunch
  );

  // Loading events for wide range
  yield takeEvery(GET_EVENT_IDS, getEventIDsWorker);
  yield takeEvery(LOAD_EVENT_IDS, loadEventIDsWorker);
  yield takeEvery(LOAD_ALL_EVENT_IDS, loadConcurrentEventIDsWorker);
  yield takeLatest(LOAD_WIDE_RANGE_EVENTS, loadWideRangeEventsWorker);

  yield takeEvery(CREAT_EVENT, createEventWorker);
  yield takeEvery(UPDATE_EVENT, updateEventWorker);
  yield takeLatest(CREAT_LJS_EVENT, createLJSeventWorker);

  yield takeLatest(GET_EVENT_SUBJECT, getEventSubjectWorker);
  yield takeLatest(CREAT_EVENT_FOR_TREE, createEventForTreeWorker);

  yield takeLatest(UPDATE_TECH_CHANGE_EVENT, updateTechChangeEventWorker);
  yield takeEvery(GET_EVENTS_AFTER_LAUNCH, eventsWorkerGetEventAfterLaunch);
  yield takeLatest(
    GET_TECHNICIANS_WORKING_HOURS,
    getTechnicianWorkingHourWorker
  );
  yield takeLatest(
    UPDATE_TECHNICIAN_WORKING_HOURS,
    updateTechWorkingHoursWorker
  );
  yield takeLatest(GET_WORKORDER_EVENTS, getWorkerOrderEventsWorker);
  yield takeLatest(FILTER_WORKORDER_EVENTS, filterWorkOrderEventsWorker);
  yield takeLatest(SCHEDULE_MULTIPLE_EVENTS, scheduleMultipleEventsWorker);
  yield takeLatest(GET_EVENT_BUSINESS_HOUR, eventBusinessHoursWorker);
  yield takeEvery(FETCH_DELTA_EVENTS, fetchDeltaEventsWorker);
  yield takeEvery(REMOVE_WORKORDER, removeWorkOrderWorker);
}
