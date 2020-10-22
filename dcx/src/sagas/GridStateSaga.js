import { call, put, select, takeLatest } from "redux-saga/effects";
import { cloneDeep, isEmpty, flatMap } from "lodash";
import {
  KEY_WORKORDERS,
  KEY_USER_SETTINGS,
  KEY_NEXT_WORKORDERS,
  KEY_PREV_WORKORDERS,
  GET_WORKORDER,
  GET_WORKORDERS,
  UPDATE_GRID_STATE,
  UPDATE_USER_SETTINGS,
  DEFAULT_VIEW_CHANGED,
  VIEW_SELECTION_CHANGED,
  FILTER_COLUMN_CHANGED,
  FILTER_TEXT_CHANGED,
  STATUS_FILTER_CHANGED,
  PAGE_SELECTION_CHANGED,
  SAVE_USER_SETTINGS,
  SORT_ORDER_CHANGED,
  ROW_SELECTION_CHANGED,
  GRID_COLUMN_CHANGED,
  GRID_COLUMN_RESIZED,
  COLOR_RULE_CHANGED,
  SAVING_USER_SETTINGS,
  USER_SETTINGS_LOADED,
  WORKORDERS_LOADED,
  SAVING_USER_SETTINGS_API_ERRORED,
  FETCH_DELTA_EVENTS
} from "constants/ActionConstants";
import { getUserSetting } from "utils/DCUtils";
import {
  CACHE_WORKORDERS,
  getSettingValue,
  SET032,
  SET058
} from "constants/AppSettings";
import {
  VIEW_COUNTER,
  FILTER_COLUMN,
  SORT_COLUMN,
  SORT_ORDER,
  REQ_WO_FIELDS,
  WO_GRID_CONF_FIELDS,
  WO_COL
} from "constants/UserSettingConstants";
import {
  DEFAULT_SORT_ORDER,
  DESC_SORT_ORDER,
  DEFAULT_SORT_BY,
  NAME,
  FALSE
} from "constants/AppConstants";
import { isView } from "utils/ViewUtils";
import { calculateTotalPage, getWorkOrderFields } from "utils/GridUtils";
import activityModalService from "components/Modals/ActivityModal/ActivityModalService";
import UserSettingService from "services/UserSettingService";
import { applyUserSettings } from "actions/UserSettingAction";
import { ID, REFERENCE } from "constants/AppConstants";

const getView = ({ gridState }) => {
  const { view } = gridState;
  return view;
};

const getActivePage = ({ gridState }) => {
  const { page = 0 } = gridState;
  return parseInt(page, 10);
};

const hasMoreWorkOrders = ({ workOrderData }) => {
  const { nextworkOrders } = workOrderData;
  const { content } = nextworkOrders;
  const { done } = content;
  return !JSON.parse(done);
};

const getWorkOrderFieldTypes = ({ metaData }) => {
  const { workOrderFields } = metaData;
  const { content } = workOrderFields;
  return content;
};

const getFilterReferenceColumn = (fieldDesc = {}, fieldName) => {
  const { fieldType, refField } = fieldDesc;
  if (fieldType && fieldType.toUpperCase() === REFERENCE) {
    let refFieldName = fieldName;
    if (fieldName.endsWith("__c")) {
      refFieldName = fieldName.replace("__c", "__r");
    } else if (fieldName.endsWith(ID)) {
      refFieldName = fieldName.replace(ID, "");
    }
    return `${refFieldName}.${refField}`;
  }
  return fieldName;
};

const getFilterName = ({ gridState, metaData }) => {
  const { workOrderFields } = metaData;
  const { content } = workOrderFields;
  const { filterColumn } = gridState;
  let columnName = filterColumn;
  if (!filterColumn) {
    columnName = getUserSetting(FILTER_COLUMN, DEFAULT_SORT_BY);
  }
  return getFilterReferenceColumn(content[`${columnName}`], columnName);
};

const getColumnSort = ({ metaData }, view) => {
  const { workOrderFields } = metaData;
  const { content } = workOrderFields;
  if (isView(view)) {
    const viewCounters = getUserSetting(VIEW_COUNTER, []);
    if (viewCounters && viewCounters.length) {
      const { Key } = view;
      const found = viewCounters.filter(viewCounter => viewCounter.id === Key);
      if (found.length) {
        const [viewCounter] = found;
        const { column, sortOrder } = viewCounter;
        return {
          desc: sortOrder
            ? sortOrder.toUpperCase() === DESC_SORT_ORDER.toUpperCase()
            : false,
          id: getFilterReferenceColumn(content[`${column}`], column) || NAME
        };
      }
    }
  }
  const sortOrder = getUserSetting(SORT_ORDER, DEFAULT_SORT_ORDER);
  const column = getUserSetting(SORT_COLUMN, DEFAULT_SORT_BY);
  return {
    desc: sortOrder.toUpperCase() === DESC_SORT_ORDER.toUpperCase(),
    id: getFilterReferenceColumn(content[`${column}`], column) || NAME
  };
};

