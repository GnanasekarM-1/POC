import { takeLatest, call, put, takeEvery } from "redux-saga/effects";

import {
  GET_VIEW_WORKORDER_COUNT,
  GET_VIEW_DEFINITION,
  GET_MAP_VIEW_DATA,
  KEY_VIEW_DEFINITION,
  KEY_MAP_VIEW_DATA,
  KEY_VIEW_WORKORDER_COUNT,
  VIEW_WORKORDER_COUNT_REQUESTED,
  VIEW_DEFINITION_REQUESTED,
  MAP_VIEW_DATA_REQUESTED,
  VIEW_WORKORDER_COUNT_LOADED,
  VIEW_DEFINITION_LOADED,
  MAP_VIEW_DATA_LOADED,
  VIEW_WORKORDER_COUNT_API_ERRORED,
  VIEW_DEFINITION_API_ERRORED,
  MAP_VIEW_DATA_API_ERRORED,
  MAP_VIEW_DATA_CLEAR,
  MAP_VIEW_DATA_CLEARED
} from "constants/ActionConstants";
import {
  ACCOUNT_API_NAME,
  LOCATION_API_NAME,
  WORKORDER_API_NAME
} from "constants/AppConstants";
import {
  MAP_VIEW_VIEW_ID,
  MAP_ACCOUNT_VIEW,
  MAP_LOCATION_VIEW,
  MAP_WORKORDER_VIEW
} from "constants/MapConstants";
import ViewDataService from "services/ViewDataService";
import { TAG140, TAG139 } from "constants/DisplayTagConstants";

const getViewWorkOrderCount = action => {
  const { configuredViews } = action;
  return ViewDataService.getViewWorkOrderCount(configuredViews).then(response =>
    response.json()
  );
};

const getViewDefinition = action => {
  const { objectTypes, viewTypes } = action;
  return ViewDataService.getViewDefinition(
    objectTypes,
    viewTypes
  ).then(response => response.json());
};

function getMapViewData(action) {
  const { payload } = action;
  return ViewDataService.getMapViewData(payload).then(response =>
    response.json()
  );
}

export function* getViewDefnWorker(action) {
  try {
    yield put({ key: KEY_VIEW_DEFINITION, type: VIEW_DEFINITION_REQUESTED });
    const payload = yield call(getViewDefinition, action);
    const { content } = payload;
    const accountView = [];
    const locationView = [];
    const workOrderView = [];
    const { stringMap } = payload.content;
    stringMap.map(item => {
      const { key } = item;
      item.checked = false;
      if (key === ACCOUNT_API_NAME) {
        accountView.push(item);
      } else if (key === LOCATION_API_NAME) {
        locationView.push(item);
      } else if (key === WORKORDER_API_NAME) {
        workOrderView.push(item);
      }
      return undefined;
    });
    payload.content[MAP_ACCOUNT_VIEW] = accountView;
    payload.content[MAP_LOCATION_VIEW] = locationView;
    payload.content[MAP_WORKORDER_VIEW] = workOrderView;
    yield put({
      data: content,
      key: KEY_VIEW_DEFINITION,
      type: VIEW_DEFINITION_LOADED
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      message: TAG139,
      key: KEY_VIEW_DEFINITION,
      type: VIEW_DEFINITION_API_ERRORED
    });
  }
}

export function* getViewWOCountWorker(action) {
  try {
    yield put({
      key: KEY_VIEW_WORKORDER_COUNT,
      type: VIEW_WORKORDER_COUNT_REQUESTED
    });
    const payload = yield call(getViewWorkOrderCount, action);
    const data = {};
    const { content } = payload;
    content.map(count => {
      const { viewId, WOcount } = count;
      data[viewId] = WOcount;
      return undefined;
    });
    yield put({
      data,
      key: KEY_VIEW_WORKORDER_COUNT,
      type: VIEW_WORKORDER_COUNT_LOADED
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_VIEW_WORKORDER_COUNT,
      type: VIEW_WORKORDER_COUNT_API_ERRORED
    });
  }
}

export function* getMapViewDataWorker(action) {
  try {
    yield put({ key: KEY_MAP_VIEW_DATA, type: MAP_VIEW_DATA_REQUESTED });
    const payload = yield call(getMapViewData, action);
    const { StringLstMap } = payload.content;
    const { objectName } = action;
    StringLstMap.objectName = objectName;
    if (objectName === WORKORDER_API_NAME) {
      payload.content.workOrderViewList = StringLstMap || [];
    } else if (objectName === LOCATION_API_NAME) {
      payload.content.locationViewList = StringLstMap || [];
    } else if (objectName === ACCOUNT_API_NAME) {
      payload.content.accountViewList = StringLstMap || [];
    }
    yield put({
      data: payload.content,
      key: KEY_MAP_VIEW_DATA,
      type: MAP_VIEW_DATA_LOADED
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      message: TAG140,
      key: KEY_MAP_VIEW_DATA,
      type: MAP_VIEW_DATA_API_ERRORED
    });
  }
}

export function* getMapViewDataClearWorker() {
  yield put({
    data: [],
    key: KEY_MAP_VIEW_DATA,
    type: MAP_VIEW_DATA_CLEARED
  });
}

export function* viewWatcher() {
  yield takeLatest(GET_VIEW_DEFINITION, getViewDefnWorker);
  yield takeLatest(GET_VIEW_WORKORDER_COUNT, getViewWOCountWorker);
  yield takeEvery(GET_MAP_VIEW_DATA, getMapViewDataWorker);
  yield takeEvery(MAP_VIEW_DATA_CLEAR, getMapViewDataClearWorker);
}
