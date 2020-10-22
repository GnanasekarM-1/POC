import React, { useEffect, useState } from "react";
import { isEmpty } from "lodash";
import { connect } from "react-redux";
import { submit, reset } from "redux-form";
import {
  Spinner,
  Grid,
  GridRow,
  GridItem
} from "@svmx/ui-components-lightning";
import GridViewToolbar from "components/GridViewToolbar";
import GridView from "components/GridView";
import {
  calculateTotalPage,
  getGridColumns,
  getGridRows,
  normalizeColumnName
} from "utils/GridUtils";
import { isView } from "utils/ViewUtils";
import {
  saveUserSettings,
  runAutoSaveUserSettings
} from "actions/UserSettingAction";
import {
  schedulerDeleteEventChanged,
  schedulerStateChanged
} from "actions/SchedulerAction";
import { eventActions } from "actions/EventsAction";
import { gridStateChanged } from "actions/GridViewAction";
import { updateWorkOrders } from "actions/WorkOrderAction";
import { getDisplayValue } from "utils/DCUtils";
import { getSettingValue, SET020 } from "constants/AppSettings";
import {
  TAG057,
  TAG181,
  TAG167,
  EVENTSTAG144
} from "constants/DisplayTagConstants";
import {
  API_ERRORED,
  API_DATA_LOADED,
  COLOR_RULE_CHANGED,
  DEFAULT_VIEW_CHANGED,
  VIEW_SELECTION_CHANGED,
  FILTER_COLUMN_CHANGED,
  FILTER_TEXT_CHANGED,
  STATUS_FILTER_CHANGED,
  PAGE_SELECTION_CHANGED,
  SORT_ORDER_CHANGED,
  ROW_SELECTION_CHANGED,
  GRID_COLUMN_CHANGED,
  GRID_COLUMN_RESIZED,
  UPDATE_GRID_STATE,
  UPDATE_SCHEDULER_STATE,
  UNASSIGN_WO
} from "constants/ActionConstants";
import {
  NAME,
  DEFAULT_SORT_BY,
  DESC_SORT_ORDER,
  MANAGE_MULTIPLE_ASSIGNMENTS,
  SHOW_RECORD,
  UNASSIGN_THIS_WORK_ORDER,
  RANKED_APPOINTMENT_BOOKING
} from "constants/AppConstants";
import { appStatusAction } from "actions/AppStatusAction";
import ErrorModalDialog from "components/PageFooter/ErrorModalDialog";
import MultipleAssignmentModal from "components/Modals/MultipleAssignmentModal";

import "./GridContainer.scss";

const mapStateToProps = ({
  gridState,
  metaData,
  userSettings,
  viewData,
  workOrderData,
  schedulerState
}) => {
  const { userTimezone, workOrderFields } = metaData;
  const { views, viewWorkOrderCount } = viewData;
  const { workOrders } = workOrderData;
  const { content: woFieldObj } = workOrderFields;
  const {
    WOUnAssigned,
    addWOtoGrid,
    timeZone: selectedTimeZone
  } = schedulerState;
  return {
    gridState,
    userSettings,
    userTimezone: (userTimezone && userTimezone.content) || {},
    viewCount: (viewWorkOrderCount && viewWorkOrderCount.content) || [],
    views,
    woFieldObj,
    workOrders,
    WOUnAssigned,
    addWOtoGrid,
    selectedTimeZone
  };
};

