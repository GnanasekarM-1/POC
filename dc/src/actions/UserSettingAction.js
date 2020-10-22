import { isEqual } from "lodash";
import {
  APPLY_USER_SETTINGS,
  SAVE_USER_SETTINGS,
  AUTO_SAVE_USER_SETTINGS,
  UPDATE_USER_SETTINGS,
  USER_SETTINGS_LOADED
} from "constants/ActionConstants";

export function applyUserSettings() {
  return { type: APPLY_USER_SETTINGS };
}

export function updateUserSettings(changed) {
  return { changed, type: UPDATE_USER_SETTINGS };
}

export function saveUserSettings() {
  return { type: SAVE_USER_SETTINGS };
}

export function runAutoSaveUserSettings() {
  return { type: AUTO_SAVE_USER_SETTINGS };
}

export function reducer(state = null, action) {
  let dirty = false;
  const { data, type, changed } = action;
  switch (type) {
    case UPDATE_USER_SETTINGS:
      Object.keys(changed).forEach(key => {
        if (!dirty && !isEqual(changed[key], state[key])) {
          dirty = true;
        }
      });
      return dirty ? { ...state, ...changed } : state;

    case USER_SETTINGS_LOADED:
      // eslint-disable-next-line no-case-declarations
      const newState = { ...state, ...data };
      sessionStorage.setItem("LastSaved", JSON.stringify(newState));
      return newState;
    default:
      return state;
  }
}
