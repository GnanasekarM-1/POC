import React, { Component } from "react";
import { PropTypes } from "prop-types";
import { IntlProvider } from "react-intl";
import * as moment from "moment";
import { chunk } from "lodash";
import {
  Button,
  Container,
  FormFields,
  Form,
  Icon,
  Label,
  Input,
  GridRow,
  GridItem,
  Tabs,
  Tab,
  Spinner,
  Section,
  Grid,
  Text,
  Textarea
} from "@svmx/ui-components-lightning";
import {
  MINUTES,
  YODA_DATE_FORMAT,
  YODA_DATE_TIME_ZONE_24_HR_FORMAT,
  DATE_TIME_FORMAT,
  DATE_FORMAT
} from "constants/DateTimeConstants";
import {
  getDisplayValue,
  getFormValues,
  getUserSetting,
  getFieldValue
} from "utils/DCUtils";
import {
  AUTO_CALC_END_DATE,
  AUTO_SYNC_SVC_DURATION
} from "constants/UserSettingConstants";
import {
  getMinutesToHours,
  convertHoursToMinutes,
  getHoursToMinutes,
  getSecondsToHours,
  validatedateObj
} from "utils/DateTimeUtils";
import { getDateTimeValueFromDateTimeField } from "utils/DateAndTimeUtils";
import {
  TAG039,
  TAG036,
  TAG238,
  TAG247,
  TAG220,
  TAG346,
  TAG237,
  EVENTSTAG037,
  EVENTSTAG024,
  EVENTSTAG001,
  EVENTSTAG025,
  EVENTSTAG026,
  EVENTSTAG027,
  EVENTSTAG070,
  EVENTSTAG019,
  EVENTSTAG018,
  EVENTSTAG011,
  EVENTSTAG012,
  EVENTSTAG010,
  EVENTSTAG031,
  EVENTSTAG033,
  EVENTSTAG006,
  EVENTSTAG023,
  EVENTSTAG022,
  EVENTSTAG007,
  EVENTSTAG028,
  EVENTSTAG089,
  EVENTSTAG055,
  EVENTSTAG015,
  EVENTSTAG017,
  EVENTSTAG030,
  EVENTSTAG065,
  EVENTSTAG072,
  EVENTSTAG135,
  EVENTSTAG035,
  EVENTSTAG063,
  EVENTSTAG066,
  EVENTSTAG071,
  EVENTSTAG016,
  EVENTSTAG068
} from "constants/DisplayTagConstants";
import {
  getWOUpdateInitialvalues,
  getWoUpdateEventPayload,
  getCreateEventPayload,
  getInitialvalues,
  getAllUpdateFields,
  getComponentForField,
  getLJScreateEventPayload,
  getSlaValues,
  getTotalDurationInMinForHourEnabled,
  isValidteEndDateForEventCreation,
  getServiceDurationInMinForHourEnabled
} from "utils/EventsUtils";
import {
  JDM_LJS_ENABLED,
  JDM_ENABLED_LJS_DISABELD,
  CUSTOMER_COMMITMENT,
  REQUEST_PASS,
  ALL_OPTION_DISABLED,
  WO_SCHEDULED_DURATION_FIELD,
  WO_UNSCHEDULED_DURATIONS,
  WO_DISPATCH_STATUS_FIELD,
  WO_PREFERRED_BUSINESS_HOURS_FIELD,
  TECH_SALESFORCE_USER_FIELD,
  SALESFORCE_EVENT,
  WO_SCHEDULING_OPTIONS,
  FALSE,
  WO_ESTIMATED_DURATION_FIELD,
  WO_SCOPE_CHANGE_FIELD,
  WO_VARIANCE_FIELD,
  WO_REVISED_DURATION_FIELD,
  HOURS,
  WORKORDER_TECHNICIAN_API_REF,
  FILTER_TECHNICIAN_RESULT,
  DOUBLE_BOOKING_ALLOW
} from "constants/AppConstants";
import {
  getSettingValue,
  SLAT003_SET001,
  DCON001_SET011,
  GLOB001_GBL025,
  DCON001_SET054,
  DCON005_SET003,
  DCON005_SET004,
  DCON001_SET037,
  DCON001_SET025
} from "constants/AppSettings";
import unScheduledDurationService from "services/UnScheduledDurationService";

import "./CreateEditEvent.scss";

import { getUserTimeSettings } from "utils/DateAndTimeUtils";
import {
  getTextField,
  formDisplayFields,
  getTextAreaField,
  getCheckBoxField,
  getDateInputField,
  getDateTimeInputField
} from "./CreateEditEventHelper";

const {
  CheckboxField,
  DateInputField,
  DateTimeInputField,
  TextField,
  TextareaField
} = FormFields;

const defaultProps = {
  dispatch: null,
  eventData: {},
  fields: null,
  fieldValues: null,
  woInfo: {}
};

const propTypes = {
  dispatch: PropTypes.func,
  eventData: PropTypes.objectOf(PropTypes.object),
  fields: PropTypes.arrayOf(PropTypes.shape({})),
  fieldValues: PropTypes.shape({}),
  woInfo: PropTypes.arrayOf(PropTypes.object)
};

class CreateEditEvent extends Component {
  constructor(props) {
    super(props);
    const {
      eventData,
      isCreateEvent,
      wo_isAlldayEvent,
      wo_respectMachineAccessHours,
      wo_respectTechnincianWorkHours,
      wo_doNotOverlapExistingEvents,
      wo_unassignWO,
      wo_deleteEventForTech
    } = this.props;

    const { dropDate, dropTime } = eventData;
    const { IsAllDayEvent } = eventData;
    const roundOffMinutes = moment(dropTime, "HH:mm A");
    const roundOffTime = parseInt(getSettingValue(DCON001_SET011, 15), 10);
    if (!isNaN(roundOffTime) && roundOffTime > 0) {
      roundOffMinutes.minutes(
        Math.round(roundOffMinutes.minutes() / roundOffTime) * roundOffTime
      );
    }

    const arrivetime = {
      date: moment(dropDate, "MM/DD/YYYY"),
      time: roundOffMinutes.clone()
    };
    this.state = {
      isEventUpdated: false,
      isBudgetOpen: false,
      isEventCreated: false,
      isScheduleEnabled: true,
      isAllDayEvent: isCreateEvent
        ? wo_isAlldayEvent === "true"
        : IsAllDayEvent,
      isShceduleAsLongJobChecked: true,
      isRespectTechWorkHoursChecked: wo_respectTechnincianWorkHours
        ? wo_respectTechnincianWorkHours.toLowerCase() === "true"
        : false,
      isRespectMachineAccessHoursChecked: wo_respectMachineAccessHours
        ? wo_respectMachineAccessHours.toLowerCase() === "true"
        : false,
      isDonotOverlapChecked: wo_doNotOverlapExistingEvents
        ? wo_doNotOverlapExistingEvents.toLowerCase() === "true"
        : false,
      arriveTime: arrivetime,
      departTime: null,
      calculatedStartDate: null,
      shouldShowDepartTimeAlert: false,
      shouldRememberMyPreference: false
    };
    this.woId = "";
    this.schedulingOption = "";
    this.techId = "";
    this.ownerId = "";
    this.techSFId = null;
    this.shouldCalculateEndTime = false;
    this.autoSyncSvcDuration = false;
    this.autoCalcEndDate = false;
    this.eventFields = {};
  }

  componentDidMount() {
    const {
      fieldValues,
      isClassicMode,
      isJDMenabled,
      isCreateEvent
    } = this.props;
    const { isAllDayEvent } = this.state;
    const showAdvancedMode = !isClassicMode && isJDMenabled;
    this.setState({
      initialValues: fieldValues,
      isModalLoaded: true,
      // isAllDayEvent: isAllDayEvent && !showAdvancedMode
      isAllDayEvent: !isCreateEvent
        ? isAllDayEvent
        : isAllDayEvent && !showAdvancedMode
    });
  }

  shouldComponentUpdate(nextProps, nextState) {
    const { isAPICallInProgress } = nextProps;
    return !isAPICallInProgress;
  }

  afterEventCreateCall = response => {
    const { success, content } = response;
    const me = this;
    const { eventActions, isJDMenabled } = me.props;
    if (success === REQUEST_PASS) {
      let payload = {};
      if (
        !isJDMenabled ||
        me.schedulingOption === ALL_OPTION_DISABLED ||
        me.schedulingOption == null
      ) {
        payload = {
          Ids: content,
          whatId: this.woId
        };
      } else {
        const { lstAESEvent } = content;
        payload = {
          Ids: lstAESEvent,
          whatId: this.woId
        };
      }

      eventActions.fetchEventWoInfoCall(me.afterFetchEventWoInfoCall, payload);
    } else {
      this.setState({ isEventCreated: false, isScheduleEnabled: true });
    }
  };

  afterFetchEventWoInfoCall = (response, error = false) => {
    const me = this;
    const {
      onClose,
      createEventCompleted,
      isClassicMode,
      onHandleServerAlertModal,
      switchViewMode,
      enableAndDisableSchedule
    } = me.props;
    if (response && response === getDisplayValue(TAG238)) {
      onHandleServerAlertModal(response);
    } else if (error && response.includes(getDisplayValue("EVENTSTAG064"))) {
      if (isClassicMode) switchViewMode();
      const errorMessage = response.substring(
        response.indexOf("@W") + 1,
        response.indexOf(")@") + 1
      );
      onHandleServerAlertModal(errorMessage, getDisplayValue(EVENTSTAG072));
    } else if (error) {
      if (response.includes("DCON005_TAG066")) {
        onHandleServerAlertModal(getDisplayValue(EVENTSTAG066));
      } else {
        onHandleServerAlertModal(response);
      }
    } else {
      createEventCompleted(response);
      onClose();
    }
    this.setState({ isEventCreated: false, isScheduleEnabled: true });
    enableAndDisableSchedule(false);
  };

  handleCalculate = () => {
    this.shouldCalculateEndTime = true;
    const { submitForm } = this.props;
    submitForm("create-event-form-field");
  };

