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
  getHoursToMinutes
} from "utils/DateTimeUtils";
import { getDateTimeValueFromDateTimeField } from "utils/DateAndTimeUtils";
import {
  TAG039,
  TAG036,
  TAG238,
  TAG247,
  TAG220,
  TAG346,
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
  EVENTSTAG063
} from "constants/DisplayTagConstants";
import {
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
  CUSTOMER_COMMITMENT,
  REQUEST_PASS,
  ALL_OPTION_DISABLED,
  WO_SCHEDULED_DURATION_FIELD,
  WO_UNSCHEDULED_DURATIONS,
  WO_DISPATCH_STATUS_FIELD,
  WO_PREFERRED_BUSINESS_HOURS_FIELD,
  TECH_SALESFORCE_USER_FIELD,
  SALESFORCE_EVENT,
  FALSE,
  HOURS,
  WORKORDER_TECHNICIAN_API_REF
} from "constants/AppConstants";
import {
  getSettingValue,
  SLAT003_SET001,
  DCON001_SET011,
  GLOB001_GBL025,
  DCON001_SET054,
  DCON005_SET003,
  DCON005_SET004,
  DCON001_SET037
} from "constants/AppSettings";

import "./CreateEvent.scss";

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

const FORM_NAME = "create-event-form-field";

class CreateEvent extends Component {
  constructor(props) {
    super(props);
    const {
      eventData,
      wo_isAlldayEvent,
      wo_respectMachineAccessHours,
      wo_respectTechnincianWorkHours,
      wo_doNotOverlapExistingEvents
    } = this.props;

    const { dropDate, dropTime } = eventData;
    let roundOffMinutes = moment(dropTime, "HH:mm A");
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
      isBudgetOpen: false,
      isEventCreated: false,
      isScheduleEnabled: true,
      isAllDayEvent: wo_isAlldayEvent === "true",
      isShceduleAsLongJobChecked: true,
      isRespectTechWorkHoursChecked:
        wo_respectTechnincianWorkHours.toLowerCase() === "true",
      isRespectMachineAccessHoursChecked:
        wo_respectMachineAccessHours.toLowerCase() === "true",
      isDonotOverlapChecked:
        wo_doNotOverlapExistingEvents.toLowerCase() === "true",
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
  }

