import React, { Component, Fragment } from "react";
import ReactDOMServer from "react-dom/server";
import { PropTypes } from "prop-types";
import moment from "moment-timezone";
import {
  Button,
  Container,
  Icon,
  Label,
  Grid,
  GridRow,
  GridItem,
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter,
  Scheduler
} from "@svmx/ui-components-lightning";
import {
  pull,
  isEqual,
  cloneDeep,
  concat,
  pullAllBy,
  difference,
  intersection,
  intersectionWith,
  flatMap,
  isEmpty,
  filter,
  clone,
  compact
} from "lodash";
import Drag from "utils/Drag";
import { getMinutesToHours } from "utils/DateTimeUtils";
import { formatDateTime } from "utils/DateAndTimeUtils";
import { applyEventColorRule, shadeColor } from "utils/ColorUtils";
import {
  getTechnicianColumn,
  setCollapsedTeam,
  setCollapsedTerritory,
  setExpandedTeam,
  setExpndedTerritory,
  getWorkOrderConfigMap,
  getExpandedTeamTechList,
  getExpandedTerritoryTechList,
  isTeamEventsLoaded,
  isTerritoryEventsLoaded,
  getSupportedPresets,
  getUserLocale,
  isSchedulingEnabled
} from "utils/SchedulerUtils";
import {
  TECH_COL,
  EXPANDED_TEAM,
  EXPANDED_TERRITORY,
  TECH_SHOWTIME_INDICATOR,
  TECH_TIMEINDICATOR_COLOR,
  getUserSettingValue
} from "constants/UserSettingConstants";
import {
  EVENTSTAG088,
  TAG006,
  TAG007,
  TAG066,
  TAG069,
  TAG082,
  TAG155,
  TAG199,
  TAG502,
  TAG279,
  TAG325,
  TAG487,
  TAG118,
  TAG183,
  TAG177,
  TAG240,
  TAG241,
  TAG260,
  EVENTSTAG144,
  EVENTSTAG142,
  EVENTSTAG036,
  EVENTSTAG075,
  EVENTSTAG074
} from "constants/DisplayTagConstants";
import {
  DCON005_SET006,
  DCON001_SET009,
  SET004,
  SET024,
  SET072,
  SET0235,
  DCON001_SET036,
  DCON001_SET054,
  DCON001_SET071,
  getSettingValue,
  SET056,
  SET010
} from "constants/AppSettings";
import {
  getSelectedSearch,
  openPopUp,
  setSearchTechDone,
  setTechnicianRouteData,
  setSchedulerSeletecdTech,
  getSchedulerSeletecdTech,
  dateTimeCheckForSame,
  checkForTechAndWoLocation,
  setShowRouteTechData,
  setShowRouteTechIdsData,
  getShowRouteTechIdsData,
  setShowRouteDataMap,
  getShowRouteDataMap,
  getShowRouteDataMapDone,
  getShowRouteSelectedDate,
  setShowRouteDataMapDone
} from "utils/MapUtils";
import {
  COLLAPSE_ALL,
  EXPAND_ALL,
  DEFAULT_TEAM,
  HOURS,
  MAP_CONFIG,
  WO_DISPATCH_STATUS_FIELD,
  WO_UNSCHEDULED_DURATIONS,
  TEAM_INDEX,
  TERRITORY_INDEX,
  TECH_KEYWORD,
  TECH_SEARCH_RESULT,
  TEAM_SEARCH_RESULT,
  ADV_SEARCH_RESULT,
  INITIAL_TREE_DATA,
  TECHNICIAN_COLUMN_ADDED,
  FILTER_TECHNICIAN_RESULT,
  FILTER_EVENTS_RESULT,
  MULTI_ASSIGN_EVENT_UPDATE,
  TECH_SALESFORCE_USER_INFO,
  DEFAULT_TREE_DATA,
  TEAM_SEQUENCE_CHANGED,
  TERRITORY_SEQUENCE_CHANGED,
  WORKORDER_TECHNICIAN_API_NAME,
  IS_ACTIVE,
  FALSE
} from "constants/AppConstants";
import { UPDATE_SCHEDULER_STATE } from "constants/ActionConstants";

import {
  MAP_CUSTOM_EVENT_LOAD_EVENTS,
  MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN
} from "constants/MapConstants";
import {
  drawSearchedTeams,
  drawSearchedTechnicians,
  getMapConfig,
  radiusModeNoLimitHandler,
  drawTechRouteForDay,
  setShowRouteCallBackFunction
} from "services/MapService";
import unScheduledDurationService from "services/UnScheduledDurationService";
import {
  getFieldValue,
  convertUint2Hex,
  getWorkOrderFromNumber,
  getDisplayValue,
  getUserSetting,
  stringToBoolean,
  lightOrDark
} from "utils/DCUtils";
import { toTime } from "utils/GridUtils";
import {
  DATE_FORMAT,
  DATE_TIME_FORMAT,
  DATE_TIME_24H_FORMAT,
  YODA_DATE_TIME_ZONE_24_HR_FORMAT
} from "constants/DateTimeConstants";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";
import DeleteEventModal from "../Modals/DeleteEventModal";
import JDMDeleteEventModal from "../Modals/JDMDeleteEventModal";
import NonWoCreateEventModal from "../Modals/NonWoCreateEventModal";
import NonWoDragEventModal from "../Modals/NonWoDragEventModal";
import DayViewModal from "../Modals/DayViewModal";
import CreateEditEventModal from "../Modals/CreateEditEventModal";

import "./SchedulerView.scss";

const defaultProps = {
  teamView: [],
  territoryView: []
};

const propTypes = {
  actions: PropTypes.shape({}).isRequired,
  onSchedulerViewChildRef: PropTypes.func.isRequired,
  onSearchTechEmpty: PropTypes.func.isRequired,
  teamView: PropTypes.arrayOf(PropTypes.oneOfType([PropTypes.shape({})])),
  territoryView: PropTypes.arrayOf(PropTypes.oneOfType([PropTypes.shape({})]))
};

let currentRecord = "";
let eventClicks = 0;
let scrollEventTo = {};

class SchedulerView extends Component {
  constructor(props) {
    super(props);
    const me = this;
    getUserLocale(props.userTimezone.locale);
    me.engine = React.createRef();
    me.allEvents = [];
    me.dirtyNodes = [];
    me.expandedNodes = [];
    me.collapsedNodes = [];
    me.timelineMarker = null;
    me.eventElement = null;
    const {
      actions,
      eventsEndDate,
      eventsStartDate,
      teamView,
      territoryView
    } = props;
    const activeView = getSettingValue(SET004, DEFAULT_TEAM) === DEFAULT_TEAM;
    me.state = {
      confirmModal: false,
      dayViewEventRecord: {},
      dayViewStartDate: {},
      dayViewEndDate: {},
      dayViewResourceRecord: {},
      editEventRecord: {},
      editEventResourceRecord: {},
      endDate: eventsEndDate,
      eventId: null,
      eventStartDate: null,
      eventsVersion: 1,
      header: getDisplayValue(TAG155),
      isCreateEvent: false,
      isDayView: false,
      isDeleteEvent: false,
      isEdit: false,
      isResizeEvent: false,
      isEditNonWOCreateEvent: false,
      isJDMDeleteEvent: false,
      isNonWOCreateEvent: false,
      isNonWoDragEvent: false,
      nonWOevenet: {},
      eventDragResourceRecord: {},
      resources: activeView ? teamView : territoryView,
      resourcesVersion: 1,
      resourceTimeRangesdata: [],
      searchActionDone: false,
      selectedIndex: activeView ? TEAM_INDEX : TERRITORY_INDEX,
      selectedEvent: null,
      schedulerSelectedTech: null,
      startDate: eventsStartDate,
      techId: null,
      viewState: 0,
      workOrderId: null,
      currentEventContext: {},
      filterEventInProgress: 0
    };
    actions.schedulerStateChanged(
      { activeView: activeView ? TEAM_INDEX : TERRITORY_INDEX },
      UPDATE_SCHEDULER_STATE
    );
    const showDelay = getUserSettingValue("tech_toolTipShowDelay");
    const hideDelay = getUserSettingValue("tech_toolTipHideDelay");
    const showTipOnClick = JSON.parse(
      getUserSettingValue("tech_dataTipOnClick", false)
    );
    const showWeekEnd = this.handleWeekEndVisible();
    this.featuresObj = {
      cellEdit: false,
      eventDragCreate: false,
      eventResize: {
        showTooltip: false
      },
      eventEdit: false,
      headerZoom: true,
      scheduleTooltip: false,
      eventDrag: {
        showTooltip: false
      },
      pan: true,
      scheduleContextMenu: {
        items: {
          addEvent: false
        }
      },
      contextMenu: {
        processCellItems: this.handleCreateContextMenu,
        processHeaderItems: () => false
      },
      eventContextMenu: {
        processItems: this.handleCreateEventContextMenu
      },
      // eventLayout: 'stack',
      eventTooltip: {
        /*hoverDelay: showTipOnClick ? 0 : showDelay,
        hideDelay,
        allowOver: true,
        focusOnToFront: true,
        trackMouse: true,
        autoClose: false,
        // align: 'l-r',
        template: data => this.getTooltip(data),
        listeners: {
          beforeShow: e => this.handelToolTipForEvents(e)
        }*/
      },
      group: false,
      nonWorkingTime: !showWeekEnd,
      resourceTimeRanges: true,
      sort: true,
      stripe: false,
      timeRanges: {
        enableResizing: true,
        highlightWeekends: true,
        showCurrentTimeLine: false,
        showHeaderElements: true
      },
      tree: true
    };
    this.loadedDateRange = {
      startDate: eventsStartDate,
      endDate: eventsEndDate
    };
    window.addEventListener(
      MAP_CUSTOM_EVENT_LOAD_EVENTS,
      this.handleEventsLoadAfterMap,
      false
    );
    this.scrollEventPromise = true;
    this.workOrderDragProgress = false;
  }

  /* lifecycle methods */
  componentDidMount() {
    const me = this;
    const { endDate, startDate } = me.state;
    const { actions, onSchedulerViewChildRef, userTimezone } = me.props;
    //window.addEventListener("click", me.handleScheduleClick);
    document.body.addEventListener("click", me.handleScheduleClick);
    const drag = new Drag({
      constrain: false,
      onDropSuccess: me.handleDropSuccess.bind(this),
      onDragStart: me.handleDragStart.bind(this),
      onDropFailure: me.handleDragFailure.bind(this),
      schedule: me.engine
    });
    this.updateTimeLineMarker(userTimezone.id);
    me.timelineMarker = setInterval(() => {
      const { userTimezone } = this.props;
      const { id } = userTimezone;
      this.updateTimeLineMarker(id);
    }, 60000);
    // Listener for scheduler actions
    me.engine.on({
      beforeEventEdit: () => false,
      expandNode: me.handleExpandNode,
      collapseNode: me.handleCollapseNode,
      // eventResizeEnd: me.handleEditResize,
      beforeEventResizeFinalize: me.handleEditResize,
      eventSelectionChange: me.eventSelectionChange,

      selectionchange: me.handleRowSelection,
      beforeeventdropfinalize: me.handleEditDrag,
      timeAxisHeaderClick: me.handleTimeAxisHeader,

      eventClick: me.handleEventClick,
      scheduleClick: me.handleScheduleClick,
      eventMouseOver: me.handleEventMouseOver,
      zoomChange: me.handleZoomChange,
      // eventMouseOut:me.handleEventMouseOut,
      presetChange: me.handlePresetChange
    });
    me.engine.subGrids.normal.scrollable.on({
      scrollend: me.handleScroll
    });
    me.engine.subGrids.normal.scrollable.element.onmousedown = me.onMouseEvents;
    me.engine.subGrids.normal.scrollable.element.addEventListener(
      "wheel",
      me.onMouseEvents
    );
    me.engine.scrollManager.scrollSpeed = 70;
    me.engine.features.eventTooltip.tooltip.on({
      innerHtmlUpdate: e => {
        const { source } = e;
        source.element.onclick = event =>
          this.handleEventContextToolTipItemClick(event, source);
      },
      once: true
    });
    me.engine.features.eventTooltip.tooltip.disabled = true;
    me.engine.headerContainer.onclick = me.handleHeaderClick;
    me.applyUserSettings();

    const mapAllowedBySetting =
      getSettingValue(DCON001_SET071).toLowerCase() === "true";
    const mapSettings = stringToBoolean(getUserSetting(MAP_CONFIG));
    if (!mapAllowedBySetting || !mapSettings) {
      actions.startEventCall(me.eventsLoaded);
      window.removeEventListener(
        MAP_CUSTOM_EVENT_LOAD_EVENTS,
        this.handleEventsLoadAfterMap,
        false
      );
    }
    onSchedulerViewChildRef(me);
    me.engine.zoomTo({ endDate, startDate });
    window.addEventListener(
      MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN,
      this.handleToggleFullscreen,
      false
    );
  }

  handlePresetChange = e => {
    const { source } = e;
    const { event } = source;
    const { onZoomComplete } = this.props;
    const { maxZoomLevel, minZoomLevel, zoomLevel } = this.engine;
    const timeSpan = this.engine.timeAxisSubGrid.grid.getVisibleDateRange();
    const { startDate, endDate } = timeSpan;
    onZoomComplete(
      zoomLevel,
      minZoomLevel,
      maxZoomLevel,
      startDate,
      endDate,
      event
    );
  };

  handleDragStart = e => {
    this.workOrderDragProgress = true;
  };

  handleDragFailure = () => {
    this.workOrderDragProgress = false;
  };

  onMouseEvents = e => {
    this.updateDate = true;
  };

  deleteDeltaReAssignedEvents = deleteEventArrIds => {
    const deletedRecords = flatMap(deleteEventArrIds, deleteId => {
      this.engine.store.eventsStore.remove(deleteId);
      return { id: deleteId };
    });
    pullAllBy(this.allEvents, deletedRecords, "id");
  };

