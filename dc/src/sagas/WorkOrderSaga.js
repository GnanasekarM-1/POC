import { delay, takeLatest, call, put, select } from "redux-saga/effects";
import {
  DELTA_WORK_ORDER_REQUESTED,
  DELTA_WORK_ORDER_LOADED,
  DELTA_WORK_ORDER_ERROR,
  KEY_DELTA_WORK_ORDER,
  KEY_USER_TIMEZONE,
  KEY_WORKORDERS,
  UPDATE_SCHEDULER_STATE,
  KEY_WORKORDER_FIELD_LIST,
  GET_DELTA_WORK_ORDER,
  GET_WORKORDERS,
  GET_WORKORDER_FIELD_LIST,
  UPDATE_GRID_STATE,
  KEY_VIEWS,
  VIEWS_LOADED,
  LOCALE_LOADED,
  WORKORDERS_REQUESTED,
  WORKORDER_FIELD_LIST_REQUESTED,
  WORKORDERS_LOADED,
  WORKORDER_FIELD_LIST_LOADED,
  WORKORDERS_API_ERRORED,
  WORKORDER_FIELD_LIST_API_ERRORED,
  GET_WORKORDER,
  FILTER_WORKORDER_EVENTS,
  GET_VIEW_WORKORDER_COUNT
} from "constants/ActionConstants";
import {
  TAG111,
  TAG522,
  TAG523,
  TAG415,
  TAG416
} from "constants/DisplayTagConstants";
import { isEmpty } from "lodash";
import {
  DEFAULT_PAGE_SIZE,
  SET073,
  getSettingValue
} from "constants/AppSettings";
import {
  MAX_RETRY_ATTEMPT,
  ADDRESS_FIELDS,
  DEFAULT_TIME_FORMAT
} from "constants/AppConstants";
import { getView } from "utils/ViewUtils";
import WorkOrderService from "services/WorkOrderService";
import {
  convertErrorToObject,
  getFieldValues,
  getUserSetting,
  getDisplayValue
} from "utils/DCUtils";
import { VIEW_COUNTER } from "constants/UserSettingConstants";
import { isUndefined } from "util";

const getWorkOrder = woId =>
  WorkOrderService.getWorkOrder(woId).then(response => response.json());

const getWorkOrders = action => {
  const {
    batchSize,
    filterColumn,
    page,
    nextRecordsUrl,
    sorted,
    status,
    filterText,
    view
  } = action;
  return WorkOrderService.getWorkOrders(
    filterColumn,
    page,
    nextRecordsUrl,
    sorted,
    status,
    filterText,
    view,
    batchSize
  ).then(response => response.json());
};

const getBatchSize = ({ gridState }) => {
  const { batchSize } = gridState || {};
  return batchSize || DEFAULT_PAGE_SIZE;
};

const getSelectedWO = ({ gridState }) => {
  const { row } = gridState || {};
  return row;
};

const getSelectedView = ({ gridState }) => {
  const { view } = gridState || {};
  return view;
};

const isMultiPage = ({ gridState, workOrderData }) => {
  const { page = 0 } = gridState || {};
  const { workOrders } = workOrderData;
  const { content } = workOrders;
  if (!content || !page) {
    return true;
  }
  const { totalSize = 0 } = content;
  const pageSize =
    page *
    Math.max(getSettingValue(SET073, DEFAULT_PAGE_SIZE), DEFAULT_PAGE_SIZE);
  return parseInt(totalSize, 10) > pageSize;
};

const getConfiguredViews = () => {
  const viewCounters = getUserSetting(VIEW_COUNTER, {});
  const views = [];
  Object.values(viewCounters).map(viewCounter => {
    const { id } = viewCounter;
    if (!isEmpty(id)) {
      views.push(id);
    }
    return undefined;
  });
  return views;
};

const getWorkOrderFields = () =>
  WorkOrderService.getWorkOrderFields().then(response => response.json());

const getDeltaWorkOrderData = action => {
  const { payload } = action;
  return WorkOrderService.getDeltaWorkOrders(payload).then(response =>
    response.json()
  );
};

