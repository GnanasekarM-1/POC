import {
  GET_VIEW_WORKORDER_COUNT,
  GET_VIEW_DEFINITION_ACTION,
  VIEW_WORKORDER_COUNT_REQUESTED,
  VIEW_DEFINITION_REQUESTED,
  MAP_VIEW_DATA_REQUESTED,
  VIEWS_LOADED,
  VIEW_WORKORDER_COUNT_LOADED,
  VIEW_DEFINITION_LOADED,
  MAP_VIEW_DATA_LOADED,
  VIEW_WORKORDER_COUNT_API_ERRORED,
  VIEW_DEFINITION_API_ERRORED,
  MAP_VIEW_DATA_API_ERRORED,
  API_INVOKED,
  API_DATA_LOADED,
  API_ERRORED,
  MAP_VIEW_DATA_CLEARED
} from "constants/ActionConstants";
import { HTTP_OK, SERVER_ERROR } from "constants/ServiceConstants";

// export function getViewWorkOrderCount(viewId, status) {
//   return { status, type: GET_VIEW_WORKORDER_COUNT, viewId };
// }

export function reducer(state = null, action) {
  const { type } = action;
  switch (type) {
    case GET_VIEW_WORKORDER_COUNT:
    case GET_VIEW_DEFINITION_ACTION:
      return { ...state, [action.key]: {} };

    case MAP_VIEW_DATA_CLEARED:
      return {
        ...state,
        [action.key]: {
          content: action.data,
          status: { api: API_DATA_LOADED, code: HTTP_OK }
        }
      };

    case VIEW_WORKORDER_COUNT_REQUESTED:
    case VIEW_DEFINITION_REQUESTED:
    case MAP_VIEW_DATA_REQUESTED:
      return { ...state, [action.key]: { status: { api: API_INVOKED } } };

    case VIEWS_LOADED:
      return { ...state, [action.key]: action.data };

    case VIEW_WORKORDER_COUNT_LOADED:
    case VIEW_DEFINITION_LOADED:
    case MAP_VIEW_DATA_LOADED:
      return {
        ...state,
        [action.key]: {
          content: action.data,
          status: { api: API_DATA_LOADED, code: HTTP_OK }
        }
      };

    case VIEW_WORKORDER_COUNT_API_ERRORED:
    case VIEW_DEFINITION_API_ERRORED:
    case MAP_VIEW_DATA_API_ERRORED:
      return {
        ...state,
        [action.key]: {
          status: {
            api: API_ERRORED,
            code: SERVER_ERROR,
            error: action.data,
            message: action.data.message
          }
        }
      };
    default:
      return state;
  }
}