  componentWillReceiveProps(nextProps) {
    const me = this;
    const {
      eventsEndDate,
      eventsStartDate,
      filterSchedulerEvents,
      multiAssignUpdate,
      newViewState,
      selectedWO,
      teamView,
      projectView,
      techWorkHours,
      territoryView,
      WOUnAssigned,
      gridActive,
      deltaEvents
    } = nextProps;
    const { removeUnAssignWO } = this.props;

    if (selectedWO) {
      if (gridActive) {
        me.seletedWorkOrder = selectedWO;
        const { Id } = selectedWO;
        me.handleEventHighlight([Id]);
      }
    }

    this.handleWOEventRowHighlight(selectedWO);

    if (techWorkHours && techWorkHours.length) {
      me.setState({
        resourceTimeRangesdata: techWorkHours
      });
    }

    // Allow Scheduler State updates for only Progress Actions & Configuration changes
    const { viewState } = me.state;
    if (newViewState !== viewState) {
      me.updateScheduler(
        newViewState,
        teamView,
        territoryView,
        multiAssignUpdate
      );
    }

    if (WOUnAssigned && Object.keys(WOUnAssigned).length) {
      const { eventIds, value, woInfo } = WOUnAssigned;
      me.removeEventsFromScheduler(eventIds, value, woInfo);
      removeUnAssignWO(null);
    }

    if (deltaEvents && !isEmpty(deltaEvents.events)) {
      const { createEventArr: events, deleteEventArrIds } = deltaEvents.events;
      const { actions } = this.props;
      let reAssignedEvents;
      if (deleteEventArrIds.length) {
        this.deleteDeltaReAssignedEvents(deleteEventArrIds);
      }
      if (events.length) {
        reAssignedEvents = compact(
          events.map(event => {
            if (me.engine.store.eventsStore.getById(event.id)) {
              return event.id;
            }
          })
        );
        if (reAssignedEvents.length) {
          this.deleteDeltaReAssignedEvents(reAssignedEvents);
        }
      }

      if (events.length) {
        me.eventsLoaded(events);
      }
      setTimeout(() => actions.deleteDeltaEvents(), 0);
    }

    if (filterSchedulerEvents) {
      const { clearFilterEvents } = me.props;
      const schedulerEvents = cloneDeep(filterSchedulerEvents);
      clearFilterEvents();
      me.showFilteredEvents(schedulerEvents, projectView);
    }

    // Fix for Handle Project View.
    const { startDate, endDate } = this.state;
    if (
      eventsStartDate.getTime() !== startDate.getTime() ||
      eventsEndDate.getTime() !== endDate.getTime()
    ) {
      this.zoomViewPort(eventsStartDate, eventsEndDate, false);
    }
  }

  componentDidUpdate() {}

  componentWillUnmount() {
    const { onSchedulerViewChildRef } = this.props;
    onSchedulerViewChildRef(undefined);
    clearInterval(this.timelineMarker);
  }

  handleWOEventRowHighlight = selecledWO => {
    const { Id } = selecledWO || {};
    // In case no workorder is selected, Don't do anything.
    if (!Id) return;

    const selectedClass = "b-selected";
    const higlightClass = "highlightRow";

    const technicianId = getFieldValue(
      selecledWO,
      WORKORDER_TECHNICIAN_API_NAME,
      null
    );

    // Clear previously selected technician
    setSchedulerSeletecdTech(null);
    this.setState({ schedulerSelectedTech: null });

    this.engine.resourceStore.forEach(resource => {
      const { Id: resourceId } = resource;
      const row = this.engine.getRowFor(resource);
      if (!row) return;

      const events = this.engine.eventStore.getEventsForResource(resourceId);
      const workOrderEvents = compact(flatMap(events, event => event.whatId));
      if (workOrderEvents.includes(Id)) {
        // Higlight TimeAxis Column
        const cell = row.getCell(this.engine.timeAxisColumn.id);
        const { classList } = cell;
        if (!classList.contains(higlightClass)) {
          classList.add(higlightClass);
        }
        // Higlight Grid Tree Column & Mark technician as selected.
        if (technicianId === resourceId) {
          row.addCls(higlightClass);
          this.handleRowSelection({ selected: [resource] });
        }
      } else {
        // Remove Grid & TimeAxis Highlight.
        row.removeCls(higlightClass);
        row.removeCls(selectedClass);
      }
    });
  };

  handleToggleFullscreen = () => {};

  handelToolTipForEvents = e => {
    const { source: tip } = e;
    const showTipOnClick = JSON.parse(
      getUserSettingValue("tech_dataTipOnClick"),
      false
    );
    const showTooltip = showTipOnClick ? this.showHoverOnClick || false : true;
    if (showTooltip && tip.height > this.engine.height) {
      tip.height = "auto";
    }
    return showTooltip;
  };

  handleEventClicktest = e => {
    eventClicks++;
    const me = this;
    const showTipOnClick = JSON.parse(
      getUserSettingValue("tech_dataTipOnClick", false)
    );
    if (eventClicks === 1) {
      setTimeout(() => {
        if (eventClicks > 1) {
          me.editEventCall(e);
        } else if (showTipOnClick) {
          me.showEventToolTip(e.eventElement);
        }
        eventClicks = 0;
      }, 400);
    }
  };

  handleEventClick = e => {
    //const showTooltip = showTipOnClick ? this.showHoverOnClick || false : true;
    //if (showTooltip && tip.height > this.engine.height) {
    // tip.height = "auto";
    //}
    eventClicks++;
    const me = this;
    const showTipOnClick = JSON.parse(
      getUserSettingValue("tech_dataTipOnClick", false)
    );
    if (eventClicks === 1) {
      setTimeout(() => {
        if (eventClicks > 1) {
          me.handleScheduleClick(e);
          me.editEventCall(e);
        } else if (showTipOnClick) {
          const tooltip = this.engine.features.eventTooltip.tooltip;
          tooltip.activeTarget = e.eventElement;
          tooltip.allowOver = true;
          tooltip.focusOnToFront = true;
          tooltip.trackMouse = true;
          tooltip.autoClose = false;
          tooltip.hideDelay = 600000;
          tooltip.html = this.getTooltip(e);
          this.eventElement = e;
          tooltip.showBy(e.eventElement);
        }
        eventClicks = 0;
      }, 400);
    }
  };

  showEventToolTip = eventElement => {
    this.showHoverOnClick = true;
    const tooltip = this.engine.features.eventTooltip.tooltip;
    tooltip.activeTarget = eventElement;
    tooltip.showBy(eventElement);
  };

  handleEventMouseOver = e => {
    /*const showTipOnClick = JSON.parse(
      getUserSettingValue("tech_dataTipOnClick", false)
    );
    if (!eventElement.classList.contains("b-active")) {
      if (showTipOnClick) {
        const tooltip = this.engine.features.eventTooltip.tooltip;
        //tooltip.hide();
        this.showHoverOnClick = false;
      }
    }*/
    const showTipOnClick = JSON.parse(
      getUserSettingValue("tech_dataTipOnClick", false)
    );
    if (!showTipOnClick) {
      const showDelay = getUserSettingValue("tech_toolTipShowDelay");
      const hideDelay = getUserSettingValue("tech_toolTipHideDelay");
      const tooltip = this.engine.features.eventTooltip.tooltip;
      tooltip.activeTarget = e.eventElement;
      tooltip.allowOver = true;
      tooltip.focusOnToFront = true;
      tooltip.trackMouse = true;
      tooltip.autoClose = false;
      tooltip.showDelay = showDelay;
      tooltip.hideDelay = hideDelay;
      tooltip.html = this.getTooltip(e);
      this.eventElement = e;
      tooltip.showBy(e.eventElement);
    }
  };

  handleScheduleClick = e => {
    const tooltip = this.engine.features.eventTooltip.tooltip;
    if (
      (e.srcElement &&
        e.srcElement.id &&
        e.srcElement.id === "eventTooltipWindow") ||
      (e.target &&
        e.target.offsetParent &&
        e.target.offsetParent.id &&
        e.target.offsetParent.id === "b-scheduler-4-event-tip")
    ) {
      //if(e.toElement&&e.toElement.innerHTML&&e.toElement.innerHTML.includes("eventTooltipWindow")){
      //tooltip.hide();
    } else {
      tooltip.hide();
    }
  };

  handleEventMouseOut = () => {
    const showTipOnClick = JSON.parse(
      getUserSettingValue("tech_dataTipOnClick", false)
    );
    if (!showTipOnClick) {
      const tooltip = this.engine.features.eventTooltip.tooltip;
      tooltip.hide();
    }
  };

  handleEventsLoadAfterMap = () => {
    const { actions } = this.props;
    actions.startEventCall(this.eventsLoaded);
    window.removeEventListener(
      MAP_CUSTOM_EVENT_LOAD_EVENTS,
      this.handleEventsLoadAfterMap,
      false
    );
  };

  handleTimeAxisHeader = e => {
    if (e) {
      e.source.trigger("timeAxisHeaderDblClick", e);
      const { actions, updateDateRange } = this.props;
      const { startDate, endDate } = e;
      updateDateRange(startDate, endDate);
      setShowRouteDataMapDone(false);
    }
  };

  handleWeekEndVisible = () => {
    const techWorkingHours = getSettingValue(SET072);
    const showWeekend = stringToBoolean(techWorkingHours);
    return showWeekend;
  };

  handleRowSelection = e => {
    const { selected } = e;
    if (selected.length) {
      const [technician] = selected;
      const { isTech, resourceId } = technician;
      if (resourceId) {
        const selectedTechObj = {};
        const { data } = technician;
        selectedTechObj.isTech = isTech;
        selectedTechObj.resourceId = resourceId;
        selectedTechObj.isScheduleEnable = isSchedulingEnabled(data);
        setSchedulerSeletecdTech(selectedTechObj);
      }
    }
  };

  handleEventHighlight = woIds => {
    if (woIds && woIds.length) {
      this.engine.eventStore.forEach(eventRecord =>
        this.handleBorderColorForEvent(eventRecord, woIds)
      );
    }
  };

  handleBorderColorForEvent = (eventRecord = {}, woIds = []) => {
    delete eventRecord.style;
    const { isWorkOrder, whatId } = eventRecord;
    eventRecord.isHightLight = isWorkOrder && woIds.includes(whatId);
  };

  /*
   * In case of recursive actions, re-hash and return the correct view state.
   */
  convertToActualViewState = newViewState => {
    let newStateValue = newViewState;
    const sign = Math.sign(newViewState);
    if (sign < 0) {
      if (newViewState < -100) {
        newStateValue = newViewState + 100;
      }
    } else if (newViewState > 100) {
      newStateValue = newViewState - 100;
    }
    return newStateValue;
  };

  /* Identify if the viewState deals with resource change which effects scheduler tree structure */
  isResourceChanged = newViewState =>
    ![MULTI_ASSIGN_EVENT_UPDATE].includes(newViewState);

  updateScheduler = (viewState, teamView, territoryView, multiAssignUpdate) => {
    const { selectedIndex } = this.state;
    const resources = selectedIndex === TEAM_INDEX ? teamView : territoryView;
    this.updateEvents(viewState, resources, multiAssignUpdate);
    if (viewState === TEAM_SEARCH_RESULT) {
      if (selectedIndex !== TEAM_INDEX) {
        this.plotOnMap(viewState, teamView);
      }
    }
    this.plotOnMap(viewState, resources);
  };

  changeToTeamView = () => {
    this.handleViewchange(TEAM_INDEX);
    document.getElementById("techViewChange").selectedIndex = "0";
    this.handleTreeChange(COLLAPSE_ALL);
  };

  updateEvents = (newViewState, resources, multiAssignEvents) => {
    const { selectedIndex } = this.state;
    const switchType = this.convertToActualViewState(newViewState);
    switch (switchType) {
      case FILTER_TECHNICIAN_RESULT:
        this.highlightWorkOrderEvents(resources);
        setTimeout(() => this.disableImageArrowFunction(), 0);
        break;
      case FILTER_EVENTS_RESULT:
        setTimeout(() => this.disableImageArrowFunction(), 1000);
        break;
      case MULTI_ASSIGN_EVENT_UPDATE:
        this.updateEventOnComplete(multiAssignEvents);
        break;
      case TECHNICIAN_COLUMN_ADDED:
        this.addRemoveColumns();
        break;
      case TEAM_SEARCH_RESULT:
        if (selectedIndex !== TEAM_INDEX) {
          setTimeout(() => this.changeToTeamView(), 0);
        }
        break;
      case DEFAULT_TREE_DATA:
        this.resetSchedulerView();
        this.applyUserSettings();
        setTimeout(() => this.disableImageArrowFunctionReset(), 0);
        break;
      case TEAM_SEQUENCE_CHANGED:
      case TERRITORY_SEQUENCE_CHANGED:
        break;
      default:
        break;
    }

    const newState = {
      viewState: newViewState
    };

    if (this.isResourceChanged(switchType)) {
      const { resourcesVersion: rVersion } = this.state;
      newState.resources = resources;
      newState.resourcesVersion = rVersion + 1;
    }
    this.setState(newState);
  };

  /*
   * Highlight all the workorder events
   */
  highlightWorkOrderEvents = () => {
    const { woInfo = [] } = this.props;
    if (woInfo && woInfo.length) {
      this.handleEventHighlight(flatMap(woInfo, workOrder => workOrder.Id));
    }
  };

  /*
   * Remove all the columns and add again based on the new order.
   */
  addRemoveColumns = () => {
    const me = this;
    let count = this.engine.columns.getCount() - 1;
    // we made totalcount-1; last column is time Axis. we need to exclude the time axis on remove the column
    while (count > 1) {
      this.engine.columns.getAt(count - 1).remove();
      count -= 1;
    }
    const configuredColumns = getUserSetting(TECH_COL);
    const columns = getTechnicianColumn(configuredColumns);
    columns.map((column, index) => {
      me.engine.columns.insert(index + 1, column);
    });
  };

  updateEventOnComplete = (eventObject = {}) => {
    const me = this;
    const { deletedEventIds = [], lstEvent = [] } = eventObject;
    if (deletedEventIds.length) {
      this.deleteDeltaReAssignedEvents(deletedEventIds);
    }
    // Add all the newly added/edit event Ids also to deleted list to update the scheduler.
    deletedEventIds.unshift(flatMap(lstEvent, event => event.id));
    // Delete deleted events from event store.
    deletedEventIds.map(eventId => me.engine.store.eventsStore.remove(eventId));
    // Add newly created events to event store.
    me.eventsLoaded(lstEvent);

    // Re-Filter events if there is change in events
    // const { viewState } = this.state;
    // if (FILTER_EVENTS_RESULT === me.convertToActualViewState(viewState)) {
    //   me.filterEvents();
    // }
  };

  zoomToFit = () => {
    const {
      actions,
      updateStartDate,
      eventsStartDate,
      eventsEndDate,
      updateDateRange,
      woInfo = []
    } = this.props;
    const span = this.engine.eventStore.getTotalTimeSpan();
    const { endDate, startDate } = span;
    const eventsStartDateObj = moment(eventsStartDate).toDate();
    const eventsEndDateObj = moment(eventsEndDate).toDate();

    if (startDate !== null && endDate !== null) {
      if (
        eventsStartDateObj.getTime() != startDate.getTime() ||
        eventsEndDateObj.getTime() !== endDate.getTime()
      ) {
        this.setState({
          startDate: eventsStartDateObj,
          endDate: eventsEndDateObj
        });
      }
      scrollEventTo = {};
      const { viewState } = this.state;
      if (viewState === FILTER_EVENTS_RESULT) {
        setTimeout(() => updateDateRange(startDate, endDate), 0);
      } else {
        const windowEvents = this.engine.eventStore.getEventsInTimeSpan(
          startDate,
          endDate,
          true
        );

        if (windowEvents.length) {
          let evtEndDateTime = null;
          let evtStDateTime = null;
          const filteredWOIds = flatMap(woInfo, record => record.Id);
          windowEvents.forEach(event => {
            const { isWorkOrder, whatId, startDateTime, endDateTime } = event;
            if (isWorkOrder && filteredWOIds.includes(whatId)) {
              const stDateObj = moment(startDateTime, DATE_TIME_FORMAT);
              const endDateObj = moment(endDateTime, DATE_TIME_FORMAT);
              if (!evtStDateTime || evtStDateTime.isAfter(stDateObj)) {
                evtStDateTime = moment(startDateTime, DATE_TIME_FORMAT);
              }
              if (!evtEndDateTime || evtEndDateTime.isBefore(endDateObj)) {
                evtEndDateTime = moment(endDateTime, DATE_TIME_FORMAT);
              }
            }
          });
          if (evtEndDateTime !== null && evtStDateTime !== null) {
            setTimeout(
              () =>
                updateDateRange(
                  evtStDateTime.toDate(),
                  evtEndDateTime.toDate()
                ),
              0
            );
            // this.zoomViewPort(evtStDateTime.toDate(), evtEndDateTime.toDate(), true);
          }
        }
      }
    }
  };

