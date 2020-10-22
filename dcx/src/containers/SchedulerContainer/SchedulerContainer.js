import React, { Component } from "react";
import store from "store";
import moment from "moment";
import { connect } from "react-redux";
import { PropTypes } from "prop-types";
import { bindActionCreators } from "redux";
import { submit, change } from "redux-form";
import { Grid, GridRow, GridItem } from "@svmx/ui-components-lightning";
import SchedulerToolbar from "components/SchedulerToolbar";
import SchedulerView from "components/SchedulerView";
import { isEqual } from "lodash";
import {
  updateUserSettings,
  saveUserSettings
} from "actions/UserSettingAction";
import {
  schedulerDeleteEventChanged,
  schedulerStateChanged
} from "actions/SchedulerAction";
import {
  DCON001_SET001,
  DEFAULT_CALENDAR_DURATION,
  getSettingValue
} from "constants/AppSettings";
import { technicianActions } from "actions/TechnicianAction";
import { appStatusAction } from "actions/AppStatusAction";
import { updateTimeZoneAction } from "actions/MetaDataAction";
import { gridStateChanged } from "actions/GridViewAction";
import { eventActions } from "actions/EventsAction";
import { formatDateTime } from "utils/DateAndTimeUtils";
import { dateCompare, sortTeamTerrirtoyBySequence } from "utils/SchedulerUtils";
import { getUserSetting } from "utils/DCUtils";
import {
  GET_DELTA_WORK_ORDER,
  SEARCH_TECH_DATA_CLEAR,
  SCHEDULER_CONF_CHANGED,
  SEARCH_TECH_DATA_EMPTY,
  SHOW_ROUTE_TECH_DATA_EMPTY,
  UPDATE_SCHEDULER_STATE,
  RESET_SCHEDULER_VIEW,
  DELETE_EVENTS,
  DELETE_JDM_EVENTS,
  DATE_SELECTION_ERRORED,
  UNASSIGN_WO,
  UPDATE_GRID_STATE,
  EXPAND_COLLAPSE_TREE,
  ZOOM_OUT_MAX_REACHED,
  ZOOM_IN_MAX_REACHED,
  VIEW_SELECTION_CHANGED,
  ROW_SELECTION_CHANGED
} from "constants/ActionConstants";
import {
  DEFAULT_END_DATE,
  DEFAULT_START_DATE,
  EVENT_START_DATE,
  EVENT_END_DATE,
  getSchedulerState
} from "constants/SchedulerConstants";
import {
  DEFAULT_TIME_FORMAT,
  FILTER_TECHNICIAN_RESULT,
  FILTER_EVENTS_RESULT
} from "constants/AppConstants";
import {
  YODA_DATE_TIME_ZONE_24_HR_FORMAT,
  DATE_FORMAT
} from "constants/DateTimeConstants";
import { TECH_REFRESH_EVENTS_ONCHANGE } from "constants/UserSettingConstants";
import { MAP_CUSTOM_EVENT_MAP_CONFIG_CHANGE } from "constants/MapConstants";
import { setErrorConfigCallBackFunction } from "services/MapService";

import "./SchedulerContainer.scss";