  componentDidMount() {
    const { fieldValues } = this.props;
    this.setState({
      initialValues: fieldValues
    });
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
      switchViewMode
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
    } else {
      createEventCompleted(response);
      onClose();
    }
    this.setState({ isEventCreated: false, isScheduleEnabled: true });
  };

  handleCalculate = () => {
    this.shouldCalculateEndTime = true;
    const { submitForm } = this.props;
    submitForm("create-event-form-field");
  };

  afterCalculateEndTime = response => {
    this.shouldCalculateEndTime = false;
    const { showCalculateMessage, chageFormField } = this.props;
    const { content } = response;
    const {
      eventsCounter,
      startDatetime,
      remainderServiceDuration,
      endDatetime
    } = content;
    const endDate = moment(endDatetime, "YYYY-MM-DD HH:mm:ss");
    const updatedEnddate = {
      date: moment(endDate, "MM/DD/YYYY"),
      time: moment(endDate, "HH:mm")
    };
    const calculatedStartDate = moment(
      startDatetime,
      "YYYY-MM-DD HH:mm:ss"
    ).format("MM/DD/YYYY HH:mm A");
    chageFormField(FORM_NAME, "enddatetime", updatedEnddate);
    chageFormField(FORM_NAME, "enddate", moment(endDate, "MM/DD/YYYY"));
    this.setState({
      isEventCreated: false,
      calculatedStartDate: calculatedStartDate,
      shouldShowDepartTimeAlert: false
    });
    showCalculateMessage(eventsCounter, remainderServiceDuration);
  };

  handleFailedFormSubmit = errors => {};

  handleFormSubmit = values => {
    const me = this;
    // const fieldValues = values;
    const fieldValues = getFormValues(FORM_NAME);
    values = fieldValues;
    const {
      eventData,
      eventActions,
      isClassicMode,
      isLJMenabled,
      isJDMenabled,
      woInfo,
      handleErrorMessage
    } = me.props;
    handleErrorMessage("");
    const {
      isAllDayEvent,
      isRespectMachineAccessHoursChecked,
      isRespectTechWorkHoursChecked,
      isDonotOverlapChecked
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
    const measureUnitInHours = getSettingValue(DCON001_SET054, HOURS) === HOURS;
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
    }
    const { wo } = eventData;
    const draggedWO = woInfo.find(info => info.Name === wo);

    if (
      isJDMenabled &&
      isLJMenabled &&
      !draggedWO[WO_PREFERRED_BUSINESS_HOURS_FIELD] &&
      isRespectMachineAccessHoursChecked
    ) {
      handleErrorMessage(getDisplayValue(EVENTSTAG065));
      return undefined;
    }
    const { Id: WhatId, SVMXDEV__Driving_Time__c: driveTime } = draggedWO;
    this.woId = WhatId;
    fieldValues.WhatId = WhatId;
    fieldValues.driveTime = driveTime;
    fieldValues.updatePrimaryTech =
      fieldValues.updateprimarytechnicians === "on";
    fieldValues.deleteEventForOtherTechs =
      fieldValues.deleteeventforothertechnicians === "on";
    fieldValues.respectTechWorkHoursChecked = isRespectTechWorkHoursChecked
      ? "on"
      : null;
    fieldValues.respectMachineAccessHoursChecked = isRespectMachineAccessHoursChecked
      ? "on"
      : null;
    fieldValues.donotOverlapChecked = isDonotOverlapChecked ? "on" : null;
    const isNewWO = draggedWO[WO_DISPATCH_STATUS_FIELD] === "New";
    if (isNewWO) fieldValues.updatePrimaryTech = true;
    fieldValues.isAllDayEvent = isAllDayEvent;
    let payload;
    if (
      isClassicMode ||
      !isJDMenabled ||
      me.schedulingOption === ALL_OPTION_DISABLED ||
      me.schedulingOption == null
    ) {
      payload = getCreateEventPayload(values);
      eventActions.createEventCall(me.afterFetchEventWoInfoCall, payload);
    } else {
      payload = getLJScreateEventPayload(values, this.shouldCalculateEndTime);
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
    this.setState({ isEventCreated: true });
  };

  handleDateTimeCheck = (startdate, enddate) => {
    const {
      handleErrorMessage,
      isClassicMode,
      isJDMenabled,
      isLJMenabled
    } = this.props;
    const showAdvancedMode = !isClassicMode && isJDMenabled;
    if (showAdvancedMode && isLJMenabled) return false;
    const isBefore = enddate.isBefore(startdate);
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
    return formValues;
  };

  handleWorkOrderEvent = values => {
    const { startdatetime, enddatetime } = values;
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
    const endDateConversion = moment(endDateInit).add(endMinutes, "minutes");
    const serviceDuration = endDateConversion.diff(
      startDateConversion,
      "minutes"
    );
    const woStartDate = moment(startDateConversion).format(DATE_TIME_FORMAT);
    const woEndDate = moment(endDateConversion).format(DATE_TIME_FORMAT);
    formValues.woServiceDuration = serviceDuration;
    formValues.startdatetime = moment
      .utc(woStartDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    formValues.enddatetime = moment
      .utc(woEndDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    return formValues;
  };

  handleBudgetOpenChange = () => {
    const { isBudgetOpen } = this.state;
    this.setState({ isBudgetOpen: !isBudgetOpen });
  };

  allDayEventChecked = data => {
    const { value } = data;
    this.setState({ isAllDayEvent: value && value === "true" });
    const { onTreeConfChanged } = this.props;
    const changed = {};
    changed.wo_isAlldayEvent = value === "true" ? "true" : "false";
    onTreeConfChanged(changed);
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
    this.setState({
      isRespectMachineAccessHoursChecked: value && value === "on"
    });
    const { onTreeConfChanged } = this.props;
    const { shouldRememberMyPreference } = this.state;
    if (shouldRememberMyPreference) {
      const changed = {};
      changed.wo_respectMachineAccessHours = value === "on" ? "true" : "false";
      onTreeConfChanged(changed);
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

  onAllDayTimeValuesChange = data => {
    const { onHandleEventBusinessHours } = this.props;
    const formValues = getFormValues(FORM_NAME);
    const { startdate, techId } = formValues;
    onHandleEventBusinessHours(startdate, techId);
  };

  onTimeValuesChange = data => {
    const { onHandleEventBusinessHours } = this.props;
    const formValues = getFormValues(FORM_NAME);
    const {
      startdatetime,
      driveaftertext,
      drivebeforetext,
      overheadaftertext,
      overheadbeforetext,
      breaktime,
      serviceduration,
      techId
    } = formValues;
    let durationInMinutes = 0;
    const measureUnitInHours = getSettingValue(DCON001_SET054, HOURS) === HOURS;
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
    const endDateTimeValue = moment(startdatetime.date).add(
      durationInMinutes,
      "minutes"
    );
    const updatedEnddate = {
      date: moment(endDateTimeValue, "MM/DD/YYYY"),
      time: moment(endDateTimeValue, "HH:mm")
    };
    const { chageFormField } = this.props;
    chageFormField(FORM_NAME, "enddatetime", updatedEnddate);
    chageFormField(
      FORM_NAME,
      "enddate",
      moment(endDateTimeValue, "MM/DD/YYYY")
    );
    this.setState({ shouldShowDepartTimeAlert: true });
    let startDateForEvent = moment(startdatetime.date).add(
      startdatetime,
      "minutes"
    );
    onHandleEventBusinessHours(startDateForEvent, techId);
  };

  triggerOnChange = (data, autoSyncSvcDuration) => {
    const formValues = getFormValues(FORM_NAME);
    const { serviceduration } = formValues;
    const { chageFormField } = this.props;
    const measureUnitInHours = getSettingValue(DCON001_SET054, HOURS) === HOURS;
    const isServiceDurationInHHMMFormat =
      measureUnitInHours && serviceduration.split(":").length > 1;
    let convertedServiceDuration;
    if (measureUnitInHours) {
      if (isServiceDurationInHHMMFormat) {
        convertedServiceDuration = getHoursToMinutes(serviceduration);
      } else {
        convertedServiceDuration = convertHoursToMinutes(serviceduration);
      }
    } else {
      convertedServiceDuration = serviceduration;
    }
    chageFormField(
      FORM_NAME,
      "serviceduration",
      measureUnitInHours
        ? getMinutesToHours(convertedServiceDuration)
        : convertedServiceDuration
    );
    this.setState({ shouldShowDepartTimeAlert: true });
    if (autoSyncSvcDuration) {
      this.onTimeValuesChange(data);
    }
  };

  onDepartTimeChange = departTime => {
    const formValues = getFormValues(FORM_NAME);

    const {
      startdatetime,
      driveaftertext,
      drivebeforetext,
      overheadaftertext,
      overheadbeforetext,
      breaktime,
      serviceduration,
      enddatetime
    } = formValues;
    const start = getDateTimeValueFromDateTimeField(startdatetime);
    const { date: eDate, time: eTime } = departTime;
    const end = getDateTimeValueFromDateTimeField(enddatetime);
    const isBefore = this.handleDateTimeCheck(start, end);
    if (isBefore) return undefined;
    const totlaMinutes = end.diff(start, "minutes");
    const measureUnitInHours = getSettingValue(DCON001_SET054, HOURS) === HOURS;
    let serviceDuration = 0;
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
      serviceDuration =
        (+serviceduration || 0) +
        (+driveaftertext || 0) +
        (+drivebeforetext || 0) +
        (+overheadaftertext || 0) +
        (+overheadbeforetext || 0) +
        (+breaktime || 0);
    }
    const { chageFormField } = this.props;
    chageFormField(
      FORM_NAME,
      "serviceduration",
      measureUnitInHours ? getMinutesToHours(serviceDuration) : serviceDuration
    );
    this.setState({ shouldShowDepartTimeAlert: true });
  };

  onArriveTimeChange = data => {
    this.setState({ shouldShowDepartTimeAlert: true });
  };

  displayFormFields = fieldArr => {
    return fieldArr.map(field => {
      const componentObject = getComponentForField(field);
      const {
        componentField: ComponentField,
        componentProps,
        isInputfield
      } = componentObject;
      return (
        <GridItem className="FormFieldForm__component">
          {isInputfield && (
            <ComponentField {...componentProps} size="large">
              <Input />
            </ComponentField>
          )}
          {!isInputfield && <ComponentField {...componentProps} size="large" />}
        </GridItem>
      );
    });
  };

  renderFormFields = () => {
    const fields = getAllUpdateFields();
    const splitFields = chunk(fields, 2);
    const { length } = fields;
    if (length) {
      return splitFields.map(fieldArr => {
        return <GridRow>{this.displayFormFields(fieldArr)}</GridRow>;
      });
    }
    return (
      <Container style={{ padding: "4px 8px" }}>
        <Textarea name={EVENTSTAG089} value={getDisplayValue(EVENTSTAG089)} />
      </Container>
    );
  };

  render() {
    const {
      isBudgetOpen,
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
      eventData,
      eventSubject,
      draggedWO,
      isClassicMode,
      isJDMenabled,
      isLJMenabled,
      isSET007Enabled,
      schedulingOption,
      wo_isAlldayEvent,
      handleSubjectChange
    } = this.props;
    let { dropTime } = eventData;
    const { dropDate, resource } = eventData;
    const { data } = resource;
    const { name: technicianName } = data;
    const { Id: techId } = data;
    this.schedulingOption = schedulingOption;

    const roundOffTime = parseInt(getSettingValue(DCON001_SET011, 15), 10);
    if (!isNaN(roundOffTime) && roundOffTime > 0) {
      dropTime = moment(dropTime, "HH:mm A");
      dropTime.minutes(
        Math.round(dropTime.minutes() / roundOffTime) * roundOffTime
      );
      dropTime = dropTime.format("HH:mm A");
    }
    const iniValue = getInitialvalues(
      dropDate,
      dropTime,
      technicianName,
      draggedWO,
      isJDMenabled,
      eventSubject
    );

    iniValue.techId = techId;
    iniValue.OwnerId = techId;
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
    const isCustomerCommit =
      getSettingValue(SLAT003_SET001) === CUSTOMER_COMMITMENT;
    const slaOnSiteValue = getSlaValues(draggedWO, isCustomerCommit, "onsite");
    const slaResolutionValue = getSlaValues(
      draggedWO,
      isCustomerCommit,
      "resolution"
    );
    const slaRestorationValue = getSlaValues(
      draggedWO,
      isCustomerCommit,
      "restoration"
    );
    const showAdvancedMode = !isClassicMode && isJDMenabled;
    const autoCalcEndDate =
      Boolean(getUserSetting(AUTO_CALC_END_DATE)) &&
      !showAdvancedMode &&
      !isLJMenabled;
    const autoSyncSvcDuration =
      Boolean(getUserSetting(AUTO_SYNC_SVC_DURATION)) &&
      !showAdvancedMode &&
      !isLJMenabled;
    const isNewWO = draggedWO[WO_DISPATCH_STATUS_FIELD] === "New";
    const jdmScheduledLabel = `${getMinutesToHours(
      draggedWO[WO_SCHEDULED_DURATION_FIELD]
    )} ${getDisplayValue(EVENTSTAG015)}`;
    const jdmUnscheduledLabel = `${getMinutesToHours(
      draggedWO[WO_UNSCHEDULED_DURATIONS]
    )} ${getDisplayValue(EVENTSTAG017)}`;
    const measureUnitInHours = getSettingValue(DCON001_SET054, HOURS) === HOURS;
    const inputPattern = measureUnitInHours
      ? "^[0-9]{2,}:^[0-9]{2}"
      : "^[0-9]{1,}";
    const showOverHead = getSettingValue(DCON005_SET003) === "True";
    const showBreakTime =
      getSettingValue(DCON005_SET004) === "True" && !showAdvancedMode;

    let ljsAlertMessage = "";
    if (!isSET007Enabled) {
      ljsAlertMessage = getDisplayValue(EVENTSTAG063);
    } else if (isLJMenabled) {
      ljsAlertMessage = getDisplayValue(EVENTSTAG035);
    } else {
      ljsAlertMessage = getDisplayValue(EVENTSTAG135);
    }
    const { Name: assignedName } = getFieldValue(
      draggedWO,
      WORKORDER_TECHNICIAN_API_REF,
      {}
    );

    //this.handleEventBusinessHours(iniValue.startdatetime);
    return (
      <IntlProvider locale="en">
        <Form
          isDisabled={false}
          name={FORM_NAME}
          initialValues={iniValue}
          onSubmit={this.handleFormSubmit}
          onSubmitFail={this.handleFailedFormSubmit}
        >
          {isEventCreated && (
            <Grid isVertical>
              <GridRow>
                <GridItem>
                  <Spinner size="large" />
                </GridItem>
              </GridRow>
            </Grid>
          )}
          <Tabs type="scoped" activeKey="1">
            <Tab className="CreateEvent__tabs" eventKey="1" title="Scheduling">
              <Grid class="CreateEvent__wrapper" isVertical>
                <GridRow cols={12}>
                  <GridItem cols={8}>
                    <TextField
                      label={getDisplayValue("TAG034")}
                      size="x-large"
                      placeholder=""
                      className="CreateEvent__wrapper-Technical-name"
                      name="technicianname"
                    >
                      <Input />
                    </TextField>
                    <TextField
                      isDisabled={!isSubjectEditable}
                      label={getDisplayValue("TAG035")}
                      isRequired
                      size="x-large"
                      placeholder=""
                      onChange={data => handleSubjectChange(data)}
                      name="eventsubject"
                    >
                      <Input />
                    </TextField>
                    <TextField
                      label={getDisplayValue(TAG039)}
                      size="x-large"
                      placeholder=""
                      name="locationnote"
                    >
                      <Input />
                    </TextField>
                    <TextareaField
                      label={getDisplayValue(TAG036)}
                      size="x-large"
                      rows={1}
                      name="descriptionfieldarea"
                    >
                      <Input />
                    </TextareaField>
                  </GridItem>
                  <GridItem cols={5} className="marginTop">
                    <CheckboxField
                      label={""}
                      isDisabled={isNewWO}
                      fieldExtras={{ value: "on" }}
                      name="updateprimarytechnicians"
                      className=""
                    >
                      {assignedName
                        ? `${getDisplayValue(
                            EVENTSTAG031
                          )} (Currently: ${assignedName})`
                        : getDisplayValue(EVENTSTAG031)}
                    </CheckboxField>
                    <CheckboxField
                      isDisabled={isNewWO}
                      fieldExtras={{ value: "on" }}
                      name="deleteeventforothertechnicians"
                      className=""
                    >
                      {getDisplayValue(EVENTSTAG033)}
                    </CheckboxField>
                  </GridItem>
                </GridRow>

                <GridRow cols={12}>
                  <GridItem cols={8} hasBorderTop>
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
                            <DateInputField
                              label={getDisplayValue(EVENTSTAG018)}
                              isRequired
                              menuAlign="left"
                              size="x-small"
                              name="startdate"
                              onInputValueChange={this.onAllDayTimeValuesChange}
                              // onBlur={this.onTimeValuesChange}
                            />
                          </GridItem>
                        ) : (
                          <DateTimeInputField
                            label={getDisplayValue(EVENTSTAG018)}
                            isRequired
                            menuAlign="left"
                            size="x-small"
                            name="startdatetime"
                            // onBlur={this.onTimeValuesChange}
                            onInputValueChange={
                              autoCalcEndDate
                                ? dateValue =>
                                    this.onTimeValuesChange(dateValue)
                                : ""
                            }
                          />
                        )}
                      </GridItem>
                      <GridItem className="marginTopTwentyEight" noFlex>
                        {showAdvancedMode && slaOnSiteValue && (
                          <span className="CreateEvent__time-section">
                            <Icon icon="clock" align="left" size="x-small" />
                            <span className="CreateEvent_time_label">
                              On Site
                            </span>
                            <Label
                              className="CreateEvent_time_text"
                              type="bordered"
                            >
                              {slaOnSiteValue}
                            </Label>
                          </span>
                        )}
                      </GridItem>
                    </GridRow>

                    <GridRow cols={8} hasBorderTop>
                      <GridItem noFlex>
                        <TextField
                          label={
                            !measureUnitInHours
                              ? getDisplayValue(EVENTSTAG010)
                              : `${getDisplayValue(
                                  EVENTSTAG010
                                )} ${"( "}${getDisplayValue(
                                  "EVENTSTAG013"
                                )} ${")"}`
                          }
                          isDisabled={isAllDayEvent}
                          size="xx-small"
                          placeholder=""
                          name="serviceduration"
                          //onBlur={autoSyncSvcDuration ? (dateValue) => this.onTimeValuesChange(dateValue) : ''}
                          onBlur={dateValue =>
                            this.triggerOnChange(dateValue, autoSyncSvcDuration)
                          }
                        >
                          <Input type="text" pattern={inputPattern} />
                        </TextField>
                      </GridItem>
                      <GridItem noFlex className="marginTopTwentyEight">
                        {!showAdvancedMode && (
                          <CheckboxField
                            fieldExtras={{ value: "true" }}
                            onChange={this.allDayEventChecked}
                            checked={isAllDayEvent}
                            name="alldayevents"
                          >
                            {getDisplayValue(TAG247)}
                          </CheckboxField>
                        )}
                      </GridItem>

                      <GridItem noFlex>
                        {!showAdvancedMode && (
                          <TextField
                            label={
                              !measureUnitInHours
                                ? getDisplayValue("TAG229")
                                : `${getDisplayValue(
                                    "TAG229"
                                  )} ${getDisplayValue(EVENTSTAG011)}`
                            }
                            isDisabled={isAllDayEvent}
                            size="xx-small"
                            placeholder=""
                            name="drivebeforetext"
                            onBlur={this.onTimeValuesChange}
                          >
                            <Input type="text" />
                          </TextField>
                        )}
                      </GridItem>
                      <GridItem noFlex>
                        {!showAdvancedMode && (
                          <TextField
                            label={
                              !measureUnitInHours
                                ? getDisplayValue("TAG213")
                                : getDisplayValue(EVENTSTAG012)
                            }
                            isDisabled={isAllDayEvent}
                            size="xx-small"
                            placeholder=""
                            name="driveaftertext"
                            onBlur={this.onTimeValuesChange}
                          >
                            <Input type="text" />
                          </TextField>
                        )}
                      </GridItem>
                      <GridItem noFlex className="marginTopTwentyEight">
                        {showAdvancedMode && <Label>{jdmScheduledLabel}</Label>}
                      </GridItem>

                      <GridItem noFlex className="marginTopTwentyEight">
                        {showAdvancedMode && (
                          <Label>{jdmUnscheduledLabel}</Label>
                        )}
                      </GridItem>
                    </GridRow>

                    {showAdvancedMode && (
                      <GridRow cols={8} hasBorderTop>
                        <GridItem noFlex>
                          <TextField
                            label={
                              !measureUnitInHours
                                ? getDisplayValue("TAG229")
                                : `${getDisplayValue(
                                    "TAG229"
                                  )} ${getDisplayValue(EVENTSTAG011)}`
                            }
                            isDisabled={isAllDayEvent}
                            size="xx-small"
                            placeholder=""
                            name="drivebeforetext"
                            onBlur={this.onTimeValuesChange}
                          >
                            <Input type="text" />
                          </TextField>
                        </GridItem>
                        <GridItem noFlex>
                          <TextField
                            label={
                              !measureUnitInHours
                                ? getDisplayValue("TAG213")
                                : getDisplayValue(EVENTSTAG012)
                            }
                            isDisabled={isAllDayEvent}
                            size="xx-small"
                            placeholder=""
                            name="driveaftertext"
                            onBlur={this.onTimeValuesChange}
                          >
                            <Input type="text" />
                          </TextField>
                        </GridItem>
                      </GridRow>
                    )}

                    {(showBreakTime || showAdvancedMode || showOverHead) && (
                      <GridRow cols={8} hasBorderTop>
                        <GridItem noFlex>
                          {showBreakTime && (
                            <TextField
                              label={getDisplayValue("TAG398")}
                              isDisabled
                              size="xx-small"
                              placeholder=""
                              name="breaktime"
                            >
                              <Input type="text" />
                            </TextField>
                          )}
                          {showAdvancedMode && (
                            <TextField
                              label={getDisplayValue(EVENTSTAG024)}
                              isDisabled={isAllDayEvent}
                              size="xx-small"
                              placeholder=""
                              name="minimumscheduleduration"
                              onBlur={this.onTimeValuesChange}
                            >
                              <Input type="text" />
                            </TextField>
                          )}
                        </GridItem>
                        <GridItem noFlex>
                          {showOverHead && (
                            <TextField
                              label={
                                !measureUnitInHours
                                  ? getDisplayValue(EVENTSTAG070)
                                  : `${getDisplayValue(
                                      EVENTSTAG070
                                    )} ${getDisplayValue(EVENTSTAG011)}`
                              }
                              isDisabled={isAllDayEvent}
                              size="xx-small"
                              placeholder=""
                              name="overheadbeforetext"
                              onBlur={this.onTimeValuesChange}
                            >
                              <Input type="text" />
                            </TextField>
                          )}
                        </GridItem>
                        <GridItem noFlex>
                          {showOverHead && (
                            <TextField
                              label={
                                !measureUnitInHours
                                  ? getDisplayValue("TAG213")
                                  : getDisplayValue(EVENTSTAG012)
                              }
                              isDisabled={isAllDayEvent}
                              size="xx-small"
                              placeholder=""
                              name="overheadaftertext"
                              onBlur={this.onTimeValuesChange}
                            >
                              <Input type="text" />
                            </TextField>
                          )}
                        </GridItem>
                      </GridRow>
                    )}
                  </GridItem>
                  <GridItem cols={4}>
                    {showAdvancedMode && (
                      <Section
                        isOpen={undefined}
                        onOpenChange={this.handleBudgetOpenChange}
                        title={getDisplayValue(EVENTSTAG037)}
                        rightAddon={<p />}
                        type="bordered"
                      >
                        <TextField
                          label={getDisplayValue(EVENTSTAG006)}
                          isDisabled
                          size="x-small"
                          placeholder=""
                          name="estimatedduration"
                        >
                          <Input type="text" />
                        </TextField>
                        <TextField
                          label={getDisplayValue(EVENTSTAG023)}
                          isDisabled={isAllDayEvent}
                          size="x-small"
                          placeholder=""
                          name="scopechange"
                        >
                          <Input type="text" />
                        </TextField>
                        <TextField
                          label={getDisplayValue(EVENTSTAG022)}
                          isDisabled={isAllDayEvent}
                          size="x-small"
                          placeholder=""
                          name="variance"
                        >
                          <Input type="text" />
                        </TextField>
                        <TextField
                          label={getDisplayValue(EVENTSTAG007)}
                          isDisabled
                          size="x-small"
                          placeholder=""
                          name="revisedduration"
                        >
                          <Input type="text" />
                        </TextField>
                      </Section>
                    )}
                  </GridItem>
                </GridRow>

                <GridRow hasBorderTop>
                  <GridItem noFlex>
                    {isAllDayEvent ? (
                      <GridItem>
                        <DateInputField
                          label={getDisplayValue(EVENTSTAG019)}
                          isRequired
                          menuAlign="left"
                          isDisabled={showAdvancedMode}
                          size="x-small"
                          name="enddate"
                        />
                      </GridItem>
                    ) : (
                      <DateTimeInputField
                        dateInputProps={{
                          isDisabled: showAdvancedMode
                        }}
                        timeInputProps={{
                          isDisabled: showAdvancedMode
                        }}
                        label={getDisplayValue(EVENTSTAG019)}
                        isRequired
                        menuAlign="left"
                        size="x-small"
                        name="enddatetime"
                        onInputValueChange={
                          showAdvancedMode && isLJMenabled
                            ? ""
                            : dateValue => this.onDepartTimeChange(dateValue)
                        }
                        // onChange={(dateValue) => this.onDepartTimeChange(dateValue)}
                      />
                    )}
                    {showAdvancedMode &&
                      isLJMenabled &&
                      shouldShowDepartTimeAlert && (
                        <Label className="CreateEvent__errorColor">
                          {getDisplayValue(EVENTSTAG030)}
                        </Label>
                      )}
                    {showAdvancedMode && isLJMenabled && (
                      <GridItem>
                        <Button
                          type="neutral"
                          label={getDisplayValue(EVENTSTAG028)}
                          onClick={this.handleCalculate}
                        />
                      </GridItem>
                    )}
                  </GridItem>
                  <GridItem className="marginTopTwentyEight" cols={1} noFlex>
                    {showAdvancedMode && (
                      <CheckboxField
                        fieldExtras={{ value: "true" }}
                        onChange={this.allDayEventChecked}
                        checked={isAllDayEvent}
                        name="alldayevents"
                      >
                        {getDisplayValue(TAG247)}
                      </CheckboxField>
                    )}
                  </GridItem>
                  <GridItem className="marginTopTwentyEight" noFlex>
                    {showAdvancedMode && slaRestorationValue && (
                      <span className="CreateEvent__time-section">
                        <Icon icon="clock" align="left" size="x-small" />
                        <span className="CreateEvent_time_label">Restore</span>
                        <Label
                          className="CreateEvent_time_text"
                          type="bordered"
                        >
                          {slaRestorationValue}
                        </Label>
                      </span>
                    )}
                  </GridItem>

                  <GridItem className="marginTopTwentyEight" noFlex>
                    {showAdvancedMode && slaResolutionValue && (
                      <span className="CreateEvent__time-section">
                        <Icon icon="clock" align="left" size="x-small" />
                        <span className="CreateEvent_time_label">Resolve</span>
                        <Label
                          className="CreateEvent_time_text"
                          type="bordered"
                        >
                          {slaResolutionValue}
                        </Label>
                      </span>
                    )}
                  </GridItem>
                </GridRow>

                {showAdvancedMode && (
                  <GridRow hasBorderTop>
                    <GridItem>
                      <Label>{ljsAlertMessage}</Label>
                    </GridItem>
                  </GridRow>
                )}
              </Grid>
            </Tab>
            <Tab
              className="CreateEvent__Field-updates CreateEvent__tabs"
              eventKey="2"
              title={getDisplayValue(TAG346)}
            >
              <Grid class="CreateEvent__wrapper" isVertical>
                {this.renderFormFields()}
              </Grid>
            </Tab>

            <Tab
              className="CreateEvent__tabs"
              eventKey="3"
              title="Options"
              isDisabled={!showAdvancedMode}
            >
              <Grid class="CreateEvent__wrapper" isVertical>
                <GridRow>
                  <GridItem>
                    <CheckboxField
                      fieldExtras={{ value: "on" }}
                      onChange={this.shceduleAsLongJobChecked}
                      name="shceduleAsLongJobChecked"
                      isDisabled={!isLJMenabled}
                    >
                      <Text
                        align="left"
                        size="small"
                        category="heading"
                        tag="span"
                      >
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
                          isDisabled={
                            !isLJMenabled || !isShceduleAsLongJobChecked
                          }
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
                          isDisabled={
                            !isLJMenabled || !isShceduleAsLongJobChecked
                          }
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
                          checked={isDonotOverlapChecked}
                          name="donotOverlapChecked"
                          isDisabled={
                            !isLJMenabled || !isShceduleAsLongJobChecked
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
          </Tabs>
        </Form>
      </IntlProvider>
    );
  }
}
CreateEvent.defaultProps = defaultProps;
CreateEvent.propTypes = propTypes;

export default CreateEvent;