  zoomViewPort = (eventsStartDate, eventsEndDate, forceLoad) => {
    const visibleDateRange = this.engine.getVisibleDateRange();
    const { startDate, endDate } = visibleDateRange;
    if (
      eventsEndDate.getTime() !== endDate.getTime() ||
      eventsStartDate.getTime() !== startDate.getTime() ||
      forceLoad
    ) {
      this.engine.zoomTo({
        endDate: new Date(eventsEndDate),
        startDate: new Date(eventsStartDate)
      });
      this.setState({ endDate: eventsEndDate, startDate: eventsStartDate });
    }
  };

  plotOnMap = (newViewState, resources) => {
    try {
      const plotMap = JSON.parse(getUserSetting(MAP_CONFIG, false));
      if (plotMap) {
        let technicians = [];
        const { selectedWO } = this.props;
        const switchType = this.convertToActualViewState(newViewState);
        switch (switchType) {
          case TECH_SEARCH_RESULT:
            technicians = this.flatternSerachResults(resources, true);
            if (selectedWO) {
              drawSearchedTechnicians(
                technicians,
                getWorkOrderConfigMap(selectedWO)
              );
            } else {
              drawSearchedTechnicians(technicians);
            }
            break;
          case TEAM_SEARCH_RESULT:
            technicians = this.flatternSerachResults(resources, false);
            if (selectedWO) {
              drawSearchedTeams(technicians, getWorkOrderConfigMap(selectedWO));
            } else {
              drawSearchedTeams(technicians);
            }
            break;
          case ADV_SEARCH_RESULT:
            technicians = this.flatternSerachResults(resources, true);
            drawSearchedTechnicians(
              technicians,
              getWorkOrderConfigMap(selectedWO)
            );
            break;
          case INITIAL_TREE_DATA:
            break;
          default:
            break;
        }
      }
    } catch (e) {
      const { name: errorCode, stack: message } = e;
      console.log(`${errorCode} :::: ${message}`);
    }
  };

  flatternSerachResults = (results, leafOnly) => {
    let resultNodes = [];
    results.map(result => {
      if (result) {
        if (leafOnly) {
          const { children } = result;
          resultNodes = concat(resultNodes, children);
        } else {
          resultNodes.push(result);
        }
      }
      return undefined;
    });
    return resultNodes;
  };

  eventSelectionChange = events => {
    const { action } = events;
    const { handleSelectedEvents } = this.props;
    this.setState({ selectedEvent: events });
    handleSelectedEvents(action);
  };

  handleEditResize = e => {
    const { context } = e;
    context.async = true;
    const { eventRecord, resourceRecord } = context;
    const { data: technician } = resourceRecord;

    if (!isSchedulingEnabled(technician)) {
      this.setState({
        confirmModal: {
          message: TAG199,
          options: [{ ok: TAG069 }]
        }
      });
      context.finalize(false);
      return;
    }
    eventRecord.resizeStartDate = context.startDate;
    eventRecord.resizeEndDate = context.endDate;
    if (eventRecord.isWorkOrder) {
      this.setState({
        editEventRecord: eventRecord,
        isEdit: true,
        editEventResourceRecord: resourceRecord,
        isResizeEvent: true,
        currentEventContext: context
      });
    } else {
      this.setState({
        nonWOevenet: eventRecord,
        eventDragResourceRecord: resourceRecord,
        isNonWoDragEvent: true,
        currentEventContext: context
      });
    }
  };

  handleEditDrag = e => {
    const { context } = e;
    context.async = true;
    const { record: eventRecord, newResource: resourceRecord } = context;
    const { data: technician } = resourceRecord;

    if (!isSchedulingEnabled(technician)) {
      this.setState({
        confirmModal: {
          message: TAG199,
          options: [{ ok: TAG069 }]
        }
      });
      context.finalize(false);
      context.finalize(false);
      return;
    }
    if (resourceRecord.isTech) {
      if (isSchedulingEnabled(technician)) {
        eventRecord.resizeStartDate = context.startDate;
        eventRecord.resizeEndDate = context.endDate;
        if (eventRecord.isWorkOrder) {
          this.setState({
            editEventRecord: eventRecord,
            isEdit: true,
            editEventResourceRecord: resourceRecord,
            isResizeEvent: true,
            currentEventContext: context
          });
        } else {
          this.setState({
            nonWOevenet: eventRecord,
            eventDragResourceRecord: resourceRecord,
            isNonWoDragEvent: true,
            currentEventContext: context
          });
        }
      } else {
        this.setState({
          confirmModal: {
            message: TAG199,
            options: [{ ok: TAG069 }]
          }
        });
        context.finalize(false);
      }
    } else {
      this.setState({
        confirmModal: {
          message: TAG502,
          options: [{ ok: TAG069 }]
        }
      });
      context.finalize(false);
    }
  };

  handleAssignConfirmation = value => {
    const { actions } = this.props;
    const { assignToTreePayload: payload, alreadyAssigned } = this.state;
    const { createEventForTreeCall } = actions;
    if (value === "yes") {
      if (alreadyAssigned) {
        payload.unassignWorkorder = true;
      }
      createEventForTreeCall(() => {}, payload);
    } else if (value === "no") {
      if (alreadyAssigned) {
        createEventForTreeCall(() => {}, payload);
      }
    }
    this.setState({ isAssignToTree: false });
  };

  handleDropSuccess = (eventData, header, isCreateEvent = true) => {
    this.workOrderDragProgress = false;
    const { resource } = eventData;
    const { data } = resource;
    const { actions, selectGridRow } = this.props;
    const { selectedIndex } = this.state;
    const { createSchedulingError } = actions;
    const schedulingAllowed = isSchedulingEnabled(data);
    if (data.isTech && !schedulingAllowed) {
      this.setState({
        confirmModal: {
          message: TAG199,
          options: [{ ok: TAG069 }]
        }
      });
      return;
    }
    if (!eventData.isTreeDrop && schedulingAllowed) {
      this.setState({
        eventData,
        header,
        isCreateEvent,
        isResizeEvent: false
      });
    } else if (eventData.isTreeDrop) {
      const payload = {};
      const SET036 = getSettingValue(DCON001_SET036);
      if (SET036 === "Allow" || SET036 === "Warn") {
        let contentMsg = null;
        let isAssignToTree = false;
        let alreadyAssigned = false;
        const woInfo = getWorkOrderFromNumber(eventData.wo);
        const dispatchStatus = woInfo[WO_DISPATCH_STATUS_FIELD];
        const { Id } = woInfo;

        payload.WorkOrderIds = [Id];
        payload.TeamId = data.Id;
        payload.dispatchStatus = dispatchStatus;
        payload.unassignWorkorder = false;

        if (dispatchStatus !== "New") {
          contentMsg = getDisplayValue("TAG200");
          isAssignToTree = true;
          alreadyAssigned = true;
        }

        if (SET036 === "Warn" && dispatchStatus === "New") {
          contentMsg = `${getDisplayValue("TAG120")} ${data.Name} ?`;
          isAssignToTree = true;
        }

        if (SET036 === "Allow" && dispatchStatus === "New") {
          isAssignToTree = false;
        }

        if (data.isTech) {
          payload.SetOwner = JSON.parse(
            getSettingValue(DCON001_SET009, FALSE).toLowerCase()
          );
          payload.isTech = true;
          this.setState({
            assignToTreePayload: payload,
            isAssignToTree,
            contentMsg,
            alreadyAssigned
          });
          if (SET036 === "Allow" && dispatchStatus === "New") {
            this.handleAssignConfirmation("yes");
          }
        } else if (selectedIndex === TEAM_INDEX) {
          payload.SetOwner = true;
          payload.isTech = false;
          this.setState({
            assignToTreePayload: payload,
            isAssignToTree,
            contentMsg,
            alreadyAssigned
          });
          if (SET036 === "Allow" && dispatchStatus === "New") {
            this.handleAssignConfirmation("yes");
          }
        } else if (createSchedulingError) {
          createSchedulingError(getDisplayValue("TAG180"));
        }
      } else if (SET036 === "Disallow") {
        this.setState({
          contentMsg: getDisplayValue("TAG239"),
          isAssignToTree: true
        });
      }
    } else {
      this.setState({
        confirmModal: {
          message: data.isTech ? TAG199 : TAG502,
          options: [{ ok: TAG069 }]
        }
      });
    }
    const { wo } = eventData;
    const selectedWO = getWorkOrderFromNumber(wo);
    if (selectGridRow && selectedWO) {
      selectGridRow(selectedWO);
    }
  };

  /* scheduler actions */
  handleViewchange = activeView => {
    const { actions, teamView, territoryView } = this.props;
    const { resourcesVersion } = this.state;
    const resourcesVer = resourcesVersion + 1;
    this.setState({
      resources: activeView === TEAM_INDEX ? teamView : territoryView,
      resourcesVersion: resourcesVer,
      selectedIndex: activeView
    });
    this.expandedNodes = [];
    this.collapsedNodes = [];
    this.dirtyNodes = [];

    const defaultSettings = getSettingValue(SET0235);
    if (defaultSettings === COLLAPSE_ALL) {
      this.handleTreeChange(COLLAPSE_ALL);
    } else if (defaultSettings === EXPAND_ALL) {
      this.handleTreeChange(EXPAND_ALL);
    } else if (activeView === TEAM_INDEX) {
      const expandedTeams = getUserSettingValue(EXPANDED_TEAM, []);
      if (expandedTeams && expandedTeams.length) {
        this.handleExpandItem(expandedTeams);
      }
    } else {
      const expandedTerritory = getUserSettingValue(EXPANDED_TERRITORY, []);
      if (expandedTerritory && expandedTerritory.length) {
        this.handleExpandItem(expandedTerritory);
      }
    }
    actions.schedulerStateChanged({ activeView }, UPDATE_SCHEDULER_STATE);
  };

  handleViewZoomIn = event => {
    const { actions } = this.props;
    actions.statusBarClearTxt();
    this.engine.zoomIn();
  };

  handleViewZoomOut = event => {
    const { actions } = this.props;
    actions.statusBarClearTxt();
    this.engine.zoomOut();
  };

  handleZoomChange = () => {};

  handleVisibleDateRange = () => {
    const visibleDateRange = this.engine.timeAxisSubGrid.grid.getVisibleDateRange();
    const { actions, updateDateRange } = this.props;
    const { startDate, endDate } = visibleDateRange;
    updateDateRange(startDate, endDate);
    setShowRouteDataMapDone(false);
    // const eventsStartDate = startDate;
    // const eventsEndDate = endDate;

    // actions.schedulerStateChanged(
    //   {
    //     eventsEndDate: formatDateTime(eventsEndDate),
    //     eventsStartDate: formatDateTime(eventsStartDate)
    //   },
    //   UPDATE_SCHEDULER_STATE
    // );
  };

  updateTimeLineMarker = timeZone => {
    const me = this;
    const currentTime = moment()
      .tz(timeZone)
      .format("YYYY-MM-DD HH:mm:ss");
    const startDate = moment(currentTime).toDate();
    me.engine.features.timeRanges.store.remove("currentTime");
    me.engine.features.timeRanges.showTooltip = false;
    me.engine.features.timeRanges.store.add({
      id: "currentTime",
      startDate
    });
  };

  handleExpandNode = e => {
    const me = this;
    const { selectedIndex } = this.state;
    let techList = [];
    const { actions } = me.props;
    const { record } = e;
    const { data } = record;
    const { id } = data;

    if (selectedIndex === TEAM_INDEX) {
      setExpandedTeam(id, data);
      if (!isTeamEventsLoaded) {
        techList = getExpandedTeamTechList();
      }
    } else {
      setExpndedTerritory(id, data);
      if (!isTerritoryEventsLoaded) {
        techList = getExpandedTerritoryTechList();
      }
    }

    // Clear Older text messages on first node expand.
    // if (!this.expandedNodes.length) {
    //   setTimeout(() => actions.statusBarClearTxt(), 0);
    // }
    if (techList && techList.length) {
      actions.startEventCall(me.eventsLoaded, techList);
    }
    this.updateExpand(id);
    this.handleTreeChange();
  };

  handleCollapseNode = e => {
    const { selectedIndex } = this.state;
    const { record } = e;
    const { data } = record;
    const { id } = data;

    if (selectedIndex === TEAM_INDEX) {
      setCollapsedTeam(id, data);
    } else {
      setCollapsedTerritory(id, data);
    }
    this.updateCollapse(id);
    this.handleTreeChange();
  };

  updateExpand = id => {
    const { selectedIndex } = this.state;
    const { teamView, territoryView } = this.props;
    const resources = selectedIndex === TEAM_INDEX ? teamView : territoryView;
    const selected = resources.filter(item => item.Id === id);
    if (selected && selected.length) {
      selected[0].expanded = true;
    }
    // On Expand complete, Remove the tree node from the processable Nodes
    pull(this.dirtyNodes, id);
    // Add the expanded tree node to the expanded node list
    if (!this.expandedNodes.includes(id)) {
      this.expandedNodes.push(id);
      pull(this.collapsedNodes, id);
    }
  };

  updateCollapse = id => {
    const { selectedIndex } = this.state;
    const { teamView, territoryView } = this.props;
    const resources = selectedIndex === TEAM_INDEX ? teamView : territoryView;
    const selected = resources.filter(item => item.Id === id);
    if (selected && selected.length) {
      selected[0].expanded = false;
    }
    // On Collapse, Remove the tree node from the processable Nodes.
    pull(this.dirtyNodes, id);
    // Also remove the collapsed node from expanded node list
    if (this.expandedNodes.includes(id)) {
      this.collapsedNodes.push(id);
      pull(this.expandedNodes, id);
    }
  };

  eventsLoaded = (events = []) => {
    const me = this;
    const { isDayEventEdit, viewState } = this.state;
    const newEvents = isEqual(me.allEvents, events) ? [...events] : events;
    // Remove existing events and re-add them with new one's.
    pullAllBy(me.allEvents, newEvents, "id");
    me.allEvents = me.allEvents.concat(newEvents);
    if (isDayEventEdit) {
      this.setState({ isDayEventEdit: false });
    }
    setTimeout(() => this.handleDayEventEdit(newEvents), 0);
    if (
      viewState === FILTER_EVENTS_RESULT ||
      viewState === FILTER_TECHNICIAN_RESULT
    ) {
      setTimeout(() => this.disableImageArrowFunction(), 0);
    }
  };

