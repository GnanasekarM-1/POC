import { select, takeLatest, call, put } from "redux-saga/effects";
import { isEmpty, isEqual } from "lodash";

import {
  KEY_USER_SETTINGS,
  GET_USER_SETTINGS,
  UPDATE_GRID_STATE,
  GET_WORKORDERS,
  KEY_NEXT_WORKORDERS,
  APPLY_USER_SETTINGS,
  USER_SETTINGS_API_ERRORED,
  USER_SETTINGS_LOADED,
  USER_SETTINGS_REQUESTED,
  GET_VIEW_WORKORDER_COUNT,
  SAVE_USER_SETTINGS,
  RESET_USER_SETTINGS,
  AUTO_SAVE_USER_SETTINGS,
  SAVING_USER_SETTINGS,
  SAVING_USER_SETTINGS_API_ERRORED,
  RESET_USER_SETTINGS_ERRORED
} from "constants/ActionConstants";
import { VIEW_COUNTER } from "constants/UserSettingConstants";
import {
  getSettingValue,
  DCON001_SET007,
  DCON001_SET008,
  CACHE_WORKORDERS
} from "constants/AppSettings";
import { FALSE } from "constants/AppConstants";
import { convertErrorToObject, getUserSetting } from "utils/DCUtils";
import UserSettingService from "services/UserSettingService";

const getNextRecordsUrl = ({ gridState }) => {
  const { nextRecordsUrl } = gridState;
  return nextRecordsUrl;
};

const hasMoreWorkOrders = ({ workOrderData }) => {
  const { workOrders } = workOrderData;
  const { content } = workOrders;
  const { done } = content;
  return !JSON.parse(done);
};

const getAllWorkOrders = ({ workOrderData }) => {
  const { workOrders } = workOrderData;
  const { content = {} } = workOrders;
  const { records } = content;
  return records || [];
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

const getUserSettingFromStore = ({ userSettings }) => userSettings;

const getUserSettings = () =>
  UserSettingService.getUserSettings().then(response => response.json());

const saveUserSettings = settings =>
  UserSettingService.saveUserSettings(settings).then(response =>
    response.json()
  );

const resetUserSettings = () =>
  UserSettingService.resetUserSettings().then(response => response.json());

export function* saveUserSettingWorker() {
  try {
    yield put({ type: SAVING_USER_SETTINGS });
    const settings = yield select(getUserSettingFromStore);
    if (!settings) {
      return;
    }
    const response = yield call(saveUserSettings, settings);
    const { message, success } = response;
    if (!success) {
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        type: SAVING_USER_SETTINGS_API_ERRORED,
        message
      });
      return;
    }
    yield put({ type: USER_SETTINGS_LOADED });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message }, errorCode, message },
      type: SAVING_USER_SETTINGS_API_ERRORED,
      message
    });
  }
}

export function* runAutoSaveUserSettingWorker() {
  try {
    const text = sessionStorage.getItem("LastSaved");
    const oldSettings = JSON.parse(text || {});
    const newSettings = yield select(getUserSettingFromStore);
    if (!isEqual(oldSettings, newSettings)) {
      yield put({ type: SAVE_USER_SETTINGS });
    }
    // eslint-disable-next-line no-empty
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      type: SAVING_USER_SETTINGS_API_ERRORED
    });
  }
}

export function* getUserSettingsWorker() {
  try {
    yield put({ key: KEY_USER_SETTINGS, type: USER_SETTINGS_REQUESTED });
    const content = yield call(getUserSettings);
    yield put({
      data: content,
      key: KEY_USER_SETTINGS,
      type: USER_SETTINGS_LOADED
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_USER_SETTINGS,
      type: USER_SETTINGS_API_ERRORED
    });
  }
}

export function* applyUserSettingWorker() {
  const configuredViews = yield select(getConfiguredViews);
  yield put({ configuredViews, type: GET_VIEW_WORKORDER_COUNT });

  const status = getSettingValue(DCON001_SET007);
  const changed = { status };

  const autoSelectWorkOrder = JSON.parse(
    getSettingValue(DCON001_SET008, FALSE).toLowerCase()
  );
  const records = yield select(getAllWorkOrders);
  const { length } = records;
  if (length === 1 && autoSelectWorkOrder) {
    const [row] = records;
    changed.row = row;
    changed.gridActive = true;
  }
  yield put({
    changed,
    type: UPDATE_GRID_STATE
  });

  if (CACHE_WORKORDERS) {
    const page = 0;
    const nextRecordsUrl = yield select(getNextRecordsUrl);
    const hasNext = yield select(hasMoreWorkOrders);
    if (hasNext && nextRecordsUrl) {
      yield put({
        key: KEY_NEXT_WORKORDERS,
        nextRecordsUrl,
        page: page + 1,
        type: GET_WORKORDERS
      });
    }
  }
}

export function* resetUserSettingWorker() {
  try {
    const response = yield call(resetUserSettings);
    const { message, success } = response;
    if (!success) {
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        message,
        type: RESET_USER_SETTINGS_ERRORED
      });
      return;
    }
    yield put({ type: USER_SETTINGS_LOADED });
    window.location.reload();
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message }, errorCode, message },
      type: RESET_USER_SETTINGS_ERRORED
    });
  }
}

export function* userSettingWatcher() {
  yield takeLatest(GET_USER_SETTINGS, getUserSettingsWorker);
  yield takeLatest(APPLY_USER_SETTINGS, applyUserSettingWorker);
  yield takeLatest(SAVE_USER_SETTINGS, saveUserSettingWorker);
  yield takeLatest(RESET_USER_SETTINGS, resetUserSettingWorker);
  yield takeLatest(AUTO_SAVE_USER_SETTINGS, runAutoSaveUserSettingWorker);
}