export function* getWorkOrdersWorker(action) {
  const {
    key,
    page,
    reload,
    filterEvents,
    projectView,
    view,
    sorted = {},
    filterColumnDisplay = ""
  } = action;
  const { sortColumnDisplay = "" } = sorted;
  const isInitial = view ? false : true;
  try {
    yield put({ key, message: reload && TAG111, type: WORKORDERS_REQUESTED });
    let batchSize = yield select(getBatchSize);
    const response = yield call(getWorkOrders, { batchSize, ...action });
    const { content = undefined, success, message, errorCode } = response;
    if (!success && errorCode) {
      // This is a HACK in the form of maximum 2 retry attempts with 1000 millis delay in every request.
      const { retry = 1 } = action;
      // const selectedView = yield select(getSelectedView);
      // if (!selectedView && retry < MAX_RETRY_ATTEMPT) {
      const error = convertErrorToObject(response);
      if (error.message === TAG522 || error.message === TAG523) {
        if (error.message === TAG522) {
          error.message = `${getDisplayValue(
            TAG416
          )}: ${sortColumnDisplay} ${getDisplayValue(error.message)}`;
        } else if (error.message === TAG523) {
          error.message = `${getDisplayValue(
            TAG415
          )}: ${filterColumnDisplay} ${getDisplayValue(error.message)}`;
        }
        //error.message = ` ${columnDisplay} ${getDisplayValue(error.message)}`;
        yield put({
          data: { error, ...error },
          message: error.message,
          key,
          type: WORKORDERS_API_ERRORED
        });
        return;
      } else {
        if (retry < MAX_RETRY_ATTEMPT) {
          yield delay(1000);
          yield put({ ...action, retry: retry + 1 });
          return;
        }

        yield put({
          data: { error, ...error },
          message,
          key,
          type: WORKORDERS_API_ERRORED
        });
        return;
      }
    }
    const { localTimeZone, nextRecordsUrl, records, soql, viewId, views } =
      content || response;

    let pageSize = DEFAULT_PAGE_SIZE;
    try {
      pageSize = parseInt(getSettingValue(SET073, DEFAULT_PAGE_SIZE), 10);
    } catch (e) {}

    // In case of view change and launch, capture the batch size from returned records.
    if (isUndefined(page) && nextRecordsUrl) {
      batchSize = records.length;
    }

    // Set the default selected view to gridState
    // Store the SOQL Query used to query WorkOrders
    // Get all the views & Queues and set it to view store.
    if (viewId && views && views.length) {
      const view = getView(views, viewId);
      yield put({
        changed: {
          batchSize,
          nextRecordsUrl,
          soql,
          view,
          page: 0
        },
        type: UPDATE_GRID_STATE
      });
      yield put({ data: views, key: KEY_VIEWS, type: VIEWS_LOADED });
      delete content.viewId;
      delete content.views;
      // Page Number won't be present on changing the view. Hence update the new nextRecordsUrl & soql.
    } else if (isUndefined(page)) {
      yield put({
        changed: { batchSize, nextRecordsUrl, soql },
        type: UPDATE_GRID_STATE
      });
    }

    // Store User Locale details into store.
    if (localTimeZone) {
      const { id, displayName } = localTimeZone;
      yield put({
        data: {
          name: id,
          value: displayName,
          defaultTZ: id,
          ...localTimeZone
        },
        key: KEY_USER_TIMEZONE,
        type: LOCALE_LOADED
      });
      const { configData = {} } = window;
      yield put({
        changed: {
          timeZone: `${id}@${configData.userTimeFormat || DEFAULT_TIME_FORMAT}`
        },
        type: UPDATE_SCHEDULER_STATE
      });
      delete content.localTimeZone;
    }

    let updateSelectedWO = null;
    const selectedWO = yield select(getSelectedWO);
    // Load Workorders from the response
    if (records && records.length) {
      records.map((record, i) => {
        // Check if the response has latest version of selected workorder.
        if (selectedWO && selectedWO.Id === record.Id) {
          updateSelectedWO = record;
        }
        record.address = getFieldValues(record, ADDRESS_FIELDS, true).join();
        return undefined;
      });
    }
    // In case if we have latest selected workorder. Update it.
    if (updateSelectedWO) {
      yield put({
        changed: { row: updateSelectedWO },
        type: UPDATE_GRID_STATE
      });
    }

    yield put({
      data: content || response,
      key,
      type: WORKORDERS_LOADED,
      viewError: message && !message.includes("Succes")
    });

    if (message && !message.includes("Succes")) {
      const error = { message, errorCode: 500, success: false };
      yield put({
        data: { error, ...error },
        message,
        key,
        type: WORKORDERS_API_ERRORED
      });
    }
    if (filterEvents) {
      yield put({
        projectView,
        type: FILTER_WORKORDER_EVENTS
      });
    }
    if (!isInitial) {
      const configuredViews = yield select(getConfiguredViews);
      yield put({ configuredViews, type: GET_VIEW_WORKORDER_COUNT });
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message }, errorCode, message },
      key,
      type: WORKORDERS_API_ERRORED
    });
  }
}