  handleDayEventEdit = newEvents => {
    const { editedEventId, viewState } = this.state;
    this.engine.store.eventsStore.add(newEvents);
    if (editedEventId) {
      this.getEditedEventRecord(editedEventId);
    }
    // Highlight workorder event(s) if scheduler is displaying filtered technicians.
    if (viewState % 100 === FILTER_TECHNICIAN_RESULT) {
      this.highlightWorkOrderEvents();
    }
  };

  handleTechConfigEventColor = (events, workOrderInfo, obj) => {
    this.engine.eventStore.forEach(eventRecord => {
      eventRecord.eventColor = convertUint2Hex(
        applyEventColorRule(workOrderInfo, eventRecord, obj)
      );
      if (eventRecord.isOverNightStay) {
        eventRecord.eventColor = convertUint2Hex(obj.overNightStayColor);
      }

      if (eventRecord.isWorkOrder) {
        if (eventRecord.agenda) {
          if (eventRecord.agenda.length) {
            eventRecord.agenda.map(nesteditem => {
              if (nesteditem.isDriveStartTime || nesteditem.isDriveEndTime) {
                nesteditem.eventColor = convertUint2Hex(
                  obj.driveTimeEventColor
                );
              }
              if (
                nesteditem.isOverHeadStartTime ||
                nesteditem.isOverHeadEndTime
              ) {
                nesteditem.eventColor = convertUint2Hex(obj.overHeadEventColor);
              }
              if (nesteditem.isActualEvent) {
                nesteditem.eventColor = eventRecord.eventColor;
              }
            });
          }
        }
      }
    });
  };

  handleTechnicianWorkColor = (workingHoursColor, HolidayHoursColor) => {
    this.handleFeaturesObj();
    this.engine.resourceTimeRangeStore.forEach(timeRangeRecord => {
      if (timeRangeRecord.isWorkingHours) {
        timeRangeRecord.style = `background:${workingHoursColor};
          border: 1px solid white;
          background-repeat: no-repeat;
          background-size: contain;`;
      }
      if (timeRangeRecord.isHolidayHours) {
        timeRangeRecord.style = `background:${HolidayHoursColor};
          border: 1px solid white;
          background-repeat: no-repeat;
          background-size: contain;`;
      }
    });
  };

  handleFeaturesObj = () => {
    const showDelay = getUserSettingValue("tech_toolTipShowDelay");
    const hideDelay = getUserSettingValue("tech_toolTipHideDelay");
    const showTipOnClick = JSON.parse(
      getUserSettingValue("tech_dataTipOnClick", false)
    );

    //this.featuresObj.eventTooltip.hoverDelay = showTipOnClick ? 0 : showDelay;
    //this.featuresObj.eventTooltip.hideDelay = hideDelay;
  };

  reloadEvents = ({ timeZone, isEventRefresh }) => {
    const me = this;
    const { actions, eventsStartDate, eventsEndDate } = me.props;
    if (timeZone) {
      actions.schedulerStateChanged({ timeZone }, UPDATE_SCHEDULER_STATE);
    }
    me.allEvents = [];
    me.engine.store.eventsStore.clear();
    actions.startEventCall(me.eventsLoaded, "", isEventRefresh);
    me.loadedDateRange = {
      startDate: eventsStartDate,
      endDate: eventsEndDate
    };
    this.zoomViewPort(eventsStartDate, eventsEndDate);
  };

  filterEvents = () => {
    const me = this;
    const { startFilterWOEvents } = this.props;
    if (startFilterWOEvents) {
      startFilterWOEvents(this.showFilteredEvents);
    }
  };

  showFilteredEvents = (events, complete) => {
    const me = this;
    me.filteredEvents = [];
    me.filteredEvents = me.filteredEvents.concat(events);
    // Clear all the previous events from the store.
    me.engine.store.eventsStore.clear();
    // Add only workorder filtered events
    me.eventsLoaded(events);
    // Filter events that are only related to passed workOrder List
    if (complete) {
      setTimeout(this.zoomToFit, 0);
    }
    // }
  };

  showProjectView = () => {
    if (this.engine.store.eventsStore.records.length) {
      const startDate = new Date(this.engine.store.eventsStore.first.startDate);
      const endDate = new Date(this.engine.store.eventsStore.first.endDate);
      this.engine.store.eventsStore.zoomTo({ startDate, endDate });
    }
  };

  removeEventsFromScheduler = (eventIds, unAssign = false, woInfo) => {
    const me = this;
    const { eventId, eventStartDate, viewState } = this.state;
    const {
      actions,
      deleteEvents,
      userTimezone,
      underScheduledEvent,
      handleSelectedEvents,
      viewSelectionChanged
    } = this.props;

    let scheduledDuration = 0;
    if (eventIds) {
      const deleteIds =
        Array.isArray(eventIds) && eventIds.length
          ? eventIds
          : eventId
          ? [eventId]
          : [];

      // On selected event deletion, disable SchedulerToolbar Delete Button.
      if (deleteIds.includes(eventId) && handleSelectedEvents) {
        handleSelectedEvents(null);
      }
      const deletedRecords = flatMap(deleteIds, deleteId => {
        const record = this.engine.store.eventsStore.getById(deleteId);
        if (record) {
          const { durationInMinutes } = record;
          scheduledDuration += Number(durationInMinutes);
        }
        this.engine.store.eventsStore.remove(deleteId);
        return { id: deleteId };
      });
      pullAllBy(me.allEvents, deletedRecords, "id");
    }

    // setTimeout(() => me.engine.store.eventsStore.refreshData(), 0);
    if (woInfo && scheduledDuration === woInfo[WO_UNSCHEDULED_DURATIONS]) {
      unScheduledDurationService.setWOInfo(woInfo);
      underScheduledEvent(true);
    } else if (woInfo) {
      const isSET056 = JSON.parse(getSettingValue(SET056, FALSE).toLowerCase());
      const isSET010 = JSON.parse(getSettingValue(SET010, FALSE).toLowerCase());

      if (isSET056) {
        viewSelectionChanged(undefined, true);
      } else if (unAssign && isSET010) {
        viewSelectionChanged(undefined, true);
      }
    }

    if (unAssign) {
      // Change unAssign to false in store once after WO is unassigned
      const { id, name } = userTimezone;
      const currentTime = toTime(id || name);
      const isFutureEvent = moment(eventStartDate).isAfter(currentTime);
      const isDeletePastEvent = getSettingValue(SET024) === "True";

      if (!isFutureEvent && !!isDeletePastEvent && eventId) {
        deleteEvents({ eventIds: [eventId] }, this.removeEventsFromScheduler);
      }
    } else {
      me.engine.store.eventsStore.remove(eventId);
      pullAllBy(me.allEvents, { id: eventId }, "id");
      // me.engine.store.eventsStore.refreshData();
    }

    const { eventsRefreshed, filterTechnicians } = actions;
    // Notify App Status Bar of Events Refreshed.
    // setTimeout(() => eventsRefreshed(), 0);

    // Apply workorder filter, post delete event.
    const actualViewState = me.convertToActualViewState(viewState);
    if (FILTER_TECHNICIAN_RESULT === actualViewState) {
      if (filterTechnicians) {
        filterTechnicians();
      }
    } else if (FILTER_EVENTS_RESULT === actualViewState) {
      me.filterEvents();
    }
  };

  applyUserSettings = () => {
    const defaultSettings = getSettingValue(SET0235);
    if (defaultSettings === COLLAPSE_ALL) {
      setTimeout(() => this.handleTreeChange(COLLAPSE_ALL), 0);
    } else if (defaultSettings === EXPAND_ALL) {
      setTimeout(() => this.handleTreeChange(EXPAND_ALL), 0);
    } else {
      const { selectedIndex } = this.state;
      let expandNodes = getUserSettingValue(EXPANDED_TERRITORY, []);
      if (selectedIndex === TEAM_INDEX) {
        expandNodes = getUserSettingValue(EXPANDED_TEAM, []);
      }
      // Expand tree nodes only if list is non empty.
      if (expandNodes && expandNodes.length) {
        setTimeout(() => this.handleExpandItem(expandNodes), 0);
      }
    }
  };

  handleSearchTechnician = (sServiceviewData, sTerritoryviewData) => {
    // const defaultSettings = getSettingValue(SET004, DEFAULT_TEAM);
    const { onSearchTechEmpty } = this.props;
    const { resourcesVersion, selectedIndex, searchActionDone } = this.state;
    const resourcesVer = resourcesVersion + 1;
    const index = selectedIndex;
    const searchFor = getSelectedSearch();

    if (sServiceviewData && searchActionDone) {
      setSearchTechDone(true);
      this.setState({
        resources: index === TEAM_INDEX ? sServiceviewData : sTerritoryviewData,
        resourcesVersion: resourcesVer,
        searchActionDone: false
      });
      const mapSettings = stringToBoolean(getUserSetting(MAP_CONFIG));
      if (mapSettings) {
        if (sServiceviewData.length) {
          let wo = {};
          if (this.seletedWorkOrder) {
            wo = getWorkOrderConfigMap(this.seletedWorkOrder);
          }
          if (searchFor === TECH_KEYWORD) {
            const techList = [];
            sServiceviewData.map(item => {
              const { children } = item;
              children.map(techItem => {
                techList.push(techItem);
                return undefined;
              });
              return undefined;
            });
            radiusModeNoLimitHandler();
            drawSearchedTechnicians(techList, wo);
          } else {
            const teamList = [];
            sServiceviewData.map(item => {
              teamList.push(item);
              return undefined;
            });
            drawSearchedTeams(teamList, wo);
          }
        }
      }
    }
  };

  handleSearchChange = () => {
    // clearSearchTechMarkers();
    // clearRadiusModeCircle();
    // clearSearchTeamMarkers();
  };

  handleResetTime = () => {
    const me = this;
    const { startDate, endDate } = this.loadedDateRange;
    const { schedulerEndDate, schedulerStartDate } = this.props;
    if (
      !(
        formatDateTime(
          schedulerStartDate,
          getUserTimeSettings("dateFormat")
        ) === formatDateTime(startDate, getUserTimeSettings("dateFormat")) &&
        formatDateTime(schedulerEndDate, getUserTimeSettings("dateFormat")) ===
          formatDateTime(endDate, getUserTimeSettings("dateFormat"))
      )
    ) {
      setTimeout(() => me.reloadEvents({ isEventRefresh: true }), 0);
    } else {
      this.zoomViewPort(schedulerStartDate, schedulerEndDate);
    }
    scrollEventTo = {};
  };

  resetSchedulerView = () => {
    const { onClearSearchTech } = this.props;
    onClearSearchTech();
    if (this.filteredEvents) {
      this.filteredEvents = null;
      this.engine.store.eventsStore.clear();
      this.eventsLoaded(this.allEvents);
    }
  };

  createStringComponent = () => {
    const { selectedIndex } = this.state;
    const html = ReactDOMServer.renderToString(
      <div>
        <div className="wrap">
          <select
            id="techViewChange"
            className="dropdown b-sch-tech-view-change"
          >
            <option
              id={TEAM_INDEX}
              name={getDisplayValue("TAG186", "Service Team View")}
            >
              {getDisplayValue("TAG186", "Service Team View")}
            </option>
            <option
              id={TERRITORY_INDEX}
              name={getDisplayValue("TAG187", "Territory View")}
              selected={selectedIndex === TERRITORY_INDEX ? "selected" : ""}
            >
              {getDisplayValue("TAG187", "Territory View")}
            </option>
          </select>
        </div>
        <div className="SchedulerView__combo_div">
          <Button
            id="expandAll"
            type="neutral-gray"
            label={getDisplayValue(TAG007)}
            className="SchedulerView__label_Link b-sch-expand-all-btn"
          />
          <Button
            id="collapseAll"
            type="neutral-gray"
            label={getDisplayValue(TAG006)}
            className="SchedulerView__label_Link b-sch-collapse-all-btn"
          />
        </div>
      </div>
    );
    return html;
  };

  handleHeaderClick = e => {
    if (e.target.closest("#expandAll")) {
      e.stopPropagation();
      this.handleTreeChange(EXPAND_ALL);
    } else if (e.target.closest("#collapseAll")) {
      e.stopPropagation();
      this.handleTreeChange(COLLAPSE_ALL);
    } else if (e.target.closest("#techViewChange")) {
      e.stopPropagation();
      if (!e.target.closest("#techViewChange").onchange) {
        e.target.closest("#techViewChange").onchange = this.onTechViewChange;
        this.onTechViewChange(e);
      }
      e.stopPropagation();
    }
  };

  onTechViewChange = e => {
    const { selectedIndex } = this.state;
    const index =
      e.target.selectedIndex !== undefined
        ? e.target.selectedIndex
        : e.target.index;
    if (index !== selectedIndex) {
      this.handleViewchange(index);
    }
  };

  handleTreeChange = forWhat => {
    const { onTreeConfChanged, actions } = this.props;
    const { selectedIndex } = this.state;
    const { teamView, territoryView } = this.props;
    const targetArray = selectedIndex === TEAM_INDEX ? teamView : territoryView;
    if (!targetArray.length) {
      return;
    }
    //actions.statusBarClearTxt();
    if (forWhat === EXPAND_ALL) {
      targetArray.map(node => {
        const { children, expanded, id } = node;
        if (
          children &&
          children.length &&
          !expanded &&
          !this.dirtyNodes.includes(id)
        ) {
          this.dirtyNodes.push(id);
        }
      });
      // console.log("Expand : " + this.dirtyNodes.length);
      this.dirtyNodes.length && this.engine.expandAll();
    } else if (forWhat === COLLAPSE_ALL) {
      targetArray.map(node => {
        const { children, expanded, id } = node;
        if (
          children &&
          children.length &&
          expanded &&
          !this.dirtyNodes.includes(id)
        ) {
          this.dirtyNodes.push(id);
        }
      });
      // all nodes already collapsed and calling again collapseall causing the crash in bryntum.
      this.dirtyNodes.length && this.engine.collapseAll();
    } else {
      const length = (this.dirtyNodes && this.dirtyNodes.length) || 0;
      if (!length) {
        const changed = {};
        let expanded = getUserSettingValue(EXPANDED_TERRITORY, []);
        if (selectedIndex === TEAM_INDEX) {
          expanded = getUserSettingValue(EXPANDED_TEAM, []);
          changed.tech_ExpandedTeam = cloneDeep(this.expandedNodes);
        } else {
          changed.tech_expandedTerritory = cloneDeep(this.expandedNodes);
        }

        const settingChanged =
          !this.expandedNodes.length ||
          difference(this.expandedNodes, expanded).length > 0 ||
          intersection(this.collapsedNodes, expanded).length > 0;
        if (settingChanged) {
          setTimeout(() => onTreeConfChanged(changed), 0);
        }
      }
    }
  };

  handleExpandItem = teamList => {
    const { selectedIndex } = this.state;
    const { teamView, territoryView } = this.props;
    const targetArray = selectedIndex === TEAM_INDEX ? teamView : territoryView;
    // Expand only valid team/territory nodes from respected team/territory expanded sequence.
    const expandNodes = intersectionWith(
      teamList,
      targetArray,
      (source, target) => source === target.Id
    );
    expandNodes.map(item => {
      this.dirtyNodes.push(item);
      this.engine.expand(item);
      return undefined;
    });
  };

