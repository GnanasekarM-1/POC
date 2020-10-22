import { all } from "redux-saga/effects";

import { metaDataWatcher } from "sagas/MetaDataSaga";
import { workOrderWatcher } from "sagas/WorkOrderSaga";
import { viewWatcher } from "sagas/ViewDataSaga";
import { userSettingWatcher } from "sagas/UserSettingSaga";
import { gridStateWatcher } from "sagas/GridStateSaga";
import { techniciansWatcher } from "sagas/TechnicianSaga";
import { eventsWatcher } from "sagas/EventsSaga";
import { schedulerStateWatcher } from "sagas/SchedulerStateSaga";
import { deployUserSettingsWatcher } from "sagas/DeployUserSettingsSaga";
import { MAP_CUSTOM_EVENT_CLOSE_CHILD_WINDOW } from "constants/MapConstants";

import store from "store";
import { isEqual } from "lodash";
import UserSettingService from "services/UserSettingService";

export default function* rootSaga() {
  yield all([
    deployUserSettingsWatcher(),
    eventsWatcher(),
    metaDataWatcher(),
    workOrderWatcher(),
    viewWatcher(),
    userSettingWatcher(),
    gridStateWatcher(),
    techniciansWatcher(),
    schedulerStateWatcher()
  ]);
}

window.onbeforeunload = () => {
  localStorage.removeItem("DCHTML");
  localStorage.removeItem("DCHTML_ACTIVE");
  clearInterval(window.dcxRefreshInterval);
  const event = new CustomEvent(MAP_CUSTOM_EVENT_CLOSE_CHILD_WINDOW, {
    detail: true
  });
  window.dispatchEvent(event);
  const state = store.getState();
  const { userSettings } = state;
  if (
    sessionStorage.LastSaved &&
    userSettings &&
    !isEqual(userSettings, JSON.parse(sessionStorage.LastSaved))
  ) {
    UserSettingService.saveUserSettings(userSettings);

    // HACK FIX: no-op loop to make sure save call is complete.
    let i = 1;
    const MAX_NO_OPS = 2000;
    while (i <= MAX_NO_OPS) {
      console.log("NO-OPERATION LOOP TO COMPLETE SAVE");
      i += 1;
    }
  }
};

window.onstorage = e => {
  const { key, newValue, target } = e;
  if (key === "DCHTML" && newValue) {
    if (newValue !== "MULTI") {
      store.dispatch({
        type: "GET_WORKORDER",
        key: "KEY_WORKORDERS",
        woLaunch: true,
        woId: decodeURIComponent(newValue)
      });
    } else {
      store.dispatch({
        type: "GET_WORKORDERS",
        key: "KEY_WORKORDERS"
      });
    }
    target.focus();
  }
};

window.dcxRefreshInterval = setInterval(() => {
  localStorage.setItem("DCHTML_ACTIVE", new Date().getTime());
}, 10000);
