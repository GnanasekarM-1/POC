import { call, put, select, takeLatest } from "redux-saga/effects";
import { cloneDeep, isEqual, differenceWith, flatMap } from "lodash";
import {
  DELETE_EVENT_REQUESTED,
  UPDATE_USER_SETTINGS,
  SAVE_USER_SETTINGS,
  TECH_SEARCH_CHANGED,
  SCHEDULER_CONF_CHANGED,
  UPDATE_SCHEDULER_STATE,
  UNASSIGN_WO,
  DELETE_EVENTS,
  DELETE_JDM_EVENTS,
  RESET_SCHEDULER_VIEW,
  UPDATE_GRID_STATE,
  KEY_TECHNICIANS,
  VIEW_SELECTION_CHANGED,
  UPDATE_TECHNICIAN_DETAILS,
  ADD_REMOVE_TECHNICIAN_COLUMNS,
  CHANGE_TEAM_TERRITORY_SEQUENCE,
  EXPAND_COLLAPSE_TREE,
  UNASSIGN_WORKORDER_COMPLETED,
  UNASSIGN_WORKORDER_ERRORED,
  UNASSIGN_WORKORDER_REQUESTED,
  UPDATE_TECHNICIAN_WORKING_HOURS
} from "constants/ActionConstants";
import {
  ID,
  WO_EXP_TYPE,
  TEAM_API_NAME,
  TEAM_API_REF,
  DEFAULT_TREE_DATA,
  DELETING_IN_PROGRESS,
  TEAM_SEQUENCE_CHANGED,
  TECHNICIAN_COLUMN_ADDED,
  TERRITORY_SEQUENCE_CHANGED,
  WO_DISPATCH_STATUS_FIELD,
  WORKORDER_TECHNICIAN_API_REF,
  WORKORDER_TECHNICIAN_API_NAME,
  TECH_SALESFORCE_USER_FIELD,
  WO_SCHEDULED_DATE_FIELD,
  WO_SCHEDULED_DATE_TIME_FIELD,
  FALSE
} from "constants/AppConstants";
import EventService from "services/EventsService";
import TechnicianService from "services/TechnicianService";
import { getFieldValue, getDisplayValue } from "utils/DCUtils";
import {
  TECH_COL,
  TECH_TEAM_SEQUENCE,
  WO_GRID_CONF_FIELDS,
  TECH_TERRITORY_SEQUENCE
} from "constants/UserSettingConstants";
import {
  ALL,
  ASSIGNED,
  SET056,
  getSettingValue,
  SET010
} from "constants/AppSettings";
import { createTeamTerritoryTree } from "utils/SchedulerUtils";
import { schedulerStateChanged } from "actions/SchedulerAction";
import { convertErrorToObject, getUserSetting } from "utils/DCUtils";
import {
  DELETE_EVENT_ERRORED,
  DELETE_EVENT_COMPLETED
} from "constants/ActionConstants";

const getTechnicianData = ({ technicianData }) => technicianData;

const getTechnicianById = ({ technicianData }, id) => {
  const { technicians: technicianContent } = technicianData;
  const { data } = technicianContent;
  const { technicians } = data;
  return technicians[id];
};

const getAnyTechnician = ({ technicianData }) => {
  const { technicians: technicianContent } = technicianData;
  const { data } = technicianContent;
  const { technicians, techniciansIds } = data;
  const techIdArray = Array.from(techniciansIds);
  return techIdArray.length ? technicians[techIdArray[0]] : null;
};

const getAllTechnicianIds = ({ technicianData }) => {
  const { technicians: technicianContent } = technicianData;
  const { data } = technicianContent;
  const { techniciansIds = [] } = data;
  return Array.from(techniciansIds);
};

const getServiceTeamTree = ({ schedulerState }) => {
  const { teamView } = schedulerState;
  return teamView;
};

const getTerrirtoryTree = ({ schedulerState }) => {
  const { territoryView } = schedulerState;
  return territoryView;
};

const getSelectedWO = ({ gridState }) => {
  const { row } = gridState;
  return row;
};

