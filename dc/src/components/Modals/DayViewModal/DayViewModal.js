import React, { Component } from "react";
import ReactDOMServer from "react-dom/server";
import { cloneDeep } from "lodash";
import ReactTooltip from "react-tooltip";
import ResizePanel from "react-resize-panel";
import {
  Container,
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter,
  Button,
  Grid,
  GridRow,
  GridItem,
  Icon,
  Label,
  Scheduler
} from "@svmx/ui-components-lightning";
import { PropTypes } from "prop-types";
import {
  getDisplayValue,
  lightOrDark,
  getWOFieldValueFromApiName
} from "utils/DCUtils";
import {
  applyEventColorRule,
  LightenDarkenColor,
  shadeColor
} from "utils/ColorUtils";
import {
  getSettingValue,
  DCON005_SET003,
  DCON005_SET004,
  DCON001_SET054
} from "constants/AppSettings";
import {
  TAG011,
  TAG012,
  TAG462,
  EVENTSTAG088,
  TAG279,
  TAG325,
  TAG487,
  TAG082
} from "constants/DisplayTagConstants";
import { openPopUp } from "utils/MapUtils";
import { HOURS } from "constants/AppConstants";
import { getUserSettingValue } from "constants/UserSettingConstants";
import { getMinutesToHours } from "utils/DateTimeUtils";
import { stringToBoolean } from "utils/DCUtils";
import moment from "moment-timezone";
import classNames from "classnames/bind";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";
import style from "./DayViewModal.scss";

const cx = classNames.bind(style);

const defaultProps = {
  handleDeleteConfirmation: () => {},
  header: "Day View",
  isOpen: false,
  onClose: () => {},
  tagValue: ""
};

const propTypes = {
  handleDeleteConfirmation: PropTypes.func,
  header: PropTypes.string,
  isOpen: PropTypes.bool,
  onClose: PropTypes.func,
  tagValue: PropTypes.string
};

const DateHelper = window.bryntum.scheduler.DateHelper;

window.bryntum.scheduler.PresetManager.registerPreset("quaterAndHourDayView", {
  id: "quaterAndHourDayView",
  name: "quaterAndHourDayView",
  tickWidth: 35,
  rowHeight: 32,
  displayDateFormat: "HH:mm",
  shiftIncrement: 15,
  shiftUnit: "MINUTE",
  timeResolution: {
    unit: "MINUTE",
    increment: 15
  },
  defaultSpan: 24,
  mainHeaderLevel: 1,
  headers: [
    {
      unit: "MINUTE",
      increment: 15,
      dateFormat: "MMMM Do YYYY"
    },
    {
      unit: "day",
      align: "center",
      dateFormat: "ddd, MMM DD YY", // Jan 2017
      renderer: () => ""
    },
    {
      unit: "MINUTE",
      align: "center",
      dateFormat: "h:mm A",
      increment: 15,
      renderer: start => {
        if (start.getMinutes() === 0 && start.getHours() === 0)
          return DateHelper.format(start, "h A");
        if (start.getMinutes() === 0 && start.getHours() === 12)
          return DateHelper.format(start, "h A");
        return DateHelper.format(start, "h:mm");
      }
    }
  ]
});

window.bryntum.scheduler.PresetManager.registerPreset("halfAndHourDayView", {
  id: "halfAndHourDayView",
  name: "halfAndHourDayView",
  tickWidth: 35,
  rowHeight: 32,
  displayDateFormat: "HH:mm",
  shiftIncrement: 30,
  shiftUnit: "MINUTE",
  timeResolution: {
    unit: "MINUTE",
    increment: 30
  },
  defaultSpan: 12,
  mainHeaderLevel: 1,
  headers: [
    {
      unit: "MINUTE",
      increment: 30,
      dateFormat: "MMMM Do YYYY"
    },
    {
      unit: "day",
      align: "center",
      dateFormat: "ddd, MMM DD YY", // Jan 2017
      renderer: () => ""
    },
    {
      unit: "MINUTE",
      align: "center",
      dateFormat: "h:mm A",
      increment: 30,
      renderer: start => {
        if (start.getMinutes() === 0 && start.getHours() === 0)
          return DateHelper.format(start, "h A");
        if (start.getMinutes() === 0 && start.getHours() === 12)
          return DateHelper.format(start, "h A");
        return DateHelper.format(start, "h:mm");
      }
    }
  ]
});

