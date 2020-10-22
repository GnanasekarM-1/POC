import { takeLatest, call, put } from "redux-saga/effects";

import {
  GET_APP_METADATA,
  KEY_METADATA,
  KEY_APP_SETTINGS,
  KEY_USER_SETTINGS,
  GET_METADATA,
  METADATA_LOADED,
  GET_APP_SETTINGS,
  KEY_WORKORDERS,
  GET_WORKORDERS_ACTION,
  GET_TECHNICIAN_ACTION,
  GET_EVENTS_ACTION,
  GET_EVENT_HOVER_INFO_ACTION,
  GET_METADATA_ACTION,
  GET_APP_SETTINGS_ACTION,
  GET_VIEW_DEFINITION_ACTION,
  KEY_DISPLAY_TAGS,
  DISPLAY_TAGS_LOADED,
  KEY_TECHNICIANS_METADATA,
  KEY_TEAM_METADATA,
  KEY_EVENTS_METADATA,
  KEY_TECH_SKILLS,
  TECHNICIANS_METADATA_LOADED,
  EVENTS_METADATA_LOADED,
  KEY_WORKORDER_FIELD_LIST,
  WORKORDER_FIELD_LIST_LOADED,
  KEY_TIMEZONES,
  TIMEZONE_LOADED,
  METADATA_REQUESTED,
  METADATA_API_ERRORED,
  TECHNICIAN_SKILLS_LOADED,
  TEAM_METADATA_LOADED,
  APP_SETTINGS_LOADED,
  USER_SETTINGS_LOADED,
  GET_WORKORDER,
  APP_SETTINGS_API_ERRORED,
  APP_SETTINGS_REQUESTED
} from "constants/ActionConstants";
import { isNull } from "util";
import { isEmpty, orderBy } from "lodash";
import { DEFAULT_SORT_ORDER } from "constants/AppConstants";
import MetaDataService from "services/MetaDataService";
// import { addInterceptor } from 'services/service';
import { getURLParams } from "utils/DCUtils";

const SKILLNAME = "skillName";

const getMetaData = () =>
  MetaDataService.getMetaData().then(response => response.json());

const getAppSettings = () =>
  MetaDataService.getAppSettings().then(response => response.json());

export function* getMetaDataWorker() {
  try {
    yield put({ key: KEY_METADATA, type: METADATA_REQUESTED });
    const payload = yield call(getMetaData);

    const { content } = payload;
    const {
      displayTags,
      sfmEventFields,
      sfmServiceGroup,
      sfmServiceGroupMembers,
      sfmWorkOrderFields,
      skills,
      timeZoneInfo
    } = content;

    // Add Display Tags to Store.
    const tags = {};
    displayTags.map(displayTag => {
      const { Key, Value } = displayTag;
      tags[Key] = Value;
      return undefined;
    });
    yield put({ data: tags, key: KEY_DISPLAY_TAGS, type: DISPLAY_TAGS_LOADED });

    // Add Event Fields to Store.
    const eventFields = {};
    let { fields = undefined } = sfmEventFields;
    if (!fields) {
      fields = sfmEventFields;
    }
    fields.forEach(field => {
      const {
        apiName,
        labelName: value,
        wrapperName,
        dataType,
        pickListVals: refField
      } = field;
      eventFields[apiName] = {
        display: value,
        fieldType: dataType,
        refField,
        value: apiName,
        wrapperName
      };
    });
    yield put({
      data: eventFields,
      key: KEY_EVENTS_METADATA,
      type: EVENTS_METADATA_LOADED
    });

    // Add Service Group Members(Technician) Fields to Store.
    const svcGrpMemberFields = {};
    sfmServiceGroupMembers.forEach(field => {
      const { apiName, labelName: value, dataType } = field;
      svcGrpMemberFields[apiName] = {
        apiName,
        display: value,
        fieldType: dataType,
        value: apiName
      };
    });
    yield put({
      data: svcGrpMemberFields,
      key: KEY_TECHNICIANS_METADATA,
      type: TECHNICIANS_METADATA_LOADED
    });

    // Add Service Group(Service Teams) Fields to Store.
    const svcGroupFields = {};
    sfmServiceGroup.forEach(field => {
      const { apiName, labelName: value, dataType } = field;
      svcGroupFields[apiName] = {
        apiName,
        display: value,
        fieldType: dataType,
        value: apiName
      };
    });
    yield put({
      data: svcGroupFields,
      key: KEY_TEAM_METADATA,
      type: TEAM_METADATA_LOADED
    });

    // Add Timezones to Store.
    const timeZones = [];
    timeZoneInfo.map(timeZone => {
      const { Key, Value } = timeZone;
      timeZones.push({ name: Key, value: Value });
      return undefined;
    });
    yield put({ data: timeZones, key: KEY_TIMEZONES, type: TIMEZONE_LOADED });

    // Add Technician Skills to Store.
    const sortedSkills = orderBy(skills, [SKILLNAME], [DEFAULT_SORT_ORDER]);
    yield put({
      data: sortedSkills,
      key: KEY_TECH_SKILLS,
      type: TECHNICIAN_SKILLS_LOADED
    });

    // Add WorkOrder Fields to Store.
    const workOrderFields = {};
    const { fields: woFields } = sfmWorkOrderFields;
    woFields.forEach(woField => {
      const { key: name, value: label, properties } = woField;
      const found = properties.filter(property => {
        const { key } = property;
        return key === "TYPE";
      });
      const [obj] = found;
      const { value: type, value1: refField } = obj;
      workOrderFields[name] = {
        display: label,
        fieldType: type,
        refField,
        value: name
      };
    });
    yield put({
      data: workOrderFields,
      key: KEY_WORKORDER_FIELD_LIST,
      type: WORKORDER_FIELD_LIST_LOADED
    });
    yield put({ data: "Success", key: KEY_METADATA, type: METADATA_LOADED });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_METADATA,
      type: METADATA_API_ERRORED
    });
  }
}

