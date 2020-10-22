import {
  GET_SEARCH_TECH,
  GET_TECHNICIANS,
  SEARCH_TECH_DATA_CLEARED,
  ADV_TECH_SEARCH_CLEARED,
  SEARCH_TECHNICIANS_REQUESTED,
  INLINE_TECHNICIAN_SEARCH_REQUESTED,
  SEARCH_TECHNICIANS_LOADED,
  SEARCH_TECHNICIANS_ERRORED,
  TECHNICIANS_REQUESTED,
  TECHNICIANS_DETAILS_REQUESTED,
  ADV_TECH_SEARCH_REQUESTED,
  ADV_TECH_SEARCH_LOADED,
  ADV_TECH_SEARCH_ERRORED,
  TECHNICIANS_WORKING_HOURS_REQUESTED,
  TECHNICIANS_LOADED,
  UPDATE_TECHNICIAN_DETAILS,
  TECHNICIANS_WORKING_HOURS_LOADED,
  TECHNICIANS_API_ERRORED,
  TECHNICIANS_DETAILS_API_ERRORED,
  TECHNICIANS_WORKING_HOURS_API_ERRORED,
  API_NOT_INVOKED,
  API_INVOKED,
  API_DATA_LOADED,
  API_ERRORED,
  KEY_TECHNICIANS,
  REMOVE_ATS_RESULTS,
  KEY_TECHNICIANS_METADATA,
  GET_TECHNICIANS_METADATA,
  GET_TECH_SKILLS_ACTION,
  KEY_WO_MATCH_SKILLS,
  GET_WO_MATCHING_TECH_SKILLS,
  PERFORM_ADV_TECH_SEARCH,
  APPLY_ADV_TECH_SEARCH,
  WO_MATCH_TECH_SKILLS_REQUESTED,
  WO_MATCH_TECH_SKILLS_LOADED,
  FILTER_WORKORDER_TECHNICIANS,
  WO_MATCH_TECH_SKILLS_API_ERRORED
} from "constants/ActionConstants";
import { HTTP_OK, SERVER_ERROR } from "constants/ServiceConstants";

export function getTechnicianMetaData() {
  return {
    key: KEY_TECHNICIANS_METADATA,
    type: GET_TECHNICIANS_METADATA
  };
}

export function technicianActions() {
  return {
    applyATS: () => ({ type: APPLY_ADV_TECH_SEARCH }),
    filterTechnicians: workorders => ({
      type: FILTER_WORKORDER_TECHNICIANS,
      workorders
    }),
    getTechSkills: () => GET_TECH_SKILLS_ACTION,
    getWOMatchTechSkills: id => ({
      id,
      key: KEY_WO_MATCH_SKILLS,
      type: GET_WO_MATCHING_TECH_SKILLS
    }),
    performATS: atsData => ({ atsData, type: PERFORM_ADV_TECH_SEARCH }),
    removeATSResults: keys => ({ keys, type: REMOVE_ATS_RESULTS })
  };
}

export function reducer(state = null, action) {
  const { data, keys, type } = action;
  switch (type) {
    case GET_TECHNICIANS:
    case GET_SEARCH_TECH:
      return { ...state, [action.key]: { status: { api: API_NOT_INVOKED } } };

    case TECHNICIANS_REQUESTED:
    case TECHNICIANS_WORKING_HOURS_REQUESTED:
    case WO_MATCH_TECH_SKILLS_REQUESTED:
    case SEARCH_TECHNICIANS_REQUESTED:
    case INLINE_TECHNICIAN_SEARCH_REQUESTED:
    case ADV_TECH_SEARCH_REQUESTED:
      return { ...state, [action.key]: { status: { api: API_INVOKED } } };

    case TECHNICIANS_LOADED:
    case TECHNICIANS_WORKING_HOURS_LOADED:
    case WO_MATCH_TECH_SKILLS_LOADED:
    case SEARCH_TECHNICIANS_LOADED:
    case ADV_TECH_SEARCH_LOADED:
      return {
        ...state,
        [action.key]: { data, status: { api: API_DATA_LOADED, code: HTTP_OK } }
      };

    case UPDATE_TECHNICIAN_DETAILS:
      const newState = { ...state };
      const { technicians: currentTechObject } = newState;
      const { data: currentData } = currentTechObject;
      const { technicians } = currentData || {};
      if (technicians) {
        // Upddate the content of technician object with latest values or add new fields.
        Object.keys(data || {}).map(techId => {
          const sorurceObject = data[techId];
          const targetObject = technicians[techId];
          if (targetObject) {
            const { technician_O: target } = targetObject;
            const { technician_O: source } = sorurceObject;
            targetObject.technician_O = Object.assign(target, source);
          } else {
            technicians[techId] = Object.assign({}, sorurceObject);
          }
        });
      }
      currentData.technicians = technicians;
      return {
        ...state,
        [action.key]: {
          data: currentData,
          status: { api: API_DATA_LOADED, code: HTTP_OK }
        }
      };

    case SEARCH_TECH_DATA_CLEARED:
    case ADV_TECH_SEARCH_CLEARED:
      return {
        ...state,
        [action.key]: {
          content: action.data,
          status: { api: API_DATA_LOADED, code: HTTP_OK }
        }
      };

    case REMOVE_ATS_RESULTS:
      const editState = { ...state };
      if (keys && keys.length) {
        keys.map(key => {
          delete editState[key];
          return undefined;
        });
      }
      return editState;

    case TECHNICIANS_API_ERRORED:
    case TECHNICIANS_DETAILS_API_ERRORED:
    case TECHNICIANS_WORKING_HOURS_API_ERRORED:
    case SEARCH_TECHNICIANS_ERRORED:
    case ADV_TECH_SEARCH_ERRORED:
    case WO_MATCH_TECH_SKILLS_API_ERRORED:
      return {
        ...state,
        [action.key]: {
          status: {
            api: API_ERRORED,
            code: SERVER_ERROR,
            error: data,
            message: data.message
          }
        }
      };
    default:
      return state;
  }
}