/*window.bryntum.scheduler.PresetManager.registerPreset("halfAndHourDayView", {
  timeResolution: {
    unit: "MINUTE",
    increment: 30
  },
  defaultSpan: 1,
  mainHeaderLevel: 1,
  headers: [
    {
      unit: "hour",
      //increment: 1,
      dateFormat: "MMMM Do YYYY"
    },
    {
      unit: "MINUTE",
      align: "center",
      increment: 30,
      dateFormat: "ddd, MMM DD YY", // Jan 2017
      renderer: () => ""
    },
    {
      unit: "MINUTE",
      align: "center",
      dateFormat: "h:mm A",
      increment: 30,
      renderer: start => {
        if (start.getMinutes() === 0 && start.getHours() === 0)
          return DateHelper.format(start, "h A");
        if (start.getMinutes() === 0 && start.getHours() === 12)
          return DateHelper.format(start, "h A");
        return DateHelper.format(start, "h:mm");
      }
    }
  ],
  id: "halfAndHourDayView",
  name: "halfAndHourDayView",
  tickWidth: 20,
  rowHeight: 32,
  //tickHeight: 60,
  displayDateFormat: "HH:mm",
  shiftIncrement: 30,
  shiftUnit: "MINUTE"
  /* id: 'halfAndHourDayView',
  name: 'halfAndHourDayView',
  tickWidth: 35,
  rowHeight: 32,
  displayDateFormat: 'HH:mm',
  shiftIncrement: 30,
  shiftUnit: 'MINUTE',
  timeResolution: {
    unit: 'MINUTE',
    increment: 30,
  },
  defaultSpan: 24,
  mainHeaderLevel: 1,
  headers: [
    {
      unit: 'MINUTE',
      increment: 30,
      dateFormat: 'MMMM Do YYYY',
    },
    /* {
      unit: "day",
      align: "center",
      dateFormat: "ddd, MMM DD YY", // Jan 2017
      renderer: () => ""
    },
    {
      unit: 'MINUTE',
      align: 'center',
      dateFormat: 'h:mm A',
      increment: 30,
      renderer: start => {
        if (start.getMinutes() === 0 && start.getHours() === 0) return DateHelper.format(start, 'h A');
        if (start.getMinutes() === 0 && start.getHours() === 12) return DateHelper.format(start, 'h A');
        return DateHelper.format(start, 'h:mm');
      },
    },
  ], 
});*/

window.bryntum.scheduler.PresetManager.registerPreset("hourAndDayDayView", {
  id: "hourAndDayDayView",
  name: "hourAndDayDayView",
  tickWidth: 35,
  rowHeight: 32,
  displayDateFormat: "HH:mm",
  shiftIncrement: 1,
  shiftUnit: "HOUR",
  timeResolution: {
    unit: "HOUR",
    increment: 1
  },
  defaultSpan: 24,
  mainHeaderLevel: 1,
  headers: [
    {
      unit: "HOUR",
      increment: 1,
      dateFormat: "MMMM Do YYYY"
    },
    {
      unit: "day",
      align: "center",
      dateFormat: "ddd, MMM DD YY", // Jan 2017
      renderer: () => ""
    },
    {
      unit: "hour",
      align: "center",
      dateFormat: "h:mm A",
      increment: 1,
      renderer: start => {
        if (start.getHours() === 0 || start.getHours() === 12)
          return DateHelper.format(start, "h A");
        return DateHelper.format(start, "h:mm");
      }
    }
  ]
});

const allDayEventDiv = [
  {
    id: 0,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "0%"
  },
  {
    id: 1,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "4.16%"
  },
  {
    id: 2,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "8.33%"
  },
  {
    id: 3,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "12.48%"
  },
  {
    id: 4,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "16.64%"
  },
  {
    id: 5,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "20.80%"
  },
  {
    id: 6,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "24.49%"
  },
  {
    id: 7,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "29.12%"
  },
  {
    id: 8,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "33.28%"
  },
  {
    id: 9,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "37.44%"
  },
  {
    id: 10,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "41.60%"
  },
  {
    id: 11,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "45.76%"
  },
  {
    id: 12,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "49.92%"
  },
  {
    id: 13,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: true,
    marginLeft: "54.08%"
  },
  {
    id: 14,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: true,
    marginLeft: "58.24%"
  },
  {
    id: 15,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: true,
    marginLeft: "62.40%"
  },
  {
    id: 16,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "66.56%"
  },
  {
    id: 17,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "70.72%"
  },
  {
    id: 18,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "74.88%"
  },
  {
    id: 19,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "79.04%"
  },
  {
    id: 20,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "83.20%"
  },
  {
    id: 21,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "87.36%"
  },
  {
    id: 22,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "91.52%"
  },
  {
    id: 23,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "95.68%"
  },
  {
    id: 24,
    classNameForEvent: "containerDiv",
    classNameForExtendedEvent: "containerLastDiv",
    eventFound: false,
    marginLeft: "0%"
  }
];

const requiredPresetIds = {
  quaterAndHourDayView: 1,
  halfAndHourDayView: 1,
  hourAndDayDayView: 1
};

const modifiedPresets = window.bryntum.scheduler.PresetManager.records.filter(
  p => requiredPresetIds[p.id]
);

class DayViewModal extends Component {
  constructor(props) {
    super(props);
    const me = this;
    me.modelscheduler = React.createRef();
    // me.tooltipRef = React.createRef();
    // this.scheduler = React.createRef();
    // const {
    //  dayViewEventRecord,
    // } = this.props;
    // const { IsAllDayEvent } = dayViewEventRecord[0];
    this.state = {
      editEventRecord: {},
      zoomInDisabled: false,
      zoomOutDisabled: false,
      tickHeight: 30,
      schedulerEvents: [],
      eventsVersionState: 0,
      schedulerExtendedEvents: []
      // isAllDayEvent: IsAllDayEvent,
    };
    this.dayViewEventMap = {};
    this.zoomCount = 0;
    const showDelay = getUserSettingValue("tech_toolTipShowDelay");
    const hideDelay = getUserSettingValue("tech_toolTipHideDelay");
    this.toolTipEventClickInProgress = false;
    this.featuresObj = {
      cellEdit: false,
      group: false,
      eventResize: false,
      eventDrag: false,
      eventResize: {
        showTooltip: false
      },
      headerZoom: false,
      eventDrag: {
        showTooltip: false
      },
      resourceTimeRanges: false,
      eventDragCreate: false,
      scheduleTooltip: false,
      scheduleContextMenu: {
        items: {
          addEvent: false
        }
      },
      contextMenu: {
        processHeaderItems: () => false
      },
      eventContextMenu: {
        // Extra items for all events
        processItems: () => false
      },
      sort: false,
      stripe: false,
      timeRanges: {
        enableResizing: true,
        showCurrentTimeLine: false,
        showHeaderElements: true
      },
      eventTooltip: {
        hoverDelay: showDelay,
        hideDelay,
        align: "l-r",
        template: data => this.getTooltip(data)
        // listeners: {
        // beforeShow: e => this.handelToolTipForEvents(e)
        // }
      }
    };
  }