const getWorkOrderById = ({ workOrderData }, Id) => {
  const { workOrders } = workOrderData;
  const { content } = workOrders;
  const { records } = content;
  return records.find(record => record.Id === Id);
};

const getStatus = ({ gridState }) => {
  const { status } = gridState;
  return status;
};

const getWorkOrderFieldTypes = ({ metaData }) => {
  const { workOrderFields } = metaData;
  const { content } = workOrderFields;
  return content;
};

const getView = ({ gridState }) => {
  const { view } = gridState;
  return view;
};

const unAssignWO = data =>
  EventService.unAssignWO(data).then(response => response.json());
const deleteEvents = data =>
  EventService.deleteEvents(data).then(response => response.json());
const deleteJDMEvents = data =>
  EventService.deleteJDMEvents(data).then(response => response.json());
const getTechniciansDetails = payload =>
  TechnicianService.getTechniciansDetails(payload).then(response =>
    response.json()
  );

const updateTreeNode = (technicianData, treeNode) => {
  if (!treeNode) {
    return;
  }
  const { Id, isTech } = treeNode;
  if (!isTech) {
    const { children } = treeNode;
    if (children && children.length) {
      children.map(node => {
        updateTreeNode(technicianData, node);
        return undefined;
      });
    }
  } else {
    const technician = technicianData[Id];
    if (technician) {
      const { technician_O: techObject } = technician;
      Object.assign(treeNode, techObject);
    }
  }
};

const updateTechnicianTreeNodes = (technicianData, tree = []) => {
  tree.map(treeNode => {
    updateTreeNode(technicianData, treeNode);
    return undefined;
  });
};

export function* expandCollapseTreeWorker(action) {
  const { changed } = action;
  yield put({ changed, type: UPDATE_USER_SETTINGS });
  yield put({ type: SAVE_USER_SETTINGS });
}

export function* resetSchedulerWorker() {
  const technicianData = yield select(getTechnicianData);
  const { technicians: techContent } = technicianData;
  const { data: datContent } = techContent;
  const { teamList, territoryList, technicians } = datContent;
  // Instead of re-creating team & territory view, why not cache the original tree and show again. Its a TBD.
  const teamView = createTeamTerritoryTree(teamList, technicians, true);
  const territoryView = createTeamTerritoryTree(
    territoryList,
    technicians,
    false
  );

  yield put({
    changed: { newViewState: DEFAULT_TREE_DATA, teamView, territoryView },
    type: UPDATE_SCHEDULER_STATE
  });

  yield put({ changed: { gridActive: false }, type: UPDATE_GRID_STATE });
}

export function* techSearchChangeWorker(action) {
  let newColumnAdded = false;
  const { changed = {} } = action;
  const { search_keyword = [] } = changed;
  const gridConfCols = getUserSetting(WO_GRID_CONF_FIELDS, []);
  if (search_keyword) {
    const wo_grid_conf_fields = cloneDeep(gridConfCols);
    const { col = [] } = search_keyword;
    if (col && col.length) {
      col.map(woColumn => {
        const { name } = woColumn;
        if (!wo_grid_conf_fields.includes(name)) {
          wo_grid_conf_fields.push(name);
          newColumnAdded = true;
        }
        return undefined;
      });
      if (newColumnAdded) {
        changed.wo_grid_conf_fields = wo_grid_conf_fields;
      }
    }
  }

  yield put({ changed, type: UPDATE_USER_SETTINGS });
  yield put({ type: SAVE_USER_SETTINGS });
  if (newColumnAdded) {
    const view = yield select(getView);
    yield put({
      changed: { reload: true, view },
      type: VIEW_SELECTION_CHANGED
    });
  }
}