const mapDispatchToProps = dispatch => ({
  actions: bindActionCreators(
    { ...eventActions(), ...technicianActions(), schedulerStateChanged },
    dispatch
  ),
  chageFormField: (formName, fieldName, value) =>
    dispatch(change(formName, fieldName, value)),
  clearFilterEvents: () =>
    dispatch(
      schedulerStateChanged({ filterEvents: null }, UPDATE_SCHEDULER_STATE)
    ),
  deleteEvents: (eventData, callback) =>
    dispatch(
      schedulerDeleteEventChanged({ ...eventData }, DELETE_EVENTS, callback)
    ),
  deleteJDMEvents: (eventData, callback) =>
    dispatch(
      schedulerDeleteEventChanged({ ...eventData }, DELETE_JDM_EVENTS, callback)
    ),
  mapConfChanged: (changed, autoSave) => {
    dispatch(updateUserSettings(changed, autoSave));
    setTimeout(() => {
      autoSave && dispatch(saveUserSettings());
    }, 0);
  },
  onClearSearchTech: () => dispatch({ type: SEARCH_TECH_DATA_CLEAR }),
  onGetDeltaWorkOrder: (payload, callback) =>
    dispatch({ callback, payload, type: GET_DELTA_WORK_ORDER }),
  onSearchTechEmpty: () => dispatch({ type: SEARCH_TECH_DATA_EMPTY }),
  onShowRouteTechEmpty: () => dispatch({ type: SHOW_ROUTE_TECH_DATA_EMPTY }),
  removeUnAssignWO: obj =>
    dispatch(
      schedulerStateChanged(
        { WOUnAssigned: { ...obj } },
        UPDATE_SCHEDULER_STATE
      )
    ),
  addWOtoGridTop: obj =>
    dispatch(
      schedulerStateChanged({ addWOtoGrid: { ...obj } }, UPDATE_SCHEDULER_STATE)
    ),
  resetSchedulerView: () => dispatch({ type: RESET_SCHEDULER_VIEW }),
  schedulerConfChanged: (settings, activeRuleIndex) =>
    dispatch(
      schedulerStateChanged(
        { ...settings, activeRuleIndex },
        SCHEDULER_CONF_CHANGED
      )
    ),
  submitForm: formName => dispatch(submit(formName)),
  treeConfChanged: changed =>
    dispatch(schedulerStateChanged(changed, EXPAND_COLLAPSE_TREE)),
  underScheduledEvent: value =>
    dispatch({ changed: { woUnderScheduled: value }, type: UPDATE_GRID_STATE }),
  unAssignWO: (woData, callback) =>
    dispatch(schedulerDeleteEventChanged({ ...woData }, UNASSIGN_WO, callback)),
  updateAppStatus: type => dispatch(appStatusAction(type)),
  updateStartDate: (startData, endDate) =>
    dispatch(
      schedulerStateChanged(
        {
          eventsEndDate: formatDateTime(endDate),
          eventsStartDate: formatDateTime(startData)
        },
        UPDATE_SCHEDULER_STATE
      )
    ),
  updateUserTimeZone: timeZone => dispatch(updateTimeZoneAction(timeZone)),
  viewSelectionChanged: (view, reload) =>
    dispatch(gridStateChanged({ reload, view }, VIEW_SELECTION_CHANGED)),
  selectGridRow: row =>
    dispatch(gridStateChanged({ row }, ROW_SELECTION_CHANGED))
});

const mapStateToProps = ({
  eventsData,
  gridState,
  metaData,
  technicianData,
  schedulerState,
  userSettings,
  workOrderData
}) => {
  const { timeZones, userTimezone, workOrderFields } = metaData;
  const { row: selectedWO, gridActive } = gridState;
  const {
    loading,
    defaultEndDate,
    defaultStartDate,
    endDateTime,
    eventsEndDate,
    eventsStartDate,
    newViewState,
    startDateTime
  } = schedulerState;
  let { activeView, teamView, territoryView } = schedulerState;
  const { content: woFields } = workOrderFields;
  const { techniciansWorkingHours } = technicianData;
  const { eventsHoverInfo, multiAssignUpdate, deltaEvents } = eventsData;
  const { data } = eventsHoverInfo;
  const { content: eventHoverRules } = data;
  const { workOrders = undefined } = workOrderData || {};
  const { content = undefined } = workOrders || {};
  const { records: woInfo } = content || workOrders || {};
  const {
    filterEvents: filterSchedulerEvents,
    WOUnAssigned,
    projectView
  } = schedulerState;
  const {
    tech_teamSequence: teamSequence,
    tech_territorySequence: territorySequence
  } = userSettings;
  teamView = sortTeamTerrirtoyBySequence(teamView, teamSequence);
  territoryView = sortTeamTerrirtoyBySequence(territoryView, territorySequence);
  return {
    loading,
    activeView,
    endDateTime: new Date(endDateTime),
    startDateTime: new Date(startDateTime),
    eventsEndDate: new Date(eventsEndDate),
    eventsStartDate: new Date(eventsStartDate),
    schedulerStartDate: new Date(defaultStartDate),
    schedulerEndDate: new Date(defaultEndDate),
    eventHoverRules,
    filterSchedulerEvents,
    multiAssignUpdate: (multiAssignUpdate && multiAssignUpdate.data) || {},
    newViewState,
    selectedWO,
    gridActive,
    teamView,
    techWorkHours:
      (techniciansWorkingHours && techniciansWorkingHours.data) || [],
    territoryView,
    timeZones: (timeZones && timeZones.content) || [],
    userSettings,
    userTimezone: userTimezone && userTimezone.content,
    woInfo,
    woFields,
    WOUnAssigned,
    projectView,
    deltaEvents
  };
};