const getFilterText = ({ gridState }) => {
  const { filterText } = gridState;
  return filterText;
};

const getStatusFilter = ({ gridState }) => {
  const { status } = gridState;
  return status;
};

const getNextRecordsUrl = ({ gridState }) => {
  const { nextRecordsUrl } = gridState;
  return nextRecordsUrl;
};

const getActiveWorkOrders = ({ workOrderData }) => {
  const { workOrders } = workOrderData;
  const { content } = workOrders;
  return cloneDeep(content);
};

const getNextWorkOrders = ({ workOrderData }) => {
  const { nextworkOrders } = workOrderData;
  const { content } = nextworkOrders;
  return cloneDeep(content);
};

const getPrevWorkOrders = ({ workOrderData }) => {
  const { prevworkOrders } = workOrderData;
  const { content } = prevworkOrders;
  return cloneDeep(content);
};

const getWorkOrderRecordFields = ({ workOrderData }) => {
  const { workOrders } = workOrderData;
  const { content } = workOrders;
  const { records } = content;
  const [record] = records || [];
  return getWorkOrderFields(record);
};

const getSelectedWorkOrder = ({ workOrderData }, param) => {
  const { workOrders } = workOrderData;
  const { content } = workOrders;
  const { records } = content;
  return (records && records.filter(record => record.Id === param)[0]) || {};
};

const getUserSettingFromStore = ({ userSettings }) => userSettings;

const saveUserSettings = settings =>
  UserSettingService.saveUserSettings(settings).then(response =>
    response.json()
  );

export function* defaultViewChangeWorker(action) {
  const { changed } = action;
  yield put({ changed, type: UPDATE_USER_SETTINGS });
  yield put({ type: SAVE_USER_SETTINGS });
}

export function* viewSelectionChangeWorker(action) {
  const { changed } = action;
  const { reload = false, view = yield select(getView) } = changed;
  // Reset Filter Column, Filter Text, Page Number & Selected Row.
  const deleteKeys = ["page"];
  // On view selection change, remove selected WO.
  if (!reload) {
    deleteKeys.push("row");
  }
  yield put({
    changed: { view },
    config: { "-": deleteKeys },
    type: UPDATE_GRID_STATE
  });
  const status = yield select(getStatusFilter);
  const filterColumn = yield select(getFilterName);
  const sorted = yield select(getColumnSort, view);
  const woFields = yield select(getWorkOrderFieldTypes);
  const { id } = sorted;
  const sortColumn = getFilterReferenceColumn(woFields[`${id}`], id);
  const sortColumnDisplay = woFields[sortColumn]
    ? woFields[sortColumn].display
    : "";
  const filterColumnDisplay = woFields[filterColumn]
    ? woFields[filterColumn].display
    : "";
  const { Key: woId, type } = view;
  if (type) {
    // If selected view type is single lanuched workorder, pass workorder id.
    yield put({
      type: GET_WORKORDER,
      woId,
      view
    });
  } else {
    // Retrive first set of configured number of workorders for the new view.
    const actionParams = {
      key: KEY_WORKORDERS,
      filterColumnDisplay,
      sorted: { sortColumnDisplay, ...sorted },
      status,
      type: GET_WORKORDERS,
      view
    };
    // if (reload) {
    const filterText = yield select(getFilterText);
    if (filterText && !isEmpty(filterText)) {
      actionParams.filterColumn = yield select(getFilterName);
      actionParams.filterText = filterText;
    }
    actionParams.reload = reload;
    // }
    yield put(actionParams);
  }
  const isSET058 = JSON.parse(getSettingValue(SET058, FALSE).toLowerCase());
  const isSET032 = JSON.parse(getSettingValue(SET032, FALSE).toLowerCase());
  if ((!reload && isSET058) || (reload && isSET032)) {
    yield put({ type: FETCH_DELTA_EVENTS });
  }
}