export function* schedulerConfChangeWorker(action) {
  const { changed } = action;
  delete changed.activeRuleIndex;

  const {
    tech_techCol: columns,
    tech_techRules: techRules,
    tech_teamSequence: teamSequence,
    tech_territorySequence: territorySequence,
    tech_workingHoursColor: workingHoursColor,
    tech_holidayHoursColor: holidayHoursColor
  } = changed;

  // Update Workorder Fields that are part of Event Color Rules evaulation.
  if (techRules) {
    const woFields = yield select(getWorkOrderFieldTypes);
    const wo_sch_col_fields = [];
    techRules.map(techRule => {
      const { operand = [] } = techRule;
      if (operand) {
        operand.map(expn => {
          const { property, type } = expn;
          if (
            type === WO_EXP_TYPE &&
            property &&
            woFields[property] &&
            !wo_sch_col_fields.includes(property)
          ) {
            wo_sch_col_fields.push(property);
          }
          return undefined;
        });
      }
      return undefined;
    });
    changed.wo_sch_col_fields = wo_sch_col_fields;
  }
  // Handle Technician column Add/Remove in new worker.
  if (columns) {
    yield put({ columns, type: ADD_REMOVE_TECHNICIAN_COLUMNS });
  }
  // Handle Team/Territory sequence change in new worker.
  if (teamSequence || territorySequence) {
    yield put({
      teamSequence,
      territorySequence,
      type: CHANGE_TEAM_TERRITORY_SEQUENCE
    });
  }
  if (workingHoursColor || holidayHoursColor) {
    yield put({ changed, type: UPDATE_USER_SETTINGS });
    yield put({ type: UPDATE_TECHNICIAN_WORKING_HOURS });
  }
  yield put({ changed, type: UPDATE_USER_SETTINGS });
  yield put({ type: SAVE_USER_SETTINGS });
}

export function* changeTeamTerritorySeqWorker(action) {
  const { teamSequence, territorySequence } = action;
  // Handle Team Sequence change.
  if (teamSequence) {
    const configuredSeq = getUserSetting(TECH_TEAM_SEQUENCE, []);
    if (isEqual(teamSequence, configuredSeq)) {
      // There is no change in the team sequence.
      return;
    }
    yield put({
      changed: { tech_teamSequence: teamSequence },
      type: UPDATE_USER_SETTINGS
    });
    yield put({
      changed: { newViewState: TEAM_SEQUENCE_CHANGED },
      type: UPDATE_SCHEDULER_STATE
    });
    yield put({ type: SAVE_USER_SETTINGS });
  }
  // Handle Territory Sequence change.
  if (territorySequence) {
    const configuredSeq = getUserSetting(TECH_TERRITORY_SEQUENCE, []);
    if (isEqual(territorySequence, configuredSeq)) {
      // There is no change in the territory sequence.
      return;
    }
    yield put({
      changed: { tech_territorySequence: territorySequence },
      type: UPDATE_USER_SETTINGS
    });
    yield put({
      changed: { newViewState: TERRITORY_SEQUENCE_CHANGED },
      type: UPDATE_SCHEDULER_STATE
    });
    yield put({ type: SAVE_USER_SETTINGS });
  }
}

export function* addRemoveTechColumnWorker(action) {
  const { columns: changedTechCols } = action;
  const configTechColumns = getUserSetting(TECH_COL, []);
  const newlyAddedCols = differenceWith(
    changedTechCols,
    configTechColumns,
    (a, b) => a.name === b.name
  );
  if (!newlyAddedCols.length) {
    if (isEqual(changedTechCols, configTechColumns)) {
      // There is no change in the technician column configuration.
      return;
    }
    // There could be change in the column sequence. Hence update user settings & Save it.
    yield put({
      changed: { tech_techCol: changedTechCols },
      type: UPDATE_USER_SETTINGS
    });
    yield put({
      changed: { newViewState: TECHNICIAN_COLUMN_ADDED },
      type: UPDATE_SCHEDULER_STATE
    });
    yield put({ type: SAVE_USER_SETTINGS });
    return;
  }
  // Update User Settings with new technician column additions.
  yield put({
    changed: { tech_techCol: changedTechCols },
    type: UPDATE_USER_SETTINGS
  });

  const changed = { newViewState: TECHNICIAN_COLUMN_ADDED };
  const technician = yield select(getAnyTechnician);
  if (technician) {
    const { technician_O: technicianObj } = technician;
    if (technicianObj) {
      const columns = newlyAddedCols.filter(
        column => !technicianObj[column.name]
      );
      if (columns.length) {
        const techIds = yield select(getAllTechnicianIds);
        const techFields = flatMap(
          columns,
          requestColumn => requestColumn.name
        );
        const payload = yield call(getTechniciansDetails, {
          techFields,
          techIds
        });
        const { content } = payload;
        yield put({
          data: content,
          key: KEY_TECHNICIANS,
          type: UPDATE_TECHNICIAN_DETAILS
        });
        const serviceTeam = yield select(getServiceTeamTree);
        const territoryTeam = yield select(getTerrirtoryTree);
        const teamView = cloneDeep(serviceTeam);
        const territoryView = cloneDeep(territoryTeam);
        updateTechnicianTreeNodes(content, teamView);
        updateTechnicianTreeNodes(content, territoryView);
        changed.columns = columns;
        changed.teamView = teamView;
        changed.territoryView = territoryView;
      }
    }
  }
  yield put({ changed, type: UPDATE_SCHEDULER_STATE });
  yield put({ type: SAVE_USER_SETTINGS });
}