  handleDayViewClose = () => {
    this.setState({ isDayView: false, isDayEventEdit: false });
  };

  handleHide = () => {
    const { actions } = this.props;
    const { currentEventContext, isDayEventEdit } = this.state;
    if (currentEventContext.finalize) {
      currentEventContext.finalize(false);
    }
    actions.schedulerStateChanged({ loading: false }, UPDATE_SCHEDULER_STATE);
    this.setState({
      isCreateEvent: false,
      isEdit: false,
      isDeleteEvent: false,
      isJDMDeleteEvent: false,
      isDayView: !!isDayEventEdit,
      isNonWOCreateEvent: false,
      isEditNonWOCreateEvent: false,
      nonWOevenet: {},
      isResizeEvent: false,
      isNonWoDragEvent: false,
      currentEventContext: {}
    });
  };

  getEditedEventRecord = editedEventId => {
    const event = this.engine.store.eventsStore.getById(editedEventId);
    if (event) {
      this.openDayView(event);
    }
    this.setState({ editedEventId: null });
  };

  handleDayViewEventEdit = (e, isResize) => {
    const { eventRecord } = e;
    this.setState({
      isDayView: false,
      isDayEventEdit: true,
      isResizeEvent: isResize,
      editedEventId: eventRecord.id
    });
    this.editEventCall(e);
  };

