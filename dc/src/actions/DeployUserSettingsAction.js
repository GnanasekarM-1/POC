import {
  API_ERRORED,
  GET_DISPATCHER_LIST,
  DISPATCHER_LIST_REQUESTED,
  DISPATCHER_LIST_LOADED,
  DISPATCHER_LIST_ERRORED,
  POST_USER_SETTINGS
} from "constants/ActionConstants";
import { SERVER_ERROR } from "constants/ServiceConstants";

export function getDispatcherListAction() {
  return { type: GET_DISPATCHER_LIST };
}
export function postUserSettings(callback, payload) {
  return {
    callback,
    payload,
    type: POST_USER_SETTINGS
  };
}

export function reducer(state = null, action) {
  const { type } = action;
  switch (type) {
    case DISPATCHER_LIST_REQUESTED:
      return { ...state, status: { api: DISPATCHER_LIST_REQUESTED } };

    case DISPATCHER_LIST_LOADED:
      return {
        ...state,
        ...action.data,
        status: { api: DISPATCHER_LIST_LOADED }
      };

    case DISPATCHER_LIST_ERRORED:
      return {
        ...state,

        status: {
          api: API_ERRORED,
          code: SERVER_ERROR,
          error: action.data,
          message: action.data.message
        }
      };
    default:
      return state;
  }
}