export function* unAssignWOWorker(action) {
  try {
    yield put({ type: UNASSIGN_WORKORDER_REQUESTED });
    const { changed } = action;
    const { WorkOrderIds } = changed;
    const response = yield call(unAssignWO, { ...changed });
    const { content, message, success } = response;
    if (!success) {
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        message,
        type: UNASSIGN_WORKORDER_ERRORED
      });
      return;
    }
    const { delEventIds, woInfo } = content;
    const eventIds = delEventIds ? delEventIds.split(",") : [];
    const obj = {};
    obj.value = true;
    obj.eventIds = eventIds;
    [obj.woId] = WorkOrderIds;
    obj.woInfo = woInfo[obj.woId];
    const [woId] = Object.keys(woInfo);
    const workOrder = woInfo[woId];
    const isSET010 = JSON.parse(getSettingValue(SET010, FALSE).toLowerCase());
    const view = yield select(getView);
    if (isSET010) {
      yield put({
        changed: { reload: true, view },
        type: VIEW_SELECTION_CHANGED
      });
    } else if (workOrder) {
      let selectedWO = yield select(getSelectedWO);
      const selectedId = getFieldValue(selectedWO, ID);
      const [WhatId] = changed.WorkOrderIds;
      if (selectedId !== WhatId) {
        selectedWO = yield select(getWorkOrderById, WhatId);
      }
      if (selectedWO) {
        const status = yield select(getStatus);
        if (
          status === ALL ||
          status.includes(workOrder[WO_DISPATCH_STATUS_FIELD])
        ) {
          const dispatchStatus = selectedWO[WO_DISPATCH_STATUS_FIELD];
          // Update all the fields of the selected workorder with new workorder data received from response to get the fields updated.
          Object.assign(selectedWO, workOrder);

          // Update Service Team & Technician field.
          if (dispatchStatus === ASSIGNED) {
            selectedWO[TEAM_API_REF] = null;
            selectedWO[TEAM_API_NAME] = null;
            selectedWO[WORKORDER_TECHNICIAN_API_REF] = null;
            selectedWO[WORKORDER_TECHNICIAN_API_NAME] = null;
          } else {
            selectedWO[TEAM_API_REF] = null;
            selectedWO[TEAM_API_NAME] = null;
          }

          // Apply State change to get the Grid Re-render the new changes.
          yield put({ type: UPDATE_GRID_STATE });
        }
      }
    }
    yield put({ type: UNASSIGN_WORKORDER_COMPLETED });
    yield put(
      schedulerStateChanged(
        { WOUnAssigned: { ...obj } },
        UPDATE_SCHEDULER_STATE
      )
    );
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      type: UNASSIGN_WORKORDER_ERRORED
    });
  }
}

export function* deleteEventsWorker(action) {
  try {
    const { callBack, changed } = action;
    const { OwnerId, TechId } = changed;
    // Fix DCH-1317 Scheduler: Delete all later/earlier events for this work order options are not working as expected
    const technician = yield select(getTechnicianById, TechId);
    if (technician) {
      const { technician_O: technicianObj } = technician;
      if (technicianObj && OwnerId) {
        changed.OwnerId =
          getFieldValue(technicianObj, TECH_SALESFORCE_USER_FIELD, null) ||
          OwnerId;
      }
    }
    yield put({
      message: getDisplayValue("TAG517", DELETING_IN_PROGRESS),
      type: DELETE_EVENT_REQUESTED
    });
    const response = yield call(deleteEvents, { ...changed });
    const { content, message, success } = response;
    if (!success) {
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        message,
        type: DELETE_EVENT_ERRORED
      });
      return;
    }
    callBack(content, false);
    yield put({ type: DELETE_EVENT_COMPLETED });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      type: DELETE_EVENT_ERRORED
    });
  }
}

