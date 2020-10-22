import React, { Component } from "react";
import { connect } from "react-redux";
import { PropTypes } from "prop-types";
import { IntlProvider } from "react-intl";
import * as moment from "moment";
import {
  YODA_DATE_TIME_ZONE_24_HR_FORMAT,
  DATE_TIME_FORMAT,
  DATE_FORMAT
} from "constants/DateTimeConstants";
import { chunk } from "lodash";
import { getMinutesToHours, getSecondsToHours } from "utils/DateTimeUtils";
import {
  Container,
  FormFields,
  Form,
  Label,
  Input,
  GridRow,
  GridItem,
  Tabs,
  Tab,
  Spinner,
  Grid,
  Section,
  Textarea
} from "@svmx/ui-components-lightning";
import {
  getDisplayValue,
  getFormValues,
  getWorkOrderIdsInfo
} from "utils/DCUtils";
import {
  TAG039,
  TAG036,
  TAG238,
  TAG247,
  TAG346,
  EVENTSTAG037,
  EVENTSTAG006,
  EVENTSTAG022,
  EVENTSTAG023,
  EVENTSTAG007,
  EVENTSTAG070,
  EVENTSTAG019,
  EVENTSTAG018,
  EVENTSTAG011,
  EVENTSTAG012,
  EVENTSTAG010,
  EVENTSTAG031,
  EVENTSTAG033,
  EVENTSTAG089,
  EVENTSTAG015,
  EVENTSTAG017
} from "constants/DisplayTagConstants";
import {
  JDM_LJS_ENABLED,
  WO_SCHEDULING_OPTIONS,
  WO_ESTIMATED_DURATION_FIELD,
  WO_SCOPE_CHANGE_FIELD,
  WO_VARIANCE_FIELD,
  WO_REVISED_DURATION_FIELD,
  WO_SCHEDULED_DURATION_FIELD,
  WO_UNSCHEDULED_DURATIONS,
  HOURS,
  FALSE,
  TECH_SALESFORCE_USER_FIELD
} from "constants/AppConstants";
import {
  getSettingValue,
  DCON001_SET054,
  DCON001_SET037,
  DCON005_SET003,
  DCON005_SET004
} from "constants/AppSettings";
import {
  getWOUpdateInitialvalues,
  getAllUpdateFields,
  getComponentForField,
  getWoUpdateEventPayload,
  getTotalDurationInMinForHourEnabled,
  isValidteEndDateForEventCreation,
  getServiceDurationInMinForHourEnabled
} from "utils/EventsUtils";
import unScheduledDurationService from "services/UnScheduledDurationService";
import { getDateTimeValueFromDateTimeField } from "utils/DateAndTimeUtils";
import "./EditEvent.scss";

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
const mapStateToProps = ({ technicianData }) => {
  const { technicians } = technicianData;
  const { data } = technicians;
  const { technicians: techData } = data;
  return { techData };
};
const FORM_NAME = "edit-event-form-field";
class EditEvent extends Component {
  constructor(props) {
    super(props);
    const { eventData } = this.props;
    const { IsAllDayEvent } = eventData;
    this.state = {
      isAllDayEvent: IsAllDayEvent,
      isEventUpdated: false,
      isScheduleEnabled: true,
      isBudgetOpen: true
    };

    this.woId = "";
    this.techId = "";
  }

  handleFailedFormSubmit = errors => {};

  handleFormSubmit = values => {
    const me = this;
    const fieldValues = values;
    const { eventActions, eventData } = me.props;
    const { isAllDayEvent } = this.state;
    let isBefore = false;
    let isSame = false;
    let durationInMinutes = 0;
    const {
      driveaftertext,
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
      if (isBefore || isSame) {
        return undefined;
      }
    }
    const { WOId } = eventData;
    this.woId = WOId;
    fieldValues.woId = WOId;
    fieldValues.updateprimarytechnicians =
      fieldValues.updateprimarytechnicians === true;
    fieldValues.deleteeventforothertechnicians =
      fieldValues.deleteeventforothertechnicians === true;
    fieldValues.isAllDayEvent = isAllDayEvent;
    fieldValues.eventId = this.eventId;
    const payload = getWoUpdateEventPayload(fieldValues);
    eventActions.updateEvent(me.afterEventEditCall, payload);
    this.setState({ isEventUpdated: true });
  };

  afterEventEditCall = (response, error = false) => {
    const {
      editWoEveventComplete,
      onClose,
      onHandleServerAlertModal
    } = this.props;
    if (response && response === getDisplayValue(TAG238)) {
      onHandleServerAlertModal(response);
    } else if (error && response.includes(getDisplayValue("EVENTSTAG064"))) {
      const errorMessage = response.substring(
        response.indexOf("@W") + 1,
        response.indexOf(")@") + 1
      );
      onHandleServerAlertModal(errorMessage, getDisplayValue("EVENTSTAG072"));
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
    }
    this.setState({ isEventUpdated: false });
  };

