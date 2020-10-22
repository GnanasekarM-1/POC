import React, { useEffect, useState } from "react";
import {
  Button,
  DataGrid,
  Grid,
  GridRow,
  GridItem,
  Icon,
  Label,
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter
} from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import { connect } from "react-redux";
import moment from "moment";
import { bindActionCreators } from "redux";
import {
  compact,
  difference,
  intersection,
  isEqual,
  remove,
  sortBy,
  uniqueId,
  isEmpty,
  sum,
  random,
  flatMap,
  groupBy,
  intersectionWith,
  intersectionBy
} from "lodash";
import {
  getDisplayValue,
  getFieldValue,
  getEventFieldUpdates
} from "utils/DCUtils";
import { toDateTime } from "utils/GridUtils";
import {
  EVENTSTAG014, // Schedule
  TAG050, // Technician
  TAG066, // Cancel
  TAG069, // OK
  TAG076, // Apply
  TAG102, // Start date should be less than end date
  TAG130, // An error occurred with the connection. Click on the icon for more details.
  TAG132, // Please enter a subject
  TAG157, // Multiple Assignments for Work Order:
  TAG172, // Please select one or more technicians
  TAG180, // Cannot assign Work Order to Territory
  TAG183, // Dispatch Console
  TAG188, // Status
  TAG199, // Creation of Events has not been enabled for the selected technician.
  TAG227, // Event subject is too long.
  TAG240, // YES
  TAG241, // NO
  TAG246, // DONE
  TAG347, // Do you want to add all the displayed technicians for the selected service team/territory?
  TAG348, // Do you want to delete the selected event(s)?
  TAG350, // Invalid event date time/duration:
  TAG351, // Start Date
  TAG352, // End Date
  TAG354, // Overlapping events:
  TAG357, // The selected technician(s) have already been assigned for the work order. Add another event?
  TAG360, // All unsaved changes including deletions will be rolled back. Are you sure to continue?
  TAG364, // Please select an owner for the Work Order
  TAG520, // Manage Multiple Assignment has been disabled due to JDM/LJS being enabled at workorder or group or org Settings
  EVENTSTAG149 // Total event duration must be a sum of drive time, overhead time, break time and service duration.
} from "constants/DisplayTagConstants";
import MultiAssignContainer from "containers/MultiAssignContainer";
import {
  DCON001_SET052,
  DCON001_SET057,
  DCON005_SET006,
  GLOB001_GBL025,
  DCON001_SET025,
  DCON001_SET064,
  DCON001_SET002,
  getSettingValue
} from "constants/AppSettings";
import {
  MINUTES,
  DATE_FORMAT,
  DATE_TIME_FORMAT,
  YODA_DATE_TIME_ZONE_24_HR_FORMAT
} from "constants/DateTimeConstants";
import {
  ID,
  NAME,
  NONE,
  IS_ACTIVE,
  TEAM_API_REF,
  TERRITORY_API_REF,
  TEAM_API_NAME,
  DISABLED,
  EVENT_START_TIME,
  FALSE,
  WO_SCHEDULING_OPTIONS,
  WO_SERVICE_DURATION_FIELD,
  MULTI_ASSIGN_READ_ONLY,
  TECH_ENABLE_SCHEDULING_FIELD,
  WORKORDER_TECHNICIAN_API_NAME,
  WORKORDER_TECHNICIAN_API_REF,
  TECH_SALESFORCE_USER_INFO,
  EMPTY_TECHNICIAN_LIST,
  CONTINUE_WITHOUT_ADDING,
  SALESFORCE_EVENT,
  DURATION,
  DOUBLE_BOOKING_ALLOW,
  WO_PREFERRED_START_TIME
} from "constants/AppConstants";
import {
  API_DATA_LOADED,
  API_INVOKED,
  API_ERRORED,
  KEY_EVENT_SUBJECT,
  KEY_WORKORDER_EVENTS,
  KEY_MULTIASSIGN_EVENTS
} from "constants/ActionConstants";
import { multiAssignActions } from "actions/EventsAction";
import LoadIndicator from "components/Modals/AdvTechSearchModal/LoadIndicator";
import WorkOrderFieldUpdate from "components/MultiAssign/WorkOrder/WorkOrderFieldUpdate";
import EditEventSchedule from "components/MultiAssign/WorkOrder/EditEventSchedule";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";
import { COLORS_BY_GROUPS, COLOR_GROUP_NAMES } from "utils/ColorUtils";

import "./MultipleAssignmentModal.scss";

const mapStateToProps = ({
  eventsData,
  gridState,
  metaData,
  schedulerState,
  technicianData,
  userSettings
}) => {
  const { technicians } = technicianData;
  const { data } = technicians;
  const {
    teamIds,
    technicians: woTechnicians,
    territoryList,
    teamView: fullTeamView,
    territoryView: fullTerritoryView
  } = data;
  const { row: selectedWO } = gridState;
  const { technicianFields } = metaData;
  const { content: techFields } = technicianFields || {};
  const {
    workorderEvents = {},
    getEventSubject,
    multiAssignEvents
  } = eventsData;
  const {
    newViewState,
    activeView: selectedIndex,
    eventsStartDate,
    teamView,
    territoryView
  } = schedulerState;
  const { data: woEvents = [], status = {} } = workorderEvents;
  const { api, errorCode, message } = status;
  return {
    eventsStartDate,
    eventSubject:
      (getEventSubject && getEventSubject.data) ||
      (selectedWO && selectedWO.Name) ||
      NONE,
    multiAssignEvents,
    newViewState,
    selectedIndex,
    selectedWO,
    teamIds,
    teamView,
    techFields,
    territoryView,
    fullTerritoryView,
    technicians: woTechnicians,
    territoryList,
    userSettings,
    fullTeamView,
    workorderEvents:
      api === API_DATA_LOADED || api === API_ERRORED
        ? woEvents || []
        : undefined,
    woEventReqError: api === API_ERRORED ? { errorCode, message } : undefined
  };
};

const mapDispatchToProps = dispatch => ({
  ...bindActionCreators(multiAssignActions(), dispatch)
});