  handelToolTipForEvents = e => {
    const { source: tip } = e;
    const showOnClick = getUserSettingValue("tech_dataTipOnClick");
    const showOnClickBoolean = stringToBoolean(showOnClick);

    if (!showOnClickBoolean) {
      return true;
    }
    if (this.toolTipEventClickInProgress && showOnClickBoolean) {
      this.toolTipEventClickInProgress = false;
      return true;
    }
    return false;
  };

  componentDidMount() {
    this.handleCheckForExtendedEvent();
    // this.modelscheduler.zoomToLevel(this.zoomCount);
    // this.scheduler = React.createRef();
    // const { dayViewEventRecord } = this.props;
    // this.modelscheduler.eventStore.add(dayViewEventRecord);
    // this.modelscheduler.features.eventTooltip.tooltip.disabled = true;
    // this.modelscheduler.presets.add(viewSet);
    this.modelscheduler.features.eventTooltip.tooltip.on({
      innerHtmlUpdate: e => {
        const { source } = e;
        source.element.onclick = event =>
          this.handleEventContextToolTipItemClick(event, source);
      },
      // once: true,
      beforeShow: e => this.handelToolTipForEvents(e)
    });
  }

  handleCheckForExtendedEvent = () => {
    const { dayViewEventRecord } = this.props;
    const schedulerEvents = [];
    const schedulerExtendedEvents = [];
    dayViewEventRecord.map(item => {
      this.dayViewEventMap[item.id] = item;
      if (!item.isExtendedEvent) {
        schedulerEvents.push(item);
      } else {
        schedulerExtendedEvents.push(item);
      }
    });
    this.handleExtendedEvents(schedulerExtendedEvents);
    this.setState({
      schedulerEvents,
      eventsVersionState: 1,
      schedulerExtendedEvents
    });
  };

  validateStartDate = (date, dayViewDate) => {
    //get start of day using moment.js
    const now = moment(dayViewDate)
      .startOf("day")
      .toDate();
    if (date < now) {
      return true; //date is before today's date
    } else {
      return false; //date is today or some day forward
    }
  };

  validateEndDate = (date, dayViewDate) => {
    //get start of day using moment.js
    if (date > dayViewDate) {
      return true; //date is before today's date
    } else {
      return false; //date is today or some day forward
    }
  };

  handleExtendedEvents = extendedEvents => {
    const { dayViewStartDate, dayViewEndDate } = this.props;
    if (extendedEvents.length) {
      extendedEvents.map(item => {
        let marginFound = false;
        item.allDayEventDiv = cloneDeep(allDayEventDiv);
        const eStateDateTime = item.startDate.getHours();
        //const eEndDateTime = item.endDate.getHours();
        const eEndDateTime =
          item.endDate.getHours() === 0 ? 24 : item.endDate.getHours();
        //const startDate = dayViewStartDate.getHours();
        //const endDate = dayViewEndDate.getHours();
        const startDate = dayViewStartDate.getDate();
        const endDate = dayViewEndDate.getHours();
        let checkStartDate = this.validateStartDate(
          item.startDate,
          dayViewStartDate
        );
        let checkEndDate = this.validateEndDate(item.endDate, dayViewEndDate);
        item.width = "100%";
        item.allDayEventDiv.map(dayItem => {
          dayItem.eventFound = false;
          dayItem.startDateTime = item.startDate;

          if (item.isEventStartBefore) {
            item.marginLeft = dayItem.marginLeft;
            //item.width = dayItem.marginLeft;
            dayItem.eventFound = true;
            dayItem.name = item.name;
            marginFound = true;
          }
          if (dayItem.id === eEndDateTime) {
            //item.width = dayItem.marginLeft;
          }

          if (item.isEventStartBefore && dayItem.id === eEndDateTime) {
            if (checkStartDate && checkEndDate) {
              item.marginLeft = "0%";
              //item.width = "98.5%";
              item.isExtendedAllDayEvent = false;
            } else {
              if (eEndDateTime === 24) {
                item.width = "100%";
              } else {
                item.marginLeft = dayItem.marginLeft;
                item.width = dayItem.marginLeft;
              }
            }
            //item.marginLeft = dayItem.marginLeft;
            //item.width = dayItem.marginLeft;
            dayItem.eventFound = true;
            dayItem.name = item.name;
            marginFound = true;
          }
          //if (item.isMultiDayEvent) {
          // dayItem.eventFound = true;
          // dayItem.name = item.name;
          // marginFound = true;
          if (item.isEventEndAfter && dayItem.id === eStateDateTime) {
            if (eStateDateTime === 24) {
              item.width = "100%";
            } else {
              item.marginLeft = dayItem.marginLeft;
              //item.width = dayItem.marginLeft;
            }
            //item.marginLeft = dayItem.marginLeft;
            //item.width = dayItem.marginLeft;
            dayItem.eventFound = true;
            dayItem.name = item.name;
            marginFound = true;
          }
          /* if (item.isEventStartBefore && dayItem.id === eEndDateTime) {
            item.marginLeft = dayItem.marginLeft;
            dayItem.eventFound = true;
            dayItem.name = item.name;
            marginFound = true;
          }*/
          //} //else if (dayItem.id >= eStateDateTime && !item.isMultiDayEvent) {
          // dayItem.eventFound = true;
          // dayItem.name = item.name;
          //} else if (
          // dayItem.eventFound &&
          // !marginFound &&
          //!item.isMultiDayEvent
          //) {
          //  item.marginLeft = dayItem.marginLeft;
          //  marginFound = true;
          // } else {
          // }
        });
      });
    }
  };