const propTypes = {
  actions: PropTypes.objectOf(PropTypes.func),
  chageFormField: PropTypes.func.isRequired,
  endDateTime: PropTypes.string.isRequired,
  events: PropTypes.arrayOf(PropTypes.object),
  eventsEndDate: PropTypes.string.isRequired,
  eventsStartDate: PropTypes.string.isRequired,
  mapConfChanged: PropTypes.shape({}).isRequired,
  resetSchedulerView: PropTypes.func.isRequired,
  selectedWO: PropTypes.shape({}).isRequired,
  startDateTime: PropTypes.string.isRequired,
  submitForm: PropTypes.func.isRequired,
  teamView: PropTypes.arrayOf(PropTypes.object).isRequired,
  timeZones: PropTypes.arrayOf(PropTypes.object).isRequired,
  updateAppStatus: PropTypes.func.isRequired,
  updateUserTimeZone: PropTypes.func.isRequired,
  userSettings: PropTypes.shape({}).isRequired,
  userTimezone: PropTypes.shape({}).isRequired,
  projectView: PropTypes.bool
};

const defaultProps = {
  actions: {},
  events: []
};

class SchedulerContainer extends Component {
  constructor(props) {
    super(props);
    const { eventsEndDate: endDate, eventsStartDate: startDate } = props;
    this.state = {
      endDate,
      isEventDeleteEnabled: false,
      startDate,
      zoomInState: 0,
      zoomOutState: 0
    };
  }

  componentDidMount() {
    window.addEventListener(
      MAP_CUSTOM_EVENT_MAP_CONFIG_CHANGE,
      this.handleMapConfigChange,
      false
    );
    setErrorConfigCallBackFunction(this.handleMapErrorStatus);
  }

  componentWillUnmount() {
    window.removeEventListener(
      MAP_CUSTOM_EVENT_MAP_CONFIG_CHANGE,
      this.handleMapConfigChange,
      false
    );
  }

  handleMapErrorStatus = (errorInfo, clearTxt = false) => {
    const { actions } = this.props;
    const { createMapError, statusBarClearTxt } = actions;
    if (clearTxt) {
      statusBarClearTxt();
    } else {
      const { errorCodeMsg, markerMsg, message } = errorInfo;
      if (createMapError && errorCodeMsg) {
        const data = { error: { errorCode: errorCodeMsg, message: markerMsg } };
        createMapError(data, message);
      }
    }
  };

  handleRefreshEventDateCheck = () => {
    const { startDate, endDate } = this.state;
    const startDateInit = moment(startDate).format(DATE_FORMAT);
    const endDateInit = moment(endDate).format(DATE_FORMAT);
    const dateCheck = dateCompare(endDateInit, startDateInit);
    const validDate = dateCheck === "isAfter" || dateCheck === "isSame";
    return validDate;
  };

  // Tollbar actions
  reloadEvents = () => {
    const dateValid = this.handleRefreshEventDateCheck();
    if (dateValid) {
      const { actions } = this.props;
      const { startDate, endDate } = this.state;
      actions.schedulerStateChanged(
        {
          eventsEndDate: formatDateTime(moment(endDate)),
          eventsStartDate: formatDateTime(moment(startDate))
        },
        UPDATE_SCHEDULER_STATE
      );
      this.schedulerView.reloadEvents({ isEventRefresh: true });
    } else {
      const { updateAppStatus } = this.props;
      updateAppStatus(DATE_SELECTION_ERRORED);
    }
  };

