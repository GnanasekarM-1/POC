import {
  DELTA_WORK_ORDER_REQUESTED,
  DELTA_WORK_ORDER_LOADED,
  DELTA_WORK_ORDER_ERROR,
  GET_WORKORDERS,
  KEY_RECORDS,
  WORKORDERS_REQUESTED,
  WORKORDERS_LOADED,
  WORKORDERS_API_ERRORED,
  API_NOT_INVOKED,
  API_INVOKED,
  API_DATA_LOADED,
  API_ERRORED,
  UPDATE_SINGLE_WO,
  GET_WORKORDER
} from "constants/ActionConstants";
import { HTTP_OK, SERVER_ERROR } from "constants/ServiceConstants";

export function updateWorkOrders(data) {
  return {
    data: data.woData,
    key: KEY_RECORDS,
    type: UPDATE_SINGLE_WO
  };
}

export function reducer(state = null, action) {
  const { data, type, viewError } = action;
  switch (type) {
    case GET_WORKORDER:
    case GET_WORKORDERS: {
      const { workOrders } = state || {};
      const { content } = workOrders || {};
      return {
        ...state,
        [action.key]: { content, status: { api: API_NOT_INVOKED } }
      };
    }

    case UPDATE_SINGLE_WO: {
      const newState = {
        workOrders: { ...state.workOrders }
      };
      newState.workOrders.content.records = [...data];
      return {
        ...newState
      };
    }

    case WORKORDERS_REQUESTED:
    case DELTA_WORK_ORDER_REQUESTED: {
      const { workOrders } = state || {};
      const { content = {} } = workOrders || {};
      return {
        ...state,
        [action.key]: { content, status: { api: API_INVOKED } }
      };
    }

    case WORKORDERS_LOADED:
    case DELTA_WORK_ORDER_LOADED:
      return {
        ...state,
        [action.key]: {
          content: data,
          status: { api: API_DATA_LOADED, code: HTTP_OK, viewError }
        }
      };

    case WORKORDERS_API_ERRORED:
    case DELTA_WORK_ORDER_ERROR:
      const { message } = data;
      return {
        ...state,
        [action.key]: {
          status: {
            api: API_ERRORED,
            code: SERVER_ERROR,
            error: data,
            message
          }
        }
      };
    default:
      return state;
  }
}