  afterCalculateEndTime = (response, error = false) => {
    if (!error) {
      const {
        showCalculateMessage,
        chageFormField,
        isCreateEvent,
        isJDMenabled,
        enableAndDisableSchedule
      } = this.props;
      const FORM_NAME = isCreateEvent
        ? "create-event-form-field"
        : "edit-event-form-field";
      this.shouldCalculateEndTime = false;
      const { content } = response;
      const {
        eventsCounter,
        startDatetime,
        remainderServiceDuration,
        endDatetime
      } = content;
      const measureUnitInHours =
        getSettingValue(DCON001_SET054, HOURS) === HOURS || isJDMenabled;
      const formValues = getFormValues(FORM_NAME);
      const { drivebeforetext, driveaftertext } = formValues;
      const driveafter = measureUnitInHours
        ? getHoursToMinutes(driveaftertext)
        : driveaftertext;
      const endDate = moment(endDatetime, "YYYY-MM-DD HH:mm:ss");
      const removeDriveAfterFromEndDate = moment(
        endDatetime,
        "YYYY-MM-DD HH:mm:ss"
      ).subtract(driveafter, "minutes");
      const updatedEnddate = {
        date: moment(
          removeDriveAfterFromEndDate,
          getUserTimeSettings("dateFormat")
        ),
        time: moment(
          removeDriveAfterFromEndDate,
          getUserTimeSettings("timeFormat")
        )
      };

      const drivebefore = measureUnitInHours
        ? getHoursToMinutes(drivebeforetext)
        : drivebeforetext;
      const calculatedStartDate = moment(
        startDatetime,
        "YYYY-MM-DD HH:mm:ss"
      ).format(getUserTimeSettings("dateTimeFormat"));
      const addDriveToStartDate = moment(
        calculatedStartDate,
        getUserTimeSettings("dateTimeFormat")
      ).add(drivebefore, "minutes");
      const eventArriveDate = moment(
        addDriveToStartDate,
        "YYYY-MM-DD HH:mm:ss"
      ).format(getUserTimeSettings("dateTimeFormat"));
      chageFormField(FORM_NAME, "enddatetime", updatedEnddate);
      chageFormField(
        FORM_NAME,
        "enddate",
        moment(endDate, getUserTimeSettings("dateFormat"))
      );
      this.setState({
        isEventCreated: false,
        calculatedStartDate: eventArriveDate,
        shouldShowDepartTimeAlert: false
      });
      showCalculateMessage(eventsCounter, remainderServiceDuration);
      enableAndDisableSchedule(false);
    } else {
      const { handleErrorMessage } = this.props;
      this.setState({ isEventCreated: false });
      if (response.includes("DCON005_TAG066"))
        handleErrorMessage(getDisplayValue(EVENTSTAG066));
    }
  };

  handleFailedFormSubmit = errors => {};

  handleFormSubmit = values => {
    const me = this;
    const {
      eventData,
      eventActions,
      isClassicMode,
      isLJMenabled,
      isJDMenabled,
      woInfo,
      handleErrorMessage,
      isCreateEvent,
      // updatePrimaryTech,
      // deleteEventForTech,
      removeWarningMessage,
      editEventResourceRecord: editData,
      enableAndDisableSchedule,
      isTechnicianChanged
    } = me.props;
    const FORM_NAME = isCreateEvent
      ? "create-event-form-field"
      : "edit-event-form-field";
    const fieldValues = getFormValues(FORM_NAME);
    const { estimatedduration } = fieldValues;
    const updatePrimaryTech =
      document.getElementsByName("updateprimarytechnicians").length > 0 &&
      document.getElementsByName("updateprimarytechnicians")[0].checked;
    const deleteEventForTech =
      document.getElementsByName("deleteeventforothertechnicians").length > 0 &&
      document.getElementsByName("deleteeventforothertechnicians")[0].checked;
    const estimationInMinutes = getHoursToMinutes(estimatedduration);
    if (estimationInMinutes == 0 && isJDMenabled && isLJMenabled) {
      removeWarningMessage();
      handleErrorMessage(getDisplayValue(EVENTSTAG071));
      return;
    }
    values = fieldValues;
    handleErrorMessage("");
    if (!this.shouldCalculateEndTime) {
      removeWarningMessage();
    }
    const {
      isAllDayEvent,
      isRespectMachineAccessHoursChecked,
      isRespectTechWorkHoursChecked,
      isDonotOverlapChecked,
      isShceduleAsLongJobChecked
    } = this.state;
    let isBefore = false;
    let isSame = false;
    let durationInMinutes = 0;
    const {
      driveaftertext,
      respectMachineAccessHoursChecked,
      drivebeforetext,
      overheadaftertext,
      overheadbeforetext,
      breaktime,
      serviceduration
    } = fieldValues;
    const measureUnitInHours =
      getSettingValue(DCON001_SET054, HOURS) === HOURS || isJDMenabled;
    if (measureUnitInHours) {
      durationInMinutes = getTotalDurationInMinForHourEnabled({
        serviceduration,
        driveaftertext,
        drivebeforetext,
        overheadaftertext,
        overheadbeforetext,
        breaktime
      });
    } else {
      durationInMinutes =
        (+serviceduration || 0) +
        (+driveaftertext || 0) +
        (+drivebeforetext || 0) +
        (+overheadaftertext || 0) +
        (+overheadbeforetext || 0) +
        (+breaktime || 0);
    }
    if (isAllDayEvent) {
      const { startdate, enddate } = values;
      isBefore = this.handleDateTimeCheck(startdate, enddate);
      if (!isBefore) {
        const allDayFormValues = this.handleAllDayEvent(values);
        if (allDayFormValues) {
          fieldValues.startDate = allDayFormValues.startDate;
          fieldValues.endDate = allDayFormValues.endDate;
          fieldValues.serviceDuration = allDayFormValues.allDayServiceDuration;
          fieldValues.durationInMinutes =
            allDayFormValues.allDayServiceDuration;
          fieldValues.activityDate = allDayFormValues.activityDate;
        }
      } else {
        return undefined;
      }
    } else {
      const woFormValues = this.handleWorkOrderEvent(values);
      fieldValues.startDate = woFormValues.startdatetime;
      fieldValues.endDate = woFormValues.enddatetime;
      fieldValues.serviceDuration = woFormValues.woServiceDuration;
      fieldValues.durationInMinutes = durationInMinutes;
      fieldValues.jdmActivityDatetime = woFormValues.jdmActivityDatetime;
      isBefore = this.handleDateTimeCheck(
        moment(woFormValues.startdatetime),
        moment(woFormValues.enddatetime)
      );
      isSame = this.handleDateTimeCheckForSame(
        moment(woFormValues.startdatetime),
        moment(woFormValues.enddatetime)
      );

      const isValidDate = isValidteEndDateForEventCreation({
        woFormValues,
        durationInMinutes
      });
      if (isBefore || isSame) {
        return undefined;
      }
      const timeDifference = moment(woFormValues.enddatetime).diff(
        moment(woFormValues.startdatetime),
        "minutes"
      );
      if (
        (!isJDMenabled && durationInMinutes !== timeDifference) ||
        serviceduration < 0
      ) {
        handleErrorMessage(getDisplayValue(TAG237));
        return undefined;
      }
    }

    if (isCreateEvent) {
      const { wo } = eventData;
      const draggedWO = woInfo.find(info => info.Name === wo);

      if (
        !isClassicMode &&
        isJDMenabled &&
        isLJMenabled &&
        !draggedWO[WO_PREFERRED_BUSINESS_HOURS_FIELD] &&
        isShceduleAsLongJobChecked &&
        isRespectMachineAccessHoursChecked
      ) {
        removeWarningMessage();
        handleErrorMessage(getDisplayValue(EVENTSTAG065));
        return undefined;
      }
      const { Id: WhatId, SVMXDEV__Driving_Time__c: driveTime } = draggedWO;
      const shouldAllowDoubleBooking =
        getSettingValue(DCON001_SET025) === DOUBLE_BOOKING_ALLOW;

      this.woId = WhatId;
      fieldValues.WhatId = WhatId;
      fieldValues.driveTime = driveTime;
      fieldValues.woDispatchStatus = draggedWO[WO_DISPATCH_STATUS_FIELD];
      const isJDMQueuedWO =
        !isClassicMode &&
        isJDMenabled &&
        isLJMenabled &&
        draggedWO[WO_DISPATCH_STATUS_FIELD] === "Queued";
      fieldValues.updatePrimaryTech = isJDMQueuedWO
        ? false
        : updatePrimaryTech ||
          false ||
          draggedWO[WO_DISPATCH_STATUS_FIELD] === "Queued";
      fieldValues.deleteEventForOtherTechs = deleteEventForTech || false;
      fieldValues.respectTechWorkHoursChecked = isRespectTechWorkHoursChecked
        ? "on"
        : null;
      fieldValues.respectMachineAccessHoursChecked = isRespectMachineAccessHoursChecked
        ? "on"
        : null;
      fieldValues.donotOverlapChecked =
        isDonotOverlapChecked && shouldAllowDoubleBooking ? "on" : null;
      fieldValues.shceduleAsLongJobChecked = isShceduleAsLongJobChecked;
      const isNewWO = draggedWO[WO_DISPATCH_STATUS_FIELD] === "New";
      if (isNewWO) fieldValues.updatePrimaryTech = true;
      fieldValues.isAllDayEvent = isAllDayEvent;
      let payload;
      if (
        isClassicMode ||
        !isJDMenabled ||
        !isLJMenabled ||
        me.schedulingOption === ALL_OPTION_DISABLED ||
        me.schedulingOption == null
      ) {
        payload = getCreateEventPayload(values, isJDMenabled);
        eventActions.createEventCall(me.afterFetchEventWoInfoCall, payload);
      } else {
        payload = getLJScreateEventPayload(
          values,
          this.shouldCalculateEndTime,
          isJDMenabled
        );
        if (me.shouldCalculateEndTime) {
          eventActions.createLJSeventCall(
            me.afterCalculateEndTime,
            payload,
            me.shouldCalculateEndTime
          );
        } else {
          eventActions.createLJSeventCall(
            me.afterFetchEventWoInfoCall,
            payload,
            me.shouldCalculateEndTime
          );
        }
      }
      enableAndDisableSchedule(true);
      this.setState({ isEventCreated: true });
    } else {
      const { WOId, woFields } = eventData;
      this.woId = WOId;
      fieldValues.woId = WOId;
      fieldValues.woDispatchStatus = woFields[WO_DISPATCH_STATUS_FIELD];
      fieldValues.updatePrimaryTech =
        updatePrimaryTech ||
        false ||
        woFields[WO_DISPATCH_STATUS_FIELD] === "Queued";

      // fieldValues.updateprimarytechnicians = (fieldValues.updateprimarytechnicians === true) || (draggedWO[WO_DISPATCH_STATUS_FIELD] === 'Queued');
      fieldValues.deleteEventForOtherTechs = deleteEventForTech || false;
      fieldValues.isAllDayEvent = isAllDayEvent;
      fieldValues.eventId = this.eventId;
      // if (isJDMenabled) {
      //   fieldValues.startDate = fieldValues.jdmActivityDatetime;
      // }
      const isNonLongJobEvent =
        (isJDMenabled && !isLJMenabled) ||
        me.schedulingOption === JDM_ENABLED_LJS_DISABELD ||
        me.schedulingOption === ALL_OPTION_DISABLED ||
        me.schedulingOption == null;
      const payload = getWoUpdateEventPayload(
        fieldValues,
        editData,
        isJDMenabled,
        isTechnicianChanged,
        isNonLongJobEvent
      );
      eventActions.updateEvent(me.afterEventEditCall, payload);
      this.setState({ isEventUpdated: true });
      enableAndDisableSchedule(true);
    }
    const { onTreeConfChanged } = this.props;
    const changed = {};
    changed.wo_isAlldayEvent = isAllDayEvent ? "true" : "false";
    onTreeConfChanged(changed);
  };

