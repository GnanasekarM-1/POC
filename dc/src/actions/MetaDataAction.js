import {
  KEY_USER_TIMEZONE,
  GET_APP_METADATA,
  METADATA_REQUESTED,
  TEAM_METADATA_REQUESTED,
  EVENTS_METADATA_REQUESTED,
  TECHNICIANS_METADATA_REQUESTED,
  LOCALE_LOADED,
  TIMEZONE_UPDATED,
  METADATA_LOADED,
  TIMEZONE_LOADED,
  DISPLAY_TAGS_LOADED,
  APP_SETTINGS_LOADED,
  TEAM_METADATA_LOADED,
  EVENTS_METADATA_LOADED,
  TECHNICIAN_SKILLS_LOADED,
  TECHNICIANS_METADATA_LOADED,
  WORKORDER_FIELD_LIST_LOADED,
  METADATA_API_ERRORED,
  TEAM_METADATA_API_ERRORED,
  EVENTS_METADATA_API_ERRORED,
  TECHNICIANS_METADATA_API_ERRORED,
  API_INVOKED,
  API_DATA_LOADED,
  API_ERRORED,
  UPDATE_USER_INFO,
  APP_SETTINGS_REQUESTED
} from "constants/ActionConstants";

import { HTTP_OK, SERVER_ERROR } from "constants/ServiceConstants";

export function getAppMetaData() {
  return { type: GET_APP_METADATA };
}

export function updateTimeZoneAction(timeZone) {
  const { name } = timeZone;
  return {
    data: { id: name, ...timeZone },
    key: KEY_USER_TIMEZONE,
    type: TIMEZONE_UPDATED
  };
}

export function reducer(state = null, action) {
  const { changed, data, key, type } = action;
  switch (type) {
    case METADATA_REQUESTED:
    case APP_SETTINGS_REQUESTED:
    case TEAM_METADATA_REQUESTED:
    case EVENTS_METADATA_REQUESTED:
    case TECHNICIANS_METADATA_REQUESTED:
      return { ...state, [action.key]: { status: { api: API_INVOKED } } };

    case LOCALE_LOADED:
    case TIMEZONE_LOADED:
    case METADATA_LOADED:
    case APP_SETTINGS_LOADED:
    case DISPLAY_TAGS_LOADED:
    case TEAM_METADATA_LOADED:
    case EVENTS_METADATA_LOADED:
    case TECHNICIAN_SKILLS_LOADED:
    case WORKORDER_FIELD_LIST_LOADED:
    case TECHNICIANS_METADATA_LOADED:
      return {
        ...state,
        [key]: {
          content: data,
          status: { api: API_DATA_LOADED, code: HTTP_OK }
        }
      };
    case TIMEZONE_UPDATED:
      const { userTimezone = {} } = state || {};
      const { content = {} } = userTimezone;
      return {
        ...state,
        [key]: {
          content: Object.assign({}, content, data),
          status: { api: API_DATA_LOADED, code: HTTP_OK }
        }
      };

    case METADATA_API_ERRORED:
    case TEAM_METADATA_API_ERRORED:
    case EVENTS_METADATA_API_ERRORED:
    case TECHNICIANS_METADATA_API_ERRORED:
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
    case UPDATE_USER_INFO:
      return { ...state, ...changed };
    default:
      return state;
  }
}
