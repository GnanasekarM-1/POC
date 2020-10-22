import { takeLatest, call, put } from "redux-saga/effects";

import {
  KEY_DEPLOY_USER_SETTINGS,
  GET_DISPATCHER_LIST,
  DISPATCHER_LIST_REQUESTED,
  DISPATCHER_LIST_LOADED,
  DISPATCHER_LIST_ERRORED,
  POST_USER_SETTINGS,
  POST_USER_SETTINGS_REQUESTED,
  POST_USER_SETTINGS_LOADED,
  POST_USER_SETTINGS_ERRORED
} from "constants/ActionConstants";

import DeployUserSettingsService from "services/DeployUserSettingsService";

const getDispatcherList = () =>
  DeployUserSettingsService.getDispatcherList().then(response =>
    response.json()
  );
const deployUserSettings = payload =>
  DeployUserSettingsService.deployUserSettings(payload).then(response =>
    response.json()
  );

export function* getDispatcherListWorker(action) {
  try {
    yield put({
      key: KEY_DEPLOY_USER_SETTINGS,
      type: DISPATCHER_LIST_REQUESTED
    });
    const payload = yield call(getDispatcherList, action);
    const { content } = payload;
    const { DispatcherList: teams, RecordList: dispatchers } = content;
    const teamList = [];
    const dispatcherList = [];
    dispatchers.forEach(iteam => {
      const { Name, Id } = iteam;
      const dispatcherObject = {
        id: Id,
        name: Name
      };
      dispatcherList.push(dispatcherObject);
    });
    teams.forEach(iteam => {
      const { Value, Key, ValueList } = iteam;
      const teamObject = {
        id: Key,
        name: Value,
        valueList: ValueList
      };
      teamList.push(teamObject);
    });
    yield put({
      data: { dispatcherList, teamList },
      key: KEY_DEPLOY_USER_SETTINGS,
      type: DISPATCHER_LIST_LOADED
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_DEPLOY_USER_SETTINGS,
      type: DISPATCHER_LIST_ERRORED
    });
  }
}
export function* deployUserSettingsWorker(action) {
  try {
    const { callback } = action;
    const { payload: requestPayload } = action;
    const payload = yield call(deployUserSettings, requestPayload);
    callback(payload);
    yield put({
      key: KEY_DEPLOY_USER_SETTINGS,
      type: POST_USER_SETTINGS_LOADED
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_DEPLOY_USER_SETTINGS,
      type: POST_USER_SETTINGS_ERRORED
    });
  }
}

export function* deployUserSettingsWatcher() {
  yield takeLatest(GET_DISPATCHER_LIST, getDispatcherListWorker);
  yield takeLatest(POST_USER_SETTINGS, deployUserSettingsWorker);
}