export function* getWorkOrderWorker(action) {
  try {
    const {
      woId,
      woLaunch,
      key,
      reload,
      filterEvents,
      projectView,
      view
    } = action;
    const isInitial = view ? false : true;

    yield put({
      key: KEY_WORKORDERS,
      message: reload && TAG111,
      type: WORKORDERS_REQUESTED
    });
    const response = yield call(getWorkOrder, woId);
    const { content = undefined, success, message, errorCode } = response;
    if (!success && errorCode) {
      // This is a HACK in the form of maximum 2 retry attempts with 1000 millis delay in every request.
      const { retry = 0 } = action;
      // const selectedView = yield select(getSelectedView);
      // if (!selectedView && retry < 2) {
      if (retry < 2) {
        yield delay(1000);
        yield put({ ...action, retry: retry + 1 });
        return;
      }
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        message,
        key,
        type: WORKORDERS_API_ERRORED
      });
      return;
    }

    const { localTimeZone, records, views } = content || response;

    // Get all the views & Queues and set it to view store.
    // Set the default selected view to gridState
    if (views && views.length) {
      const [record] = records;
      const { Name, Id } = record;
      const view = {
        Key: Id,
        type: "WO",
        Value: Name,
        woViewType: null
      };
      views.unshift(view);
      yield put({ data: views, key: KEY_VIEWS, type: VIEWS_LOADED });
      const selectedView = yield select(getSelectedView);
      yield put({
        changed: { row: record, view: woLaunch ? view : selectedView || view },
        type: UPDATE_GRID_STATE
      });
      delete content.views;
      delete content.viewId;
    }

    // Store User Locale details into store.
    if (localTimeZone) {
      const { id, displayName } = localTimeZone;
      yield put({
        data: {
          name: id,
          value: displayName,
          defaultTZ: id,
          ...localTimeZone
        },
        key: KEY_USER_TIMEZONE,
        type: LOCALE_LOADED
      });
      const { configData = {} } = window;
      yield put({
        changed: {
          timeZone: `${id}@${configData.userTimeFormat || DEFAULT_TIME_FORMAT}`
        },
        type: UPDATE_SCHEDULER_STATE
      });
      delete content.localTimeZone;
    }

    if (records && records.length) {
      records.map(record => {
        record.address = getFieldValues(record, ADDRESS_FIELDS, true).join();
        return undefined;
      });
      // In case of single WO Launch, Make it selected by default.
      const [row] = records;
      yield put({
        changed: { gridActive: true, row },
        type: UPDATE_GRID_STATE
      });
    }
    yield put({
      data: content || response,
      key: KEY_WORKORDERS,
      type: WORKORDERS_LOADED
    });

    if (filterEvents) {
      yield put({
        projectView,
        type: FILTER_WORKORDER_EVENTS
      });
    }
    if (!isInitial) {
      const configuredViews = yield select(getConfiguredViews);
      yield put({ configuredViews, type: GET_VIEW_WORKORDER_COUNT });
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message }, errorCode, message },
      key: KEY_WORKORDERS,
      type: WORKORDERS_API_ERRORED
    });
  }
}

export function* workOrderFieldsWorker() {
  try {
    yield put({
      key: KEY_WORKORDER_FIELD_LIST,
      type: WORKORDER_FIELD_LIST_REQUESTED
    });
    const payload = yield call(getWorkOrderFields);
    // Create Map of Work Order Fields in key & value format to make retreival faster.
    const data = {};
    const { fields } = payload;
    fields.forEach(field => {
      const { name, label, type } = field;
      data[name] = {
        display: label,
        fieldType: type,
        value: name
      };
    });
    yield put({
      data,
      key: KEY_WORKORDER_FIELD_LIST,
      type: WORKORDER_FIELD_LIST_LOADED
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_WORKORDER_FIELD_LIST,
      type: WORKORDER_FIELD_LIST_API_ERRORED
    });
  }
}

export function* deltaWorkOrderWorker(action) {
  try {
    yield put({ key: KEY_DELTA_WORK_ORDER, type: DELTA_WORK_ORDER_REQUESTED });
    const payload = yield call(getDeltaWorkOrderData, action);
    const { callback } = action;
    const { content } = payload;
    const deltaData = Object.keys(content);
    if (deltaData) {
      deltaData.map(item => {
        if (content[item]) {
          content[item].address = getFieldValues(
            content[item],
            ADDRESS_FIELDS,
            true
          ).join();
        }
      });
    }
    yield put({
      data: content,
      key: KEY_DELTA_WORK_ORDER,
      type: DELTA_WORK_ORDER_LOADED
    });
    callback();
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_DELTA_WORK_ORDER,
      type: DELTA_WORK_ORDER_ERROR
    });
  }
}

export function* workOrderWatcher() {
  yield takeLatest(GET_WORKORDER, getWorkOrderWorker);
  yield takeLatest(GET_WORKORDERS, getWorkOrdersWorker);
  yield takeLatest(GET_WORKORDER_FIELD_LIST, workOrderFieldsWorker);
  yield takeLatest(GET_DELTA_WORK_ORDER, deltaWorkOrderWorker);
}