  applyTimeZone = selection => {
    const { startDate, endDate } = this.state;
    const { actions, timeZones, updateUserTimeZone } = this.props;
    if (updateUserTimeZone) {
      const [userTimeZone] = timeZones.filter(
        timeZone => timeZone.name === selection
      );
      updateUserTimeZone(userTimeZone);
    }
    const { configData = {} } = window;
    this.schedulerView.updateTimeLineMarker(selection);

    // In case if the scheduler Date Ranage has changed, Update Store before reload events.
    const eventsEndDate = getSchedulerState(EVENT_END_DATE);
    const eventsStartDate = getSchedulerState(EVENT_START_DATE);
    if (
      new Date(eventsStartDate).getTime() !== startDate.getTime() ||
      new Date(eventsEndDate).getTime() !== endDate.getTime()
    ) {
      actions.schedulerStateChanged(
        {
          eventsStartDate: formatDateTime(moment(startDate)),
          eventsEndDate: formatDateTime(moment(endDate))
        },
        UPDATE_SCHEDULER_STATE
      );
    }
    setTimeout(
      () =>
        this.schedulerView.reloadEvents({
          timeZone: `${selection}@${configData.userTimeFormat ||
            DEFAULT_TIME_FORMAT}`
        }),
      0
    );
  };

  handleViewZoomIn = event => {
    this.setState({ zoomInState: 1 });
    setTimeout(() => this.schedulerView.handleViewZoomIn(event), 0);
  };

  handleViewZoomOut = event => {
    this.setState({ zoomOutState: 1 });
    setTimeout(() => this.schedulerView.handleViewZoomOut(event), 0);
  };

  handleZoomComplete = (
    zoomLevel,
    minZoomLevel,
    maxZoomLevel,
    startDate,
    endDate,
    event
  ) => {
    const { updateAppStatus } = this.props;
    const {
      startDate: eStartDate,
      endDate: eEndDate,
      zoomOutState: zoomOutClicked,
      zoomInState: zoomInClicked
    } = this.state;
    if (zoomOutClicked || zoomInClicked) {
      const zoomInState = zoomLevel >= maxZoomLevel;
      const zoomOutState = zoomLevel <= minZoomLevel;
      if (zoomOutState) {
        updateAppStatus(ZOOM_OUT_MAX_REACHED);
      }
      if (zoomInState) {
        updateAppStatus(ZOOM_IN_MAX_REACHED);
      }
      this.setState({
        endDate,
        startDate,
        zoomLevel,
        zoomInState,
        zoomOutState
      });
      return;
    }

    if (moment(endDate).diff(moment(startDate), "years") >= 5) {
      this.setState({
        endDate,
        startDate,
        zoomLevel,
        zoomInState: false,
        zoomOutState: true
      });
      updateAppStatus(ZOOM_OUT_MAX_REACHED);
      return;
    }
    const { type } = event || {};
    if (type === "mousemove") {
      this.setState({
        endDate,
        startDate,
        zoomLevel
      });
    } else {
      this.setState({
        endDate: eEndDate,
        startDate: eStartDate,
        zoomLevel
      });
    }
  };

  updateDateRange = (startDate, endDate) => {
    this.setState({ startDate, endDate });
  };

  handleEndDateChange = value => {
    const { actions } = this.props;
    actions.statusBarClearTxt();
    this.setState({ endDate: value.toDate() }, () => {
      const autoRefreshEvents = getUserSetting(
        TECH_REFRESH_EVENTS_ONCHANGE,
        false
      );
      if (JSON.parse(autoRefreshEvents)) {
        const { startDate } = this.state;
        const starDateMoment = moment(startDate);
        const changed = { eventsEndDate: formatDateTime(value.endOf("day")) };
        if (starDateMoment.diff(value, "days") <= 0) {
          changed.eventsStartDate = formatDateTime(
            starDateMoment.startOf("day")
          );
        }
        actions.schedulerStateChanged(changed, UPDATE_SCHEDULER_STATE);
        // This is ensure that you we run reloadEvents as an async action.
        setTimeout(() => this.reloadEvents(), 0);
      }
    });
  };