  afterEventEditCall = (response, error = false) => {
    const {
      editWoEveventComplete,
      isClassicMode,
      switchViewMode,
      newViewState,
      onClose,
      onHandleServerAlertModal,
      enableAndDisableSchedule
    } = this.props;
    if (response && response === getDisplayValue(TAG238)) {
      onHandleServerAlertModal(response);
    } else if (error && response.includes(getDisplayValue("EVENTSTAG064"))) {
      if (isClassicMode) switchViewMode();
      const errorMessage = response.substring(
        response.indexOf("@W") + 1,
        response.indexOf(")@") + 1
      );
      onHandleServerAlertModal(errorMessage, getDisplayValue("EVENTSTAG072"));
    } else if (error) {
      onHandleServerAlertModal(response);
    } else if (response && !error) {
      const { eventData, isJDMenabled, underScheduledEvent } = this.props;
      const { woFields, Service_Duration: oldServiceDuration } = eventData;
      const { workOrder: updatedWo, lstEvent } = response;
      const updatedEvent = lstEvent[0];
      const { Service_Duration: newServiceDuration } = updatedEvent;
      const unscheduleDuration = woFields[WO_UNSCHEDULED_DURATIONS];
      const schedulingOption = woFields[WO_SCHEDULING_OPTIONS];
      const jdmEnabld = isJDMenabled && schedulingOption === JDM_LJS_ENABLED;
      if (
        jdmEnabld &&
        Number(unscheduleDuration) === 0 &&
        Number(oldServiceDuration) > Number(newServiceDuration)
      ) {
        unScheduledDurationService.setWOInfo(updatedWo);
        underScheduledEvent(true);
      }
      setTimeout(() => onClose(), 0);
      editWoEveventComplete(response);

      // In case of editing of event from filtered Technician result, Re-apply apply Technician filter to drop disqualifying
      // technicians due to edit event change.
      // if (FILTER_TECHNICIAN_RESULT === newViewState) {
      //   const { eventActions } = this.props;
      //   const { filterTechnicians } = eventActions;
      //   if (filterTechnicians) {
      //     filterTechnicians();
      //   }
      // }
    }
    this.setState({ isEventUpdated: false });
    enableAndDisableSchedule(false);
  };

  handleDateTimeCheck = (startdate, enddate) => {
    const { isAllDayEvent } = this.state;
    const {
      handleErrorMessage,
      isClassicMode,
      isJDMenabled,
      isLJMenabled
    } = this.props;
    const showAdvancedMode = !isClassicMode && isJDMenabled;
    if (showAdvancedMode && isLJMenabled) return false;
    const isBefore = isAllDayEvent
      ? enddate.startOf("day").isBefore(startdate.startOf("day"))
      : enddate.isBefore(startdate);
    if (isBefore) {
      handleErrorMessage(getDisplayValue("TAG133"));
    }
    return isBefore;
  };

  handleDateTimeCheckForSame = (startdate, enddate) => {
    const {
      handleErrorMessage,
      isClassicMode,
      isJDMenabled,
      isLJMenabled
    } = this.props;
    const showAdvancedMode = !isClassicMode && isJDMenabled;
    if (showAdvancedMode && isLJMenabled) return false;
    const isSame = startdate.isSame(enddate);
    if (isSame) {
      handleErrorMessage(getDisplayValue("TAG133"));
    }
    return isSame;
  };