function mapDispatchToProps(dispatch) {
  const { fetchEventWoInfoCall, startFilterEvents } = eventActions();
  return {
    updateAppStatus: (type, message, msgType) =>
      dispatch(appStatusAction(type, message, msgType)),
    autoSaveUserSettings: () => dispatch(runAutoSaveUserSettings()),
    eventCreationCompleted: obj =>
      dispatch(gridStateChanged({ updateWOGridRow: obj }, UPDATE_GRID_STATE)),
    defaultViewChanged: defaultView =>
      dispatch(
        gridStateChanged({ wo_defaultView: defaultView }, DEFAULT_VIEW_CHANGED)
      ),
    dispatch,
    fetchWOInfo: (callback, payload) =>
      dispatch(fetchEventWoInfoCall(callback, payload)),
    filterColumnChanged: filterColumn =>
      dispatch(
        gridStateChanged(
          { wo_filterColumn: filterColumn },
          FILTER_COLUMN_CHANGED
        )
      ),
    filterTextChanged: (
      filterColumn,
      filterText,
      filterEvents = false,
      projectView = false,
      woId
    ) =>
      dispatch(
        gridStateChanged(
          { filterColumn, filterText, filterEvents, projectView, woId },
          FILTER_TEXT_CHANGED
        )
      ),
    gridColorRuleChanged: modifiedColorRules =>
      dispatch(gridStateChanged({ ...modifiedColorRules }, COLOR_RULE_CHANGED)),
    gridColumnChanged: (wo_woCol, wo_autorefresh, wo_refreshtime) =>
      dispatch(
        gridStateChanged(
          { wo_autorefresh, wo_refreshtime, wo_woCol },
          GRID_COLUMN_CHANGED
        )
      ),
    gridColumnResized: column =>
      dispatch(gridStateChanged({ column }, GRID_COLUMN_RESIZED)),
    pageSelectionChanged: page =>
      dispatch(gridStateChanged({ page }, PAGE_SELECTION_CHANGED)),
    resetForm: formName => dispatch(reset(formName)),
    rowSelectionChanged: row =>
      dispatch(gridStateChanged({ row }, ROW_SELECTION_CHANGED)),
    saveUserSettings: () => dispatch(saveUserSettings()),
    sortOrderChanged: sorted =>
      dispatch(gridStateChanged({ sorted }, SORT_ORDER_CHANGED)),
    statusFilterChanged: status =>
      dispatch(gridStateChanged({ status }, STATUS_FILTER_CHANGED)),
    submitForm: formName => dispatch(submit(formName)),
    unAssignWO: (woData, callback) =>
      dispatch(
        schedulerDeleteEventChanged({ ...woData }, UNASSIGN_WO, callback)
      ),
    removeUnAssignWO: obj =>
      dispatch(
        schedulerStateChanged(
          { WOUnAssigned: { ...obj } },
          UPDATE_SCHEDULER_STATE
        )
      ),
    updateSingleWOInfo: woData => dispatch(updateWorkOrders({ woData })),
    underScheduledEvent: value =>
      dispatch({
        changed: { woUnderScheduled: value },
        type: UPDATE_GRID_STATE
      }),
    viewSelectionChanged: (view, reload) =>
      dispatch(gridStateChanged({ reload, view }, VIEW_SELECTION_CHANGED))
  };
}

const getContextMenuOptions = () => {
  const menuOptions = [];
  if (getSettingValue(SET020, true)) {
    menuOptions.push({
      display: getDisplayValue(TAG181),
      value: MANAGE_MULTIPLE_ASSIGNMENTS
    });
  }
  menuOptions.push({ display: getDisplayValue(TAG057), value: SHOW_RECORD });
  menuOptions.push({
    display: getDisplayValue(TAG167),
    value: UNASSIGN_THIS_WORK_ORDER
  });
  if (window.configData && window.configData.OptimaxLicenseEnabled) {
    menuOptions.push({
      display: getDisplayValue(EVENTSTAG144),
      value: RANKED_APPOINTMENT_BOOKING
    });
  }
  return menuOptions;
};