  handleExtendedEventstest = extendedEvents => {
    const { dayViewStartDate, dayViewEndDate } = this.props;
    if (extendedEvents.length) {
      extendedEvents.map(item => {
        let marginFound = false;
        item.allDayEventDiv = cloneDeep(allDayEventDiv);
        const eStateDateTime = item.startDate.getHours();
        const eEndDateTime = item.endDate.getHours();
        const startDate = dayViewStartDate.getHours();
        const endDate = dayViewEndDate.getHours();
        item.allDayEventDiv.map(dayItem => {
          dayItem.eventFound = false;
          dayItem.startDateTime = item.startDate;
          if (item.isMultiDayEvent) {
            dayItem.eventFound = true;
            dayItem.name = item.name;
            marginFound = true;
            if (dayItem.id === eEndDateTime) {
              item.marginLeft = dayItem.marginLeft;
            }
          } else if (dayItem.id >= eStateDateTime && !item.isMultiDayEvent) {
            dayItem.eventFound = true;
            dayItem.name = item.name;
          } else if (
            dayItem.eventFound &&
            !marginFound &&
            !item.isMultiDayEvent
          ) {
            item.marginLeft = dayItem.marginLeft;
            marginFound = true;
          } else {
          }
        });
      });
    }
  };

  handleViewZoomIn = event => {
    this.modelscheduler.scrollToTop();
    this.modelscheduler.zoomIn();
  };