  handleAllDayEvent = values => {
    const { startdate, enddate } = values;
    const alllDayStartDate = moment(startdate).startOf("day");
    const alllDayEndDate = moment(enddate).endOf("day");
    const days = alllDayEndDate.diff(alllDayStartDate, "days") + 1;
    const modifiedChangeStartDate = alllDayStartDate.format("L LT");
    const modifiedChangeEndDate = moment(startdate)
      .startOf("day")
      .add(days, "days")
      .subtract(1, "minutes")
      .format("L LT");
    const serviceDuration =
      moment(modifiedChangeEndDate, DATE_TIME_FORMAT).diff(
        moment(modifiedChangeStartDate, DATE_TIME_FORMAT),
        "minutes"
      ) + 1;
    const formValues = {};
    formValues.allDayServiceDuration = serviceDuration;
    formValues.startDate = moment
      .utc(modifiedChangeStartDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    formValues.endDate = moment
      .utc(modifiedChangeEndDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    formValues.activityDate = moment
      .utc(modifiedChangeStartDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_FORMAT);
    return formValues;
  };

  handleWorkOrderEvent = values => {
    const { startdatetime, enddatetime, drivebeforetext } = values;
    const { isJDMenabled } = this.props;
    const measureUnitInHours =
      getSettingValue(DCON001_SET054, HOURS) === HOURS || isJDMenabled;
    const formValues = {};
    const startDateInit = moment(startdatetime.date).format(DATE_FORMAT);
    const endDateInit = moment(enddatetime.date).format(DATE_FORMAT);
    const startMinutes =
      startdatetime.time.hour() * 60 + startdatetime.time.minute();
    const endMinutes = enddatetime.time.hour() * 60 + enddatetime.time.minute();
    const startDateConversion = moment(startDateInit).add(
      startMinutes,
      "minutes"
    );
    const drivebefore = measureUnitInHours
      ? getHoursToMinutes(drivebeforetext)
      : drivebeforetext;
    const activityDateConversion = moment(startDateInit).add(
      startMinutes - drivebefore,
      "minutes"
    );
    const endDateConversion = moment(endDateInit).add(endMinutes, "minutes");
    const serviceDuration = endDateConversion.diff(
      startDateConversion,
      "minutes"
    );
    const woStartDate = moment(startDateConversion).format(DATE_TIME_FORMAT);
    const woActivityDate = moment(activityDateConversion).format(
      DATE_TIME_FORMAT
    );
    const woEndDate = moment(endDateConversion).format(DATE_TIME_FORMAT);
    formValues.woServiceDuration = serviceDuration;
    formValues.startdatetime = moment
      .utc(woStartDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    formValues.enddatetime = moment
      .utc(woEndDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    formValues.jdmActivityDatetime = moment
      .utc(woActivityDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    return formValues;
  };

  handleBudgetOpenChange = () => {
    const { isBudgetOpen } = this.state;
    this.setState({ isBudgetOpen: !isBudgetOpen });
  };

  allDayEventChecked = data => {
    const { value } = data;
    const isChecked = value && value === "true";
    this.setState({ isAllDayEvent: isChecked });
    this.calculateStartAndEndValuesOnAllDayChange(isChecked);
    this.calculateServiceDurationOnAllDayChange(isChecked);
  };

  calculateStartAndEndValuesOnAllDayChange = isChecked => {
    const { isCreateEvent, isJDMenabled, chageFormField } = this.props;
    const FORM_NAME = isCreateEvent
      ? "create-event-form-field"
      : "edit-event-form-field";
    const formValues = getFormValues(FORM_NAME);
    const { startdatetime, startdate, enddate, enddatetime } = formValues;
    if (isChecked) {
      const start = getDateTimeValueFromDateTimeField(startdatetime);
      const end = getDateTimeValueFromDateTimeField(enddatetime);
      chageFormField(
        FORM_NAME,
        "enddate",
        moment(end, getUserTimeSettings("dateFormat"))
      );
      chageFormField(
        FORM_NAME,
        "startdate",
        moment(start, getUserTimeSettings("dateFormat"))
      );
    } else {
      const { time: sTime } = startdatetime;
      const { time: eTime } = enddatetime;
      const updatedStartdate = {
        date: moment(startdate, getUserTimeSettings("dateFormat")),
        time: sTime
      };
      const updatedEnddate = {
        date: moment(enddate, getUserTimeSettings("dateFormat")),
        time: eTime
      };
      chageFormField(FORM_NAME, "startdatetime", updatedStartdate);
      chageFormField(FORM_NAME, "enddatetime", updatedEnddate);
    }
  };

  calculateServiceDurationOnAllDayChange = isChecked => {
    const { isCreateEvent, isJDMenabled, chageFormField } = this.props;
    const FORM_NAME = isCreateEvent
      ? "create-event-form-field"
      : "edit-event-form-field";
    const measureUnitInHours =
      getSettingValue(DCON001_SET054, HOURS) === HOURS || isJDMenabled;
    const formValues = getFormValues(FORM_NAME);
    const {
      startdatetime,
      startdate,
      enddate,
      enddatetime,
      driveaftertext,
      drivebeforetext,
      overheadaftertext,
      overheadbeforetext,
      breaktime
    } = formValues;
    if (isChecked) {
      const diffInMinutes =
        (moment(moment(enddate).format(DATE_FORMAT)).diff(
          moment(startdate).format(DATE_FORMAT),
          "day"
        ) +
          1) *
        60 *
        24;
      chageFormField(
        FORM_NAME,
        "serviceduration",
        measureUnitInHours ? getMinutesToHours(diffInMinutes) : diffInMinutes
      );
      this.eventFields = {
        driveaftertext,
        drivebeforetext,
        overheadaftertext,
        overheadbeforetext
      };
      chageFormField(
        FORM_NAME,
        "driveaftertext",
        measureUnitInHours ? "00 : 00" : "0"
      );
      chageFormField(
        FORM_NAME,
        "drivebeforetext",
        measureUnitInHours ? "00 : 00" : "0"
      );
      chageFormField(
        FORM_NAME,
        "overheadaftertext",
        measureUnitInHours ? "00 : 00" : "0"
      );
      chageFormField(
        FORM_NAME,
        "overheadbeforetext",
        measureUnitInHours ? "00 : 00" : "0"
      );
    } else {
      const start = getDateTimeValueFromDateTimeField(startdatetime);
      const end = getDateTimeValueFromDateTimeField(enddatetime);
      const totlaMinutes = end.diff(start, "minutes");
      let serviceDuration = 0;
      const isBefore = this.handleDateTimeCheck(start, end);
      const {
        driveaftertext: dAfter,
        drivebeforetext: dBefore,
        overheadaftertext: ovrAfter,
        overheadbeforetext: ovrBefore
      } = this.eventFields;
      if (isBefore) return undefined;
      if (measureUnitInHours) {
        serviceDuration = getServiceDurationInMinForHourEnabled({
          totlaMinutes,
          ...this.eventFields,
          breaktime
        });
      } else {
        serviceDuration =
          (+totlaMinutes || 0) -
          ((+dAfter || 0) +
            (+dBefore || 0) +
            (+ovrAfter || 0) +
            (+ovrBefore || 0));
      }
      chageFormField(
        FORM_NAME,
        "serviceduration",
        measureUnitInHours
          ? getMinutesToHours(serviceDuration)
          : serviceDuration
      );

      chageFormField(FORM_NAME, "driveaftertext", dAfter);
      chageFormField(FORM_NAME, "drivebeforetext", dBefore);
      chageFormField(FORM_NAME, "overheadaftertext", ovrAfter);
      chageFormField(FORM_NAME, "overheadbeforetext", ovrBefore);
    }
  };

  rememberMyPreferenceChecked = data => {
    const { value } = data;

    if (value && value === "on") {
      const { onTreeConfChanged } = this.props;
      const {
        isDonotOverlapChecked,
        isRespectTechWorkHoursChecked,
        isRespectMachineAccessHoursChecked
      } = this.state;
      const changed = {};
      changed.wo_respectTechnincianWorkHours = isRespectTechWorkHoursChecked
        ? "true"
        : "false";
      changed.wo_respectMachineAccessHours = isRespectMachineAccessHoursChecked
        ? "true"
        : "false";
      changed.wo_doNotOverlapExistingEvents = isDonotOverlapChecked
        ? "true"
        : "false";
      onTreeConfChanged(changed);
      this.setState({ shouldRememberMyPreference: value && value === "on" });
    }
  };

  shceduleAsLongJobChecked = data => {
    const { value } = data;
    this.setState({ isShceduleAsLongJobChecked: value && value === "on" });
  };

  respectTechWorkHoursChecked = data => {
    const { value } = data;
    this.setState({ isRespectTechWorkHoursChecked: value && value === "on" });
    const { onTreeConfChanged } = this.props;
    const { shouldRememberMyPreference } = this.state;
    if (shouldRememberMyPreference) {
      const changed = {};
      changed.wo_respectTechnincianWorkHours =
        value === "on" ? "true" : "false";
      onTreeConfChanged(changed);
    }
  };

  respectMachineAccessHoursChecked = data => {
    const { value } = data;
    const isRespectMachineAccessHoursChecked = value && value === "on";
    this.setState({
      isRespectMachineAccessHoursChecked
    });
    const { onTreeConfChanged, removeErrorMessage } = this.props;
    const { shouldRememberMyPreference } = this.state;
    if (shouldRememberMyPreference) {
      const changed = {};
      changed.wo_respectMachineAccessHours = value === "on" ? "true" : "false";
      onTreeConfChanged(changed);
    }
    if (!isRespectMachineAccessHoursChecked) {
      removeErrorMessage(getDisplayValue(EVENTSTAG065));
    }
  };

  donotOverlapChecked = data => {
    const { value } = data;
    this.setState({ isDonotOverlapChecked: value && value === "on" });
    const { onTreeConfChanged } = this.props;
    const { shouldRememberMyPreference } = this.state;
    if (shouldRememberMyPreference) {
      const changed = {};
      changed.wo_doNotOverlapExistingEvents = value === "on" ? "true" : "false";
      onTreeConfChanged(changed);
    }
  };

  formatTimeFieldValue = (data, fieldName) => {
    const { chageFormField, isCreateEvent, isJDMenabled } = this.props;
    const FORM_NAME = isCreateEvent
      ? "create-event-form-field"
      : "edit-event-form-field";
    const formValues = getFormValues(FORM_NAME);
    const fieldValue = formValues[fieldName] || "0";
    const measureUnitInHours =
      getSettingValue(DCON001_SET054, HOURS) === HOURS || isJDMenabled;
    const isFieldInHHMMFormat = fieldValue.toString().split(":").length > 1;
    let convertedFieldValue;
    if (measureUnitInHours) {
      if (isFieldInHHMMFormat) {
        convertedFieldValue = getHoursToMinutes(fieldValue);
      } else {
        convertedFieldValue = convertHoursToMinutes(fieldValue);
      }
    } else if (isFieldInHHMMFormat) {
      convertedFieldValue = getHoursToMinutes(fieldValue);
    } else {
      convertedFieldValue = fieldValue;
    }
    chageFormField(
      FORM_NAME,
      fieldName,
      measureUnitInHours
        ? getMinutesToHours(convertedFieldValue)
        : convertedFieldValue
    );
  };

  formatDatevalue = dateValue => {
    const date = moment(dateValue.date, getUserTimeSettings("dateFormat"));
    const time = moment(dateValue.time, getUserTimeSettings("timeFormat"));
    return { date, time };
  };

  updateTimeFieldValues = (data, fieldName, showAdvancedMode) => {
    let dateTimeObj;
    const { handleErrorMessage } = this.props;
    switch (fieldName) {
      case "serviceduration":
        this.formatTimeFieldValue(data, fieldName);
        if (this.autoSyncSvcDuration) {
          this.updateServiceDurationOrDepartTime(
            data,
            "updateEndDate",
            fieldName,
            showAdvancedMode
          );
        } else {
          this.setState({ shouldShowDepartTimeAlert: true });
        }
        break;
      case "startdatetime":
      case "enddatetime":
        if (data) dateTimeObj = this.formatDatevalue(data);
        this.updateServiceDurationOrDepartTime(
          dateTimeObj,
          fieldName === "startdatetime"
            ? "updateEndDate"
            : "updateServiceDuration",
          fieldName,
          showAdvancedMode
        );
        break;
      case "drivebeforetext":
      case "driveaftertext":
      case "minimumscheduleduration":
      case "overheadbeforetext":
      case "overheadaftertext":
        this.formatTimeFieldValue(data, fieldName);
        if (this.autoSyncSvcDuration) {
          this.updateServiceDurationOrDepartTime(
            data,
            "updateEndDate",
            fieldName,
            showAdvancedMode
          );
        }

        break;
      case "scopechange":
      case "variance":
        this.formatTimeFieldValue(data, fieldName);
        break;
      default:
        this.updateServiceDurationOrDepartTime(data);
    }
    handleErrorMessage("");
  };

  updateServiceDurationOrDepartTime = (
    dateValue,
    fieldToUpdate,
    field,
    showAdvancedMode
  ) => {
    const {
      chageFormField,
      isCreateEvent,
      onHandleEventBusinessHours,
      isJDMenabled
    } = this.props;
    const FORM_NAME = isCreateEvent
      ? "create-event-form-field"
      : "edit-event-form-field";
    const formValues = getFormValues(FORM_NAME);
    const {
      startdatetime,
      driveaftertext,
      drivebeforetext,
      overheadaftertext,
      overheadbeforetext,
      breaktime,
      serviceduration,
      enddatetime,
      techId
    } = formValues;
    const start = getDateTimeValueFromDateTimeField(
      field === "startdatetime" ? dateValue : startdatetime
    );
    const end = getDateTimeValueFromDateTimeField(
      field === "enddatetime" && dateValue ? dateValue : enddatetime
    );
    const totlaMinutes = end.diff(start, "minutes");
    const measureUnitInHours =
      getSettingValue(DCON001_SET054, HOURS) === HOURS || isJDMenabled;
    let serviceDuration = 0;
    if (fieldToUpdate === "updateServiceDuration") {
      const isBefore = this.handleDateTimeCheck(start, end);
      if (isBefore) return undefined;
      if (measureUnitInHours) {
        serviceDuration = getServiceDurationInMinForHourEnabled({
          totlaMinutes,
          driveaftertext,
          drivebeforetext,
          overheadaftertext,
          overheadbeforetext,
          breaktime
        });
      } else {
        serviceDuration = totlaMinutes;
        serviceDuration =
          (+totlaMinutes || 0) -
          ((+driveaftertext || 0) +
            (+drivebeforetext || 0) +
            (+overheadaftertext || 0) +
            (+overheadbeforetext || 0));
      }
      chageFormField(
        FORM_NAME,
        "serviceduration",
        measureUnitInHours
          ? getMinutesToHours(serviceDuration)
          : serviceDuration
      );
    } else if (fieldToUpdate === "updateEndDate") {
      let durationInMinutes = 0;
      if (measureUnitInHours) {
        durationInMinutes = getTotalDurationInMinForHourEnabled({
          serviceduration,
          driveaftertext,
          drivebeforetext,
          overheadaftertext,
          overheadbeforetext,
          breaktime
        });
      } else {
        durationInMinutes =
          (+serviceduration || 0) +
          (+driveaftertext || 0) +
          (+drivebeforetext || 0) +
          (+overheadaftertext || 0) +
          (+overheadbeforetext || 0) +
          (+breaktime || 0);
      }
      if (isJDMenabled) {
        const reduceDriveTime = measureUnitInHours
          ? getHoursToMinutes(drivebeforetext) +
            getHoursToMinutes(driveaftertext)
          : drivebeforetext + driveaftertext;
        durationInMinutes -= reduceDriveTime;
      }
      const { isAllDayEvent } = this.state;
      const endDateTimeValue = start.add(
        isAllDayEvent ? durationInMinutes - 1 : durationInMinutes,
        "minutes"
      );

      const updatedEnddate = {
        date: moment(endDateTimeValue, getUserTimeSettings("dateFormat")),
        time: moment(endDateTimeValue, getUserTimeSettings("timeFormat"))
      };
      chageFormField(FORM_NAME, "enddatetime", updatedEnddate);
      chageFormField(
        FORM_NAME,
        "enddate",
        moment(endDateTimeValue, getUserTimeSettings("dateFormat"))
      );
      if (
        (field === "startdatetime" || field === "enddatetime") &&
        !showAdvancedMode
      ) {
        onHandleEventBusinessHours(!showAdvancedMode, dateValue, field);
      }
    }
    this.setState({ shouldShowDepartTimeAlert: true });
  };

  onArriveTimeChange = data => {
    this.setState({ shouldShowDepartTimeAlert: true });
  };

  displayFormFields = fieldArr =>
    fieldArr.map(field => {
      const componentObject = getComponentForField(field);
      const {
        componentField: ComponentField,
        componentProps,
        isInputfield
      } = componentObject;
      return (
        <GridItem cols={6} className="FormFieldForm__component">
          {isInputfield && (
            <ComponentField {...componentProps}>
              <Input />
            </ComponentField>
          )}
          {!isInputfield && <ComponentField {...componentProps} />}
        </GridItem>
      );
    });

  renderFormFields = () => {
    const fields = getAllUpdateFields();
    const splitFields = chunk(fields, 2);
    const { length } = fields;
    if (length) {
      return splitFields.map(fieldArr => (
        <GridRow cols={12}>{this.displayFormFields(fieldArr)}</GridRow>
      ));
    }
    return (
      <Container style={{ padding: "4px 8px" }}>
        <Textarea name={EVENTSTAG089} value={getDisplayValue(EVENTSTAG089)} />
      </Container>
    );
  };

  getFormField = (fieldName, fieldOptions) =>
    Object.assign(
      {},
      formDisplayFields.find(field => field.name === fieldName),
      fieldOptions
    );

  getEditInitialValues = (eventData, isResizeEvent = false) => {
    const { isJDMenabled, isLJMenabled, schedulingOption } = this.props;
    const { data, resizeStartDate, resizeEndDate } = eventData;
    const {
      endDate,
      id,
      location,
      startDate,
      subject,
      TechId,
      IsAllDayEvent,
      description,
      ownerId,
      techName,
      Overhead_Time_After,
      Overhead_Time_Before,
      Driving_Time,
      Driving_Time_Home,
      Break_Time_Total,
      woFields
    } = data;

    let { Service_Duration } = data;
    const measureUnitInHours =
      getSettingValue(DCON001_SET054, HOURS) === HOURS || isJDMenabled;
    this.eventId = id;
    this.techId = TechId;
    this.OwnerId = ownerId;
    let startDateTime = !isJDMenabled
      ? startDate
      : moment(startDate)
          .add(Driving_Time, "minutes")
          .toDate();
    let endDateTime = !isJDMenabled
      ? endDate
      : moment(endDate)
          .subtract(Driving_Time_Home, "minutes")
          .toDate();
    let eventStartDate = !isJDMenabled
      ? startDate
      : moment(startDate)
          .add(Driving_Time, "minutes")
          .toDate();
    let eventEndDate = !isJDMenabled
      ? endDate
      : moment(endDate)
          .subtract(Driving_Time_Home, "minutes")
          .toDate();
    let allDayEventEndDate = moment(endDate).subtract(1, "minutes");
    let resizeedStartTime;
    if (isResizeEvent) {
      const rsdate = moment(resizeStartDate, DATE_TIME_FORMAT);
      const redate = moment(resizeEndDate, DATE_TIME_FORMAT);
      const roundOffTime = parseInt(getSettingValue(DCON001_SET011, 15), 10);

      if (!isNaN(roundOffTime) && roundOffTime > 0) {
        resizeedStartTime = moment(
          resizeStartDate,
          getUserTimeSettings("timeFormat")
        );
        resizeedStartTime.minutes(
          Math.round(resizeedStartTime.minutes() / roundOffTime) * roundOffTime
        );
        resizeedStartTime = resizeedStartTime.format(
          getUserTimeSettings("timeFormat")
        );
      }
      Service_Duration = moment(redate).diff(moment(rsdate), "minutes");
      Service_Duration =
        (+Service_Duration || 0) -
        (+Driving_Time_Home || 0) -
        (+Driving_Time || 0) -
        (+Overhead_Time_After || 0) -
        (+Overhead_Time_Before || 0) -
        (+Break_Time_Total || 0);
      Service_Duration *= 60; // convert back minutes to seconds
      eventStartDate = resizeStartDate;
      startDateTime = resizeStartDate;
      eventEndDate = resizeEndDate;
      endDateTime = resizeEndDate;
      const isNoNLongJobEvent =
        (isJDMenabled && !isLJMenabled) ||
        schedulingOption === JDM_ENABLED_LJS_DISABELD ||
        schedulingOption === ALL_OPTION_DISABLED ||
        schedulingOption == null;
      if (isJDMenabled) {
        eventStartDate = moment(resizeStartDate).add(
          +Driving_Time || 0,
          "minutes"
        );
        startDateTime = moment(resizeStartDate).add(
          +Driving_Time || 0,
          "minutes"
        );
        eventEndDate = moment(resizeEndDate).subtract(
          +Driving_Time_Home || 0,
          "minutes"
        );
        endDateTime = moment(resizeEndDate).subtract(
          +Driving_Time_Home || 0,
          "minutes"
        );
      }

      const allDayEndDateConversion = moment(resizeEndDate).subtract(
        1,
        "minutes"
      );
      allDayEventEndDate = allDayEndDateConversion;
    }
    const initialValue = {
      alldayevents: IsAllDayEvent ? "on" : null,
      enddatetime: {
        date: IsAllDayEvent
          ? moment(allDayEventEndDate, getUserTimeSettings("dateFormat"))
          : moment(eventEndDate, getUserTimeSettings("dateFormat")),
        time: IsAllDayEvent
          ? moment(allDayEventEndDate, getUserTimeSettings("timeFormat"))
          : moment(endDateTime, getUserTimeSettings("timeFormat"))
      },
      eventsubject: subject,
      descriptionfieldarea: description,
      locationnote: location,
      startdatetime: {
        date: moment(eventStartDate, getUserTimeSettings("dateFormat")),
        time: isResizeEvent
          ? moment(startDateTime, getUserTimeSettings("timeFormat"))
          : moment(startDateTime, getUserTimeSettings("timeFormat"))
      },
      technicianname: techName,
      enddate: IsAllDayEvent
        ? moment(allDayEventEndDate, getUserTimeSettings("dateFormat"))
        : moment(eventEndDate, getUserTimeSettings("dateFormat")),
      startdate: moment(eventStartDate, getUserTimeSettings("dateFormat")),
      serviceduration: measureUnitInHours
        ? getSecondsToHours(Service_Duration)
        : parseInt(Service_Duration / 60),
      driveaftertext: measureUnitInHours
        ? getMinutesToHours(Driving_Time_Home)
        : parseInt(Driving_Time_Home),
      drivebeforetext: measureUnitInHours
        ? getMinutesToHours(Driving_Time)
        : parseInt(Driving_Time),
      overheadbeforetext: measureUnitInHours
        ? getMinutesToHours(Overhead_Time_Before)
        : parseInt(Overhead_Time_Before),
      overheadaftertext: measureUnitInHours
        ? getMinutesToHours(Overhead_Time_After)
        : parseInt(Overhead_Time_After),
      breaktime: measureUnitInHours
        ? getMinutesToHours(Break_Time_Total)
        : parseInt(Break_Time_Total),
      updateprimarytechnicians: null,
      deleteeventforothertechnicians: null,
      estimatedduration: getMinutesToHours(
        woFields[WO_ESTIMATED_DURATION_FIELD]
      ),
      scopechange: getMinutesToHours(woFields[WO_SCOPE_CHANGE_FIELD]),
      variance: getMinutesToHours(woFields[WO_VARIANCE_FIELD]),
      revisedduration: getMinutesToHours(woFields[WO_REVISED_DURATION_FIELD])
    };
    getWOUpdateInitialvalues(initialValue, data);
    return initialValue;
  };

  validateTimeValues = evt => {
    const charCode = evt.which ? evt.which : evt.charCode;
    if (charCode > 31 && (charCode < 48 || charCode > 58)) {
      evt.preventDefault();
      return false;
    }
    return true;
  };

  validateDateTimeObj = dateValue => {
    const newTime = moment(
      dateValue.time,
      getUserTimeSettings("timeFormat"),
      true
    );
    const newDate = moment(
      dateValue.date,
      getUserTimeSettings("dateFormat"),
      true
    );
    if (!newTime.isValid() || !newDate.isValid()) {
      return false;
    }
    return true;
  };

  ignoreDateUpdate = (dateValue, fieldType, showAdvancedMode) => {
    const { onHandleEventBusinessHours, handleErrorMessage } = this.props;
    let dateTimeObj;
    dateTimeObj = this.formatDatevalue(dateValue);
    if (!showAdvancedMode) {
      onHandleEventBusinessHours(!showAdvancedMode, dateTimeObj, fieldType);
    }
    if (fieldType === "startdatetime") {
      this.setState({ shouldShowDepartTimeAlert: true });
    }
    handleErrorMessage("");
  };

  calculateSLA = draggedWO => {
    const { isModalLoaded } = this.state;
    const FORM_NAME = "create-event-form-field";
    let isOnSiteOverdue;

    let isRestoredue;

    let isResolutionOverdue;

    let slaOnSiteValue;

    let slaRestorationValue;

    let slaResolutionValue;
    if (isModalLoaded) {
      const formValues = getFormValues(FORM_NAME);
      const { startdatetime, enddatetime } = formValues;
      const startDateInit = moment(startdatetime.date).format(DATE_FORMAT);
      const endDateInit = moment(enddatetime.date).format(DATE_FORMAT);
      const startMinutes =
        startdatetime.time.hour() * 60 + startdatetime.time.minute();
      const endMinutes =
        enddatetime.time.hour() * 60 + enddatetime.time.minute();
      const startDateConversion = moment(startDateInit).add(
        startMinutes,
        "minutes"
      );
      const endDateConversion = moment(endDateInit).add(endMinutes, "minutes");
      const isCustomerCommit =
        getSettingValue(SLAT003_SET001) === CUSTOMER_COMMITMENT;
      slaOnSiteValue = getSlaValues(draggedWO, isCustomerCommit, "onsite");
      slaResolutionValue = getSlaValues(
        draggedWO,
        isCustomerCommit,
        "resolution"
      );
      slaRestorationValue = getSlaValues(
        draggedWO,
        isCustomerCommit,
        "restoration"
      );
      isOnSiteOverdue = moment(
        moment(slaOnSiteValue, DATE_TIME_FORMAT)
      ).isSameOrAfter(startDateConversion);
      isRestoredue = moment(
        moment(slaRestorationValue, DATE_TIME_FORMAT)
      ).isSameOrAfter(endDateConversion);
      isResolutionOverdue = moment(
        moment(slaResolutionValue, DATE_TIME_FORMAT)
      ).isSameOrAfter(endDateConversion);
    }

    return {
      isOnSiteOverdue,
      isRestoredue,
      isResolutionOverdue,
      slaOnSiteValue,
      slaRestorationValue,
      slaResolutionValue
    };
  };
  getDateTimeObject = dateValue => {
    return {
      date: moment(dateValue.value).format(getUserTimeSettings("dateFormat")),
      time: moment(dateValue.value).format(getUserTimeSettings("timeFormat"))
    };
  };
  createTabs = () => {
    const children = [];
    let {
      isBudgetOpen,
      isEventUpdated,
      isEventCreated,
      isAllDayEvent,
      isShceduleAsLongJobChecked,
      isRespectMachineAccessHoursChecked,
      isRespectTechWorkHoursChecked,
      isDonotOverlapChecked,
      calculatedStartDate,
      shouldShowDepartTimeAlert,
      shouldRememberMyPreference
    } = this.state;
    const {
      editEventResourceRecord,
      isCreateEvent,
      eventData,
      eventSubject,
      draggedWO,
      isClassicMode,
      isJDMenabled,
      isLJMenabled,
      isSET007Enabled,
      schedulingOption,
      wo_isAlldayEvent,
      isResizeEvent,
      onHandleEventBusinessHours,
      handleSubjectChange,
      isTechnicianChanged,
      updateTechCheckbox,
      rememberMyPreferenceTechUpdateAndDeleteChecked,
      updatePrimaryTech,
      deleteEventForTech
    } = this.props;

    let { dropTime, TechId, ownerId, woFields, dropDate, resource } = eventData;
    const { data } = isCreateEvent ? resource : editEventResourceRecord;
    const { name: technicianName, Id: techId } = data;
    this.schedulingOption = schedulingOption;

    const roundOffTime = parseInt(getSettingValue(DCON001_SET011, 15), 10);
    if (!isNaN(roundOffTime) && roundOffTime > 0) {
      dropTime = moment(dropTime, getUserTimeSettings("timeFormat"));
      dropTime.minutes(
        Math.round(dropTime.minutes() / roundOffTime) * roundOffTime
      );
      dropTime = dropTime.format(getUserTimeSettings("timeFormat"));
    }
    let iniValue;
    if (isCreateEvent) {
      iniValue = getInitialvalues(
        dropDate,
        dropTime,
        technicianName,
        draggedWO,
        isJDMenabled,
        eventSubject,
        wo_isAlldayEvent == "true",
        isLJMenabled,
        schedulingOption
      );
      iniValue.techId = techId;
      iniValue.OwnerId = techId;
    } else {
      iniValue = this.getEditInitialValues(eventData, isResizeEvent);
      iniValue.techId = TechId;
      iniValue.OwnerId = ownerId;
      iniValue.techSFId = null;
      if (data[TECH_SALESFORCE_USER_FIELD]) {
        iniValue.techSFId = data[TECH_SALESFORCE_USER_FIELD];
      }
      const { technicianName } = iniValue;
    }

    const isSaleforceEvent =
      getSettingValue(GLOB001_GBL025) === SALESFORCE_EVENT;
    if (isSaleforceEvent && data[TECH_SALESFORCE_USER_FIELD]) {
      iniValue.OwnerId = data[TECH_SALESFORCE_USER_FIELD];
    }
    iniValue.techSFId = null;
    if (data[TECH_SALESFORCE_USER_FIELD]) {
      iniValue.techSFId = data[TECH_SALESFORCE_USER_FIELD];
    }
    const isSubjectEditable = JSON.parse(
      getSettingValue(DCON001_SET037, FALSE).toLowerCase()
    );
    const shouldAllowDoubleBooking =
      getSettingValue(DCON001_SET025) === DOUBLE_BOOKING_ALLOW;
    const showAdvancedMode = !isClassicMode && isJDMenabled;
    const isNewWO = isCreateEvent
      ? draggedWO[WO_DISPATCH_STATUS_FIELD] === "New"
      : isCreateEvent;
    const jdmScheduledLabel = `${getMinutesToHours(
      isCreateEvent
        ? draggedWO[WO_SCHEDULED_DURATION_FIELD]
        : woFields[WO_SCHEDULED_DURATION_FIELD]
    )} ${getDisplayValue(EVENTSTAG015)}`;
    const jdmUnscheduledLabel = `${getMinutesToHours(
      isCreateEvent
        ? draggedWO[WO_UNSCHEDULED_DURATIONS]
        : woFields[WO_UNSCHEDULED_DURATIONS]
    )} ${getDisplayValue(EVENTSTAG017)}`;
    const measureUnitInHours =
      getSettingValue(DCON001_SET054, HOURS) === HOURS || isJDMenabled;
    const inputPattern = measureUnitInHours
      ? "^[0-9]{2,}:^[0-9]{2}"
      : "^[0-9]{1,}";
    const showOverHead = getSettingValue(DCON005_SET003) === "True";
    const showBreakTime =
      getSettingValue(DCON005_SET004) === "True" && !showAdvancedMode;
    const FORM_NAME = isCreateEvent
      ? "create-event-form-field"
      : "edit-event-form-field";
    const {
      isOnSiteOverdue,
      isRestoredue,
      isResolutionOverdue,
      slaOnSiteValue,
      slaRestorationValue,
      slaResolutionValue
    } = isCreateEvent ? this.calculateSLA(draggedWO) : {};
    this.autoCalcEndDate =
      (JSON.parse(getUserSetting(AUTO_CALC_END_DATE, false)) &&
        !showAdvancedMode) ||
      (JSON.parse(getUserSetting(AUTO_CALC_END_DATE, false)) &&
        showAdvancedMode &&
        !isLJMenabled);
    this.autoSyncSvcDuration =
      (JSON.parse(getUserSetting(AUTO_SYNC_SVC_DURATION, false)) &&
        !showAdvancedMode) ||
      (JSON.parse(getUserSetting(AUTO_SYNC_SVC_DURATION, false)) &&
        showAdvancedMode &&
        !isLJMenabled);
    let showOnlyDateField;
    if (showAdvancedMode) {
      showOnlyDateField = false;
    } else if (!showAdvancedMode && isAllDayEvent) {
      showOnlyDateField = true;
    }

    let ljsAlertMessage = "";
    if (!isSET007Enabled) {
      ljsAlertMessage = getDisplayValue(EVENTSTAG063);
    } else if (isLJMenabled) {
      ljsAlertMessage = getDisplayValue(EVENTSTAG035);
    } else {
      ljsAlertMessage = getDisplayValue(EVENTSTAG135);
    }
    const { Name: assignedName } = getFieldValue(
      isCreateEvent ? draggedWO : woFields,
      WORKORDER_TECHNICIAN_API_REF,
      {}
    );
    let disablePrimaryTech = true;
    if (assignedName !== technicianName) {
      disablePrimaryTech = false;
    } else if (isTechnicianChanged) {
      disablePrimaryTech = false;
    }
    const minStepInterval = roundOffTime || 15;
    // isAllDayEvent = isAllDayEvent && !showAdvancedMode;
    isAllDayEvent = !isCreateEvent
      ? isAllDayEvent
      : isAllDayEvent && !showAdvancedMode;
    const isLongJobWo =
      showAdvancedMode &&
      (schedulingOption === JDM_LJS_ENABLED ||
        schedulingOption === JDM_ENABLED_LJS_DISABELD);
    children.push(
      <Tab
        className="CreateEvent__tabs"
        eventKey="1"
        title={getDisplayValue(EVENTSTAG016)}
      >
        <Grid class="CreateEvent__wrapper" isVertical>
          <GridRow cols={12}>
            <GridItem cols={8}>
              {getTextField(
                this.getFormField("technicianname", { isDisabled: true })
              )}
            </GridItem>
          </GridRow>
          {!isNewWO && (
            <GridRow cols={12}>
              <GridItem cols={4} noFlex>
                {getCheckBoxField(
                  this.getFormField("updateprimarytechnicians", {
                    onChange: data =>
                      updateTechCheckbox(data, "updateprimarytechnicians"),
                    checked: updatePrimaryTech,
                    isDisabled: isCreateEvent ? isNewWO : disablePrimaryTech,
                    value: assignedName
                      ? `${getDisplayValue(EVENTSTAG031)} ${getDisplayValue(
                          EVENTSTAG068
                        )} ${assignedName})`
                      : getDisplayValue(EVENTSTAG031)
                  })
                )}
              </GridItem>
              <GridItem cols={4} noFlex>
                {getCheckBoxField(
                  this.getFormField("deleteeventforothertechnicians", {
                    onChange: data =>
                      updateTechCheckbox(
                        data,
                        "deleteeventforothertechnicians"
                      ),
                    checked: (disablePrimaryTech
                    ? !disablePrimaryTech
                    : updatePrimaryTech)
                      ? disablePrimaryTech
                        ? !disablePrimaryTech
                        : deleteEventForTech
                      : false,
                    // isDisabled: isCreateEvent ? isNewWO : disablePrimaryTech,
                    isDisabled: disablePrimaryTech || !updatePrimaryTech,
                    value: getDisplayValue(EVENTSTAG033)
                  })
                )}
              </GridItem>
              <GridItem>
                {getCheckBoxField(
                  this.getFormField("remembertechupdateanddelete", {
                    onChange: data =>
                      rememberMyPreferenceTechUpdateAndDeleteChecked(data),
                    value: getDisplayValue(TAG220),
                    isDisabled: isCreateEvent ? isNewWO : disablePrimaryTech
                  })
                )}
              </GridItem>
            </GridRow>
          )}
          <GridRow cols={12}>
            <GridItem cols={8}>
              {getTextField(
                this.getFormField("eventsubject", {
                  isDisabled: !isSubjectEditable,
                  onChange: data => handleSubjectChange(data)
                })
              )}
            </GridItem>
          </GridRow>
          <GridRow cols={12}>
            <GridItem cols={8}>
              {getTextField(this.getFormField("locationnote", {}))}
            </GridItem>
          </GridRow>
          <GridRow cols={12}>
            <GridItem cols={8}>
              {getTextAreaField(this.getFormField("descriptionfieldarea", {}))}
            </GridItem>
          </GridRow>

          <GridRow cols={12}>
            <GridItem cols={showAdvancedMode ? 8 : 12} hasBorderTop>
              {showAdvancedMode && calculatedStartDate && (
                <GridRow>
                  <GridItem>
                    <Label className="CreateEvent__errorColor">
                      {showAdvancedMode && calculatedStartDate
                        ? `${getDisplayValue(
                            EVENTSTAG055
                          )}  ${calculatedStartDate}`
                        : ""}
                    </Label>
                  </GridItem>
                </GridRow>
              )}
              <GridRow>
                <GridItem noFlex>
                  {isAllDayEvent ? (
                    <GridItem>
                      {getDateInputField(
                        this.getFormField("startdate", {
                          label: isJDMenabled ? "EVENTSTAG018" : "TAG351",
                          dateFormat: getUserTimeSettings("dateFormat"),
                          onChange: this.autoCalcEndDate
                            ? dateValue => {
                                if (
                                  validatedateObj(
                                    this.getDateTimeObject(dateValue)
                                  ) &&
                                  this.validateDateTimeObj(
                                    this.getDateTimeObject(dateValue)
                                  )
                                ) {
                                  this.updateTimeFieldValues(
                                    this.getDateTimeObject(dateValue),
                                    "startdatetime",
                                    showAdvancedMode
                                  );
                                }
                              }
                            : dateValue => {
                                if (
                                  validatedateObj(
                                    this.getDateTimeObject(dateValue)
                                  ) &&
                                  this.validateDateTimeObj(
                                    this.getDateTimeObject(dateValue)
                                  )
                                ) {
                                  this.ignoreDateUpdate(
                                    this.getDateTimeObject(dateValue),
                                    "startdatetime",
                                    showAdvancedMode
                                  );
                                }
                              }
                        })
                      )}
                    </GridItem>
                  ) : (
                    <GridItem>
                      {getDateTimeInputField(
                        this.getFormField("startdatetime", {
                          label: isJDMenabled ? "EVENTSTAG018" : "TAG351",
                          dateInputProps: {
                            dateFormat: getUserTimeSettings("dateFormat")
                          },
                          timeInputProps: {
                            step: minStepInterval,
                            timeFormat: getUserTimeSettings("timeFormat")
                          },
                          onInputValueChange: this.autoCalcEndDate
                            ? dateValue => {
                                if (
                                  validatedateObj(dateValue) &&
                                  this.validateDateTimeObj(dateValue)
                                ) {
                                  this.updateTimeFieldValues(
                                    dateValue,
                                    "startdatetime",
                                    showAdvancedMode
                                  );
                                }
                              }
                            : dateValue => {
                                if (
                                  validatedateObj(dateValue) &&
                                  this.validateDateTimeObj(dateValue)
                                ) {
                                  this.ignoreDateUpdate(
                                    dateValue,
                                    "startdatetime",
                                    showAdvancedMode
                                  );
                                }
                              }
                        })
                      )}
                    </GridItem>
                  )}
                </GridItem>
                <GridItem className="marginTopTwentyEight" noFlex>
                  {showAdvancedMode && slaOnSiteValue && (
                    <span
                      className={
                        isOnSiteOverdue
                          ? "CreateEvent__time-section"
                          : "CreateEvent__time-section_overduetime"
                      }
                    >
                      <Icon icon="clock" align="left" size="x-small" />
                      <span className="CreateEvent_time_label">On Site</span>
                      <Label className="CreateEvent_time_text" type="bordered">
                        {slaOnSiteValue}
                      </Label>
                    </span>
                  )}
                </GridItem>
              </GridRow>

              <GridRow cols={8} hasBorderTop className="textCapitalize">
                <GridItem noFlex>
                  {getTextField(
                    this.getFormField("serviceduration", {
                      inputPattern,
                      onKeyPress: evt => this.validateTimeValues(evt),
                      isDisabled: isAllDayEvent,
                      showHHMMFormat: measureUnitInHours,
                      onBlur: dateValue =>
                        this.updateTimeFieldValues(
                          dateValue,
                          "serviceduration",
                          showAdvancedMode
                        )
                    })
                  )}
                </GridItem>
                <GridItem noFlex className="marginTopTwentyEight">
                  {!(showAdvancedMode && isCreateEvent) &&
                    getCheckBoxField(
                      this.getFormField("alldayevents", {
                        value: getDisplayValue(TAG247),
                        onChange: this.allDayEventChecked,
                        checked: isAllDayEvent
                      })
                    )}
                </GridItem>

                <GridItem noFlex>
                  {!showAdvancedMode &&
                    getTextField(
                      this.getFormField("drivebeforetext", {
                        onKeyPress: evt => this.validateTimeValues(evt),
                        isDisabled: isAllDayEvent,
                        showHHMMFormat: measureUnitInHours,
                        onBlur: value =>
                          this.updateTimeFieldValues(
                            value,
                            "drivebeforetext",
                            showAdvancedMode
                          )
                      })
                    )}
                </GridItem>
                <GridItem noFlex>
                  {!showAdvancedMode &&
                    getTextField(
                      this.getFormField("driveaftertext", {
                        onKeyPress: evt => this.validateTimeValues(evt),
                        isDisabled: isAllDayEvent,
                        showHHMMFormat: measureUnitInHours,
                        onBlur: value =>
                          this.updateTimeFieldValues(
                            value,
                            "driveaftertext",
                            showAdvancedMode
                          )
                      })
                    )}
                </GridItem>
                <GridItem noFlex className="marginTopTwentyEight">
                  {isLongJobWo && <Label>{jdmScheduledLabel}</Label>}
                </GridItem>

                <GridItem noFlex className="marginTopTwentyEight">
                  {isLongJobWo && <Label>{jdmUnscheduledLabel}</Label>}
                </GridItem>
              </GridRow>

              {showAdvancedMode && (
                <GridRow cols={8} hasBorderTop className="textCapitalize">
                  <GridItem noFlex>
                    {getTextField(
                      this.getFormField("drivebeforetext", {
                        onKeyPress: evt => this.validateTimeValues(evt),
                        isDisabled: isAllDayEvent,
                        showHHMMFormat: measureUnitInHours,
                        onBlur: value =>
                          this.updateTimeFieldValues(
                            value,
                            "drivebeforetext",
                            showAdvancedMode
                          )
                      })
                    )}
                  </GridItem>
                  <GridItem noFlex>
                    {getTextField(
                      this.getFormField("driveaftertext", {
                        onKeyPress: evt => this.validateTimeValues(evt),
                        isDisabled: isAllDayEvent,
                        showHHMMFormat: measureUnitInHours,
                        onBlur: value =>
                          this.updateTimeFieldValues(
                            value,
                            "driveaftertext",
                            showAdvancedMode
                          )
                      })
                    )}
                  </GridItem>
                </GridRow>
              )}

              {(showBreakTime || showAdvancedMode || showOverHead) && (
                <GridRow cols={8} hasBorderTop className="textCapitalize">
                  <GridItem noFlex>
                    {showBreakTime &&
                      getTextField(
                        this.getFormField("breaktime", {
                          isDisabled: true,
                          showHHMMFormat: measureUnitInHours
                        })
                      )}
                    {isCreateEvent &&
                      showAdvancedMode &&
                      isLJMenabled &&
                      this.schedulingOption === JDM_LJS_ENABLED &&
                      getTextField(
                        this.getFormField("minimumscheduleduration", {
                          onKeyPress: evt => this.validateTimeValues(evt),
                          isDisabled: isAllDayEvent,
                          showHHMMFormat: measureUnitInHours,
                          onBlur: value =>
                            this.updateTimeFieldValues(
                              value,
                              "minimumscheduleduration",
                              showAdvancedMode
                            )
                        })
                      )}
                  </GridItem>
                  <GridItem noFlex>
                    {showOverHead &&
                      getTextField(
                        this.getFormField("overheadbeforetext", {
                          onKeyPress: evt => this.validateTimeValues(evt),
                          isDisabled: isAllDayEvent,
                          showHHMMFormat: measureUnitInHours,
                          onBlur: value =>
                            this.updateTimeFieldValues(
                              value,
                              "overheadbeforetext",
                              showAdvancedMode
                            )
                        })
                      )}
                  </GridItem>
                  <GridItem noFlex>
                    {showOverHead &&
                      getTextField(
                        this.getFormField("overheadaftertext", {
                          onKeyPress: evt => this.validateTimeValues(evt),
                          isDisabled: isAllDayEvent,
                          showHHMMFormat: measureUnitInHours,
                          onBlur: value =>
                            this.updateTimeFieldValues(
                              value,
                              "overheadaftertext",
                              showAdvancedMode
                            )
                        })
                      )}
                  </GridItem>
                </GridRow>
              )}
            </GridItem>
            <GridItem cols={4} className="textCapitalize">
              {showAdvancedMode &&
                this.schedulingOption !== ALL_OPTION_DISABLED &&
                this.schedulingOption !== null && (
                  <Section
                    isOpen={undefined}
                    onOpenChange={this.handleBudgetOpenChange}
                    title={getDisplayValue(EVENTSTAG037)}
                    rightAddon={<p />}
                    type="bordered"
                  >
                    {getTextField(
                      this.getFormField("estimatedduration", {
                        isDisabled: true
                      })
                    )}

                    {getTextField(
                      this.getFormField("scopechange", {
                        onKeyPress: evt => this.validateTimeValues(evt),
                        onBlur: value =>
                          this.updateTimeFieldValues(
                            value,
                            "scopechange",
                            showAdvancedMode
                          )
                      })
                    )}

                    {getTextField(
                      this.getFormField("variance", {
                        onKeyPress: evt => this.validateTimeValues(evt),
                        onBlur: value =>
                          this.updateTimeFieldValues(
                            value,
                            "variance",
                            showAdvancedMode
                          )
                      })
                    )}

                    {getTextField(
                      this.getFormField("revisedduration", {
                        isDisabled: true
                      })
                    )}
                  </Section>
                )}
            </GridItem>
          </GridRow>

          <GridRow hasBorderTop>
            <GridItem noFlex>
              {isAllDayEvent ? (
                <GridItem>
                  {getDateInputField(
                    this.getFormField("enddate", {
                      isDisabled:
                        showAdvancedMode && isSET007Enabled && isCreateEvent,
                      label: isJDMenabled ? "EVENTSTAG019" : "TAG352",
                      dateFormat: getUserTimeSettings("dateFormat")
                    })
                  )}
                </GridItem>
              ) : (
                <GridItem>
                  {getDateTimeInputField(
                    this.getFormField("enddatetime", {
                      onInputValueChange: !this.autoSyncSvcDuration
                        ? dateValue => {
                            if (
                              validatedateObj(dateValue) &&
                              this.validateDateTimeObj(dateValue)
                            ) {
                              this.ignoreDateUpdate(
                                dateValue,
                                "enddatetime",
                                showAdvancedMode
                              );
                            }
                          }
                        : dateValue => {
                            if (
                              validatedateObj(dateValue) &&
                              this.validateDateTimeObj(dateValue)
                            ) {
                              this.updateTimeFieldValues(
                                dateValue,
                                "enddatetime",
                                showAdvancedMode
                              );
                            }
                          },
                      dateInputProps: {
                        isDisabled:
                          showAdvancedMode &&
                          isLJMenabled &&
                          isCreateEvent &&
                          isShceduleAsLongJobChecked,
                        dateFormat: getUserTimeSettings("dateFormat")
                      },
                      timeInputProps: {
                        isDisabled:
                          showAdvancedMode &&
                          isLJMenabled &&
                          isCreateEvent &&
                          isShceduleAsLongJobChecked,
                        step: minStepInterval,
                        timeFormat: getUserTimeSettings("timeFormat")
                      },
                      label: isJDMenabled ? "EVENTSTAG019" : "TAG352"
                    })
                  )}
                </GridItem>
              )}
              {isCreateEvent &&
                showAdvancedMode &&
                isLJMenabled &&
                shouldShowDepartTimeAlert &&
                isShceduleAsLongJobChecked && (
                  <Label className="CreateEvent__errorColor">
                    {getDisplayValue(EVENTSTAG030)}
                  </Label>
                )}
              {isCreateEvent &&
                showAdvancedMode &&
                isLJMenabled &&
                isShceduleAsLongJobChecked && (
                  <GridItem>
                    <Button
                      type="neutral"
                      label={getDisplayValue(EVENTSTAG028)}
                      onClick={this.handleCalculate}
                    />
                  </GridItem>
                )}
            </GridItem>
            {/* <GridItem className="marginTopTwentyEight" cols={1} noFlex>
                                        {showAdvancedMode && getCheckBoxField(this.getFormField('alldayevents', { value: getDisplayValue(TAG247), onChange: this.allDayEventChecked, checked: isAllDayEvent }))}
                                    </GridItem> */}
            <GridItem className="marginTopTwentyEight" noFlex>
              {showAdvancedMode && slaRestorationValue && (
                <span
                  className={
                    isRestoredue
                      ? "CreateEvent__time-section"
                      : "CreateEvent__time-section_overduetime"
                  }
                >
                  <Icon icon="clock" align="left" size="x-small" />
                  <span className="CreateEvent_time_label">Restore</span>
                  <Label className="CreateEvent_time_text" type="bordered">
                    {slaRestorationValue}
                  </Label>
                </span>
              )}
            </GridItem>

            <GridItem className="marginTopTwentyEight" noFlex>
              {showAdvancedMode && slaResolutionValue && (
                <span
                  className={
                    isResolutionOverdue
                      ? "CreateEvent__time-section"
                      : "CreateEvent__time-section_overduetime"
                  }
                >
                  <Icon icon="clock" align="left" size="x-small" />
                  <span className="CreateEvent_time_label">Resolve</span>
                  <Label className="CreateEvent_time_text" type="bordered">
                    {slaResolutionValue}
                  </Label>
                </span>
              )}
            </GridItem>
          </GridRow>

          {showAdvancedMode && isCreateEvent && (
            <GridRow hasBorderTop>
              <GridItem>
                <Label>{ljsAlertMessage}</Label>
              </GridItem>
            </GridRow>
          )}
        </Grid>
      </Tab>
    );
    children.push(
      <Tab
        className="CreateEvent__Field-updates CreateEvent__tabs"
        eventKey="2"
        title={getDisplayValue(TAG346)}
      >
        <Grid class="CreateEvent__wrapper" isVertical>
          {this.renderFormFields()}
        </Grid>
      </Tab>
    );

    if (isJDMenabled) {
      children.push(
        <Tab
          className="CreateEvent__tabs"
          eventKey="3"
          title="Options"
          isDisabled={!showAdvancedMode || !isCreateEvent}
        >
          <Grid class="CreateEvent__wrapper" isVertical>
            <GridRow>
              <GridItem>
                <CheckboxField
                  fieldExtras={{ value: "on" }}
                  onChange={this.shceduleAsLongJobChecked}
                  name="shceduleAsLongJobChecked"
                  isDisabled={!isLJMenabled}
                  checked={isShceduleAsLongJobChecked}
                >
                  <Text align="left" size="small" category="heading" tag="span">
                    {getDisplayValue(EVENTSTAG001)}
                  </Text>
                </CheckboxField>
              </GridItem>
            </GridRow>
            <GridRow>
              <div className="CreateEvent__shcedule-long--job">
                <GridRow>
                  <GridItem>
                    <CheckboxField
                      fieldExtras={{ value: "on" }}
                      onChange={this.respectTechWorkHoursChecked}
                      checked={isRespectTechWorkHoursChecked}
                      name="respectTechWorkHoursChecked"
                      isDisabled={!isLJMenabled || !isShceduleAsLongJobChecked}
                    >
                      {getDisplayValue(EVENTSTAG025)}
                    </CheckboxField>
                  </GridItem>
                </GridRow>
                <GridRow>
                  <GridItem>
                    <CheckboxField
                      fieldExtras={{ value: "on" }}
                      onChange={this.respectMachineAccessHoursChecked}
                      checked={isRespectMachineAccessHoursChecked}
                      name="respectMachineAccessHoursChecked"
                      isDisabled={!isLJMenabled || !isShceduleAsLongJobChecked}
                    >
                      {getDisplayValue(EVENTSTAG026)}
                    </CheckboxField>
                  </GridItem>
                </GridRow>
                <GridRow>
                  <GridItem>
                    <CheckboxField
                      fieldExtras={{ value: "on" }}
                      onChange={this.donotOverlapChecked}
                      checked={
                        isDonotOverlapChecked && shouldAllowDoubleBooking
                      }
                      name="donotOverlapChecked"
                      isDisabled={
                        !isLJMenabled ||
                        !isShceduleAsLongJobChecked ||
                        !shouldAllowDoubleBooking
                      }
                    >
                      {getDisplayValue(EVENTSTAG027)}
                    </CheckboxField>
                  </GridItem>
                </GridRow>
              </div>
            </GridRow>
            <GridRow>
              <GridItem>
                <CheckboxField
                  fieldExtras={{ value: "on" }}
                  onChange={this.rememberMyPreferenceChecked}
                  name="remembermypreference"
                  isDisabled={!isLJMenabled || !isShceduleAsLongJobChecked}
                >
                  {getDisplayValue(TAG220)}
                </CheckboxField>
              </GridItem>
            </GridRow>
          </Grid>
        </Tab>
      );
    }
    return children;
  };

  render() {
    const { isEventUpdated, isEventCreated, isAllDayEvent } = this.state;
    const {
      editEventResourceRecord,
      isCreateEvent,
      eventData,
      eventSubject,
      draggedWO,
      isClassicMode,
      isJDMenabled,
      isLJMenabled,
      isSET007Enabled,
      schedulingOption,
      isResizeEvent,
      wo_isAlldayEvent
    } = this.props;

    let { dropTime, TechId, ownerId, woFields, dropDate, resource } = eventData;
    const { data } = isCreateEvent ? resource : editEventResourceRecord;
    const { name: technicianName, Id: techId } = data;
    this.schedulingOption = schedulingOption;
    const FORM_NAME = isCreateEvent
      ? "create-event-form-field"
      : "edit-event-form-field";

    const roundOffTime = parseInt(getSettingValue(DCON001_SET011, 15), 10);
    if (!isNaN(roundOffTime) && roundOffTime > 0) {
      dropTime = moment(dropTime, getUserTimeSettings("timeFormat"));
      dropTime.minutes(
        Math.round(dropTime.minutes() / roundOffTime) * roundOffTime
      );
      dropTime = dropTime.format(getUserTimeSettings("timeFormat"));
    }
    let iniValue;
    if (isCreateEvent) {
      iniValue = getInitialvalues(
        dropDate,
        dropTime,
        technicianName,
        draggedWO,
        isJDMenabled,
        eventSubject,
        wo_isAlldayEvent == "true",
        isLJMenabled,
        schedulingOption
      );
      iniValue.techId = techId;
      iniValue.OwnerId = techId;
    } else {
      iniValue = this.getEditInitialValues(eventData, isResizeEvent);
      iniValue.techId = TechId;
      iniValue.OwnerId = ownerId;
      iniValue.techSFId = null;
      if (data[TECH_SALESFORCE_USER_FIELD]) {
        iniValue.techSFId = data[TECH_SALESFORCE_USER_FIELD];
      }
      const { technicianName } = iniValue;
    }

    const isSaleforceEvent =
      getSettingValue(GLOB001_GBL025) === SALESFORCE_EVENT;
    if (isSaleforceEvent && data[TECH_SALESFORCE_USER_FIELD]) {
      iniValue.OwnerId = data[TECH_SALESFORCE_USER_FIELD];
    }
    iniValue.techSFId = null;
    if (data[TECH_SALESFORCE_USER_FIELD]) {
      iniValue.techSFId = data[TECH_SALESFORCE_USER_FIELD];
    }

    return (
      <IntlProvider locale="en">
        <Form
          isDisabled={false}
          name={FORM_NAME}
          initialValues={iniValue}
          onSubmit={this.handleFormSubmit}
          onSubmitFail={this.handleFailedFormSubmit}
        >
          {/* {(isEventCreated || isEventUpdated) && (
            <Grid isVertical>
              <GridRow>
                <GridItem>
                  <Spinner size="large" />
                </GridItem>
              </GridRow>
            </Grid>
          )} */}
          <Tabs type="scoped" activeKey="1">
            {this.createTabs()}
          </Tabs>
        </Form>
      </IntlProvider>
    );
  }
}
CreateEditEvent.defaultProps = defaultProps;
CreateEditEvent.propTypes = propTypes;

export default CreateEditEvent;