  handleStartDateChange = value => {
    const { actions } = this.props;
    actions.statusBarClearTxt();
    this.setState({ startDate: value.toDate() }, () => {
      // This is ensure that you we run reloadEvents as an async action.
      const autoRefreshEvents = getUserSetting(
        TECH_REFRESH_EVENTS_ONCHANGE,
        false
      );
      if (JSON.parse(autoRefreshEvents)) {
        const { endDate } = this.state;
        const endDateMoment = moment(endDate);
        const changed = {
          eventsStartDate: formatDateTime(value.startOf("day"))
        };
        if (endDateMoment.diff(value, "days") <= 0) {
          changed.eventsEndDate = formatDateTime(endDateMoment.endOf("day"));
        }
        actions.schedulerStateChanged(changed, UPDATE_SCHEDULER_STATE);
        setTimeout(() => this.reloadEvents(), 0);
      }
    });
  };

  handleResetTime = () => {
    const { actions } = this.props;
    const eventsEndDate = getSchedulerState(DEFAULT_END_DATE);
    const eventsStartDate = getSchedulerState(DEFAULT_START_DATE);

    actions.schedulerStateChanged(
      { eventsEndDate, eventsStartDate },
      UPDATE_SCHEDULER_STATE
    );
    const endDate = moment(
      eventsEndDate,
      YODA_DATE_TIME_ZONE_24_HR_FORMAT
    ).toDate();
    const startDate = moment(
      eventsStartDate,
      YODA_DATE_TIME_ZONE_24_HR_FORMAT
    ).toDate();
    this.setState({ startDate, endDate });

    setTimeout(() => this.schedulerView.handleResetTime(), 0);
  };

  handleSearchChange = () => {
    this.schedulerView.handleSearchChange();
  };

  handleTechConfigChange = () => {};

  handleAddEvent = () => {
    this.schedulerView.addNonWoEvent();
  };

  handleDeleteEvent = () => {
    this.schedulerView.handleDeletEventClick();
  };

  handleSelectedEvents = action => {
    this.setState({
      isEventDeleteEnabled: action === "select" || action === "update"
    });
  };

  handleProjectView = () => {
    this.schedulerView.zoomToFit();
  };

  filterTechnicians = () => {
    const { actions, newViewState, resetSchedulerView } = this.props;
    if (newViewState % 100 === FILTER_TECHNICIAN_RESULT) {
      resetSchedulerView();
    } else {
      const { filterTechnicians } = actions;
      if (filterTechnicians) {
        filterTechnicians();
      }
      // In case of filter technician is applied, after filter events we need to retrive all the events again, Hence doing Reload.
      if (newViewState % 100 === FILTER_EVENTS_RESULT) {
        this.schedulerView.reloadEvents({ isEventRefresh: true });
      }
    }
  };

  filterWorkOrderEvents = () => {
    const { newViewState, resetSchedulerView } = this.props;
    if (newViewState % 100 === FILTER_EVENTS_RESULT) {
      resetSchedulerView();
    } else {
      this.schedulerView.filterEvents();
    }
  };

  startFilterWOEvents = () => {
    const { actions } = this.props;
    actions.startFilterEvents();
  };

  doSave = (modifiedUserSettings, currentIndex, newStartDate) => {
    const { schedulerConfChanged, updateStartDate } = this.props;
    schedulerConfChanged(modifiedUserSettings, currentIndex);
    if (newStartDate) {
      let defCalDuration = DEFAULT_CALENDAR_DURATION;
      try {
        defCalDuration = parseInt(
          getSettingValue(DCON001_SET001, DEFAULT_CALENDAR_DURATION),
          10
        );
      } catch (e) {
        console.log(e);
      }

      // Based on new start date, compute end date and display scheduler timeline accordingly.
      const startDate = moment(newStartDate)
        .startOf("day")
        .toDate();
      const endDate = moment(startDate)
        .add(defCalDuration, "days")
        .add(1, "seconds")
        .toDate();
      updateStartDate(startDate, endDate);
      // Auto reload the events for the new date range.
      this.reloadEvents();
    }
  };