  handleDateTimeCheck = (startdate, enddate) => {
    const { handleErrorMessage } = this.props;
    const isBefore = enddate.isBefore(startdate);
    if (isBefore) {
      handleErrorMessage(getDisplayValue("TAG133"));
    }
    return isBefore;
  };

  handleDateTimeCheckForSame = (startdate, enddate) => {
    const { handleErrorMessage } = this.props;
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

  allDayEventChecked = data => {
    const { value } = data;
    this.setState({ isAllDayEvent: value && value === "true" });
  };

  onTimeValuesChange = data => {
    const formValues = getFormValues(FORM_NAME);
    const {
      startdatetime,
      driveaftertext,
      drivebeforetext,
      overheadaftertext,
      overheadbeforetext,
      breaktime,
      serviceduration
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
    chageFormField(FORM_NAME, "enddate", updatedEnddate);
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
    const eday = moment(`${eDate} ${eTime}`, "MM/DD/YYYY hh:mm A");
    const isBefore = this.handleDateTimeCheck(start, eday);
    if (isBefore) return undefined;
    const totlaMinutes = eday.diff(start, "minutes");
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

  handleBudgetOpenChange = () => {
    const { isBudgetOpen } = this.state;
    this.setState({ isBudgetOpen: !isBudgetOpen });
  };

  getInitialValues = (eventData, isResizeEvent = false) => {
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
    const measureUnitInHours = getSettingValue(DCON001_SET054, HOURS) === HOURS;
    this.eventId = id;
    this.techId = TechId;
    this.OwnerId = ownerId;
    let startDateTime = startDate;
    let endDateTime = endDate;
    let eventStartDate = startDate;
    let eventEndDate = endDate;
    let allDayEventEndDate = moment(endDate).subtract(1, "day");
    if (isResizeEvent) {
      const rsdate = moment(resizeStartDate, DATE_TIME_FORMAT);
      const redate = moment(resizeEndDate, DATE_TIME_FORMAT);
      Service_Duration = moment(redate).diff(moment(rsdate), "seconds");
      eventStartDate = resizeStartDate;
      eventEndDate = resizeEndDate;
      startDateTime = resizeStartDate;
      endDateTime = resizeEndDate;
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
          ? moment(allDayEventEndDate, "MM/DD/YYYY")
          : moment(eventEndDate, "MM/DD/YYYY"),
        time: moment(endDateTime, "HH:mm A")
      },
      eventsubject: subject,
      descriptionfieldarea: description,
      locationnote: location,
      startdatetime: {
        date: moment(eventStartDate, "MM/DD/YYYY"),
        time: moment(startDateTime, "HH:mm A")
      },
      technicianname: techName,
      enddate: IsAllDayEvent
        ? moment(allDayEventEndDate, "MM/DD/YYYY")
        : moment(eventEndDate, "MM/DD/YYYY"),
      startdate: moment(eventStartDate, "MM/DD/YYYY"),
      serviceduration: measureUnitInHours
        ? getSecondsToHours(Service_Duration)
        : Service_Duration / 60,
      driveaftertext: measureUnitInHours
        ? getMinutesToHours(Driving_Time_Home)
        : Driving_Time_Home,
      drivebeforetext: measureUnitInHours
        ? getMinutesToHours(Driving_Time)
        : Driving_Time,
      overheadbeforetext: measureUnitInHours
        ? getMinutesToHours(Overhead_Time_Before)
        : Overhead_Time_Before,
      overheadaftertext: measureUnitInHours
        ? getMinutesToHours(Overhead_Time_After)
        : Overhead_Time_After,
      breaktime: measureUnitInHours
        ? getMinutesToHours(Break_Time_Total)
        : Break_Time_Total,
      updateprimarytechnicians: null,
      deleteeventforothertechnicians: null,
      estimatedduration: woFields[WO_ESTIMATED_DURATION_FIELD],
      scopechange: getMinutesToHours(woFields[WO_SCOPE_CHANGE_FIELD]),
      variance: getMinutesToHours(woFields[WO_VARIANCE_FIELD]),
      revisedduration: woFields[WO_REVISED_DURATION_FIELD]
    };
    getWOUpdateInitialvalues(initialValue, data);
    return initialValue;
  };

  render() {
    const { isEventUpdated, isAllDayEvent, isBudgetOpen } = this.state;

    const {
      editEventResourceRecord: data,
      eventData,
      isJDMenabled,
      isResizeEvent,
      isClassicMode,
      isTechnicianChanged
    } = this.props;
    const { TechId, ownerId, woFields } = eventData;
    const schedulingOption = woFields[WO_SCHEDULING_OPTIONS];
    const jdmEnabld =
      !isClassicMode && isJDMenabled && schedulingOption === JDM_LJS_ENABLED;
    const jdmScheduledLabel = `${getMinutesToHours(
      woFields[WO_SCHEDULED_DURATION_FIELD]
    )} ${getDisplayValue(EVENTSTAG015)}`;
    const jdmUnscheduledLabel = `${getMinutesToHours(
      woFields[WO_UNSCHEDULED_DURATIONS]
    )} ${getDisplayValue(EVENTSTAG017)}`;
    const iniValue = this.getInitialValues(eventData, isResizeEvent);
    iniValue.techId = TechId;
    iniValue.OwnerId = ownerId;
    iniValue.techSFId = null;
    if (data[TECH_SALESFORCE_USER_FIELD]) {
      iniValue.techSFId = data[TECH_SALESFORCE_USER_FIELD];
    }
    const { technicianname } = iniValue;
    const measureUnitInHours = getSettingValue(DCON001_SET054, HOURS) === HOURS;
    const showOverHead = getSettingValue(DCON005_SET003) === "True";
    const showBreakTime = getSettingValue(DCON005_SET004) === "True";
    const isSubjectEditable = JSON.parse(
      getSettingValue(DCON001_SET037, FALSE).toLowerCase()
    );
    return (
      <IntlProvider locale="en">
        <Form
          isDisabled={false}
          initialValues={iniValue}
          name={FORM_NAME}
          onSubmit={this.handleFormSubmit}
          onSubmitFail={this.handleFailedFormSubmit}
        >
          {isEventUpdated && (
            <Grid isVertical>
              <GridRow>
                <GridItem>
                  <Spinner size="large" />
                </GridItem>
              </GridRow>
            </Grid>
          )}
          <Tabs type="scoped" activeKey="1">
            <Tab className="EditEvent__tabs" eventKey="1" title="Scheduling">
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
                      size="x-large"
                      placeholder=""
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
                      isDisabled={!isTechnicianChanged}
                      fieldExtras={{ value: "on" }}
                      name="updateprimarytechnicians"
                      className=""
                    >
                      {technicianname
                        ? `${getDisplayValue(
                            EVENTSTAG031
                          )} (Currently: ${technicianname})`
                        : getDisplayValue(EVENTSTAG031)}
                    </CheckboxField>
                    <CheckboxField
                      isDisabled={!isTechnicianChanged}
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
                            />
                          </GridItem>
                        ) : (
                          <DateTimeInputField
                            label={getDisplayValue(EVENTSTAG018)}
                            isRequired
                            menuAlign="left"
                            size="x-small"
                            name="startdatetime"
                          />
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
                        >
                          <Input type="text" />
                        </TextField>
                      </GridItem>
                      <GridItem noFlex className="marginTopTwentyEight">
                        {!jdmEnabld && (
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
                        {!jdmEnabld && (
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
                          >
                            <Input type="text" />
                          </TextField>
                        )}
                      </GridItem>
                      <GridItem noFlex>
                        {!jdmEnabld && (
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
                          >
                            <Input type="text" />
                          </TextField>
                        )}
                      </GridItem>
                      <GridItem noFlex className="marginTopTwentyEight">
                        {jdmEnabld && <Label>{jdmScheduledLabel}</Label>}
                      </GridItem>

                      <GridItem noFlex className="marginTopTwentyEight">
                        {jdmEnabld && <Label>{jdmUnscheduledLabel}</Label>}
                      </GridItem>
                    </GridRow>

                    {jdmEnabld && (
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
                          >
                            <Input type="text" />
                          </TextField>
                        </GridItem>
                      </GridRow>
                    )}

                    {(showBreakTime || showOverHead) && (
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
                            >
                              <Input type="text" />
                            </TextField>
                          )}
                        </GridItem>
                      </GridRow>
                    )}
                  </GridItem>
                  <GridItem cols={4}>
                    {jdmEnabld && (
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
                          <Input type="number" />
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
                          <Input type="number" />
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
                          size="x-small"
                          name="enddate"
                        />
                      </GridItem>
                    ) : (
                      <DateTimeInputField
                        label={getDisplayValue(EVENTSTAG019)}
                        isRequired
                        menuAlign="left"
                        size="x-small"
                        name="enddatetime"
                        onInputValueChange={dateValue =>
                          this.onDepartTimeChange(dateValue)
                        }
                      />
                    )}
                  </GridItem>
                  <GridItem className="marginTopTwentyEight" cols={1} noFlex>
                    {jdmEnabld && (
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
                </GridRow>
              </Grid>
            </Tab>
            <Tab
              className="EditEvent__tabs"
              eventKey="2"
              title={getDisplayValue(TAG346)}
            >
              <Grid class="CreateEvent__wrapper" isVertical>
                {this.renderFormFields()}
              </Grid>
            </Tab>
          </Tabs>
        </Form>
      </IntlProvider>
    );
  }
}
EditEvent.defaultProps = defaultProps;
EditEvent.propTypes = propTypes;
export default connect(mapStateToProps)(EditEvent);