export function* appSettingsWorker(action) {
  try {
    yield put({ key: KEY_APP_SETTINGS, type: APP_SETTINGS_REQUESTED });
    const response = yield call(getAppSettings, action);
    const { content = undefined } = response;
    const { appSettings, userSettings } = content || response;

    // Load UserSettings from Workorder for the first time
    if (!isNull(userSettings) && !isEmpty(userSettings)) {
      yield put({
        data: userSettings,
        key: KEY_USER_SETTINGS,
        type: USER_SETTINGS_LOADED
      });
      delete content.userSettings;
    }

    // Load AppSettings from Workorder for the first time
    if (!isNull(appSettings) && !isEmpty(appSettings)) {
      yield put({
        data: appSettings,
        key: KEY_APP_SETTINGS,
        type: APP_SETTINGS_LOADED
      });
      delete content.appSettings;
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message }, errorCode, message },
      type: APP_SETTINGS_API_ERRORED,
      message
    });
  }
}

export function* appLaunchWorker() {
  // addInterceptor();
  // Get Metadata action will retrieve the following.
  // a) List of all the timezones.
  // b) All the WorkOrderFields configured by SFM.
  // c) All the SFMEvents & Custom Event fields.
  // d) All the display labels.
  // e) TBD //include Technician Fields.
  yield put(GET_METADATA_ACTION);
  yield put(GET_APP_SETTINGS_ACTION);
  // This action will return the following.
  // a) User configured settings.
  // b) Application Settings.
  // c) Default View.
  // e) List of Views & Queues.
  // f) Configured number of workorders.
  // g) SOQL uses to query the workorders.
  const URLParams = getURLParams();
  const { wid: woId } = URLParams;
  if (woId) {
    yield put({
      type: GET_WORKORDER,
      key: KEY_WORKORDERS,
      woId: decodeURIComponent(woId)
    });
  } else {
    yield put(GET_WORKORDERS_ACTION);
  }

  // This action will return the following.
  // a) List of Views.
  // b) List of Accounts.
  // c) List of Locations.
  yield put(GET_VIEW_DEFINITION_ACTION);
  //yield put(GET_EVENTS_ACTION);
  yield put(GET_TECHNICIAN_ACTION);
  yield put(GET_EVENT_HOVER_INFO_ACTION);
}

export function* metaDataWatcher() {
  yield takeLatest(GET_APP_METADATA, appLaunchWorker);
  yield takeLatest(GET_METADATA, getMetaDataWorker);
  yield takeLatest(GET_APP_SETTINGS, appSettingsWorker);
}