export function* filterColumnChangeWorker(action) {
  const { changed } = action;
  const { wo_filterColumn: filterColumn } = changed;
  // Find the proper column API name for reference field types.
  const woFields = yield select(getWorkOrderFieldTypes);
  const view = yield select(getView);
  yield put({ changed: { filterColumn }, type: UPDATE_GRID_STATE });
  yield put({ changed, type: UPDATE_USER_SETTINGS });
  const filterText = yield select(getFilterText);
  if (filterText) {
    // Incase if the exists filter text, remove active selection & current page.
    yield put({ config: { "-": ["page", "row"] }, type: UPDATE_GRID_STATE });
    const status = yield select(getStatusFilter);
    const sorted = yield select(getColumnSort, view);
    // Retrive first set of configured number of workorders for the new view.
    yield put({
      filterColumn: getFilterReferenceColumn(
        woFields[`${filterColumn}`],
        filterColumn
      ),
      filterText,
      key: KEY_WORKORDERS,
      sorted,
      status,
      type: GET_WORKORDERS,
      view
    });
  }
}

export function* filterTextChangeWorker(action) {
  const { changed } = action;
  const { woId } = changed;

  yield put({ changed, type: UPDATE_GRID_STATE });
  const status = yield select(getStatusFilter);
  const view = yield select(getView);
  const sorted = yield select(getColumnSort, view);
  const filterColumn = yield select(getFilterName);
  const woFields = yield select(getWorkOrderFieldTypes);
  const { id } = sorted;
  const sortColumn = getFilterReferenceColumn(woFields[`${id}`], id);
  const sortColumnDisplay = woFields[sortColumn]
    ? woFields[sortColumn].display
    : "";
  const filterColumnDisplay = woFields[filterColumn]
    ? woFields[filterColumn].display
    : "";
  // Incase if the exists filter text, remove active selection & current page.
  yield put({ config: { "-": ["page", "row"] }, type: UPDATE_GRID_STATE });
  // Retrive first set of configured number of workorders for the new view.
  if (woId) {
    yield put({
      ...changed,
      filterColumn,
      filterColumnDisplay,
      key: KEY_WORKORDERS,
      sorted: { sortColumnDisplay, ...sorted },
      status,
      type: GET_WORKORDER,
      view
    });
  } else {
    yield put({
      ...changed,
      filterColumn,
      filterColumnDisplay,
      key: KEY_WORKORDERS,
      sorted: { sortColumnDisplay, ...sorted },
      status,
      type: GET_WORKORDERS,
      view
    });
  }
}

export function* statusFilterChangeWorker(action) {
  const { changed } = action;
  yield put({ changed, type: UPDATE_GRID_STATE });
  const view = yield select(getView);
  const { type } = view;
  if (type === "WO") {
    // In case of single WO launch, Statue Filter change has no effect.
    return;
  }
  const filterColumn = yield select(getFilterName);
  const filterText = yield select(getFilterText);

  const sorted = yield select(getColumnSort, view);
  // Incase if the exists filter text, remove active selection & current page.
  yield put({ config: { "-": ["page", "row"] }, type: UPDATE_GRID_STATE });
  // Retrive first set of configured number of workorders for the new view.
  yield put({
    ...changed,
    filterColumn,
    filterText,
    key: KEY_WORKORDERS,
    sorted,
    type: GET_WORKORDERS,
    view
  });
  const isSET058 = JSON.parse(getSettingValue(SET058, FALSE).toLowerCase());
  if (isSET058) {
    yield put({ type: FETCH_DELTA_EVENTS });
  }
}

export function* pageSelectionChangeWorker(action) {
  const { changed } = action;
  const activePage = yield select(getActivePage);
  yield put({ changed, config: { "-": ["row"] }, type: UPDATE_GRID_STATE });
  const nextRecordsUrl = yield select(getNextRecordsUrl);
  if (CACHE_WORKORDERS) {
    const { page: nextPage } = changed;
    if (activePage + 1 === nextPage) {
      const content = yield select(getActiveWorkOrders);
      const nextContent = yield select(getNextWorkOrders);
      yield put({
        data: nextContent,
        key: KEY_WORKORDERS,
        type: WORKORDERS_LOADED
      });
      yield put({
        data: content,
        key: KEY_PREV_WORKORDERS,
        type: WORKORDERS_LOADED
      });
      const hasMoreRecords = yield select(hasMoreWorkOrders);
      if (hasMoreRecords) {
        yield put({
          key: KEY_NEXT_WORKORDERS,
          nextRecordsUrl,
          page: activePage + 2,
          type: GET_WORKORDERS
        });
      }
    } else if (activePage - 1 === nextPage) {
      const content = yield select(getActiveWorkOrders);
      const prevContent = yield select(getPrevWorkOrders);
      yield put({
        data: prevContent,
        key: KEY_WORKORDERS,
        type: WORKORDERS_LOADED
      });
      yield put({
        data: content,
        key: KEY_NEXT_WORKORDERS,
        type: WORKORDERS_LOADED
      });
      if (nextPage) {
        yield put({
          key: KEY_PREV_WORKORDERS,
          nextRecordsUrl,
          page: activePage - 2,
          type: GET_WORKORDERS
        });
      }
    } else {
      const content = yield select(getActiveWorkOrders);
      const pages = calculateTotalPage(content);
      yield put({
        key: KEY_WORKORDERS,
        nextRecordsUrl,
        page: nextPage,
        type: GET_WORKORDERS
      });
      if (nextPage < pages - 1) {
        yield put({
          key: KEY_NEXT_WORKORDERS,
          nextRecordsUrl,
          page: nextPage + 1,
          type: GET_WORKORDERS
        });
      }
      if (nextPage) {
        yield put({
          key: KEY_PREV_WORKORDERS,
          nextRecordsUrl,
          page: nextPage - 1,
          type: GET_WORKORDERS
        });
      }
    }
  } else {
    yield put({
      ...changed,
      key: KEY_WORKORDERS,
      nextRecordsUrl,
      type: GET_WORKORDERS
    });
  }
}