export function* deleteJDMEventsWorker(action) {
  try {
    const { changed } = action;
    const { isUnassignTech, OwnerId, TechId, WorkOrderId } = changed;
    // Fix DCH-1317 Scheduler: Delete all later/earlier events for this work order options are not working as expected
    const technician = yield select(getTechnicianById, TechId);
    if (technician) {
      const { technician_O: technicianObj } = technician;
      if (technicianObj && OwnerId) {
        changed.OwnerId =
          getFieldValue(technicianObj, TECH_SALESFORCE_USER_FIELD, null) ||
          OwnerId;
      }
    }
    yield put({
      message: getDisplayValue("TAG517", DELETING_IN_PROGRESS),
      type: DELETE_EVENT_REQUESTED
    });
    const response = yield call(deleteJDMEvents, { ...changed });
    const { content, message, success } = response;
    if (!success) {
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        message,
        type: DELETE_EVENT_ERRORED
      });
      return;
    }
    const { eventsResponse, woInfo } = content;
    const { StatusMessage } = eventsResponse;
    const eventIds = (StatusMessage && StatusMessage.split(",")) || [];
    eventIds.shift();
    const obj = {};
    obj.value = isUnassignTech;
    obj.eventIds = eventIds || [];
    obj.woId = WorkOrderId;
    obj.woInfo = woInfo[WorkOrderId];

    const selectedWO = yield select(getWorkOrderById, WorkOrderId);
    if (selectedWO) {
      const { woInfo } = obj;

      // Update all the fields of the selected workorder with new workorder data received from response to get the fields updated.
      Object.assign(selectedWO, woInfo);
      const dispatchStatus = getFieldValue(
        woInfo,
        WO_DISPATCH_STATUS_FIELD,
        null
      );
      if (dispatchStatus && dispatchStatus !== ASSIGNED) {
        selectedWO[TEAM_API_REF] = null;
        selectedWO[TEAM_API_NAME] = null;
        selectedWO[WORKORDER_TECHNICIAN_API_REF] = null;
        selectedWO[WORKORDER_TECHNICIAN_API_NAME] = null;
        selectedWO[WO_SCHEDULED_DATE_FIELD] = null;
        selectedWO[WO_SCHEDULED_DATE_TIME_FIELD] = null;
      }
      // Apply State change to get the Grid Re-render the new changes.
      yield put({ type: UPDATE_GRID_STATE });
    }

    yield put(
      schedulerStateChanged(
        { WOUnAssigned: { ...obj } },
        UPDATE_SCHEDULER_STATE
      )
    );

    yield put({ type: DELETE_EVENT_COMPLETED });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      type: DELETE_EVENT_ERRORED
    });
  }
}

export function* schedulerStateWatcher() {
  yield takeLatest(EXPAND_COLLAPSE_TREE, expandCollapseTreeWorker);
  yield takeLatest(RESET_SCHEDULER_VIEW, resetSchedulerWorker);
  yield takeLatest(TECH_SEARCH_CHANGED, techSearchChangeWorker);
  yield takeLatest(SCHEDULER_CONF_CHANGED, schedulerConfChangeWorker);
  yield takeLatest(UNASSIGN_WO, unAssignWOWorker);
  yield takeLatest(DELETE_EVENTS, deleteEventsWorker);
  yield takeLatest(DELETE_JDM_EVENTS, deleteJDMEventsWorker);
  yield takeLatest(ADD_REMOVE_TECHNICIAN_COLUMNS, addRemoveTechColumnWorker);
  yield takeLatest(
    CHANGE_TEAM_TERRITORY_SEQUENCE,
    changeTeamTerritorySeqWorker
  );
}