const GridContainer = props => {
  const { gridState, userSettings, workOrders } = props;
  const [filterDetail, setFilterDetail] = useState(null);
  const [openErrorModal, setOpenErrorModal] = useState(false);
  const [multiAssignModal, setMultiAssignModal] = useState(false);

  const applyFilter = (value, projectView, id) => {
    setFilterDetail({ value, projectView, id });
  };

  const clearFilter = () => {
    setFilterDetail(null);
  };

  useEffect(() => {
    const { status } = workOrders;
    const { viewError, api, code, message } = status;
    if (api === API_ERRORED || viewError) {
      setOpenErrorModal(
        viewError
          ? { errorCode: 500, message: viewError }
          : { errorCode: code, message }
      );
    } else {
      setOpenErrorModal(false);
    }
    return () => {};
  }, [workOrders]);

  useEffect(() => {
    const { autoSaveUserSettings } = props;
    const duration = 10 * 60 * 1000;
    const interval = setInterval(() => autoSaveUserSettings(), duration);
    return () => {
      autoSaveUserSettings();
      clearInterval(interval);
    };
  }, []);

  const getSortOrder = () => {
    const { view } = gridState;
    if (isView(view)) {
      const { wo_viewCounter: viewCounters } = userSettings;
      if (viewCounters && viewCounters.length) {
        const { Key } = view;
        const found = viewCounters.filter(
          viewCounter => viewCounter.id === Key
        );
        if (found.length) {
          const [viewCounter] = found;
          const { column, sortOrder } = viewCounter;
          return {
            desc: sortOrder
              ? sortOrder.toUpperCase() === DESC_SORT_ORDER.toUpperCase()
              : false,
            id: normalizeColumnName(column) || NAME
          };
        }
      }
    }
    const { wo_sortColumn: sortColumn, wo_sortOrder: sortOrder } = userSettings;
    return {
      desc: isEmpty(sortOrder)
        ? false
        : sortOrder.toUpperCase() === DESC_SORT_ORDER.toUpperCase(),
      id: isEmpty(sortColumn)
        ? DEFAULT_SORT_BY
        : normalizeColumnName(sortColumn)
    };
  };

  const isWorkOrderLoaded = () => {
    const { workOrders } = props;
    const { status } = workOrders;
    const { api } = status;
    return api === API_DATA_LOADED || api === API_ERRORED;
  };

  const {
    fetchWOInfo,
    filterTextChanged,
    eventCreationCompleted,
    gridColumnResized,
    pageSelectionChanged,
    rowSelectionChanged,
    removeUnAssignWO,
    sortOrderChanged,
    userTimezone,
    woFieldObj,
    unAssignWO,
    updateSingleWOInfo,
    underScheduledEvent,
    WOUnAssigned,
    addWOtoGrid,
    viewSelectionChanged,
    selectedTimeZone
  } = props;

  const { content = undefined } = workOrders;
  const { batchSize, view } = gridState;
  const {
    wo_woCol: woCol,
    wo_woHoverColor: woHoverColor,
    wo_woRules: woRules,
    wo_woSelectionColor: woSelectionColor,
    wo_grid_col_fields: requiredColorFields
  } = userSettings;
  const dataLoaded = isWorkOrderLoaded();
  const { records } = content || workOrders;
  const defaultColumns = isView(view) ? undefined : woCol;
  const columns = getGridColumns(view, defaultColumns, woFieldObj);
  const columnData = [
    ...columns,
    ...getGridColumns(null, requiredColorFields, woFieldObj)
  ];
  const data = getGridRows(records, columnData, woFieldObj, userTimezone);
  const pages = calculateTotalPage(content || workOrders, batchSize);
  const sorted = getSortOrder();
  return (
    <Grid className="GridContainer__work-order" isVertical>
      <GridRow className="GridRow__gridViewToolbar GridContainer__grid-row">
        <GridItem>
          <GridViewToolbar
            {...props}
            loading={!dataLoaded}
            filterDetail={filterDetail}
            clearFilter={clearFilter}
          />
        </GridItem>
      </GridRow>
      <GridRow className="GridRow__gridViewRow GridContainer__grid-row">
        <GridItem className="GridItem__gridView">
          {!dataLoaded && <Spinner size="large" />}
          {dataLoaded && (
            <GridView
              columns={columns}
              data={data}
              eventCreationCompleted={eventCreationCompleted}
              fetchWOInfo={fetchWOInfo}
              filterTextChanged={filterTextChanged}
              filterSingleWO={applyFilter}
              menuOptions={getContextMenuOptions()}
              pages={pages}
              pageSelectionChanged={pageSelectionChanged}
              rowSelectionChanged={rowSelectionChanged}
              sortOrderChanged={sortOrderChanged}
              gridColumnResized={gridColumnResized}
              gridState={gridState}
              rules={woRules}
              sorted={sorted}
              hoverColor={woHoverColor}
              viewSelectionChanged={viewSelectionChanged}
              openMMADialog={setMultiAssignModal}
              selectionColor={woSelectionColor}
              unAssignWO={unAssignWO}
              removeUnAssignWO={removeUnAssignWO}
              updateSingleWOInfo={updateSingleWOInfo}
              WOUnAssigned={WOUnAssigned}
              underScheduledEvent={underScheduledEvent}
              addWOtoGrid={addWOtoGrid}
            />
          )}
        </GridItem>
      </GridRow>
      {multiAssignModal && (
        <MultipleAssignmentModal
          open={multiAssignModal}
          isOpen={setMultiAssignModal}
          selectedTimeZone={selectedTimeZone}
        />
      )}
      {openErrorModal && (
        <ErrorModalDialog
          close={setOpenErrorModal}
          error={openErrorModal}
          open={openErrorModal}
        />
      )}
    </Grid>
  );
};

export default connect(mapStateToProps, mapDispatchToProps)(GridContainer);