export function* sortOrderChangeWorker(action) {
  const view = yield select(getView);
  const { type } = view;
  // In case of single WO View, Sort doesn't make any sense.
  if (type === "WO") {
    return;
  }
  const { changed } = action;
  const { sorted } = changed;
  const { desc, id } = sorted;
  const woFields = yield select(getWorkOrderFieldTypes);
  const column = getFilterReferenceColumn(woFields[`${id}`], id);
  const columnDisplay = woFields[column] ? woFields[column].display : "";
  const sortOrder = desc ? DESC_SORT_ORDER : DEFAULT_SORT_ORDER;
  let found;
  if (isView(view)) {
    const viewCounters = getUserSetting(VIEW_COUNTER, []);
    if (viewCounters && viewCounters.length) {
      const { Key } = view;
      found = viewCounters.filter(viewCounter => viewCounter.id === Key);
      if (found.length) {
        const [viewCounter] = found;
        viewCounter.column = id;
        viewCounter.sortOrder = sortOrder;
        yield put({
          changed: { [VIEW_COUNTER]: viewCounters },
          type: UPDATE_USER_SETTINGS
        });
      }
    }
  }

  if (!found || !found.length) {
    const sortedOrder = { wo_sortColumn: id, wo_sortOrder: sortOrder };
    yield put({ changed: sortedOrder, type: UPDATE_USER_SETTINGS });
  }

  // Incase if the exists filter text, remove active selection & current page.
  yield put({ config: { "-": ["page", "row"] }, type: UPDATE_GRID_STATE });

  const filterColumn = yield select(getFilterName);
  const filterText = yield select(getFilterText);
  const status = yield select(getStatusFilter);
  const filterColumnDisplay = woFields[filterColumn]
    ? woFields[filterColumn].display
    : "";
  // Retrive first set of configured number of workorders for the new view.
  yield put({
    filterColumn,
    filterColumnDisplay,
    filterText,
    key: KEY_WORKORDERS,
    sorted: {
      desc,
      id: column,
      sortColumnDisplay: columnDisplay
    },
    status,
    type: GET_WORKORDERS,
    view
  });
}

export function* rowSelectionChangeWorker(action) {
  const { changed } = action;
  const { row } = changed;
  const { Id } = row;
  const workOrder = yield select(getSelectedWorkOrder, Id);
  yield put({
    changed: { gridActive: true, row: workOrder },
    type: UPDATE_GRID_STATE
  });
}