const MultipleAssignmentModal = props => {
  const {
    open,
    isOpen,
    multiAssignEvents,
    cleanEventStore,
    selectedWO,
    selectedIndex,
    technicians,
    workorderEvents,
    eventSubject,
    eventsStartDate,
    woEventReqError,
    selectedTimeZone
  } = props;
  const [title, setTitle] = useState(eventSubject);
  const [isDisabled, setDisabled] = useState(false);
  const [allDayEvent, setAllDayEvent] = useState([]);
  const [isOwner, setOwner] = useState(undefined);
  const [ownerName, setOwnerName] = useState(undefined);
  const [requestEvents, setRequestEvents] = useState(false);
  const [requestMultiAssign, setRequestMultiAssign] = useState(false);
  const [eventLoaded, setEventLoaded] = useState(false);
  const [selectedRows, setSelectedRows] = useState([]);
  const [selection, setSelection] = useState([]);
  const [showPastEvents, setShowPastEvents] = useState(false);
  const [hasPastEvents, setHasPastEvents] = useState(false);
  const [techRows, setTechRows] = useState({});
  const [deletedEvents, setDeletedEvents] = useState([]);
  const [filterText, setFilterText] = useState([]);
  const [editEvent, setEditEvent] = useState(undefined);
  const [confirmModal, setConfirmModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [showUpdateModal, setShowUpdateModal] = useState(false);
  const [editFields, setEditFields] = useState({});
  const [subject, setSubject] = useState(eventSubject);
  const [schedulingError, setSchedulingError] = useState(false);
  const [errors, setErrors] = useState({});
  const [editError, setEditError] = useState(false);
  const [overLappingEvents, setOverLappingEvents] = useState({});
  const [overLappingEventColors, setOverLappingEventColors] = useState({});

  const tzDtFormatArr = selectedTimeZone.split("@");
  const userTImeZone = tzDtFormatArr[0];

  const dateTimeFormat = getUserTimeSettings("dateTimeFormat");
  const showDuration =
    getSettingValue(DCON001_SET064, "End Date Time") === DURATION;
  const allowDoubleBooking =
    getSettingValue(DCON001_SET025) === DOUBLE_BOOKING_ALLOW;

  let updateEvent;
  let colorCounter = COLOR_GROUP_NAMES.length - 1;

  const createEventRow = (
    id,
    techNode,
    duplicate,
    startDate,
    endDate,
    scheduledEvent,
    serviceDuration,
    beforeDriveTime,
    afterDriveTime,
    beforeOHTime,
    afterOHTime,
    breakTime,
    dayEvent,
    lstKeyValuePair,
    description = "",
    location = ""
  ) => {
    let teamName = getFieldValue(techNode, TEAM_API_NAME);
    const Id = getFieldValue(techNode, ID);
    const { technician_O: techObj } = technicians[Id] || {};
    const name = getFieldValue(techObj || techNode, NAME);
    const teamRefObj = getFieldValue(
      techNode,
      selectedIndex ? TERRITORY_API_REF : TEAM_API_REF
    );
    if (teamRefObj) {
      teamName = getFieldValue(teamRefObj, NAME);
    }
    const newId = duplicate ? uniqueId(`${Id}_`) : id || Id;
    const eventFields = getEventFieldUpdates(lstKeyValuePair);
    const fullDayEvent = dayEvent || allDayEvent.includes(newId);
    const newEndDateTime = fullDayEvent
      ? moment(endDate, DATE_TIME_FORMAT)
          .subtract(1, MINUTES)
          .format(DATE_TIME_FORMAT)
      : endDate;
    return {
      afterDriveTime,
      afterOHTime,
      beforeDriveTime,
      beforeOHTime,
      breakTime,
      dayEvent: fullDayEvent,
      endDate: newEndDateTime,
      id: newId,
      Id,
      isOwner: false,
      name,
      scheduledEvent,
      selected: false,
      serviceDuration,
      startDate,
      teamName,
      description,
      location,
      ...eventFields
    };
  };

  const getSchedulingErros = (selectedTechnicians = []) => {
    const schedulingErrors = {};
    let slno = 1;
    const isSaleforceEvent =
      getSettingValue(GLOB001_GBL025) === SALESFORCE_EVENT;
    selectedTechnicians.map(technician => {
      const enableScheduling = getFieldValue(
        technician,
        TECH_ENABLE_SCHEDULING_FIELD,
        false
      );
      const techSFInfo = getFieldValue(
        technician,
        TECH_SALESFORCE_USER_INFO,
        null
      );
      const isActive = techSFInfo
        ? getFieldValue(techSFInfo, IS_ACTIVE, false)
        : enableScheduling;
      const schedulingAllowed = isSaleforceEvent ? isActive : enableScheduling;
      if (!schedulingAllowed) {
        const { Id } = technician;
        const name = getFieldValue(technician, NAME, false);
        schedulingErrors[Id] = {
          Id,
          slno,
          name,
          isActive,
          enableScheduling
        };
        slno += 1;
      }
    });
    return schedulingErrors;
  };

  const onSelection = value => {
    if (isDisabled) {
      return;
    }
    const { length } = value;
    if (length) {
      const schedulingErros = getSchedulingErros(value);
      if (Object.keys(schedulingErros).length) {
        const warn = Object.keys(schedulingErros).length !== value.length;
        const content = {
          value,
          warn,
          message: TAG199,
          data: schedulingErros
        };
        if (warn) {
          content.yes = TAG240;
          content.no = TAG241;
        } else {
          content.ok = TAG069;
        }
        // Enable Scheduling Error
        setSchedulingError(true);
        setConfirmModal(content);
      } else if (intersectionBy(Object.values(techRows), value, ID).length) {
        setConfirmModal({
          message: TAG357,
          no: TAG241,
          value,
          yes: TAG240
        });
      } else if (length > 1 && !schedulingError) {
        setConfirmModal({
          message: TAG347,
          no: TAG241,
          value,
          yes: TAG240
        });
      } else {
        setSelection(value);
        setSchedulingError(false);
      }
    } else {
      setConfirmModal({
        message: getDisplayValue("TAG521", EMPTY_TECHNICIAN_LIST),
        ok: TAG069
      });
    }
  };

  const handleSearchChange = newData => {
    // Restore original technician events added through MMA
    if (isEmpty(newData.value) && sessionStorage.MMA) {
      const originalRows = JSON.parse(sessionStorage.MMA);
      // Update back filtered records, if there are any changes.
      Object.values(techRows).map(techRow => {
        const { id } = techRow;
        Object.assign(originalRows[id], techRow);
        return undefined;
      });
      // Remove records that might have been deleted after filtering
      deletedEvents.map(eventId => {
        delete originalRows[eventId];
        return undefined;
      });
      setTechRows(originalRows);
    }
    setFilterText(newData.value);
  };

  const handleRowSelection = id => {
    const newArray = [...selectedRows];
    if (newArray.includes(id)) {
      remove(newArray, item => item === id);
    } else {
      newArray.push(id);
    }
    setSelectedRows(newArray);
  };

  const handleSelectAllRows = ({ isChecked }) => {
    setSelectedRows(isChecked ? Object.keys(techRows) : []);
  };

  const handleDayEventSelection = id => {
    const newData = { ...techRows };
    const row = newData[id];
    const newArray = [...allDayEvent];
    if (newArray.includes(id)) {
      remove(newArray, item => item === id);
      row.dayEvent = false;
    } else {
      newArray.push(id);
      row.dayEvent = true;
    }
    const { id: eventId } = row;
    const newErrors = { ...errors };
    const newErrorMsg = validateAllDayChange(row);
    if (newErrorMsg) {
      newErrors[eventId] = newErrorMsg;
    } else {
      delete newErrors[eventId];
    }
    setErrors(newErrors);
    setAllDayEvent(newArray);
    setTechRows(newData);
  };

  const validateAllDayChange = event => {
    let errorMsg = null;
    const { dayEvent, startDate, endDate, name } = event;
    const endDateTime = dayEvent
      ? moment(endDate, DATE_TIME_FORMAT).endOf("day")
      : moment(endDate, DATE_TIME_FORMAT);
    const startDateTime = dayEvent
      ? moment(startDate, DATE_TIME_FORMAT).startOf("day")
      : moment(startDate, DATE_TIME_FORMAT);
    // Return proper error message if enddatetime is less than startdatetime.
    if (endDateTime.isSameOrBefore(startDateTime)) {
      errorMsg = `${
        dayEvent ? getDisplayValue(TAG102) : getDisplayValue(TAG350)
      } ${name} ${getDisplayValue(TAG351)} : ${moment(
        startDate,
        DATE_TIME_FORMAT
      ).format(dateTimeFormat)} ${getDisplayValue(TAG352)} : ${moment(
        endDate,
        DATE_TIME_FORMAT
      ).format(dateTimeFormat)}`;
      return errorMsg;
    }
    // Check if there are any scheduling related issues (SvcTime + Extra > or < (enddatetime - startdatetime))
    if (!dayEvent) {
      const serviceDuration = endDateTime.diff(startDateTime, MINUTES);
      const extraDuration = computeExtraDuration(event);
      if (serviceDuration - extraDuration <= 0) {
        errorMsg = `${getDisplayValue(EVENTSTAG149)} - ${name}`;
      }
    }
    return errorMsg;
  };

  const handleAllDayEvent = ({ isChecked }) => {
    setAllDayEvent(isChecked ? Object.keys(techRows) : []);
    const newErrors = { ...errors };
    const newData = { ...techRows };
    Object.keys(newData).map(item => {
      const row = newData[item];
      row.dayEvent = isChecked;

      // Check of scheduling issues.
      const { id } = row;
      const newErrorMsg = validateAllDayChange(row);
      if (newErrorMsg) {
        newErrors[id] = newErrorMsg;
      } else {
        delete newErrors[id];
      }
      return undefined;
    });
    setErrors(newErrors);
    setTechRows(newData);
  };

  const handleOwnerChange = owner => {
    setOwner(owner);
    setTechRows({ ...techRows });
  };

  const isRowSelected = id => selectedRows.includes(id);
  const isDayEvent = id => allDayEvent.includes(id);

  const handlePastEventChange = ({ isChecked }) => {
    setShowPastEvents(isChecked);
  };

  const handleRemoveRow = id => {
    setConfirmModal({
      id,
      message: TAG348,
      no: TAG241,
      yes: TAG240
    });
  };

  const handleFieldUpdates = () => {
    const { length } = selectedRows;
    if (length) {
      updateEvent = { ...techRows[selectedRows[length - 1]] };
      setEditEvent({ ...techRows[selectedRows[length - 1]] });
    }
    setShowUpdateModal(true);
  };

  const handleEditSchedule = () => {
    const { length } = selectedRows;
    if (length) {
      updateEvent = { ...techRows[selectedRows[length - 1]] };
      setEditEvent({ ...techRows[selectedRows[length - 1]] });
      setShowEditModal(true);
    }
  };

  const deleteEventRow = id => {
    if (selectedRows.includes(id)) {
      remove(selectedRows, item => item === id);
      setSelectedRows([...selectedRows]);
    }
    if (allDayEvent.includes(id)) {
      remove(allDayEvent, item => item === id);
      setAllDayEvent([...allDayEvent]);
    }
    if (isOwner === id) {
      setOwner(undefined);
      // const { Name = NONE } = getFieldValue(
      //   selectedWO,
      //   WORKORDER_TECHNICIAN_API_REF,
      //   {}
      // );
      setOwnerName(NONE);
    }

    const deletedRows = [...deletedEvents];
    const row = techRows[id];
    const { Id, scheduledEvent } = row;
    if (scheduledEvent) {
      deletedRows.push(id);
      setDeletedEvents(deletedRows);
    }

    const conflictingEvents = { ...overLappingEvents };
    const stackedEvents = conflictingEvents[Id];
    if (stackedEvents) {
      remove(stackedEvents, item => item === id);
      if (stackedEvents.length === 1) {
        delete conflictingEvents[Id];
      }
      setOverLappingEvents(conflictingEvents);
    }

    const newData = { ...techRows };
    delete newData[id];

    const newErrors = { ...errors };
    // Delete Scheduling error for removed technician event.
    delete newErrors[id];

    // Handle Subject Related Errors
    if (isEmpty(subject)) {
      newErrors[TAG132] = TAG132;
      delete newErrors[TAG227];
    } else if (subject.length > 80) {
      newErrors[TAG227] = TAG227;
      delete newErrors[TAG132];
    } else {
      delete newErrors[TAG132];
      delete newErrors[TAG227];
    }

    const { length } = Object.keys(newData);
    if (length) {
      delete newErrors[TAG172];
    } else {
      newErrors[TAG172] = TAG172;
    }
    setErrors(newErrors);
    setTechRows(newData);
  };

  const handleRemoveSelectedRows = () => {
    setConfirmModal({
      message: TAG348,
      no: TAG241,
      yes: TAG240
    });
  };

  const deleteEventRows = () => {
    let newData = { ...techRows };
    const deletedRows = [...deletedEvents];
    if (
      selectedRows.length === Object.values(techRows).length &&
      showPastEvents
    ) {
      newData = {};
      setAllDayEvent([]);
      setOwner(undefined);
      setOverLappingEvents({});
      selectedRows.map(row => {
        const techRow = techRows[row];
        const { scheduledEvent } = techRow;
        if (scheduledEvent) {
          deletedRows.push(row);
        }
        return undefined;
      });
      const { Name = NONE } = getFieldValue(
        selectedWO,
        WORKORDER_TECHNICIAN_API_REF,
        {}
      );
      setOwnerName(Name);
    } else {
      const conflictingEvents = { ...overLappingEvents };
      selectedRows.map(id => {
        if (allDayEvent.includes(id)) {
          remove(allDayEvent, item => item === id);
        }
        if (isOwner === id) {
          setOwner(undefined);
          const { Name = NONE } = getFieldValue(
            selectedWO,
            WORKORDER_TECHNICIAN_API_REF,
            {}
          );
          setOwnerName(Name);
        }
        const row = techRows[id];
        const { Id, scheduledEvent } = row;
        // Remove Overlapping Events
        const stackedEvents = conflictingEvents[Id];
        if (stackedEvents) {
          remove(stackedEvents, item => item === id);
          if (stackedEvents.length === 1) {
            delete conflictingEvents[Id];
          }
        }
        if (scheduledEvent) {
          deletedRows.push(id);
        }

        delete newData[id];
        return undefined;
      });
      setAllDayEvent([...allDayEvent]);
      setOverLappingEvents(conflictingEvents);
    }

    const newErrors = { ...errors };
    // Handle Subject Related Errors
    if (isEmpty(subject)) {
      newErrors[TAG132] = TAG132;
      delete newErrors[TAG227];
    } else if (subject.length > 80) {
      newErrors[TAG227] = TAG227;
      delete newErrors[TAG132];
    } else {
      delete newErrors[TAG132];
      delete newErrors[TAG227];
    }

    const { length } = Object.keys(newData);
    if (length) {
      delete newErrors[TAG172];
    } else {
      newErrors[TAG172] = TAG172;
    }
    setErrors(newErrors);
    setTechRows(newData);
    setSelectedRows([]);
    setDeletedEvents(deletedRows);
  };

  const showTechnicianEvents = () => {
    const newData = {};
    if (workorderEvents) {
      let ownerFound;
      const ownerId = getFieldValue(selectedWO, WORKORDER_TECHNICIAN_API_NAME);
      const allDayEvents = [...allDayEvent];
      workorderEvents.map(event => {
        const { event_WP: eventObj } = event;
        const {
          endDateTime,
          id,
          startDateTime,
          TechId,
          IsAllDayEvent,
          durationInMinutes,
          Driving_Time: beforeDriveTime,
          Driving_Time_Home: afterDriveTime,
          Overhead_Time_Before: beforeOHTime,
          Overhead_Time_After: afterOHTime,
          Break_Time_Total: breakTime,
          lstKeyValuePair,
          description,
          location
        } = eventObj;
        const { technician_O: techObj } = technicians[TechId] || {};
        if (techObj && new Date(endDateTime).getTime() > Date.now()) {
          // If WorkOrder Event is of AllDayEvent type, Add event id to allDayEvents Array to render it as AllDayEvent in UI.
          if (IsAllDayEvent && !allDayEvents.includes(id)) {
            allDayEvents.push(id);
          }
          newData[id] = createEventRow(
            id,
            techObj,
            false,
            toDateTime(startDateTime),
            toDateTime(endDateTime),
            true,
            parseInt(durationInMinutes, 10),
            parseInt(beforeDriveTime, 10),
            parseInt(afterDriveTime, 10),
            parseInt(beforeOHTime, 10),
            parseInt(afterOHTime, 10),
            parseInt(breakTime, 10),
            IsAllDayEvent,
            lstKeyValuePair,
            description,
            location
          );
        }
        // If Technician assigned to workorder has a future event, then display him as default owner.
        if (!ownerFound && ownerId === TechId) {
          ownerFound = id;
          let techName = NONE;
          if (techObj) {
            techName = getFieldValue(techObj, NAME, NONE);
          } else {
            const { Name = NONE } = getFieldValue(
              selectedWO,
              WORKORDER_TECHNICIAN_API_REF,
              {}
            );
            techName = Name;
          }
          setOwnerName(techName);
        }
        return undefined;
      });

      // Set the WorkOrder technician with future event as default owner
      if (ownerFound) {
        setOwner(ownerFound);
      } else {
        // In case if workorder has technician assigned, then we should keep
        const { technician_O: techObj } = technicians[ownerId] || {};
        if (techObj) {
          setOwnerName(getFieldValue(techObj, NAME, NONE));
        } else {
          const { Name = NONE } = getFieldValue(
            selectedWO,
            WORKORDER_TECHNICIAN_API_REF,
            {}
          );
          setOwnerName(Name);
        }
      }
      // Incase if there are any allDayEvent
      if (allDayEvents.length) {
        setAllDayEvent(allDayEvents);
      }
      // Incase if there are no pastEvents, Disable show Past Events.
      setHasPastEvents(workorderEvents.length !== Object.keys(newData).length);
      setTechRows(newData);
    }
    const newErros = { ...errors };
    if (isDisabled && !newErros[TAG520]) {
      newErros[TAG520] = TAG520;
      setErrors(newErros);
    } else {
      const { length } = Object.keys(newData);
      if (length) {
        delete newErros[TAG172];
      } else {
        newErros[TAG172] = TAG172;
      }
      setErrors(newErros);
    }
  };

  const isFilterableRow = (techObj = {}) => {
    // Filter all rows if there is no filter text
    if (isEmpty(filterText)) {
      return true;
    }
    let teamName = getFieldValue(techObj, TEAM_API_NAME);
    const techName = getFieldValue(techObj, NAME);
    const teamRefObj = getFieldValue(
      techObj,
      selectedIndex ? TERRITORY_API_REF : TEAM_API_REF
    );
    if (teamRefObj) {
      teamName = getFieldValue(teamRefObj, NAME);
    }
    const searchText = filterText.toLowerCase();
    return (
      teamName.toLowerCase().indexOf(searchText) !== -1 ||
      techName.toLowerCase().indexOf(searchText) !== -1
    );
  };

  const filterTechnicianEvents = () => {
    const newData = {};
    // Display already scheduled workorder events (Only Future Events, Future + Past based on user selection)
    // In case if user has deleted already scheduled events, don't show it later on in the grid.
    if (workorderEvents && workorderEvents.length !== deletedEvents.length) {
      let ownerFound;
      const ownerId = getFieldValue(selectedWO, WORKORDER_TECHNICIAN_API_NAME);
      const allDayEvents = [...allDayEvent];
      workorderEvents.map(event => {
        const { event_WP: eventObj } = event;
        const {
          endDateTime,
          id,
          startDateTime,
          TechId,
          IsAllDayEvent,
          durationInMinutes,
          Driving_Time: beforeDriveTime,
          Driving_Time_Home: afterDriveTime,
          Overhead_Time_Before: beforeOHTime,
          Overhead_Time_After: afterOHTime,
          Break_Time_Total: breakTime,
          lstKeyValuePair,
          description,
          location
        } = eventObj;
        // Ignore deleted technician events.
        if (!deletedEvents.includes(id)) {
          // If WorkOrder Event is of AllDayEvent type, Add event id to allDayEvents Array to render it as AllDayEvent in UI.
          if (IsAllDayEvent && !allDayEvents.includes(id)) {
            allDayEvents.push(id);
          }
          // Display Past Events + Future Events || only Future Events.
          const { technician_O: techObj } = technicians[TechId] || {};
          if (
            techObj &&
            (showPastEvents || new Date(endDateTime).getTime() > Date.now()) &&
            isFilterableRow(techObj)
          ) {
            const techRow = createEventRow(
              id,
              techObj,
              false,
              toDateTime(startDateTime),
              toDateTime(endDateTime),
              true,
              parseInt(durationInMinutes, 10),
              parseInt(beforeDriveTime, 10),
              parseInt(afterDriveTime, 10),
              parseInt(beforeOHTime, 10),
              parseInt(afterOHTime, 10),
              parseInt(breakTime, 10),
              IsAllDayEvent,
              lstKeyValuePair,
              description,
              location
            );
            newData[id] = techRow;
          }
          // If Technician assigned to workorder has a future event, then display him as default owner.
          if (!ownerFound && ownerId === TechId) {
            ownerFound = id;
            let techName = NONE;
            if (techObj) {
              techName = getFieldValue(techObj, NAME, NONE);
            } else {
              const { Name = NONE } = getFieldValue(
                selectedWO,
                WORKORDER_TECHNICIAN_API_REF,
                {}
              );
              techName = Name;
            }
            setOwnerName(techName);
          }
        }
        return undefined;
      });

      // Set the WorkOrder technician with past event as default owner, in case if there is no future events the selected workorder.
      if (ownerFound && !isOwner) {
        setOwner(ownerFound);
      }
      // Incase if there are any new past AllDayEvent, update the new State.
      if (difference(allDayEvents, allDayEvent).length) {
        setAllDayEvent(allDayEvents);
      }
    }

    // Show all the newly added workorder events at the end.
    const newAddedEvents = Object.values(techRows).filter(
      techRow => !techRow.scheduledEvent
    );
    newAddedEvents.map(row => {
      const { id, Id } = row;
      const { technician_O: techObj } = technicians[Id];
      if (isFilterableRow(techObj)) {
        newData[id] = row;
      }
      return undefined;
    });

    if (workorderEvents) {
      const newErros = { ...errors };
      if (Object.keys(newData).length) {
        delete newErros[TAG172];
      } else {
        newErros[TAG172] = TAG172;
      }
      setErrors(newErros);
    }
    setTechRows(newData);
  };

  const getStartDateTime = lastEvent => {
    if (lastEvent) {
      const { startDate } = lastEvent;
      return startDate;
    }
    const preferredStartTime = getFieldValue(
      selectedWO,
      WO_PREFERRED_START_TIME
    );

    if (preferredStartTime) {
      const preferredStartDate = moment(preferredStartTime, moment.ISO_8601)
        .tz(userTImeZone)
        .format(DATE_TIME_FORMAT);
      return moment(preferredStartDate, DATE_TIME_FORMAT).toDate();
    }

    // Default Start Time for Multi Assign Dialog Event
    const dateFormatted = `${moment(
      eventsStartDate,
      YODA_DATE_TIME_ZONE_24_HR_FORMAT
    ).format(DATE_FORMAT)}`;
    const timeFormatted = `${getSettingValue(
      DCON001_SET052,
      EVENT_START_TIME
    )} AM`;
    const dateTimeFormat = moment(
      `${dateFormatted} ${timeFormatted}`,
      DATE_TIME_FORMAT
    );
    return dateTimeFormat.toDate();
  };

  const getEndDateTime = lastEvent => {
    if (lastEvent) {
      const { endDate } = lastEvent;
      return endDate;
    }

    const endDateTime = new Date();
    const startDateTime = getStartDateTime(lastEvent);
    const serviceDuration = getFieldValue(
      selectedWO,
      WO_SERVICE_DURATION_FIELD,
      getSettingValue(DCON001_SET002) * 60
    );
    endDateTime.setTime(startDateTime.getTime() + serviceDuration * 1000);
    return endDateTime;
  };

  const isOverLappingEvent = (newEvent, existingEvents) => {
    // const COMPARE_FIELDS = [START_DATE, SERVICE_DURATION];
    return intersectionWith(existingEvents, newEvent, (e1, e2) => {
      // let isEqual = true;
      // COMPARE_FIELDS.forEach(field => {
      //   isEqual = e1[field] === e2[field];
      //   if (!isEqual) {
      //   }
      // });
      // return isEqual;
      const { startDate: startDate1, endDate: endDate1 } = e1;
      const { startDate: startDate2, endDate: endDate2 } = e2;
      return (
        new Date(startDate1).getTime() < new Date(endDate2).getTime() &&
        new Date(startDate2).getTime() < new Date(endDate1).getTime()
      );
    });
  };

  const addSelectedTechnicians = () => {
    if (selection.length) {
      const techData = { ...techRows };
      const lastRow = Object.values(techRows).pop();
      const {
        afterDriveTime = 0,
        afterOHTime = 0,
        beforeDriveTime = 0,
        beforeOHTime = 0,
        breakTime = 0,
        IsAllDayEvent = false
      } = lastRow || {};

      const techEventMap = groupBy(Object.values(techData), event => event.Id);

      const overLappingEvts = { ...overLappingEvents };
      sortBy(selection, [NAME]).map(techNode => {
        const { Id } = techNode;
        const endDateTime = toDateTime(getEndDateTime(lastRow));
        const startDateTime = toDateTime(getStartDateTime(lastRow));
        const serviceDuration = moment(endDateTime, DATE_TIME_FORMAT).diff(
          moment(startDateTime, DATE_TIME_FORMAT),
          MINUTES
        );
        const duplicate = techData[Id] !== undefined;
        const techRow = createEventRow(
          Id,
          techNode,
          duplicate,
          startDateTime,
          endDateTime,
          false,
          serviceDuration,
          beforeDriveTime,
          afterDriveTime,
          beforeOHTime,
          afterOHTime,
          breakTime,
          IsAllDayEvent
        );
        const { id } = techRow;
        if (techEventMap[Id]) {
          const overLappingEvent = isOverLappingEvent(
            [techRow],
            techEventMap[Id]
          );
          if (overLappingEvent.length) {
            let techIds = overLappingEvts[Id] || [];
            if (!techIds.length) {
              techIds = techIds.concat(
                flatMap(overLappingEvent, event => event.id)
              );
              overLappingEvts[Id] = techIds;
            }
            if (!techIds.includes(id)) {
              techIds.push(id);
            }
          }
        }
        techData[id] = techRow;
        return undefined;
      });

      // Set the first event technician as Owner, if there was no past & future scheduled events
      // const keys = Object.keys(techData);
      // if (!isOwner && !lastRow) {
      //   setOwner(keys[0]);
      //   setOwnerName(getFieldValue(techData[keys[0]], NAME, NONE));
      // }

      if (Object.keys(techData).length) {
        const newErros = { ...errors };
        delete newErros[TAG172];
        setErrors(newErros);
      }

      if (Object.keys(overLappingEvts).length) {
        setOverLappingEvents(overLappingEvts);
      }

      setSelection([]);
      setTechRows(techData);
      // Store event records after new additions, so that we need them to revert back after clear filter.
      sessionStorage.MMA = JSON.stringify(techData);
    }
  };

  const getOverLappingEventColor = () => {
    if (colorCounter <= 1) {
      colorCounter = COLOR_GROUP_NAMES.length - 1;
    }
    colorCounter -= 1;
    const colorGrpName = COLOR_GROUP_NAMES[colorCounter];
    const colorsByGroup = COLORS_BY_GROUPS[colorGrpName];
    return colorsByGroup[random(colorsByGroup.length - 1)].toLowerCase();
  };

  const displayOverLappingErrors = () => {
    const newErros = { ...errors };
    const overLappingColors = { ...overLappingEventColors };
    if (Object.keys(overLappingEvents).length) {
      let techNames = [];
      Object.keys(overLappingEvents).map(techId => {
        const { technician_O: techObj } = technicians[techId];
        if (techObj) {
          techNames.push(getFieldValue(techObj, NAME, null));
        }

        if (!overLappingColors[techId]) {
          const eventColor = getOverLappingEventColor();
          const assignedColor = Object.values(overLappingColors).includes(
            eventColor
          );
          overLappingColors[techId] = assignedColor
            ? getOverLappingEventColor()
            : eventColor;
        }
      });
      techNames = compact(techNames);
      if (techNames.length) {
        newErros[TAG354] = `${getDisplayValue(TAG354)} ${techNames.join()}`;
      } else {
        delete newErros[TAG354];
      }
    } else {
      delete newErros[TAG354];
    }
    const deletedRows = difference(
      Object.keys(overLappingColors),
      Object.keys(overLappingEvents)
    );
    if (deletedRows.length) {
      deletedRows.map(deletedRow => {
        delete overLappingColors[deletedRow];
        return undefined;
      });
    }
    setOverLappingEventColors(overLappingColors);
    setErrors(newErros);
  };

  useEffect(() => {
    const { getEventSubjectDefn, getWorkorderEvents } = props;
    // Make REST API to get all workorder events & Event subject.
    if (!requestEvents) {
      const { Id } = selectedWO;
      getWorkorderEvents(Id);
      // Apply Event Subject Rule Enabled
      const applyEventSubjectRule = JSON.parse(
        getSettingValue(DCON001_SET057, FALSE).toLowerCase()
      );
      if (applyEventSubjectRule) {
        getEventSubjectDefn(Id);
      }
      // JDM Status
      const JDMEnabled = getSettingValue(DCON005_SET006, DISABLED);
      const schedulingOptions = getFieldValue(
        selectedWO,
        WO_SCHEDULING_OPTIONS
      );
      const disabled =
        MULTI_ASSIGN_READ_ONLY.includes(JDMEnabled) &&
        MULTI_ASSIGN_READ_ONLY.includes(schedulingOptions);
      setDisabled(disabled);
      // In case of JDM/LJS enabled, display alert
      if (disabled) {
        setConfirmModal({
          message: TAG520,
          ok: TAG069
        });
      }
      setRequestEvents(!requestEvents);
    }

    // Once`events are loaded display technician events
    if (!eventLoaded && (workorderEvents || woEventReqError)) {
      showTechnicianEvents();
      setEventLoaded(true);
      if (woEventReqError) {
        setConfirmModal({
          details: { ...woEventReqError },
          message: TAG130,
          ok: TAG069
        });
      }
    }
    return () => {};
  });

  useEffect(() => {
    const { Name } = selectedWO || {};
    const value = isEmpty(eventSubject) ? Name || title : eventSubject;
    handleSubjectChange({ value });
    return () => {};
  }, [eventSubject]);

  useEffect(() => {
    if (selection.length) {
      addSelectedTechnicians();
    } else {
      filterTechnicianEvents();
    }
    return () => {};
  }, [selection, showPastEvents, filterText]);

  useEffect(() => {
    // if (!allowDoubleBooking) {
    displayOverLappingErrors();
    // }
    return () => {};
  }, [overLappingEvents]);

  useEffect(() => {
    if (multiAssignEvents) {
      const { status } = multiAssignEvents;
      const { api } = status;
      if (api === API_INVOKED) {
        setRequestMultiAssign(true);
        return;
      }
      setRequestMultiAssign(false);
      if (api === API_ERRORED) {
        const { message } = status;
        setConfirmModal({
          message,
          ok: TAG069
        });
        return;
      }
      isOpen(false);
      // setTimeout(() => isOpen(false), 0);
    }
    return () => {
      // Clear event records store & events returned during current launch.
      if (multiAssignEvents && multiAssignEvents.data) {
        delete sessionStorage.MMA;
        cleanEventStore([
          KEY_EVENT_SUBJECT,
          KEY_WORKORDER_EVENTS,
          KEY_MULTIASSIGN_EVENTS
        ]);
      }
    };
  }, [multiAssignEvents]);

  const handleClick = action => {
    if (action === TAG240) {
      const { id, message, value = [], data = [] } = confirmModal;
      switch (message) {
        case TAG360:
          cleanEventStore([
            KEY_EVENT_SUBJECT,
            KEY_WORKORDER_EVENTS,
            KEY_MULTIASSIGN_EVENTS
          ]);
          setConfirmModal(false);
          isOpen(false);
          break;

        case TAG347:
        case TAG357:
          setSchedulingError(false);
          setSelection(value);
          break;
        // Recursive call to check if technician's already exits
        case TAG199:
          // Added Hack to ensure that duplicate tech dialog appears if there are any.
          setTimeout(
            () => onSelection(value.filter(technician => !data[technician.Id])),
            300
          );
          break;
        case TAG348:
          if (id) {
            deleteEventRow(id);
          } else {
            deleteEventRows();
          }
          break;
        default:
          console.log(action);
      }
    }
    if (selection.length) {
      setSelection([]);
    }
    setConfirmModal(false);
  };

  const updateScheduleDate = (eventId, key, value) => {
    const newData = { ...techRows };
    const newEvent = newData[eventId];
    if (newEvent) {
      newEvent[key] = value;
      const { dayEvent, name, startDate, serviceDuration } = newEvent;
      let { endDate } = newEvent;
      const evtStartDate = key === START_DATE ? value : startDate;
      if (showDuration) {
        const duration = key === END_DATE ? value : serviceDuration;
        newEvent[END_DATE] = endDate = moment(startDate, DATE_TIME_FORMAT)
          .add(duration, MINUTES)
          .format(DATE_TIME_FORMAT);
      }
      const evtEndDate = key === END_DATE ? value : endDate;
      const dateRangeError = validateScheduleUpdate(
        eventId,
        evtStartDate,
        evtEndDate,
        name,
        dayEvent
      );
      // Check for Scheduling errors in case of Non All Day eventss
      if (!dayEvent && !dateRangeError) {
        const serviceDuration = moment(endDate, DATE_TIME_FORMAT).diff(
          moment(startDate, DATE_TIME_FORMAT),
          MINUTES
        );
        const extraDuration = computeExtraDuration(newEvent);
        if (serviceDuration - extraDuration > 0) {
          newEvent[SERVICE_DURATION] = serviceDuration;
        } else {
          const newErrors = { ...errors };
          newErrors[eventId] = `${getDisplayValue(EVENTSTAG149)} - ${name}`;
          setErrors(newErrors);
        }
      }
      setTechRows(newData);
    }
  };

  const computeExtraDuration = event => {
    const {
      afterDriveTime = 0,
      afterOHTime = 0,
      beforeDriveTime = 0,
      beforeOHTime = 0,
      breakTime = 0
    } = event;
    const idleTime = Number.isNaN(breakTime) ? 0 : breakTime;
    return sum([
      afterDriveTime,
      afterOHTime,
      beforeDriveTime,
      beforeOHTime,
      idleTime
    ]);
  };

  const validateScheduleUpdate = (
    eventId,
    startDate,
    endDate,
    techName,
    dayEvent
  ) => {
    let hasError = false;
    const newErrors = { ...errors };
    const endDateTime = dayEvent
      ? moment(endDate, DATE_TIME_FORMAT).endOf("day")
      : moment(endDate, DATE_TIME_FORMAT);
    const startDateTime = dayEvent
      ? moment(startDate, DATE_TIME_FORMAT).startOf("day")
      : moment(startDate, DATE_TIME_FORMAT);
    const overLappingEvts = { ...overLappingEvents };
    const row = techRows[eventId];
    if (row) {
      const { Id } = row;
      const techEvents = Object.values(techRows).filter(
        techRow => techRow.Id === Id && techRow.id !== eventId
      );

      const conflictEvents = isOverLappingEvent(
        [{ ...row, startDate, endDate }],
        techEvents
      );
      if (conflictEvents.length) {
        let techIds = overLappingEvts[Id] || [];
        if (!techIds.length) {
          techIds = techIds.concat(flatMap(conflictEvents, event => event.id));
          overLappingEvts[Id] = techIds;
        }
        if (!techIds.includes(eventId)) {
          techIds.push(eventId);
        }
      } else {
        if (overLappingEvts[Id]) {
          delete overLappingEvts[Id];
        }
      }
    }
    if (endDateTime.isSameOrBefore(startDateTime)) {
      newErrors[eventId] = `${
        dayEvent ? getDisplayValue(TAG102) : getDisplayValue(TAG350)
      } ${techName} ${getDisplayValue(TAG351)} : ${moment(
        startDate,
        DATE_TIME_FORMAT
      ).format(dateTimeFormat)} ${getDisplayValue(TAG352)} : ${moment(
        endDate,
        DATE_TIME_FORMAT
      ).format(dateTimeFormat)}`;
      setErrors(newErrors);
      hasError = true;
    } else if (newErrors[eventId]) {
      delete newErrors[eventId];
      setErrors(newErrors);
    }
    setOverLappingEvents(overLappingEvts);
    return hasError;
  };

  const updateScheduledEvent = event => {
    const editScheduleEvent = { ...updateEvent, ...event };
    if (!isEqual(editScheduleEvent, updateEvent)) {
      updateEvent = editScheduleEvent;
    }
  };

  const updateEventFields = (field, value) => {
    setEditFields({ ...editFields, [field]: value });
  };

  const AFTER_DRIVE_TIME = "afterDriveTime";
  const AFTER_OH_TIME = "afterOHTime";
  const BEFORE_DRIVE_TIME = "beforeDriveTime";
  const BEFORE_OH_TIME = "beforeOHTime";
  const END_DATE = "endDate";
  const SERVICE_DURATION = "serviceDuration";
  const START_DATE = "startDate";
  const UPDATE_FIELDS = [
    AFTER_DRIVE_TIME,
    AFTER_OH_TIME,
    BEFORE_DRIVE_TIME,
    BEFORE_OH_TIME,
    END_DATE,
    SERVICE_DURATION,
    START_DATE
  ];

  const applyScheduleChange = () => {
    const newErrors = { ...errors };
    const newData = { ...techRows };
    selectedRows.map(row => {
      const eventRow = newData[row];
      UPDATE_FIELDS.map(name => {
        eventRow[name] = updateEvent[name];
        return undefined;
      });
      delete newErrors[row];
      return undefined;
    });
    setErrors(newErrors);
    setTechRows(newData);
    setShowEditModal(false);

    setTimeout(() => {
      selectedRows.map(row => {
        const techRow = techRows[row];
        const { id, startDate, endDate, name, dayEvent } = techRow;
        validateScheduleUpdate(id, startDate, endDate, name, dayEvent);
      });
    }, 0);
  };

  const cancelUpdateFields = () => {
    setEditFields({});
    setShowUpdateModal(false);
  };

  const applyFieldUpdates = () => {
    setShowUpdateModal(false);
  };

  const getOwnerEvent = () => {
    let pastOwnerEvent = null;
    const workOrderTechId = getFieldValue(
      selectedWO,
      WORKORDER_TECHNICIAN_API_NAME
    );
    if (workOrderTechId && workorderEvents.length) {
      const ownerEvents = workorderEvents.filter(event => {
        const { event_WP: eventObj } = event;
        const { TechId } = eventObj;
        return workOrderTechId === TechId;
      });
      if (ownerEvents.length) {
        const [ownerEvent] = ownerEvents;
        const { event_WP: eventObj } = ownerEvent;
        const {
          endDateTime,
          id,
          startDateTime,
          TechId,
          IsAllDayEvent,
          durationInMinutes,
          Driving_Time: beforeDriveTime,
          Driving_Time_Home: afterDriveTime,
          Overhead_Time_Before: beforeOHTime,
          Overhead_Time_After: afterOHTime,
          Break_Time_Total: breakTime,
          lstKeyValuePair,
          description,
          location
        } = eventObj;
        if (deletedEvents.includes(id)) {
          return pastOwnerEvent;
        }
        const { technician_O: techObj } = technicians[TechId] || {};
        if (techObj) {
          pastOwnerEvent = createEventRow(
            id,
            techObj,
            false,
            toDateTime(startDateTime),
            toDateTime(endDateTime),
            true,
            parseInt(durationInMinutes, 10),
            parseInt(beforeDriveTime, 10),
            parseInt(afterDriveTime, 10),
            parseInt(beforeOHTime, 10),
            parseInt(afterOHTime, 10),
            parseInt(breakTime, 10),
            IsAllDayEvent,
            lstKeyValuePair,
            description,
            location
          );
        }
      }
    }
    return pastOwnerEvent;
  };

  const getOverLappingBgColor = record => {
    const { Id: resourceId } = record;
    return overLappingEventColors[resourceId] || "#FFF";
  };

  const isOverLappingRecord = record => {
    const { id: eventId, Id: resourceId } = record;
    const conflictEvents = overLappingEvents[resourceId] || [];
    return conflictEvents ? conflictEvents.includes(eventId) : false;
  };

  const scheduleEvents = () => {
    let ownerId = getFieldValue(
      selectedWO,
      WORKORDER_TECHNICIAN_API_NAME,
      null
    );
    if (!isOwner) {
      setConfirmModal({
        message: TAG364,
        ok: TAG069
      });
      return;
    }
    const scheduledEvents = { ...techRows };
    const { scheduleMultipleEvents } = props;
    if (scheduleMultipleEvents) {
      // This is to make sure OwnerEvent will be the last event in the list.
      const ownerEvent = scheduledEvents[isOwner];
      if (ownerEvent) {
        delete scheduledEvents[isOwner];
        scheduledEvents[isOwner] = ownerEvent;
        const { Id } = ownerEvent;
        ownerId = Id;
      } else {
        // In case if the owner event is in the past event, Do send the past owner event in the request
        const pastOwnerEvent = getOwnerEvent();
        if (pastOwnerEvent) {
          const { Id } = pastOwnerEvent;
          ownerId = Id;
        }
      }
      // }
      // Remove any falsy values from the list.
      const events = compact(Object.values(scheduledEvents));
      scheduleMultipleEvents(
        updateEvent || events[0],
        events,
        subject,
        editFields,
        deletedEvents,
        ownerId
      );
    }
  };

  const handleSubjectChange = ({ value }) => {
    const newErrors = { ...errors };
    if (isEmpty(value)) {
      newErrors[TAG132] = TAG132;
    } else if (value.length > 80) {
      newErrors[TAG227] = TAG227;
    } else {
      delete newErrors[TAG132];
      delete newErrors[TAG227];
    }
    setSubject(value);
    setErrors(newErrors);
  };

  const cancelSchedule = () => {
    if (isDisabled) {
      cleanEventStore([
        KEY_EVENT_SUBJECT,
        KEY_WORKORDER_EVENTS,
        KEY_MULTIASSIGN_EVENTS
      ]);
      isOpen(false);
      return;
    }
    setConfirmModal({
      message: TAG360,
      no: TAG241,
      yes: TAG240
    });
  };

  const SCH_ERROR_COLS = [
    {
      accessor: "slno",
      className: "DataGrid__cell--align-center",
      Header: "Sl. No.",
      headerAlign: "center",
      width: 70
    },
    {
      accessor: "name",
      Header: getDisplayValue(TAG050),
      width: 200
    },
    {
      accessor: "enableScheduling",
      align: "center",
      Cell: row => {
        const { original } = row;
        const { enableScheduling } = original;
        return (
          <Icon
            className={enableScheduling ? "enabled" : "disabled"}
            icon={enableScheduling ? "check" : "close"}
            align="center"
            size="x-small"
          />
        );
      },
      Header: "Enable Scheduling",
      headerAlign: "center"
    },
    {
      accessor: "isActive",
      align: "center",
      Cell: row => {
        const { original } = row;
        const { isActive } = original;
        return (
          <Icon
            className={isActive ? "enabled" : "disabled"}
            icon={isActive ? "check" : "close"}
            align="center"
            size="x-small"
          />
        );
      },
      Header: "Is Active",
      headerAlign: "center"
    }
  ];

  const rows = Object.values(techRows);
  const hasErrors = Object.keys(errors).length !== 0;

  return (
    <div>
      <Modal
        className="MultipleAssignmentModal"
        size="large"
        isOpen={open}
        onClose={() => cancelSchedule()}
      >
        <ModalHeader title={`${getDisplayValue(TAG157)} ${title}`} />
        <ModalContent className="MultipleAssignmentModal__content">
          {workorderEvents && !requestMultiAssign && (
            <MultiAssignContainer
              {...props}
              onSelection={onSelection}
              selections={selection}
              isDisabled={isDisabled}
              rows={rows}
              handleSearchChange={handleSearchChange}
              hasPastEvents={hasPastEvents}
              showPastEvents={showPastEvents}
              handlePastEventChange={handlePastEventChange}
              selectAllRows={
                selectedRows.length && selectedRows.length === rows.length
              }
              handleRowSelection={handleRowSelection}
              handleSelectAllRows={handleSelectAllRows}
              allDayEvent={
                allDayEvent.length && allDayEvent.length === rows.length
              }
              handleDayEventSelection={handleDayEventSelection}
              handleAllDayEvent={handleAllDayEvent}
              isOwner={isOwner}
              subject={subject}
              ownerName={ownerName}
              handleOwnerChange={handleOwnerChange}
              handleRemoveRow={handleRemoveRow}
              handleSubjectChange={handleSubjectChange}
              handleRemoveSelectedRows={handleRemoveSelectedRows}
              handleFieldUpdates={handleFieldUpdates}
              handleEditSchedule={handleEditSchedule}
              updateScheduleDate={updateScheduleDate}
              isDayEvent={isDayEvent}
              isRowSelected={isRowSelected}
              isOverLappingRecord={isOverLappingRecord}
              getOverLappingBgColor={getOverLappingBgColor}
            />
          )}
          {(!workorderEvents || requestMultiAssign) && <LoadIndicator />}
        </ModalContent>
        <ModalFooter className="MultipleAssignmentModal__footer">
          <Grid className="slds-gutters" isVertical>
            <GridRow>
              <GridItem className="MultipleAssignmentModal__footer-text">
                {hasErrors && (
                  <span className="MultipleAssignmentModal__footer-text">
                    <Icon icon="error" size="small" />
                    <Label className="error">
                      <b>
                        {Object.keys(errors)[0] ===
                        errors[Object.keys(errors)[0]]
                          ? getDisplayValue(Object.keys(errors)[0])
                          : errors[Object.keys(errors)[0]]}
                      </b>
                    </Label>
                  </span>
                )}
              </GridItem>
              <GridItem noFlex>
                <Button
                  type="neutral"
                  label={getDisplayValue(TAG066)}
                  onClick={() => cancelSchedule()}
                />
              </GridItem>
              <GridItem noFlex>
                <Button
                  type="brand"
                  label={getDisplayValue(EVENTSTAG014)}
                  isDisabled={
                    !Object.values(techRows).length ||
                    isDisabled ||
                    requestMultiAssign ||
                    hasErrors
                  }
                  onClick={() => scheduleEvents()}
                />
              </GridItem>
            </GridRow>
          </Grid>
        </ModalFooter>
      </Modal>
      {confirmModal && (
        <Modal
          className="MultipleAssignmentModal__ConfirmDialog"
          isOpen={confirmModal}
          onClose={() => setConfirmModal(false)}
          zIndex={9003}
        >
          <ModalHeader title={getDisplayValue(TAG183)} />
          <ModalContent className="slds-p-around--small">
            <div>
              {/^TAG[0-9]+$/.test(confirmModal.message)
                ? getDisplayValue(confirmModal.message)
                : confirmModal.message}
              <br />
              {confirmModal.details && confirmModal.details.message}
              {confirmModal.data && (
                <DataGrid
                  style={{ marginTop: "1em" }}
                  columns={SCH_ERROR_COLS}
                  data={Object.values(confirmModal.data)}
                  hasColumnBorder
                  resizable={false}
                  showPagination={false}
                  sortable={false}
                />
              )}
              {confirmModal.warn && (
                <div style={{ marginTop: "0.5em" }}>
                  {getDisplayValue(
                    CONTINUE_WITHOUT_ADDING,
                    CONTINUE_WITHOUT_ADDING
                  )}
                </div>
              )}
            </div>
          </ModalContent>
          <ModalFooter
            style={{
              display: "flex",
              justifyContent: confirmModal.ok ? "space-around" : "flex-end"
            }}
          >
            {confirmModal.no && (
              <Button
                type="brand"
                label={getDisplayValue(confirmModal.no)}
                onClick={() => handleClick(confirmModal.no)}
              />
            )}
            {confirmModal.yes && (
              <Button
                type="brand"
                label={getDisplayValue(confirmModal.yes)}
                onClick={() => handleClick(confirmModal.yes)}
              />
            )}
            {confirmModal.ok && (
              <Button
                type="brand"
                label={getDisplayValue(confirmModal.ok)}
                onClick={() => handleClick(confirmModal.ok)}
              />
            )}
          </ModalFooter>
        </Modal>
      )}
      {showEditModal && (
        <Modal
          isOpen={showEditModal}
          onClose={() => setShowEditModal(false)}
          className="MultipleAssignmentModal__content_w70"
          zIndex={9003}
        >
          <ModalHeader title={getDisplayValue(TAG183)} />
          <ModalContent className="slds-p-around--small">
            <EditEventSchedule
              event={editEvent}
              editError={editError}
              setEditError={setEditError}
              isAllDayEvent={intersection(selectedRows, allDayEvent).length > 0}
              updateScheduledEvent={updateScheduledEvent}
            />
          </ModalContent>
          <ModalFooter>
            <Button
              type="brand"
              label={getDisplayValue(TAG066)}
              onClick={() => setShowEditModal(false)}
            />
            <Button
              type="brand"
              isDisabled={editError}
              label={getDisplayValue(TAG076)}
              onClick={() => applyScheduleChange()}
            />
          </ModalFooter>
        </Modal>
      )}
      {showUpdateModal && (
        <Modal
          className="WorkOrderFieldUpdate__Modal"
          isOpen={showUpdateModal}
          onClose={() => cancelUpdateFields()}
          zIndex={9003}
        >
          <ModalHeader title={getDisplayValue(TAG183)} />
          <ModalContent className="slds-p-around--small">
            <WorkOrderFieldUpdate
              selectedWO={selectedWO}
              editEvent={editEvent}
              editFields={editFields}
              updateEventFields={updateEventFields}
              selectedTimeZone={selectedTimeZone}
              rows={rows}
            />
          </ModalContent>
          <ModalFooter>
            <Button
              type="brand"
              label={getDisplayValue(TAG066)}
              onClick={() => cancelUpdateFields()}
            />
            <Button
              type="brand"
              isDisabled={isDisabled}
              label={getDisplayValue(TAG246)}
              onClick={() => applyFieldUpdates()}
            />
          </ModalFooter>
        </Modal>
      )}
    </div>
  );
};

MultipleAssignmentModal.propTypes = {
  apply: PropTypes.func,
  isOpen: PropTypes.func,
  open: PropTypes.bool.isRequired,
  selectedTimeZone: PropTypes.string.isRequired,
  selectedWO: PropTypes.shape({}).isRequired
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(MultipleAssignmentModal);