  handleMapConfigChange = ({ detail }) => {
    const { mapConfChanged } = this.props;
    const state = store.getState();
    const { userSettings } = state;
    const detailKeys = Object.keys(detail);
    const mapSettings = Object.keys(userSettings)
      .filter(key => detailKeys.includes(key))
      .reduce((obj, key) => {
        obj[key] = parseFloat(userSettings[key]);
        return obj;
      }, {});
    const dirty = isEqual(mapSettings, detail);
    if (dirty) {
      mapConfChanged(detail);
    } else {
      mapConfChanged(detail, true);
    }
  };

  render() {
    const {
      isEventDeleteEnabled,
      zoomInState,
      zoomOutState,
      startDate,
      endDate
    } = this.state;
    const {
      actions,
      eventsEndDate,
      eventsStartDate,
      mapConfChanged,
      newViewState,
      selectedWO,
      resetSchedulerView,
      submitForm,
      treeConfChanged,
      timeZones,
      updateAppStatus,
      userTimezone,
      userSettings,
      teamView,
      territoryView,
      techWorkHours,
      viewSelectionChanged
    } = this.props;
    const { applyATS } = actions;
    return (
      <Grid className="GridContainer" isVertical>
        <GridRow className="GridRow__gridViewToolbar">
          <GridItem>
            <SchedulerToolbar
              {...this.props}
              applyATS={applyATS}
              applyTimeZone={this.applyTimeZone}
              filterTechnicians={this.filterTechnicians}
              filterWorkOrderEvents={this.filterWorkOrderEvents}
              handleProjectView={this.handleProjectView}
              handleViewZoomIn={this.handleViewZoomIn}
              handleViewZoomOut={this.handleViewZoomOut}
              handleEndDateChange={this.handleEndDateChange}
              handleStartDateChange={this.handleStartDateChange}
              handleResetTime={this.handleResetTime}
              isEventDeleteEnabled={isEventDeleteEnabled}
              onMapConfig={mapConfChanged}
              onSave={this.doSave}
              onSchedulerReset={resetSchedulerView}
              onSearchChange={this.handleSearchChange}
              onTechConfigChange={this.handleTechConfigChange}
              addNonWoEvent={this.handleAddEvent}
              deleteEvent={this.handleDeleteEvent}
              eventsEndDate={endDate || eventsEndDate}
              eventsStartDate={startDate || eventsStartDate}
              newViewState={newViewState}
              selectedWO={selectedWO}
              startEventCall={this.reloadEvents}
              submitForm={submitForm}
              userSettings={userSettings}
              timeZones={timeZones}
              updateAppStatus={updateAppStatus}
              userTimezone={userTimezone}
              zoomInState={zoomInState}
              zoomOutState={zoomOutState}
            />
          </GridItem>
        </GridRow>
        <GridRow className="SchedulerContainer__grid-row">
          <GridItem className="GridItem__gridView">
            <SchedulerView
              {...this.props}
              onSchedulerViewChildRef={schedulerView => {
                this.schedulerView = schedulerView;
                return undefined;
              }}
              eventsEndDate={endDate || eventsEndDate}
              eventActions={actions}
              eventsStartDate={startDate || eventsStartDate}
              handleProjectView={this.handleProjectView}
              handleSelectedEvents={this.handleSelectedEvents}
              userSettings={userSettings}
              onTreeConfChanged={treeConfChanged}
              newViewState={newViewState}
              selectedWO={selectedWO}
              teamView={teamView}
              territoryView={territoryView}
              techWorkHours={techWorkHours}
              timeZones={timeZones}
              userTimezone={userTimezone}
              startFilterWOEvents={this.startFilterWOEvents}
              submitForm={submitForm}
              onHandleMapErrorStatus={this.handleMapErrorStatus}
              updateAppStatus={updateAppStatus}
              updateDateRange={this.updateDateRange}
              onZoomComplete={this.handleZoomComplete}
              viewSelectionChanged={viewSelectionChanged}
            />
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

SchedulerContainer.propTypes = propTypes;
SchedulerContainer.defaultProps = defaultProps;
export default connect(mapStateToProps, mapDispatchToProps)(SchedulerContainer);