  handleViewZoomOut = event => {
    this.modelscheduler.scrollToTop();
    this.modelscheduler.zoomOut();
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
    const borderSize = 1;
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
            rendererTemplate = `<div class="SchedulerView__driveTimeStart" style="color: ${textColor};width:100%;height: ${width}%;background-color: ${color}">${name}</div>`;
          } else if (isOverHeadStartTime) {
            rendererTemplate = `<div class="SchedulerView__events_overhead" style="color: ${textColor};width:100%;height:${width}%;background-color: ${color}">${name}</div>`;
          } else if (isActualEvent) {
            rendererTemplate = `<div class="SchedulerView__events" style="color: ${textColor};width:100%;height:${width}%;background-color: ${color};border: 1px solid ${eventBorderColor}">${name}</div>`;
          } else if (isOverHeadEndTime) {
            rendererTemplate = `<div class="SchedulerView__events_overhead" style="color: ${textColor};width:100%;height:${width}%;background-color: ${color}">${name}</div>`;
          } else if (isDriveEndTime) {
            rendererTemplate = `<div class="SchedulerView__driveTimeEnd" style="color: ${textColor};width:100%;height: ${width}%;background-color: ${color}">${name}</div>`;
          } else if (isOverNightStay) {
            rendererTemplate = `<div class="SchedulerView__overNightStay" style="color: ${textColor};width:100%;height:${width}%;background-color: ${color}">${name}</div>`;
          } else {
            rendererTemplate = `<div class="SchedulerView__events" style="color: ${textColor};width:100%;height:${width}%;background-color: ${color};border: 1px solid ${eventBorderColor}">${name}</div>`;
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

  handleDoubleClick = (e, isResize = false) => {
    this.handleEventMouseOut();
    const { onDayViewEventEdit } = this.props;
    onDayViewEventEdit(e, isResize);
    // return false;
  };

  handleZoomChange = e => {
    /* this.setState({
      zoomInDisabled: this.zoomCount === zoomLevelsArr.length - 1,
      zoomOutDisabled: this.zoomCount === 0
    }); */
  };

  handleEventClick = ({ eventElement }) => {
    const showOnClick = getUserSettingValue("tech_dataTipOnClick");
    const showOnClickBoolean = stringToBoolean(showOnClick);
    if (showOnClickBoolean) {
      const tooltip = this.modelscheduler.features.eventTooltip.tooltip;
      this.toolTipEventClickInProgress = true;
      tooltip.activeTarget = eventElement;
      tooltip.showBy(eventElement);
      // tooltip.show();
    }
  };

  handleEventMouseOver = ({ eventElement }) => {
    const showOnClick = getUserSettingValue("tech_dataTipOnClick");
    const showOnClickBoolean = stringToBoolean(showOnClick);
    if (!showOnClickBoolean) {
      const tooltip = this.modelscheduler.features.eventTooltip.tooltip;
      tooltip.activeTarget = eventElement;
      tooltip.showBy(eventElement);
    }
  };

  handleEventMouseOut = () => {
    const tooltip = this.modelscheduler.features.eventTooltip.tooltip;
    tooltip.hide();
  };

  handleSchedulerReference = e => {
    if (e) {
      this.modelscheduler = e.engine;
    }
  };

  getTooltip = data => {
    const { eventRecord = {} } = data;
    const {
      description,
      durationInMinutes,
      isWorkOrder,
      startDateTime,
      subject
    } = eventRecord;
    const children = description
      ? description.split("\n").map(line => <div>{line}</div>)
      : [];
    const { height } = this.modelscheduler;
    if (isWorkOrder) {
      const { hoverFields = {} } = eventRecord;
      return ReactDOMServer.renderToString(
        <div className="SchedulerView__eventTooltip">
          <div className="SchedulerView__eventTooltip-header">
            <div className="SchedulerView__eventTooltip-htitle">
              {getDisplayValue(EVENTSTAG088)}
            </div>
            <div className="SchedulerView__eventTooltip-closeIcon">
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

          <div className="SchedulerView__eventTooltip-subHeader">
            <div className="SchedulerView__eventTooltip-layout">
              <div className="SchedulerView__subject">{subject}</div>
              <div>
                {moment(startDateTime).format(
                  getUserTimeSettings("dateTimeFormat")
                )}
              </div>
              {getSettingValue(DCON001_SET054) === HOURS && (
                <div>{this.getHours(durationInMinutes)}</div>
              )}
              {getSettingValue(DCON001_SET054) !== HOURS && (
                <div>{`${durationInMinutes} ${getDisplayValue(TAG082)}`}</div>
              )}
            </div>
            <div className="SchedulerView__eventTooltip-icons">
              <Grid>
                <GridRow>
                  <GridItem>
                    <figure>
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
                      <figcaption cursor="pointer">
                        {getDisplayValue(TAG279)}
                      </figcaption>
                    </figure>
                  </GridItem>
                </GridRow>
              </Grid>
            </div>
          </div>
          <Container
            style={{
              height:
                Object.keys(hoverFields).length > 10
                  ? `${height - 100}px`
                  : "auto"
            }}
            className="SchedulerView__eventTooltip-hoverRule"
          >
            {children}
            {this.renderHoverRules(hoverFields, height)}
          </Container>
        </div>
      );
    }

    const hasDescription = children.length > 0;
    return ReactDOMServer.renderToString(
      <div className="SchedulerView__eventTooltip">
        <div className="SchedulerView__eventTooltip-header">
          <div className="SchedulerView__eventTooltip-htitle">
            {getDisplayValue(EVENTSTAG088)}
          </div>
          <div className="SchedulerView__eventTooltip-closeIcon">
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
        <div className="SchedulerView__eventTooltip-subHeader">
          <div className="SchedulerView__eventTooltip-layout">
            <div>{subject}</div>
            <div>{startDateTime}</div>
            {getSettingValue(DCON001_SET054) === HOURS && (
              <div>{this.getHours(durationInMinutes)}</div>
            )}
            {getSettingValue(DCON001_SET054) !== HOURS && (
              <div>{`${durationInMinutes} ${getDisplayValue(TAG082)}`}</div>
            )}
          </div>
        </div>
        {hasDescription && (
          <Container
            style={{
              height:
                children.length > 10 ||
                (!children.length && description.length > 200)
                  ? `${height - 120}px`
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

  renderHoverRules = (hoverFields = {}) =>
    Object.keys(hoverFields).map(hoverField => {
      const hoverInfo = hoverFields[hoverField] || {};
      const { display, fieldValue } = hoverInfo;
      return (
        <div>
          <Label className="SchedulerView__eventTooltip-hoverRuleItem">
            <b>{`${display} : `}</b> {fieldValue}
          </Label>
        </div>
      );
    });

  getHours = durationInMinutes => {
    const timeInHours = `${getMinutesToHours(durationInMinutes).replace(
      /:/g,
      getDisplayValue("TAG170")
    )} ${getDisplayValue("TAG082")}`;
    const minutes = `00 ${getDisplayValue("TAG082")}`;

    return timeInHours.replace(minutes, " ");
  };

  handleEventContextToolTipItemClick = (event, source) => {
    const { eventRecord } = source;
    if (event.target.id === "closeTooltipBtn") {
      source.hide();
    }
    if (event.target.id === "openRecordBtnId") {
      const { isWorkOrder, whatId } = eventRecord;
      if (isWorkOrder) {
        // const url = `/${id}?isdtp=mn`;
        openPopUp(whatId);
      }
    }
  };

  handleEditResize = e => {
    const { context } = e;
    context.async = true;
    const { eventRecord, resourceRecord } = context;
    eventRecord.resizeStartDate = context.startDate;
    eventRecord.resizeEndDate = context.endDate;
    // eventRecord.IsAllDayEvent=false;
    context.finalize(false);
    this.handleDoubleClick(context, true);
  };

  handleEditDrag = e => {
    const { context } = e;
    context.async = true;
    const { record: eventRecord, newResource: resourceRecord } = context;
    eventRecord.resizeStartDate = context.startDate;
    eventRecord.resizeEndDate = context.endDate;
    // eventRecord.IsAllDayEvent=false;
    const newContextObj = {};
    newContextObj.eventRecord = eventRecord;
    context.finalize(false);
    this.handleDoubleClick(newContextObj, true);
  };

  handleDivEventDoubleClick = e => {
    if (e) {
      const s = this.dayViewEventMap;
      const eventid = e.currentTarget.id;
      const selectedEvent = this.dayViewEventMap[eventid];
      if (selectedEvent) {
        const newContextObj = {};
        newContextObj.eventRecord = selectedEvent;
        this.handleDoubleClick(newContextObj);
      }
    }
  };

  getTooltipHover = (eventRecord, name) => {
    const {
      description,
      durationInMinutes,
      isWorkOrder,
      startDateTime,
      subject
    } = eventRecord;
    const children = description
      ? description.split("\n").map(line => <div>{line}</div>)
      : [];
    const { height } = this.modelscheduler;
    if (isWorkOrder) {
      const { hoverFields = {} } = eventRecord;
      return (
        <div className="SchedulerView__eventTooltip">
          <div className="SchedulerView__eventTooltip-header">
            <div className="SchedulerView__eventTooltip-htitle">
              {getDisplayValue(EVENTSTAG088)}
            </div>
            <div className="SchedulerView__eventTooltip-closeIcon">
              <Button
                id="closeTooltipBtn"
                type="icon-bare"
                size="small"
                align="center"
                name={name}
                onClick={this.handleItemsForAllDayHover}
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

          <div className="SchedulerView__eventTooltip-subHeader">
            <div className="SchedulerView__eventTooltip-layout">
              <div className="SchedulerView__subject">{subject}</div>
              <div>{startDateTime}</div>
              {getSettingValue(DCON001_SET054) === HOURS && (
                <div>{this.getHours(durationInMinutes)}</div>
              )}
              {getSettingValue(DCON001_SET054) !== HOURS && (
                <div>{`${durationInMinutes} ${getDisplayValue(TAG082)}`}</div>
              )}
            </div>
            <div className="SchedulerView__eventTooltip-icons">
              <Grid>
                <GridRow>
                  <GridItem>
                    <figure>
                      <Button
                        id="openRecordBtnId"
                        type="icon-bare"
                        size="large"
                        align="center"
                        onClick={e =>
                          this.handleItemsForAllDayHover(e, eventRecord)
                        }
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
                      <figcaption cursor="pointer">
                        {getDisplayValue(TAG279)}
                      </figcaption>
                    </figure>
                  </GridItem>
                </GridRow>
              </Grid>
            </div>
          </div>
          <Container
            style={{
              height:
                Object.keys(hoverFields).length > 10
                  ? `${height - 100}px`
                  : "auto"
            }}
            className="SchedulerView__eventTooltip-hoverRule"
          >
            {children}
            {this.renderHoverRules(hoverFields, height)}
          </Container>
        </div>
      );
    }

    const hasDescription = children.length > 0;
    return (
      <div className="SchedulerView__eventTooltip">
        <div className="SchedulerView__eventTooltip-header">
          <div className="SchedulerView__eventTooltip-htitle">
            {getDisplayValue(EVENTSTAG088)}
          </div>
          <div className="SchedulerView__eventTooltip-closeIcon">
            <Button
              id="closeTooltipBtn"
              type="icon-bare"
              size="small"
              align="center"
              name={name}
              onClick={this.handleItemsForAllDayHover}
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
        <div className="SchedulerView__eventTooltip-subHeader">
          <div className="SchedulerView__eventTooltip-layout">
            <div>{subject}</div>
            <div>{startDateTime}</div>
            {getSettingValue(DCON001_SET054) === HOURS && (
              <div>{this.getHours(durationInMinutes)}</div>
            )}
            {getSettingValue(DCON001_SET054) !== HOURS && (
              <div>{`${durationInMinutes} ${getDisplayValue(TAG082)}`}</div>
            )}
          </div>
        </div>
        {hasDescription && (
          <Container
            style={{
              height:
                children.length > 10 ||
                (!children.length && description.length > 200)
                  ? `${height - 120}px`
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

  handleItemsForAllDayHover = (e, eventRecord) => {
    if (e.target.id === "closeTooltipBtn") {
      this.tooltip[e.target.name].tooltipRef = null;
      this.tooltip[e.target.name].hideTooltip();
    }
    if (e.target.id === "openRecordBtnId") {
      const { isWorkOrder, whatId } = eventRecord;
      if (isWorkOrder) {
        // const url = `/${id}?isdtp=mn`;
        openPopUp(whatId);
      }
    }
  };

  handleDivResize = (e, event) => {
    if (e._targetInst.elementType === "span") {
      const containerWidth = document.getElementById("resizeContainerId")
        .offsetWidth;
      const containerZoomWidth = document.getElementById(
        "resizeZoomContainerId"
      ).offsetWidth;
      const availableStartDragWidth =
        e.currentTarget.children[0].children[1].offsetLeft - containerZoomWidth;
      // const availableEndDragWidth =
      //  e.currentTarget.children[3].children[1].offsetLeft - containerZoomWidth;

      const hourWidth = containerWidth / 24;

      const hourStartOffset = availableStartDragWidth / hourWidth;
      // const hourEndOffset = availableEndDragWidth / hourWidth;
      const roundedStartHours = Math.ceil(hourStartOffset);
      // let roundedEndHours = Math.ceil(hourEndOffset);
      // if (roundedEndHours === 24) {
      // roundedEndHours = 23;
      // }

      const { dayViewResourceRecord } = this.props;
      const context = {};

      // const startDate = event.startDateTime;
      // const endDate = event.endDateTime;
      const startDate = new Date(event.startDateTime);
      startDate.setHours(roundedStartHours, 0, 0, 0);
      const endDate = new Date(event.endDateTime);
      // endDate.setHours(roundedEndHours, 0, 0, 0);
      event.resizeStartDate = startDate;
      event.resizeEndDate = endDate;
      event.IsAllDayEvent = false;
      context.eventRecord = event;
      context.resourceRecord = dayViewResourceRecord;
      // event.resizeStartDate = context.startDate;
      // event.resizeEndDate = context.endDate;
      this.handleDoubleClick(context, true);
    }
  };

  handleToolTipHideGlobal = e => {
    let overAllToolTip = Object.keys(this.tooltip);
    overAllToolTip.map(item => {
      if (item !== e) {
        this.tooltip[item].tooltipRef = null;
        this.tooltip[item].hideTooltip();
      }
    });
    //this.tooltip[e.target.name].tooltipRef = null;
    //this.tooltip[e.target.name].hideTooltip();
  };

  handleAllDayExtendedEventHover = schedulerExtendedEvents => {
    const showOnClick = getUserSettingValue("tech_dataTipOnClick");
    const showOnClickBoolean = stringToBoolean(showOnClick);
    return schedulerExtendedEvents.map((dist, i) => {
      let marginFound = false;
      this.tooltip = {};
      let textColor;
      let eventBorderColor;
      if (lightOrDark(dist.eventColor) === "light") {
        textColor = "#000000";
        eventBorderColor = shadeColor(dist.eventColor, -30);
      } else {
        textColor = "#FFFFFF";
        eventBorderColor = shadeColor(dist.eventColor, 30);
      }
      if (showOnClickBoolean) {
        return (
          <div className={cx("container")}>
            <div
              className={cx("body")}
              id="initialDrag"
              onClick={dataTip => this.handleDivResize(dataTip, dist)}
            >
              <ResizePanel
                direction="e"
                style={{
                  width: dist.marginLeft
                }}
              >
                <div className={cx("sidebar", "panel")} />
              </ResizePanel>
              {dist.allDayEventDiv.map(distItem => {
                if (distItem.eventFound && !marginFound) {
                  marginFound = true;
                  return (
                    <div
                      className={
                        dist.isExtendedAllDayEvent
                          ? distItem.classNameForEvent
                          : distItem.classNameForExtendedEvent
                      }
                      style={{
                        //marginLeft: distItem.marginLeft,
                        backgroundColor: dist.eventColor,
                        //width: "98.5%",
                        width: dist.width,
                        border: `1px solid${eventBorderColor}`
                        // height: "100%"
                      }}
                      id={dist.id}
                      onDoubleClick={e => {
                        this.handleDivEventDoubleClick(e);
                      }}
                      data-for={`soclose${i}`}
                      data-tip=""
                      data-place="right"
                      data-multiline="true"
                      data-type="light"
                    >
                      <span
                        className="AllDayEventSubject"
                        style={{
                          color: textColor
                        }}
                      >
                        {`${moment(distItem.startDateTime).format(
                          getUserTimeSettings("timeFormat")
                        )} ${distItem.name}`}
                      </span>
                    </div>
                  );
                }
              })}
              <ReactTooltip
                ref={el => (this.tooltip[`soclose${i}`] = el)}
                id={`soclose${i}`}
                getContent={dataTip =>
                  this.getTooltipHover(dist, `soclose${i}`)
                }
                afterShow={e => this.handleToolTipHideGlobal(`soclose${i}`)}
                effect="solid"
                globalEventOff="click"
                event="click"
                delayHide={50}
                // delayShow={500}
                delayUpdate={500}
                place="right"
                type="light"
              />
            </div>
          </div>
        );
      }
      return (
        <div className={cx("container")}>
          <div
            className={cx("body")}
            id="initialDrag"
            onClick={dataTip => this.handleDivResize(dataTip, dist)}
          >
            <ResizePanel
              direction="e"
              style={{
                width: dist.marginLeft
              }}
            >
              <div className={cx("sidebar", "panel")} />
            </ResizePanel>
            {dist.allDayEventDiv.map(distItem => {
              if (distItem.eventFound && !marginFound) {
                marginFound = true;
                return (
                  <div
                    className={
                      dist.isExtendedAllDayEvent
                        ? distItem.classNameForEvent
                        : distItem.classNameForExtendedEvent
                    }
                    style={{
                      // marginLeft: distItem.marginLeft,
                      backgroundColor: dist.eventColor,
                      //width: "98.5%",
                      width: dist.width,
                      border: `1px solid${eventBorderColor}`
                      // height: "100%"
                    }}
                    id={dist.id}
                    onDoubleClick={e => {
                      this.handleDivEventDoubleClick(e);
                    }}
                    data-for={`soclose${i}`}
                    data-tip=""
                    data-place="right"
                    data-multiline="true"
                    data-type="light"
                  >
                    <span
                      className="AllDayEventSubject"
                      style={{
                        color: textColor
                      }}
                    >
                      {distItem.name}
                    </span>
                  </div>
                );
              }
            })}
            <ReactTooltip
              ref={el => (this.tooltip[`soclose${i}`] = el)}
              id={`soclose${i}`}
              getContent={dataTip => this.getTooltipHover(dist, `soclose${i}`)}
              effect="solid"
              afterShow={e => this.handleToolTipHideGlobal(`soclose${i}`)}
              // globalEventOff={showOnClick ? "click" : {}}
              // event={showOnClick ? "click" : {}}
              delayHide={50}
              // delayShow={500}
              delayUpdate={500}
              place="right"
              type="light"
            />
            <ResizePanel direction="w" id="finalDrag">
              <div className={cx("sidebar", "panel")} />
            </ResizePanel>
          </div>
        </div>
      );
    });
  };

  handleOnClose = () => {
    const { onClose } = this.props;
    onClose();
    // if (this.modelscheduler.destroy) {
    //   this.modelscheduler.destroy();
    //  }
    // onClose();
  };

  render() {
    const {
      isOpen,
      onClose,
      tagValue,
      dayViewEventRecord,
      dayViewResourceRecord,
      resourcesVersion,
      eventsVersion,
      dayViewStartDate,
      dayViewEndDate
    } = this.props;
    const {
      zoomInDisabled,
      zoomOutDisabled,
      tickHeight,
      schedulerEvents,
      eventsVersionState,
      schedulerExtendedEvents
    } = this.state;
    // const startDate = new Date(dayViewEventRecord[0].startDate);
    // startDate.setHours(0, 0, 0, 0);
    // const endDate = new Date(dayViewEventRecord[0].startDate);
    // endDate.setHours(23, 59, 0, 0);
    const startDate = new Date(dayViewStartDate);
    const endDate = new Date(dayViewEndDate);
    // endDate.setDate(endDate.getDate() + 1);

    return (
      <Modal size="regular" isOpen={isOpen} onClose={this.handleOnClose}>
        <ModalHeader title={dayViewResourceRecord[0].name} />
        <ModalContent className="DayViewModal__content">
          <GridRow className="DayViewModal_gridRow">
            <GridItem className="DayViewModal_gridFirstItem" noFlex>
              <Button
                className="DayViewModal_grid_Button"
                type="icon-border"
                size="medium"
                isDisabled={zoomInDisabled}
                title={getDisplayValue(TAG011)}
                onClick={this.handleViewZoomIn}
              >
                <Icon icon="zoomin" type="utility" />
              </Button>
            </GridItem>
            <GridItem className="DayViewModal_gridSecondItem">
              <Label>{moment(startDate).format("dddd, MMMM DD")}</Label>
            </GridItem>
          </GridRow>
          <GridRow className="DayViewModal_gridRow">
            <GridItem className="DayViewModal_gridFirstItem" noFlex>
              <Button
                className="DayViewModal_grid_Button"
                id="resizeZoomContainerId"
                type="icon-border"
                size="medium"
                isDisabled={zoomOutDisabled}
                title={getDisplayValue(TAG012)}
                onClick={this.handleViewZoomOut}
              >
                <Icon icon="zoomout" type="utility" />
              </Button>
            </GridItem>
            <GridItem
              id="resizeContainerId"
              className="DayViewModal_gridAllDayItem"
            >
              {this.handleAllDayExtendedEventHover(schedulerExtendedEvents)}
            </GridItem>
          </GridRow>
          <Scheduler
            className="DayView_schedulerView"
            features={this.featuresObj}
            ref={this.handleSchedulerReference}
            listeners={{
              beforeEventEdit: this.handleDoubleClick,
              zoomChange: this.handleZoomChange,
              eventClick: this.handleEventClick,
              // eventMouseOver: this.handleEventMouseOver,
              beforeEventResizeFinalize: this.handleEditResize,
              beforeeventdropfinalize: this.handleEditDrag,
              presetChange({ from, to }) {
                // combo.value = to;
                // To disable buttons based on zoom levels use this code:
                // zoomOut.disabled = level <= 0;
                // zoomIn.disabled = level >= this.presets.length - 1;
                // To disable buttons based on presets in combo use this code:
                // const index = combo.store.indexOf(combo.record);
                // zoomOut.disabled = index === 0;
                // zoomIn.disabled = index === combo.store.count - 1;
              }
            }}
            mode="vertical"
            minHeight="20em"
            startDate={startDate}
            endDate={endDate}
            viewPreset="hourAndDayDayView"
            columns={[
              {
                text: "Name",
                field: "name",
                hidden: true
              }
            ]}
            resourceColumns={{
              visible: false
            }}
            presets={modifiedPresets}
            createEventOnDblClick={false}
            autoAdjustTimeAxix={false}
            zoomKeepsOriginalTimespan
            events={schedulerEvents}
            eventsVersion={eventsVersionState}
            resources={dayViewResourceRecord}
            resourcesVersion={0}
            eventRenderer={this.handleEventRenderer}
            eventBodyTemplate={this.handleEventBodyTemplate}
          />
        </ModalContent>
        <ModalFooter className="DayViewModal__footer" />
      </Modal>
    );
  }
}

DayViewModal.propTypes = propTypes;
DayViewModal.defaultProps = defaultProps;

export default DayViewModal;