export function* gridColumnChangeWorker(action) {
  const { changed } = action;
  const { wo_woCol: woCol } = changed;
  let woFields;
  let fieldExists = true;
  const view = yield select(getView);
  const requiredWoFields = getUserSetting(WO_GRID_CONF_FIELDS, []);
  const woColumns = getUserSetting(WO_COL, []);
  const svmxView = isView(view);
  if (!svmxView) {
    woFields = yield select(getWorkOrderRecordFields);
  }
  changed.wo_woCol = flatMap(woCol, name => {
    if (woFields && fieldExists) {
      fieldExists = woFields.includes(name);
    }
    if (!requiredWoFields.includes(name)) {
      requiredWoFields.push(name);
    }
    const found = woColumns.find(woColumn => {
      const { name: colName } = woColumn;
      return colName === name;
    });
    if (found) {
      return found;
    }
    return { name };
  });

  if (!fieldExists) {
    changed.wo_grid_conf_fields = requiredWoFields;
    // Incase if newly added column doesn't exists. Reset to first page & clear active selection
    yield put({ config: { "-": ["page", "row"] }, type: UPDATE_GRID_STATE });
  }
  yield put({ changed, type: UPDATE_USER_SETTINGS });

  try {
    yield put({ key: KEY_USER_SETTINGS, type: SAVING_USER_SETTINGS });
    const settings = yield select(getUserSettingFromStore);
    if (!settings) {
      return;
    }
    const response = yield call(saveUserSettings, settings);
    const { success } = response;
    if (success) {
      yield put({
        key: KEY_USER_SETTINGS,
        type: USER_SETTINGS_LOADED
      });
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_USER_SETTINGS,
      type: SAVING_USER_SETTINGS_API_ERRORED
    });
  }

  if (!fieldExists && !svmxView) {
    const filterColumn = yield select(getFilterName);
    const filterText = yield select(getFilterText);
    const status = yield select(getStatusFilter);
    const sorted = yield select(getColumnSort, view);
    const { Key: woId, type } = view;
    if (type) {
      yield put({
        type: GET_WORKORDER,
        woId,
        view
      });
    } else {
      // Retrive first set of configured number of workorders for the new view.
      yield put({
        filterColumn,
        filterText,
        key: KEY_WORKORDERS,
        sorted,
        status,
        type: GET_WORKORDERS,
        view
      });
    }
  }
}

export function* gridColumnResizeWorker(action) {
  const { changed } = action;
  const { column: columns } = changed;
  const woColumns = getUserSetting(WO_COL, []);
  columns.forEach(column => {
    const { id: name, value: width } = column;
    woColumns.filter(woCol => {
      if (woCol.name === name) {
        woCol.width = Math.round(width);
      }
      return undefined;
    });
  });

  yield put({ changed: { [WO_COL]: woColumns }, type: UPDATE_USER_SETTINGS });
}

export function* gridColorRuleChangeWorker(action) {
  const { changed } = action;
  const { wo_woRules: woRules } = changed;

  let fieldExists = true;
  const view = yield select(getView);
  const requiredWoFields = getUserSetting(REQ_WO_FIELDS, []);

  if (woRules && activityModalService.getActiveRuleIndex() !== -1) {
    const { operand } = woRules[activityModalService.getActiveRuleIndex()];

    operand.flatMap(row => {
      if (!requiredWoFields.includes(row.property)) {
        requiredWoFields.push(row.property);
        fieldExists = false;
      }
      return row.property;
    });
  }

  if (!fieldExists) {
    changed[REQ_WO_FIELDS] = requiredWoFields;
    // Incase if newly added column doesn't exists. Reset to first page & clear active selection
    yield put({ config: { "-": ["page", "row"] }, type: UPDATE_GRID_STATE });
  }

  yield put({ changed, type: UPDATE_USER_SETTINGS });
  yield put({ type: SAVE_USER_SETTINGS });

  if (!fieldExists) {
    const filterColumn = yield select(getFilterName);
    const filterText = yield select(getFilterText);
    const status = yield select(getStatusFilter);
    const sorted = yield select(getColumnSort, view);
    const { Key: woId, type } = view;
    if (type) {
      yield put({
        type: GET_WORKORDER,
        woId,
        view
      });
    } else {
      yield put({
        filterColumn,
        filterText,
        key: KEY_WORKORDERS,
        sorted,
        status,
        type: GET_WORKORDERS,
        view
      });
    }
  }
  yield put(applyUserSettings());
}

export function* gridStateWatcher() {
  yield takeLatest(DEFAULT_VIEW_CHANGED, defaultViewChangeWorker);
  yield takeLatest(VIEW_SELECTION_CHANGED, viewSelectionChangeWorker);
  yield takeLatest(FILTER_COLUMN_CHANGED, filterColumnChangeWorker);
  yield takeLatest(FILTER_TEXT_CHANGED, filterTextChangeWorker);
  yield takeLatest(STATUS_FILTER_CHANGED, statusFilterChangeWorker);
  yield takeLatest(PAGE_SELECTION_CHANGED, pageSelectionChangeWorker);
  yield takeLatest(SORT_ORDER_CHANGED, sortOrderChangeWorker);
  yield takeLatest(ROW_SELECTION_CHANGED, rowSelectionChangeWorker);
  yield takeLatest(GRID_COLUMN_CHANGED, gridColumnChangeWorker);
  yield takeLatest(GRID_COLUMN_RESIZED, gridColumnResizeWorker);
  yield takeLatest(COLOR_RULE_CHANGED, gridColorRuleChangeWorker);
}