  handleDeletEventClick = e => {
    const { selectedEvent } = this.state;
    const eventRecord = e ? e.eventRecord : selectedEvent.selected[0].data;
    let workOrderId = null;
    const startDateTime = moment(eventRecord.startDate).format(
      DATE_TIME_24H_FORMAT
    );
    const eventStartDate = moment
      .utc(startDateTime, DATE_TIME_24H_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    if ((eventRecord && !eventRecord.WOId) || eventRecord.WOId === "") {
      this.setState({
        eventId: eventRecord.id,
        eventStartDate,
        isDeleteEvent: true,
        tagValue: "TAG113",
        workOrderId: null
      });
    } else if (eventRecord && eventRecord.WOId) {
      workOrderId = eventRecord.WOId;

      this.setState({
        eventId: eventRecord.id,
        eventStartDate,
        isJDMDeleteEvent: true,
        techId: eventRecord.TechId,
        workOrderId
      });
    }
  };

  handleDeleteConfirmation = value => {
    const { eventId, eventStartDate, workOrderId } = this.state;
    const { deleteEvents, unAssignWO, userTimezone } = this.props;
    const events = {};
    // Delete Non WO Event
    if (!workOrderId && value === "Yes") {
      events.eventIds = [eventId];
      deleteEvents(events, this.removeEventsFromScheduler);
    } else if (workOrderId) {
      // Delete WO Event
      if (value === "Yes") {
        // Delete Event and Unassign WO
        const wo = {};
        wo.WorkOrderIds = [workOrderId];
        unAssignWO(wo, () => {});
      } else {
        // Delete only Event
        events.eventIds = [eventId];
        deleteEvents(events, this.removeEventsFromScheduler);
      }
    }
    this.handleHide();
  };

  handleEditHide = () => {
    this.setState({ isEdit: false });
  };

  editEventCompleted = (events = []) => {
    events.map(event => this.engine.store.eventsStore.remove(event.id));
    this.eventsLoaded(events);
  };

  addNonWoEvent = () => {
    const selectedTech = getSchedulerSeletecdTech();
    if (selectedTech) {
      const { isTech, resourceId, isScheduleEnable } = selectedTech;
      if (isTech && isScheduleEnable) {
        this.setState({
          isNonWOCreateEvent: true,
          schedulerSelectedTech: resourceId,
          nonWOevenet: {}
        });
      } else {
        this.setState({
          confirmModal: {
            message: TAG199,
            options: [{ ok: TAG069 }]
          }
        });
      }
    } else {
      this.setState({ isNonWOCreateEvent: true, nonWOevenet: {} });
    }
  };

  editEventCall = e => {
    this.handleEventMouseOut();
    const { eventRecord } = e;
    const { resource, WOId } = eventRecord;
    const { data: technician } = resource;

    if (!isSchedulingEnabled(technician)) {
      this.setState({
        confirmModal: {
          message: TAG199,
          options: [{ ok: TAG069 }]
        }
      });
      return;
    }
    if (resource && WOId) {
      // edit wo event
      this.setState({
        editEventRecord: eventRecord,
        isEdit: true,
        editEventResourceRecord: resource
      });
    } else if (resource && !WOId) {
      // edit non-wo event
      this.setState({
        nonWOevenet: eventRecord,
        isNonWOCreateEvent: true,
        isEditNonWOCreateEvent: true
      });
    } else {
      // create non-wo event
      this.setState({
        nonWOevenet: eventRecord,
        isNonWOCreateEvent: true
      });
    }
    return false;
  };

  handleEventContextToolTipItemClick = (event, source) => {
    // const { eventRecord } = source;
    //let s = this.eventElement;
    const { eventRecord } = this.eventElement;

    if (event.target.id === "closeTooltipBtn") {
      source.hide();
    }
    if (event.target.id === "openRecordBtnId") {
      const { isWorkOrder, whatId } = eventRecord;
      if (isWorkOrder) {
        openPopUp(whatId);
      }
    }
    if (event.target.id === "dayViewBtnId") {
      source.hide();
      this.openDayView(eventRecord);
    }
  };

  openDayView = (eventRecord, resources) => {
    let singleResourceRecord;
    if (resources) {
      singleResourceRecord = resources;
    } else {
      singleResourceRecord = this.engine.eventStore.getResourcesForEvent(
        eventRecord
      );
    }
    // const selectedDayEvents = this.engine.eventStore.getEventsByStartDate(
    // eventRecord.startDate
    // );
    const selectedStartDate = new Date(eventRecord.startDate);
    selectedStartDate.setHours(0, 0, 0, 0);
    const selectedEndDate = new Date(eventRecord.startDate);
    selectedEndDate.setHours(24, 0, 0, 0);
    const selectedDayEvents = this.engine.eventStore.getEventsInTimeSpan(
      selectedStartDate,
      selectedEndDate,
      true
    );
    const selectedStartTime = selectedStartDate.getTime();
    const selectedEndTime = selectedEndDate.getTime();
    const selectedTechEvents = [];
    selectedDayEvents.map(eventItem => {
      const isSelectedtechEvent = this.engine.eventStore.isEventAssignedToResource(
        eventItem,
        singleResourceRecord[0]
      );
      eventItem.isEventStartBefore = false;
      eventItem.isExtendedEvent = false;
      eventItem.isEventEndAfter = false;
      eventItem.isEventSameDay = false;
      eventItem.isExtendedAllDayEvent = false;
      if (isSelectedtechEvent) {
        const eventStartTime = eventItem.originalData.startDate.getTime();
        const eventEndTime = eventItem.originalData.endDate.getTime();
        if (
          eventStartTime >= selectedStartTime &&
          eventEndTime <= selectedEndTime
        ) {
          eventItem.isEventSameDay = true;
        } else if (eventStartTime < selectedStartTime) {
          eventItem.isEventStartBefore = true;
          eventItem.isExtendedEvent = true;
          eventItem.isExtendedAllDayEvent = true;
        } else if (eventEndTime > selectedEndTime) {
          eventItem.isEventEndAfter = true;
          eventItem.isExtendedEvent = true;
          //eventItem.isExtendedAllDayEvent = true;
          //eventItem.isExtendedAllDayEvent = true;
        }
        selectedTechEvents.push(eventItem);
      }
    });
    this.setState({
      dayViewStartDate: selectedStartDate,
      dayViewEndDate: selectedEndDate,
      dayViewEventRecord: selectedTechEvents,
      dayViewResourceRecord: singleResourceRecord,
      isDayView: true,
      tagValue: "TAG113"
    });
  };

  openDayViewTest = (eventRecord, resources) => {
    let singleResourceRecord;
    if (resources) {
      singleResourceRecord = resources;
    } else {
      singleResourceRecord = this.engine.eventStore.getResourcesForEvent(
        eventRecord
      );
    }
    // const selectedDayEvents = this.engine.eventStore.getEventsByStartDate(
    // eventRecord.startDate
    // );
    const selectedStartDate = new Date(eventRecord.startDate);
    selectedStartDate.setHours(0, 0, 0, 0);
    const selectedEndDate = new Date(eventRecord.startDate);
    selectedEndDate.setHours(24, 0, 0, 0);
    const selectedDayEvents = this.engine.eventStore.getEventsInTimeSpan(
      selectedStartDate,
      selectedEndDate,
      true
    );
    const selectedStartTime = selectedStartDate.getTime();
    const selectedEndTime = selectedEndDate.getTime();
    const selectedTechEvents = [];
    selectedDayEvents.map(eventItem => {
      const isSelectedtechEvent = this.engine.eventStore.isEventAssignedToResource(
        eventItem,
        singleResourceRecord[0]
      );
      eventItem.isExtendedEvent = true;
      eventItem.isExtendedAllDayEvent = false;
      eventItem.isMultiDayEvent = false;
      if (isSelectedtechEvent) {
        if (
          eventItem._startDateMS >= selectedStartTime &&
          eventItem._endDateMS < selectedEndTime
        ) {
          eventItem.isExtendedEvent = false;
        } else if (
          eventItem._startDateMS === selectedStartTime &&
          eventItem._endDateMS === selectedEndTime
        ) {
          eventItem.isExtendedAllDayEvent = true;
          eventItem.isExtendedEvent = false;
        } else if (
          eventItem._startDateMS <= selectedStartTime &&
          eventItem._endDateMS >= selectedEndTime
        ) {
          eventItem.isMultiDayEvent = true;
        } else if (
          eventItem._startDateMS >= selectedStartTime &&
          eventItem._endDateMS >= selectedEndTime
        ) {
          eventItem.isMultiDayEvent = true;
        }
        selectedTechEvents.push(eventItem);
      }
    });
    this.setState({
      dayViewStartDate: selectedStartDate,
      dayViewEndDate: selectedEndDate,
      dayViewEventRecord: selectedTechEvents,
      dayViewResourceRecord: singleResourceRecord,
      isDayView: true,
      tagValue: "TAG113"
    });
  };

  handleCreateContextMenu = e => {
    const { items, record } = e;
    const { isTech } = record;
    items.pop();
    const mapAllowedBySetting =
      getSettingValue(DCON001_SET071).toLowerCase() === "true";
    const mapSettings = stringToBoolean(getUserSetting(MAP_CONFIG));
    if (mapAllowedBySetting && mapSettings) {
      if (isTech) {
        items.push({
          text: getDisplayValue("TAG135", "Show Route"),
          onItem: e => {
            this.handleContextMenuItemClick(e, "Show Route");
          }
        });
      }
    }
    items.push({
      text: getDisplayValue("TAG136", "Show Record"),
      onItem: e => {
        this.handleContextMenuItemClick(e, "Show Record");
      }
    });
    return items;
  };

  handleContextMenuItemClick = (e, forWhat) => {
    const { record } = e;
    const { data } = record;
    const { Id } = data;
    if (forWhat === "Show Route") {
      setShowRouteTechIdsData(record);
      this.createPlotRoute(record);
    } else {
      openPopUp(Id);
    }
  };

  handleCellMouseClick = e => {
    let events = [];
    let eventSortedArray;
    const { eventsStartDate } = this.props;
    if (e.target.id === "techIconId") {
      const ev3 = new MouseEvent("contextmenu", {
        bubbles: true,
        cancelable: false,
        view: window,
        clientX: e.target.getBoundingClientRect().x + 10,
        clientY: e.target.getBoundingClientRect().y
      });
      e.target.dispatchEvent(ev3);
    }
    if (e.target.id === "previousIconId" || e.target.id === "nextIconId") {
      events = this.engine.eventStore.getEventsForResource(e.record);
      eventSortedArray = events.sort((a, b) => a.startDate - b.startDate);
      if (!scrollEventTo.startDate) {
        scrollEventTo.startDate = eventsStartDate;
      }
      if (currentRecord !== e.record) {
        currentRecord = e.record;
        scrollEventTo.startDate = eventsStartDate;
      }
    }
    if (e.target.id === "previousIconId") {
      const prevArr = filter(
        eventSortedArray,
        ev => ev.startDate < scrollEventTo.startDate
      );
      if (!isEmpty(prevArr)) {
        scrollEventTo = clone(prevArr[prevArr.length - 1]);
        this.scrollAndCheckEvents(e, scrollEventTo);
      }
    }
    if (e.target.id === "nextIconId") {
      const nextArr = filter(
        eventSortedArray,
        ev => ev.startDate > scrollEventTo.startDate
      );
      if (!isEmpty(nextArr)) {
        scrollEventTo = clone(nextArr[0]);
        this.scrollAndCheckEvents(e, scrollEventTo);
      }
    }
  };

  modifyDateRange = event => {
    const visibleDateRange = this.engine.timeAxisSubGrid.grid.getVisibleDateRange();
    const { updateDateRange } = this.props;
    const { startDate, endDate } = visibleDateRange;
    const currentTimeSpanRange = endDate - startDate;
    const modifiedStartDate = moment(event.startDate).startOf("day");
    updateDateRange(
      modifiedStartDate.toDate(),
      new Date(modifiedStartDate + currentTimeSpanRange)
    );
  };

  scrollAndCheckEvents = (e, event) => {
    this.modifyDateRange(event);
    setTimeout(() => {
      const s = this.engine.getCoordinateFromDate(event.startDate);
      try {
        this.engine.scrollHorizontallyTo(s).then(() => {
          this.handleVisibleDateRange();
          this.disableImageArrowFunction();
        });
      } catch (e) {
        this.disableImageArrowFunction();
      }
    }, 10);
  };

  checkForEventsAndResources = (record, events) => {
    let eventsForResource;
    const { eventsStartDate } = this.props;
    if (events) {
      eventsForResource = events;
    } else {
      eventsForResource = this.engine.eventStore.getEventsForResource(record);
    }

    if (!scrollEventTo.startDate) {
      scrollEventTo.startDate = eventsStartDate;
    }
    const prevArr = filter(
      eventsForResource,
      ev => ev.startDate < scrollEventTo.startDate
    );
    const nextArr = filter(
      eventsForResource,
      ev => ev.startDate > scrollEventTo.startDate
    );

    record.isHavePrevEvent = !isEmpty(prevArr);
    record.isHaveNextEvent = !isEmpty(nextArr);
    record.showPrevNextIcon = true;
  };

  disableImageArrowFunction = () => {
    this.engine.resourceStore.forEach(resourceRecord => {
      if (resourceRecord.isTech) {
        // if (resourceRecord.id === "a2D17000000VBXpEAO") {
        this.checkForEventsAndResources(resourceRecord);
        // }
      }
    });
  };

  disableImageArrowFunctionReset = () => {
    this.engine.resourceStore.forEach(resourceRecord => {
      if (resourceRecord.isTech) {
        resourceRecord.showPrevNextIcon = false;
      }
    });
  };

  handleScroll = e => {
    const { viewState } = this.state;
    this.handleScrollDateChange();
    if (
      viewState === FILTER_EVENTS_RESULT ||
      viewState === FILTER_TECHNICIAN_RESULT
    ) {
      setTimeout(() => this.disableImageArrowFunction(), 0);
    }
  };

  handleScrollDateChange = () => {
    if (
      this.engine.timeAxisSubGrid.scrollable.x <
        this.engine.timeAxisSubGrid.width ||
      this.engine.timeAxisSubGrid.scrollable.scrollWidth -
        (this.engine.timeAxisSubGrid.scrollable.x +
          this.engine.timeAxisSubGrid.width) <
        this.engine.timeAxisSubGrid.width
    ) {
      // const visibleDateRange = this.engine.getVisibleDateRange();
      const visibleDateRange = this.engine.timeAxisSubGrid.grid.getVisibleDateRange();
      const { startDate, endDate } = visibleDateRange;
      this.zoomViewPort(startDate, endDate, true);
    }
    this.updateDate && this.updateDateRange();
  };

  updateDateRange = () => {
    // const visibleDateRange = this.engine.getVisibleDateRange();
    const visibleDateRange = this.engine.timeAxisSubGrid.grid.getVisibleDateRange();
    const { startDate, endDate } = visibleDateRange;
    const { eventsStartDate, eventsEndDate } = this.props;
    /* if (
      !(
        formatDateTime(eventsStartDate, getUserTimeSettings("dateFormat")) ===
          formatDateTime(startDate, getUserTimeSettings("dateFormat")) &&
        formatDateTime(eventsEndDate, getUserTimeSettings("dateFormat")) ===
          formatDateTime(endDate, getUserTimeSettings("dateFormat"))
      )
    ) {
      this.handleVisibleDateRange();
    } */
    this.handleVisibleDateRange();
    scrollEventTo = {};
    this.updateDate = false;
  };

  createStringTechComponent = ({ record }) => {
    const {
      isTech,
      name,
      isHavePrevEvent,
      isHaveNextEvent,
      showPrevNextIcon
    } = record;
    const prevEventColor = isHavePrevEvent ? "#0070d2" : "#706e6b";
    const nextEventColor = isHaveNextEvent ? "#0070d2" : "#706e6b";
    const html = ReactDOMServer.renderToString(
      <div className="SchedulerView__Tech_div">
        <Label>{name}</Label>
        <span>
          <Icon
            id="techIconId"
            className="RemoveItemColumn"
            cursor="pointer"
            icon="threedots_vertical"
            size="x-small"
            align="right"
            style={{
              fill: "#0070d2"
            }}
          />
          {showPrevNextIcon && (
            <Icon
              id="previousIconId"
              style={{
                fill: prevEventColor
              }}
              cursor="pointer"
              icon="left"
              size="x-small"
              align="center"
            />
          )}
          {showPrevNextIcon && (
            <Icon
              id="nextIconId"
              style={{
                fill: nextEventColor
              }}
              cursor="pointer"
              icon="right"
              size="x-small"
              align="center"
            />
          )}
        </span>
      </div>
    );
    return isTech ? html : name;
  };

  handleDateForRoute = (checkDate, startDate, EndDate) => {
    const eventSDate = moment(startDate).format(
      getUserTimeSettings("dateFormat")
    );
    const eventEDate = moment(EndDate).format(
      getUserTimeSettings("dateFormat")
    );
    const isBetween = moment(checkDate).isBetween(eventSDate, eventEDate);
    return isBetween;
  };

  handleDateForSame = (checkDate, eventDate) => {
    const eventSDate = moment(eventDate).format(
      getUserTimeSettings("dateFormat")
    );
    const isSame = moment(checkDate).isSame(eventSDate);
    return isSame;
  };

  handleDateIsBetweenEvents = (checkDate, startDate, EndDate) => {
    const startDateEx = new Date(startDate);
    const endDateEx = new Date(EndDate);
    const checkDateEx = new Date(checkDate);
    return (
      startDateEx.getTime() < checkDateEx.getTime() &&
      endDateEx.getTime() > checkDateEx.getTime()
    );
  };

  handleEventForViewPortDateRange = (
    techId,
    schedulerStartDate,
    schedulerEndDate
  ) => {
    const techEvents = [];
    this.engine.eventStore.map(eventItem => {
      if (eventItem.resourceId === techId) {
        if (eventItem.isWorkOrder) {
          const isStartBetween = this.handleDateForRoute(
            eventItem.startDate,
            schedulerStartDate,
            schedulerEndDate
          );
          const isEndBetween = this.handleDateForRoute(
            eventItem.endDate,
            schedulerStartDate,
            schedulerEndDate
          );
          const isStartEBetween = this.handleDateForRoute(
            schedulerStartDate,
            eventItem.startDate,
            eventItem.endDate
          );
          const isEndEBetween = this.handleDateForRoute(
            schedulerEndDate,
            eventItem.startDate,
            eventItem.endDate
          );
          const isStartSame = this.handleDateForSame(
            schedulerStartDate,
            eventItem.startDate
          );
          const isStartESame = this.handleDateForSame(
            schedulerStartDate,
            eventItem.endDate
          );
          const isEndSame = this.handleDateForSame(
            schedulerEndDate,
            eventItem.startDate
          );
          const isEndESame = this.handleDateForSame(
            schedulerEndDate,
            eventItem.endDate
          );
          // this.handleDateIsBetweenEvents(schedulerStartDate, eventItem.startDate, eventItem.endDate);
          if (
            isStartBetween ||
            isEndBetween ||
            isStartSame ||
            isEndSame ||
            isStartESame ||
            isEndESame ||
            isStartEBetween ||
            isEndEBetween
          ) {
            techEvents.push(eventItem);
          }
        }
      }
    });
    if (techEvents.length) {
      const sortedArray = techEvents.sort(
        (a, b) =>
          moment(a.startDate).format(getUserTimeSettings("dateFormat")) -
          moment(b.startDate).format(getUserTimeSettings("dateFormat"))
      );
    }
    return techEvents;
  };

  handleGetEventsInRangeForRouteTechs = currentDate => {
    const resourceRecords = getShowRouteTechIdsData();
    const resourceKeys = Object.keys(resourceRecords);
    resourceKeys.map(techItem => {
      this.handleGetEventsInRangeForRoute(
        currentDate,
        resourceRecords[techItem]
      );
    });
  };

  handleGetEventsInRangeForRoute = (currentDate, resource) => {
    // let singleResourceRecord=getShowRouteTechData();
    const singleResourceRecord = resource;
    // const selectedDayEvents = this.engine.eventStore.getEventsByStartDate(
    //  new Date(currentDate)
    // );
    const selectedStartDate = new Date(currentDate);
    selectedStartDate.setHours(0, 0, 0, 0);
    const selectedEndDate = new Date(currentDate);
    selectedEndDate.setHours(24, 0, 0, 0);
    // const selectedEndDateForSpan = new Date(currentDate);
    // selectedEndDateForSpan.setHours(23, 59, 0, 0);
    const selectedDayEvents = this.engine.eventStore.getEventsInTimeSpan(
      selectedStartDate,
      selectedEndDate,
      true
    );
    const selectedDayEventsSortedArr = selectedDayEvents.sort(
      (a, b) => a.startDate - b.startDate
    );

    const selectedStartTime = selectedStartDate.getTime();
    const selectedEndTime = selectedEndDate.getTime();
    const selectedTechEvents = [];
    selectedDayEventsSortedArr.map(eventItem => {
      const isSelectedtechEvent = this.engine.eventStore.isEventAssignedToResource(
        eventItem,
        singleResourceRecord
      );
      eventItem.isExtendedEvent = true;
      eventItem.isExtendedAllDayEvent = false;
      if (isSelectedtechEvent && eventItem.isWorkOrder) {
        if (
          eventItem._startDateMS >= selectedStartTime &&
          eventItem._endDateMS < selectedEndTime
        ) {
          eventItem.isExtendedEvent = false;
        } else if (
          eventItem._startDateMS === selectedStartTime &&
          eventItem._endDateMS === selectedEndTime
        ) {
          eventItem.isExtendedAllDayEvent = true;
        }
        const checkWorkOrderLocation = checkForTechAndWoLocation(
          eventItem.data,
          false
        );
        const techEventsObj = {
          address: eventItem.data.address,
          endTime: { time: moment(eventItem.eventsEndTime).valueOf() },
          lat: eventItem.data.lat,
          lng: eventItem.data.lng,
          Name: eventItem.workOrderName,
          WOId: eventItem.whatId,
          id: eventItem.whatId,
          startTime: { time: moment(eventItem.startDateTime).valueOf() },
          startDate: moment(eventItem.startDate).format(
            getUserTimeSettings("dateFormat")
          ),
          endDate: moment(eventItem.endDate).format(
            getUserTimeSettings("dateFormat")
          ),
          isHaveLocation: checkWorkOrderLocation
        };
        selectedTechEvents.push(techEventsObj);
      }
    });
    const techData = getShowRouteDataMap(singleResourceRecord.id);
    let temp;
    const { eventsForWorkOrders, technician } = (temp = { ...techData });
    if (eventsForWorkOrders[currentDate]) {
      eventsForWorkOrders[currentDate] = selectedTechEvents;
    }
  };

  createPlotRoute = record => {
    setShowRouteCallBackFunction(this.handleGetEventsInRangeForRouteTechs);
    setShowRouteTechData(record);
    const { onShowRouteTechEmpty, eventsEndDate, eventsStartDate } = this.props;
    // const selectedStartDate = new Date(getSchedulerState(EVENT_START_DATE));
    // selectedStartDate.setHours(0, 0, 0, 0);
    // const selectedEndDate = new Date(getSchedulerState(EVENT_END_DATE));
    // selectedEndDate.setHours(24, 0, 0, 0);
    // const selectedStartDate = moment(
    //  new Date(getSchedulerState(EVENT_START_DATE))
    // ).format(DATE_TIME_FORMAT);
    // const selectedEndDate = moment(
    //  new Date(getSchedulerState(EVENT_END_DATE))
    // ).format(DATE_TIME_FORMAT);
    const selectedStartDate = moment(new Date(eventsStartDate)).format(
      DATE_TIME_FORMAT
    );
    const selectedEndDate = moment(new Date(eventsEndDate)).format(
      DATE_TIME_FORMAT
    );
    // const selectedEndDateForSpan = new Date(currentDate);
    // selectedEndDateForSpan.setHours(23, 59, 0, 0);
    const selectedDayEvents = this.engine.eventStore.getEventsInTimeSpan(
      new Date(selectedStartDate),
      new Date(selectedEndDate),
      true
    );
    const selectedDayEventsSortedArr = selectedDayEvents.sort(
      (a, b) => a.startDate - b.startDate
    );
    const showRouteDone = getShowRouteDataMapDone();
    let routeSelectedDate = selectedStartDate;
    if (showRouteDone) {
      routeSelectedDate = getShowRouteSelectedDate();
      // this.handleGetEventsInRangeForRouteTechs(routeSelectedDate);
    }
    // const routeSelectedDate = selectedStartDate;
    const { data: TechData } = record;
    const { id: TechId } = TechData;
    const techEvents = [];

    selectedDayEventsSortedArr.map(eventItem => {
      const isSelectedtechEvent = this.engine.eventStore.isEventAssignedToResource(
        eventItem,
        record
      );
      if (isSelectedtechEvent && eventItem.isWorkOrder) {
        techEvents.push(eventItem);
      }
    });
    const showRouteDataForSelectedTech = {};
    const startDate = new Date(selectedStartDate);
    const endDate = new Date(selectedEndDate);

    while (startDate.getTime() <= endDate.getTime()) {
      const newDate = moment(startDate).format(DATE_FORMAT);
      showRouteDataForSelectedTech[newDate] = [];
      techEvents.map(eventItem => {
        const eventDate = moment(eventItem.startDate).format(DATE_FORMAT);
        const dateIsSame = dateTimeCheckForSame(newDate, eventDate);
        const dateInRange = this.handleDateIsBetweenEvents(
          newDate,
          eventItem.startDate,
          eventItem.endDate
        );

        if (dateIsSame || dateInRange) {
          const checkWorkOrderLocation = checkForTechAndWoLocation(
            eventItem.data,
            false
          );
          const techEventsObj = {
            address: eventItem.data.address,
            endTime: { time: moment(eventItem.eventsEndTime).valueOf() },
            lat: eventItem.data.lat,
            lng: eventItem.data.lng,
            Name: eventItem.workOrderName,
            WOId: eventItem.whatId,
            id: eventItem.whatId,
            startTime: { time: moment(eventItem.startDateTime).valueOf() },
            startDate: moment(eventItem.startDate).format(DATE_FORMAT),
            endDate: moment(eventItem.endDate).format(DATE_FORMAT),
            isHaveLocation: checkWorkOrderLocation
          };
          showRouteDataForSelectedTech[newDate].push(techEventsObj);
        }
      });
      startDate.setDate(startDate.getDate() + 1);
    }
    this.handleRouteForDay(
      TechData,
      TechId,
      routeSelectedDate,
      selectedStartDate,
      selectedEndDate,
      techEvents,
      showRouteDataForSelectedTech,
      onShowRouteTechEmpty
    );
  };

  /* createPlotRoute = record => {
    //this.createPlotRouteTest(record);
    setShowRouteCallBackFunction(this.handleGetEventsInRangeForRouteTechs);
    setShowRouteTechData(record);
    const { onShowRouteTechEmpty } = this.props;
    const schedulerStartDate = moment(
      new Date(getSchedulerState(EVENT_START_DATE))
    ).format(DATE_TIME_FORMAT);
    const schedulerEndDate = moment(
      new Date(getSchedulerState(EVENT_END_DATE))
    ).format(DATE_TIME_FORMAT);
    const routeSelectedDate = schedulerStartDate;
    const { data: TechData } = record;
    const { id: TechId } = TechData;
    let techEvents = [];
    techEvents = this.handleEventForViewPortDateRange(
      TechId,
      schedulerStartDate,
      schedulerEndDate
    );
    const startDate = new Date(schedulerStartDate);
    const endDate = new Date(schedulerEndDate);
    const showRouteDataForSelectedTech = {};
    while (startDate.getTime() <= endDate.getTime()) {
      const newDate = moment(startDate).format(
        getUserTimeSettings("dateFormat")
      );
      showRouteDataForSelectedTech[
        moment(newDate).format(getUserTimeSettings("dateFormat"))
      ] = [];
      techEvents.map(eventItem => {
        const eventDate = moment(eventItem.startDate).format(
          getUserTimeSettings("dateFormat")
        );
        const dateIsSame = dateTimeCheckForSame(newDate, eventDate);
        const dateInRange = this.handleDateIsBetweenEvents(
          newDate,
          eventItem.startDate,
          eventItem.endDate
        );
        if (dateIsSame || dateInRange) {
          const checkWorkOrderLocation = checkForTechAndWoLocation(
            eventItem.data,
            false
          );
          const techEventsObj = {
            address: eventItem.data.address,
            endTime: { time: moment(eventItem.eventsEndTime).valueOf() },
            lat: eventItem.data.lat,
            lng: eventItem.data.lng,
            Name: eventItem.workOrderName,
            WOId: eventItem.whatId,
            startTime: { time: moment(eventItem.startDateTime).valueOf() },
            startDate: moment(eventItem.startDate).format(
              getUserTimeSettings("dateFormat")
            ),
            endDate: moment(eventItem.endDate).format(
              getUserTimeSettings("dateFormat")
            ),
            isHaveLocation: checkWorkOrderLocation
          };
          showRouteDataForSelectedTech[
            moment(newDate).format(getUserTimeSettings("dateFormat"))
          ].push(techEventsObj);
        }
      });
      startDate.setDate(startDate.getDate() + 1);
    }
    this.handleRouteForDay(
      TechData,
      TechId,
      routeSelectedDate,
      schedulerStartDate,
      schedulerEndDate,
      techEvents,
      showRouteDataForSelectedTech,
      onShowRouteTechEmpty
    );
  }; */

  handleRouteForDay = (
    TechData,
    TechId,
    routeSelectedDate,
    schedulerStartDate,
    schedulerEndDate,
    techEvents,
    techEventsList
  ) => {
    const mapSettings = stringToBoolean(getUserSetting(MAP_CONFIG));
    if (mapSettings) {
      const checkTechLocation = checkForTechAndWoLocation(TechData, true);
      const showRouteDone = getShowRouteDataMapDone();
      const {
        address: TechAddress,
        name: TechName,
        FirstName: TechFirstName,
        homeAddress: TechhomeAddress,
        LastName: TechLastName,
        lat: TechLat,
        lng: TechLng,
        homeLat: TechHomeLat,
        homeLng: TechHomeLng,
        SmallPhotoUrl: TechSmallPhotoUrl,
        isTechSalesforceUser
      } = TechData;

      const defaultConfig = getMapConfig();
      const data = {
        currentDateInMilliSeconds: moment().valueOf(),
        currentDateInUserFormat: getUserTimeSettings("dateFormat"),
        currentTimerMarkInMillis: moment().valueOf(),
        eventsForWorkOrders: techEventsList,
        futureOverNightStayEvent: {},
        ganttEndDateInMilliSeconds: moment(schedulerEndDate).valueOf(),
        ganttStartDateInMilliSeconds: moment(schedulerStartDate).valueOf(),
        pastOverNightStayEvent: {},
        techHomeIcon: defaultConfig.techHomeIcon,
        techIcon: defaultConfig.techIcon,
        technician: {
          address: TechAddress,
          FirstName: TechFirstName,
          homeAddress: TechhomeAddress,
          id: TechId,
          lat: TechLat,
          lng: TechLng,
          homeLat: TechHomeLat,
          homeLng: TechHomeLng,
          LatName: TechLastName,
          name: TechName,
          SmallPhotoUrl: TechSmallPhotoUrl,
          isHaveLocation: checkTechLocation,
          isTechSalesforceUser
        },
        viewAllEventForToday: true,
        woIcon: defaultConfig.woIcon,
        selectedCurrentDate: routeSelectedDate,
        schedulerMinDate: moment(schedulerStartDate),
        schedulerMaxDate: moment(schedulerEndDate)
      };
      if (checkTechLocation) {
        setTechnicianRouteData(data);
        setShowRouteDataMap(data);
        drawTechRouteForDay(
          moment(routeSelectedDate).format(DATE_FORMAT),
          true
        );
      } else {
        this.showMapErrorinStatus(TechData);
      }
    }
    // }
  };

  showMapErrorinStatus = data => {
    const { onHandleMapErrorStatus } = this.props;
    const { name } = data;
    const errorInfo = {};
    errorInfo.message = getDisplayValue(TAG177);
    errorInfo.markerMsg = `${getDisplayValue("TAG340")}\n${name}`;
    errorInfo.errorCodeMsg = getDisplayValue(TAG260);
    onHandleMapErrorStatus(errorInfo);
  };

  getHours = durationInMinutes => {
    const timeInHours = `${getMinutesToHours(durationInMinutes).replace(
      /:/g,
      getDisplayValue("TAG170")
    )} ${getDisplayValue("TAG082")}`;
    const minutes = `00 ${getDisplayValue("TAG082")}`;
    return timeInHours.replace(minutes, " ");
  };

  renderHoverRules = (hoverFields = {}) =>
    Object.keys(hoverFields).map(hoverField => {
      const hoverInfo = hoverFields[hoverField] || {};
      const { display, fieldValue } = hoverInfo;
      return (
        <div id="eventTooltipWindow">
          <Label
            id="eventTooltipWindow"
            className="SchedulerView__eventTooltip-hoverRuleItem"
          >
            <b id="eventTooltipWindow">{`${display} : `}</b> {fieldValue}
          </Label>
        </div>
      );
    });

  getTooltip = data => {
    const { eventRecord = {} } = data;
    const {
      description,
      durationInMinutes,
      isWorkOrder,
      startDateTime,
      subject
    } = eventRecord;
    const { height } = this.engine;
    const children = description
      ? description
          .split("\n")
          .map(line => <div id="eventTooltipWindow">{line}</div>)
      : [];
    if (isWorkOrder) {
      const { hoverFields = {} } = eventRecord;
      return ReactDOMServer.renderToString(
        <div className="SchedulerView__eventTooltip" id="eventTooltipWindow">
          <div
            className="SchedulerView__eventTooltip-header"
            id="eventTooltipWindow"
          >
            <div
              className="SchedulerView__eventTooltip-htitle"
              id="eventTooltipWindow"
            >
              {getDisplayValue(EVENTSTAG088)}
            </div>
            <div
              className="SchedulerView__eventTooltip-closeIcon"
              id="eventTooltipWindow"
            >
              <Button
                id="closeTooltipBtn"
                type="icon-bare"
                size="small"
                align="center"
                title={getDisplayValue(TAG487)}
              >
                <Icon
                  id="closeTooltipBtn"
                  icon="close"
                  cursor="pointer"
                  size="small"
                  align="center"
                />
              </Button>
            </div>
          </div>

          <div
            className="SchedulerView__eventTooltip-subHeader"
            id="eventTooltipWindow"
          >
            <div
              className="SchedulerView__eventTooltip-layout"
              id="eventTooltipWindow"
            >
              <div id="eventTooltipWindow" className="SchedulerView__subject">
                {subject}
              </div>
              <div id="eventTooltipWindow">
                {moment(startDateTime).format(
                  getUserTimeSettings("dateTimeFormat")
                )}
              </div>
              {getSettingValue(DCON001_SET054) === HOURS && (
                <div id="eventTooltipWindow">
                  {this.getHours(durationInMinutes)}
                </div>
              )}
              {getSettingValue(DCON001_SET054) !== HOURS && (
                <div id="eventTooltipWindow">{`${durationInMinutes} ${getDisplayValue(
                  TAG082
                )}`}</div>
              )}
            </div>
            <div
              id="eventTooltipWindow"
              className="SchedulerView__eventTooltip-icons"
            >
              <Grid>
                <GridRow>
                  <GridItem>
                    <figure id="eventTooltipWindow" cursor="pointer">
                      <Button
                        id="openRecordBtnId"
                        type="icon-bare"
                        size="large"
                        align="center"
                        title={getDisplayValue(TAG487)}
                      >
                        <Icon
                          id="openRecordBtnId"
                          icon="open"
                          cursor="pointer"
                          size="large"
                          align="center"
                        />
                      </Button>
                      <figcaption cursor="pointer" id="eventTooltipWindow">
                        {getDisplayValue(TAG279)}
                      </figcaption>
                    </figure>
                  </GridItem>
                  <GridItem>
                    <figure id="eventTooltipWindow" cursor="pointer">
                      <Button
                        id="dayViewBtnId"
                        type="icon-bare"
                        size="large"
                        align="center"
                      >
                        <Icon
                          id="dayViewBtnId"
                          icon="dayview"
                          cursor="pointer"
                          size="large"
                          align="center"
                        />
                      </Button>
                      <figcaption cursor="pointer" id="eventTooltipWindow">
                        {getDisplayValue(TAG325)}
                      </figcaption>
                    </figure>
                  </GridItem>
                </GridRow>
              </Grid>
            </div>
          </div>
          <Container
            id="eventTooltipWindow"
            style={{
              height:
                Object.keys(hoverFields).length > 10
                  ? `${height - 130}px`
                  : "auto"
            }}
            className="SchedulerView__eventTooltip-hoverRule"
          >
            {children}
            {this.renderHoverRules(hoverFields)}
          </Container>
        </div>
      );
    }

    const hasDescription = children.length > 0;
    return ReactDOMServer.renderToString(
      <div className="SchedulerView__eventTooltip" id="eventTooltipWindow">
        <div
          className="SchedulerView__eventTooltip-header"
          id="eventTooltipWindow"
        >
          <div
            className="SchedulerView__eventTooltip-htitle"
            id="eventTooltipWindow"
          >
            {getDisplayValue(EVENTSTAG088)}
          </div>
          <div
            className="SchedulerView__eventTooltip-closeIcon"
            id="eventTooltipWindow"
          >
            <Button
              id="closeTooltipBtn"
              type="icon-bare"
              size="small"
              align="center"
              title={getDisplayValue(TAG487)}
            >
              <Icon
                id="closeTooltipBtn"
                icon="close"
                cursor="pointer"
                size="small"
                align="center"
              />
            </Button>
          </div>
        </div>
        <div
          className="SchedulerView__eventTooltip-subHeader"
          id="eventTooltipWindow"
        >
          <div
            className="SchedulerView__eventTooltip-layout"
            id="eventTooltipWindow"
          >
            <div id="eventTooltipWindow">{subject}</div>
            <div id="eventTooltipWindow">
              {moment(startDateTime).format(
                getUserTimeSettings("dateTimeFormat")
              )}
            </div>
            {getSettingValue(DCON001_SET054) === HOURS && (
              <div id="eventTooltipWindow">
                {this.getHours(durationInMinutes)}
              </div>
            )}
            {getSettingValue(DCON001_SET054) !== HOURS && (
              <div id="eventTooltipWindow">{`${durationInMinutes} ${getDisplayValue(
                TAG082
              )}`}</div>
            )}
          </div>
          <div
            className="SchedulerView__eventTooltip-icons"
            id="eventTooltipWindow"
          >
            <Grid>
              <GridRow>
                <GridItem>
                  <figure id="eventTooltipWindow" cursor="pointer">
                    <Button
                      id="dayViewBtnId"
                      type="icon-bare"
                      size="large"
                      align="center"
                    >
                      <Icon
                        id="dayViewBtnId"
                        icon="dayview"
                        cursor="pointer"
                        size="large"
                        align="center"
                      />
                    </Button>
                    <figcaption id="eventTooltipWindow">
                      {getDisplayValue(TAG325)}
                    </figcaption>
                  </figure>
                </GridItem>
              </GridRow>
            </Grid>
          </div>
        </div>
        {hasDescription && (
          <Container
            id="eventTooltipWindow"
            style={{
              height:
                children.length > 10 ||
                (!children.length && description.length > 200)
                  ? `${height - 130}px`
                  : "auto"
            }}
            className="SchedulerView__eventTooltip-hoverRule"
          >
            {children}
          </Container>
        )}
      </div>
    );
  };

  handleContextMenuEventItemClick = (e, forWhat) => {
    const { eventRecord } = e;
    const { id: eventId, isWorkOrder, WOId } = eventRecord;
    if (forWhat === "Show Record") {
      if (isWorkOrder) {
        openPopUp(WOId);
      }
    } else if (forWhat === "Ranked Appointment Booking") {
      if (isWorkOrder) {
        const URL = `apex/WSCH_Provider_ECO_Appointment?id=${WOId}`;
        openPopUp(URL, true);
      }
    } else if (forWhat === "Add Work Order to Grid (top pane)") {
      this.setState({
        confirmModal: {
          message: EVENTSTAG074,
          options: [{ ok: TAG069 }],
          eventRecord
        }
      });
    } else {
      this.openDayView(eventRecord);
    }
  };

  handleCreateEventContextMenu = e => {
    if (getSettingValue(DCON005_SET006) !== "Enabled") return false;
    const { items, eventRecord } = e;
    const { isWorkOrder } = eventRecord;
    // items.pop();
    items.deleteEvent.onItem = this.handleDeletEventClick;
    items[getDisplayValue(EVENTSTAG036, "View Details")] = {
      text: getDisplayValue(EVENTSTAG036, "View Details"),
      icon: "b-fa b-fa-fw b-fa-flag",
      onItem: e => {
        this.handleEventClick(e);
      }
    };
    items.editEvent.text = getDisplayValue("TAG156", "Edit Event");
    if (isWorkOrder) {
      items[getDisplayValue(TAG487, "Show Record")] = {
        text: getDisplayValue(TAG487, "Show Record"),
        icon: "b-fa b-fa-fw b-fa-flag",
        onItem: e => {
          this.handleContextMenuEventItemClick(e, "Show Record");
        }
      };
      items[getDisplayValue(EVENTSTAG142, "Day View")] = {
        text: getDisplayValue(EVENTSTAG142, "Day View"),
        icon: "b-fa b-fa-fw b-fa-flag",
        onItem: e => {
          this.handleContextMenuEventItemClick(e, "Day View");
        }
      };
      items[
        getDisplayValue(EVENTSTAG075, "Add Work Order to Grid (top pane)")
      ] = {
        text: getDisplayValue(
          EVENTSTAG075,
          "Add Work Order to Grid (top pane)"
        ),
        icon: "b-fa b-fa-fw b-fa-flag",
        onItem: e => {
          this.handleContextMenuEventItemClick(
            e,
            "Add Work Order to Grid (top pane)"
          );
        }
      };
      items[getDisplayValue(EVENTSTAG144, "Ranked Appointment Booking")] = {
        text: getDisplayValue(EVENTSTAG144, "Ranked Appointment Booking"),
        icon: "b-fa b-fa-fw b-fa-flag",
        onItem: e => {
          this.handleContextMenuEventItemClick(e, "Ranked Appointment Booking");
        }
      };
      return items;
    }
  };

  handleJDMDelete = (radioValue, laterValue, earlierValue, unAssignValue) => {
    const { eventId, eventStartDate, techId, workOrderId } = this.state;
    const { deleteJDMEvents, userTimezone } = this.props;
    let obj = {};

    if (radioValue === "single") {
      if (laterValue || earlierValue) {
        obj.EventStartDtTm = eventStartDate;
      }
      if (!laterValue && !earlierValue) {
        obj.deleteSingleEventId = eventId;
      }
      if (laterValue && earlierValue) {
        obj = {};
      }
      obj.eventId = eventId;
      obj.isUnassignTech = unAssignValue;
      obj.isEarlierEvents = earlierValue;
      obj.TechId = techId;
      obj.OwnerId = techId;
      obj.isDeleteAllEvents = false;
      obj.WorkOrderId = workOrderId;
      obj.timeZone = userTimezone.id;
    } else if (radioValue === "all") {
      obj = {};
      obj.eventId = eventId;
      obj.OwnerId = techId;
      obj.TechId = techId;
      obj.isUnassignTech = unAssignValue;
      obj.isDeleteAllEvents = true;
      obj.WorkOrderId = workOrderId;
      obj.timeZone = userTimezone.id;
    }
    deleteJDMEvents(obj);

    if (getSettingValue(DCON005_SET006) === "Enabled") {
      unScheduledDurationService.setSelectedWOId(workOrderId);
    }
  };

  refreshAgendaOffsets = eventData => {
    eventData.agenda.forEach(nestedEvent => {
      nestedEvent.startDate = new Date(nestedEvent.startDate);
      nestedEvent.endDate = new Date(nestedEvent.endDate);
      // Calculate offsets, more useful for rendering in case event is dragged to a new date
      nestedEvent.startOffset = moment(eventData.startDate).diff(
        nestedEvent.startDate,
        getSettingValue(DCON001_SET054).toLowerCase()
      );
      nestedEvent.endOffset = moment(nestedEvent.startDate).diff(
        nestedEvent.endDate,
        getSettingValue(DCON001_SET054).toLowerCase()
      );
    });
  };

  handleEventRenderer = ({ eventRecord, tplData }) => {
    // getCoordinateFromDate gives us a px value in time axis, subtract events left from it to be within the event
    const dateCorOrdinatFunction = this.engine.getCoordinateFromDate
      ? this.engine.getCoordinateFromDate
      : this.getCoordinateFromDate;
    const timeSpanCorOrdinatFunction = this.engine.getTimeSpanDistance
      ? this.engine.getTimeSpanDistance
      : this.getTimeSpanDistance;
    const dateToPx = date =>
      this.engine.getCoordinateFromDate(date) - tplData.left;
    const distanceToPx = (startDate, endDate) =>
      this.engine.getTimeSpanDistance(startDate, endDate);
    const { startDate, endDate } = eventRecord;
    const durationInMins = moment(endDate).diff(moment(startDate), "minutes");
    // Calculate coordinates for all nested events and put in an array passed on to eventBodyTemplate
    const records =
      eventRecord.agenda && eventRecord.agenda.length
        ? eventRecord.agenda
        : [eventRecord];
    this.refreshAgendaOffsets(eventRecord);
    return records.map(nestedEvent => {
      const { startDate, endDate } = nestedEvent;
      const nextedDuration = moment(endDate).diff(moment(startDate), "minutes");
      const width = Math.abs((nextedDuration / durationInMins) * 100).toFixed(
        2
      );
      return {
        //left: dateToPx(nestedEvent.startDate),
        /*width: distanceToPx(
          moment(nestedEvent.startDate),
          moment(nestedEvent.endDate)
        ),*/
        width,
        name: nestedEvent.name,
        color: nestedEvent.eventColor,
        startDate: nestedEvent.startDate,
        endDate: nestedEvent.endDate,
        isDriveStartTime: nestedEvent.isDriveStartTime,
        isDriveEndTime: nestedEvent.isDriveEndTime,
        isOverHeadStartTime: nestedEvent.isOverHeadStartTime,
        isOverHeadEndTime: nestedEvent.isOverHeadEndTime,
        isActualEvent: nestedEvent.isActualEvent,
        isHightLight: eventRecord.isHightLight,
        tplData,
        isOverNightStay: eventRecord.isOverNightStay
          ? eventRecord.isOverNightStay
          : eventRecord.data.isOverNightStay
      };
    });
  };

  handleEventBodyTemplate = values => {
    let rendererTemplate;
    let textColor = "#FFFFFF";
    const { viewState } = this.state;
    const borderSize = viewState % 100 === FILTER_TECHNICIAN_RESULT ? 3 : 1;
    let eventBorderColor = "#FFFFFF";
    if (values.length) {
      return values
        .map(event => {
          const {
            color,
            isDriveStartTime,
            left,
            width,
            isDriveEndTime,
            name,
            isOverHeadStartTime,
            isOverHeadEndTime,
            tplData,
            isHightLight,
            isOverNightStay,
            isActualEvent
          } = event;

          if (color) {
            if (lightOrDark(color) === "light") {
              textColor = "#000000";
              eventBorderColor = shadeColor(color, -30);
            } else {
              textColor = "#FFFFFF";
              eventBorderColor = shadeColor(color, 30);
            }
          }
          if (isDriveStartTime) {
            rendererTemplate = `<div class="SchedulerView__driveTimeStart" style="color: ${textColor};width: ${width}%;background-color: ${color}">${name}</div>`;
          } else if (isOverHeadStartTime) {
            rendererTemplate = `<div class="SchedulerView__events_overhead" style="color: ${textColor};width:${width}%;background-color: ${color}">${name}</div>`;
          } else if (isActualEvent) {
            rendererTemplate = `<div class="SchedulerView__events" style="color: ${textColor};width:${width}%;background-color: ${color};border: 1px solid ${eventBorderColor}">${name}</div>`;
          } else if (isOverHeadEndTime) {
            rendererTemplate = `<div class="SchedulerView__events_overhead" style="color: ${textColor};width:${width}%;background-color: ${color}">${name}</div>`;
          } else if (isDriveEndTime) {
            rendererTemplate = `<div class="SchedulerView__driveTimeEnd" style="color: ${textColor};width: ${width}%;background-color: ${color}">${name}</div>`;
          } else if (isOverNightStay) {
            rendererTemplate = `<div class="SchedulerView__overNightStay" style="color: ${textColor};width:${width}%;background-color: ${color}">${name}</div>`;
          } else {
            rendererTemplate = `<div class="SchedulerView__events" style="color: ${textColor};width:${width}%;background-color: ${color};border: 1px solid ${eventBorderColor}">${name}</div>`;
          }
          if (tplData && tplData.style) {
            event.tplData.style = "background-color: rgba(255,255,255, 0.1);";
            if (isHightLight) {
              event.tplData.style = `background-color: rgba(255,255,255, 0.1);border: ${borderSize}px solid ${"#0964b8"};box-shadow:0 0 5px ${"#0964b8"};`;
            }
          }
          return rendererTemplate;
        })
        .join("");
    }
    return (rendererTemplate = `<div class="SchedulerView__events" style="color: ${textColor};border: 1px solid ${eventBorderColor}">${values.name}</div>`);
  };

  getTechnicianColumns(selectedView) {
    const techCol = getUserSettingValue("tech_techCol");
    const otherColumns = getTechnicianColumn(techCol, selectedView);
    const nameColumn = [
      {
        editor: false,
        field: "name",
        headerRenderer: this.createStringComponent,
        htmlEncode: false,
        renderer: this.createStringTechComponent,
        enableHeaderContextMenu: false,
        sortable: true,
        type: "tree",
        parentContext: this,
        draggable: false,
        width: 210,
        locked: true,
        region: "locked",
        maxWidth: 410,
        minWidth: 210
      }
    ];
    return nameColumn.concat(otherColumns);
  }

  handleSchedulerReference = e => {
    if (e) {
      this.engine = e.engine;
    }
  };

  handleModalClick = (action, eventRecord) => {
    const { confirmModal } = this.state;
    if (action === TAG069) {
      const { message } = confirmModal;
      switch (message) {
        default:
          console.log(action);
      }
    }
    if (eventRecord) {
      const { addWOtoGridTop } = this.props;
      const { data, WOId } = eventRecord;
      const { name } = data;
      addWOtoGridTop({ WOId, name });
    }
    this.setState({ confirmModal: false });
  };

  render() {
    const { eventActions, woInfo, submitForm } = this.props;
    const {
      confirmModal,
      contentMsg,
      eventData,
      editEventRecord,
      eventStartDate,
      eventEndDate,
      eventsVersion,
      header,
      isCreateEvent,
      isEdit,
      isNonWOCreateEvent,
      isEditNonWOCreateEvent,
      nonWOevenet,
      eventDragResourceRecord,
      resources,
      resourcesVersion,
      resourceTimeRangesdata,
      isDeleteEvent,
      isJDMDeleteEvent,
      isDayView,
      tagValue,
      dayViewEventRecord,
      dayViewStartDate,
      dayViewEndDate,
      dayViewResourceRecord,
      schedulerSelectedTech,
      selectedIndex,
      isResizeEvent,
      isNonWoDragEvent,
      editEventResourceRecord,
      isAssignToTree,
      alreadyAssigned
    } = this.state;
    const columns = this.getTechnicianColumns(selectedIndex);
    const columnContainerWidth = columns.length === 1 ? 210 : 410;
    const { chageFormField } = this.props;
    const self = this;

    const highlightTechColor = getUserSettingValue("tech_eventRowColor");
    const timeLineColor = getUserSettingValue(TECH_TIMEINDICATOR_COLOR);
    const showTimeIndicator = JSON.parse(
      getUserSettingValue(TECH_SHOWTIME_INDICATOR, true)
    );
    let cssStyles = null;
    if (showTimeIndicator) {
      cssStyles = `--timeLine-display: block; --timeline-color: ${convertUint2Hex(
        timeLineColor
      )}; --highlight-tech: ${convertUint2Hex(highlightTechColor)}`;
    } else {
      cssStyles = `--timeLine-display: none; --highlight-tech: ${convertUint2Hex(
        highlightTechColor
      )}`;
    }

    return (
      <div className="SchedulerView">
        <Scheduler
          columns={columns}
          autoTree
          tree
          features={this.featuresObj}
          zoomOnMouseWheel={false}
          rowHeight={30}
          resourceMargin={4}
          barMargin={4}
          enableDeleteKey={false}
          emptyText=""
          style={cssStyles}
          subGridConfigs={{
            locked: {
              width: columnContainerWidth,
              maxWidth: 410,
              minWidth: 210
            }
          }}
          presets={getSupportedPresets()}
          viewPreset="hourAndDay-56by60"
          createEventOnDblClick={false}
          onCellClick={e => this.handleCellMouseClick(e)}
          resources={resources}
          resourcesVersion={resourcesVersion}
          eventsVersion={eventsVersion}
          ref={this.handleSchedulerReference}
          resourceTimeRanges={resourceTimeRangesdata}
          eventRenderer={this.handleEventRenderer}
          eventBodyTemplate={this.handleEventBodyTemplate}
        />
        {confirmModal && (
          <Modal
            isOpen={confirmModal}
            onClose={() => this.setState({ confirmModal: false })}
            zIndex={9003}
          >
            <ModalHeader title={getDisplayValue(TAG183)} />
            <ModalContent className="slds-p-around--small">
              {getDisplayValue(confirmModal.message)}
            </ModalContent>
            <ModalFooter
              className={
                confirmModal.options.length === 1
                  ? "ConfirmModal__options-center"
                  : ""
              }
            >
              {confirmModal.options.length === 1 && (
                <Button
                  type="brand"
                  label={getDisplayValue(confirmModal.options[0].ok)}
                  onClick={() =>
                    this.handleModalClick(
                      confirmModal.options[0].ok,
                      confirmModal.eventRecord || null
                    )
                  }
                />
              )}
            </ModalFooter>
          </Modal>
        )}
        {isNonWOCreateEvent && (
          <NonWoCreateEventModal
            {...this.props}
            createEventCompleted={this.updateEventOnComplete}
            editEventCompleted={this.updateEventOnComplete}
            isOpen={isNonWOCreateEvent}
            isEditNonWOCreateEvent={isEditNonWOCreateEvent}
            onClose={this.handleHide}
            eventRecord={nonWOevenet}
            eventActions={eventActions}
            submitForm={submitForm}
            onSchedulerSelectedTech={schedulerSelectedTech}
            selectedIndex={selectedIndex}
            isResizeEvent={isResizeEvent}
          />
        )}
        {isNonWoDragEvent && (
          <NonWoDragEventModal
            eventRecord={nonWOevenet}
            resourceRecord={eventDragResourceRecord}
            editEventCompleted={this.updateEventOnComplete}
            eventActions={eventActions}
            header={TAG183}
            isOpen={isNonWoDragEvent}
            onClose={this.handleHide}
            tagValue={TAG118}
            isResizeEvent={isResizeEvent}
          />
        )}
        {(isCreateEvent || isEdit) && (
          <CreateEditEventModal
            {...this.props}
            chageFormField={chageFormField}
            createEventCompleted={this.updateEventOnComplete}
            editWoEveventComplete={this.updateEventOnComplete}
            header={header}
            isCreateEvent={isCreateEvent}
            isOpen={isCreateEvent || isEdit}
            onClose={this.handleHide}
            eventData={isCreateEvent ? eventData : editEventRecord}
            editEventResourceRecord={editEventResourceRecord}
            isResizeEvent={isResizeEvent}
            woInfo={woInfo}
            eventActions={eventActions}
            submitForm={submitForm}
            removeEventsFromScheduler={this.removeEventsFromScheduler}
            selectedIndex={selectedIndex}
          />
        )}

        {isDeleteEvent && (
          <DeleteEventModal
            isOpen={isDeleteEvent}
            onClose={this.handleHide}
            tagValue={tagValue}
            handleDeleteConfirmation={this.handleDeleteConfirmation}
          />
        )}
        {isJDMDeleteEvent && (
          <JDMDeleteEventModal
            eventStartDate={eventStartDate}
            isOpen={isJDMDeleteEvent}
            onClose={this.handleHide}
            onDelete={this.handleJDMDelete}
          />
        )}
        {isDayView && (
          <DayViewModal
            isOpen={isDayView}
            onClose={this.handleDayViewClose}
            onDayViewEventEdit={this.handleDayViewEventEdit}
            tagValue={tagValue}
            dayViewEventRecord={dayViewEventRecord}
            dayViewStartDate={dayViewStartDate}
            dayViewEndDate={dayViewEndDate}
            dayViewResourceRecord={dayViewResourceRecord}
            resourcesVersion={resourcesVersion}
            eventsVersion={eventsVersion}
          />
        )}
        {isAssignToTree && (
          <Modal
            isOpen={isAssignToTree}
            onClose={() => this.setState({ isAssignToTree: false })}
            zIndex={9003}
          >
            <ModalHeader title={getDisplayValue(TAG183)} />
            <ModalContent className="SchedulerView__content">
              {contentMsg}
            </ModalContent>
            <ModalFooter>
              <Fragment>
                {getSettingValue(DCON001_SET036) === "Disallow" && (
                  <Button
                    type="brand"
                    label={getDisplayValue(TAG069)}
                    onClick={() => this.setState({ isAssignToTree: false })}
                  />
                )}
                {(getSettingValue(DCON001_SET036) === "Allow" ||
                  getSettingValue(DCON001_SET036) === "Warn") && (
                  <Fragment>
                    <Button
                      type="brand"
                      label={getDisplayValue(TAG240)}
                      onClick={() => this.handleAssignConfirmation("yes")}
                    />
                    <Button
                      type="brand"
                      label={getDisplayValue(TAG241)}
                      onClick={() => this.handleAssignConfirmation("no")}
                    />
                    <Button
                      type="brand"
                      style={{ display: alreadyAssigned ? "inline" : "none" }}
                      label={getDisplayValue(TAG066)}
                      onClick={() => this.setState({ isAssignToTree: false })}
                    />
                  </Fragment>
                )}
              </Fragment>
            </ModalFooter>
          </Modal>
        )}
      </div>
    );
  }
}

SchedulerView.propTypes = propTypes;
SchedulerView.defaultProps = defaultProps;
export default SchedulerView;
