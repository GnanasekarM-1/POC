import React, { Component } from "react";
import * as moment from "moment";
import { cloneDeep, filter, flatMap, remove, reverse } from "lodash";
import { IntlProvider } from "react-intl";
import {
  FormFields,
  Form,
  Input,
  GridRow,
  GridItem,
  Spinner,
  Grid,
  Tabs,
  Tab
} from "@svmx/ui-components-lightning";
import { getDisplayValue } from "utils/DCUtils";
import { getDateTimeValueFromDateTimeField } from "utils/DateAndTimeUtils";
import {
  getUserSettingValue,
  AUTO_CALC_END_DATE
} from "constants/UserSettingConstants";
import {
  TAG039,
  TAG036,
  TAG132,
  TAG133,
  TAG238,
  TAG247,
  TAG346,
  TAG037,
  TAG038,
  EVENTSTAG016,
  EVENTSTAG150
} from "constants/DisplayTagConstants";
import { DEFAULT_VALUE } from "constants/AppConstants";
import {
  getCreateNonWoEventPayload,
  getNonWoUpdateEventPayload,
  getAllNonWorkOrderUpdateFields,
  getComponentForField,
  getNonWOUpdateInitialvalues
} from "utils/EventsUtils";
import {
  getSettingValue,
  DCON005_SET005,
  SET002,
  DCON001_SET011
} from "constants/AppSettings";

import {
  YODA_DATE_TIME_ZONE_24_HR_FORMAT,
  DATE_TIME_FORMAT,
  YODA_DATE_FORMAT
} from "constants/DateTimeConstants";

import { getUserTimeSettings } from "utils/DateAndTimeUtils";

const {
  CheckboxField,
  DateTimeInputField,
  DateInputField,
  TextField,
  TextareaField,
  PicklistFactoryField
} = FormFields;

const FORM_NAME = "non-wo-create-event";
class EditEvent extends Component {
  constructor(props) {
    super(props);
    const { eventRecord, wo_isAlldayEvent } = this.props;
    let isAllDayEventCheck = wo_isAlldayEvent === "true";
    let serviceDuration = parseInt(getSettingValue(SET002));
    this.fields = getAllNonWorkOrderUpdateFields();
    if (eventRecord && eventRecord.data) {
      isAllDayEventCheck = eventRecord.data.IsAllDayEvent;
      const startDate = moment(eventRecord.data.startDate);
      const endDate = moment(eventRecord.data.endDate);
      serviceDuration = endDate.diff(startDate, "minutes");
    }
    this.state = {
      isEventUpdated: true,
      isAllDayEventChk: isAllDayEventCheck,
      isFieldDisabled: !this.fields.length
    };
    this.isEventStyle = false;
    this.checkStatusMsg = false;
    this.defaultDuration = serviceDuration;
  }

  handleFailedFormSubmit = errors => {
    this.checkStatusMsg = true;
    const { onHandleModalFieldCheck } = this.props;
    if (errors && errors.eventsubject) {
      onHandleModalFieldCheck(getDisplayValue(TAG132));
    }
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

  handleNonWorkOrderEvent = values => {
    const { starttime, endtime } = values;
    const formValues = {};
    const startDateInit = moment(starttime.date).format(
      getUserTimeSettings("dateFormat")
    );
    const endDateInit = moment(endtime.date).format(
      getUserTimeSettings("dateFormat")
    );
    const startMinutes = starttime.time.hour() * 60 + starttime.time.minute();
    const endMinutes = endtime.time.hour() * 60 + endtime.time.minute();
    const startDateConversion = moment(
      startDateInit,
      getUserTimeSettings("dateFormat")
    ).add(startMinutes, "minutes");
    const endDateConversion = moment(
      endDateInit,
      getUserTimeSettings("dateFormat")
    ).add(endMinutes, "minutes");
    const serviceDuration = endDateConversion.diff(
      startDateConversion,
      "minutes"
    );
    const nonWOStartDate = moment(startDateConversion).format(DATE_TIME_FORMAT);
    const nonWOEndDate = moment(endDateConversion).format(DATE_TIME_FORMAT);
    formValues.nonWOServiceDuration = serviceDuration;
    formValues.startDate = moment
      .utc(nonWOStartDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    formValues.endDate = moment
      .utc(nonWOEndDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    return formValues;
  };

  handleDateTimeCheck = (startdate, enddate, onHandleModalFieldCheck) => {
    const isBefore = enddate.isBefore(startdate);
    if (isBefore) {
      onHandleModalFieldCheck(getDisplayValue(TAG133));
    }
    return isBefore;
  };

  handleDateTimeCheckForSame = (
    startdate,
    enddate,
    onHandleModalFieldCheck
  ) => {
    const isSame = startdate.isSame(enddate);
    if (isSame) {
      onHandleModalFieldCheck(getDisplayValue(TAG133));
    }
    return isSame;
  };

  handleFormSubmit = values => {
    const me = this;
    const { eventActions } = me.props;
    const {
      eventRecord: eventData,
      isEditNonWOCreateEvent,
      onHandleModalFieldCheck,
      technicianObject,
      enableAndDisableSchedule
    } = me.props;
    const { isAllDayEventChk } = this.state;
    const {
      eventsubject,
      descriptionfieldarea,
      locationnote,
      eventTypePicklist,
      startdate,
      enddate,
      technicianname,
      techId,
      eventId,
      OwnerId
    } = values;
    const formValues = {};
    let isBefore = false;
    let isSame = false;
    if (technicianname === getDisplayValue("TAG041")) {
      onHandleModalFieldCheck(getDisplayValue("TAG041"));
      return undefined;
    }
    if (isAllDayEventChk) {
      isBefore = this.handleDateTimeCheck(
        startdate,
        enddate,
        onHandleModalFieldCheck
      );
      if (!isBefore) {
        const allDayFormValues = this.handleAllDayEvent(values);
        if (allDayFormValues) {
          formValues.startDate = allDayFormValues.startDate;
          formValues.endDate = allDayFormValues.endDate;
          formValues.serviceDuration = allDayFormValues.allDayServiceDuration;
          formValues.activityDate = allDayFormValues.activityDate;
        }
      } else {
        return undefined;
      }
    } else {
      const nonWorkOrderFormValues = this.handleNonWorkOrderEvent(values);
      formValues.startDate = nonWorkOrderFormValues.startDate;
      formValues.endDate = nonWorkOrderFormValues.endDate;
      formValues.serviceDuration = nonWorkOrderFormValues.nonWOServiceDuration;
      isBefore = this.handleDateTimeCheck(
        moment(nonWorkOrderFormValues.startDate),
        moment(nonWorkOrderFormValues.endDate),
        onHandleModalFieldCheck
      );
      isSame = this.handleDateTimeCheckForSame(
        moment(nonWorkOrderFormValues.startDate),
        moment(nonWorkOrderFormValues.endDate),
        onHandleModalFieldCheck
      );
      if (isBefore || isSame) {
        return undefined;
      }
    }
    formValues.OwnerId = OwnerId;
    formValues.techId = techId;
    formValues.eventData = eventData;
    formValues.isAllDayEventChk = isAllDayEventChk;
    formValues.eventsubject = eventsubject;
    formValues.descriptionfieldarea = descriptionfieldarea;
    formValues.locationnote = locationnote;
    formValues.eventTypePicklist = eventTypePicklist[0] || undefined;
    me.setState({ isEventUpdated: false, isScheduleEnabled: false });
    let payload;
    if (isEditNonWOCreateEvent) {
      formValues.eventId = eventId;
      payload = getNonWoUpdateEventPayload(formValues, values);
      eventActions.updateEvent(this.afterEventEditCall, payload);
    } else {
      payload = getCreateNonWoEventPayload(formValues, values);
      eventActions.createEventCall(this.afterEventCreateCall, payload);
    }
    enableAndDisableSchedule(true);
  };

  afterEventEditCall = (response, error = false) => {
    const {
      onClose,
      editEventCompleted,
      onHandleServerAlertModal,
      enableAndDisableSchedule
    } = this.props;
    if ((response && response === getDisplayValue(TAG238)) || error) {
      onHandleServerAlertModal(response);
    } else if (response && !error) {
      editEventCompleted(response);
      onClose();
    }
    this.setState({ isEventUpdated: true, isScheduleEnabled: true });
    enableAndDisableSchedule(false);
  };

  afterEventCreateCall = (response, error = false) => {
    const {
      onClose,
      createEventCompleted,
      onHandleServerAlertModal,
      enableAndDisableSchedule
    } = this.props;
    if ((response && response === getDisplayValue(TAG238)) || error) {
      onHandleServerAlertModal(response);
    } else if (response && !error) {
      createEventCompleted(response);
      onClose();
    }
    this.setState({ isEventUpdated: true, isScheduleEnabled: true });
    enableAndDisableSchedule(false);
  };

  allDayEventChecked = data => {
    const { value } = data;
    const { isAllDayEventChk } = this.state;
    this.setState({
      isAllDayEvent: value && value === "on",
      isAllDayEventChk: !isAllDayEventChk
    });
    const { onTreeConfChanged } = this.props;
    const changed = {};
    changed.wo_isAlldayEvent = value && value === "on" ? "true" : "false";
    onTreeConfChanged(changed);
  };

  timeInputChange = data => {};

  onDateTimeInputChange = e => {
    const { event } = e;
    const { date } = event;
    const toDateFormat = moment(new Date(date)).format(
      getUserTimeSettings("dateFormat")
    );
    const isValidDate = moment(
      toDateFormat,
      getUserTimeSettings("dateFormat"),
      true
    ).isValid();
    if (isValidDate) {
      return true;
    }
    return false;
  };

  getInitialValues = (eventData, refFieldArr, isResizeEvent) => {
    const { data, resizeStartDate, resizeEndDate } = eventData;
    const {
      endDate,
      id,
      location,
      startDate,
      subject,
      TechId,
      IsAllDayEvent,
      Type,
      description,
      ownerId
    } = data;
    // const refIndex = refFieldArr.indexOf(Type);
    const refField = filter(refFieldArr, field => field.name === Type);
    const [defaultType] = refField.length
      ? refField
      : refFieldArr.length
      ? refFieldArr
      : [];
    const calculatedStartDate = moment(startDate).format(
      getUserTimeSettings("dateFormat")
    );
    let startDateTime = moment(startDate).format(
      getUserTimeSettings("timeFormat")
    );
    const calculatedEnddate = IsAllDayEvent
      ? moment(endDate)
          .subtract(1, "minutes")
          .format(getUserTimeSettings("dateFormat"))
      : moment(endDate).format(getUserTimeSettings("dateFormat"));
    let endDateTime = IsAllDayEvent
      ? moment(endDate)
          .subtract(1, "minutes")
          .format(getUserTimeSettings("timeFormat"))
      : moment(endDate).format(getUserTimeSettings("timeFormat"));
    if (isResizeEvent) {
      startDateTime = moment(resizeStartDate).format(
        getUserTimeSettings("timeFormat")
      );
      endDateTime = moment(resizeEndDate).format(
        getUserTimeSettings("timeFormat")
      );
    }

    const initialValue = {
      alldayevents: IsAllDayEvent ? "on" : null,
      endtime: {
        date: moment(calculatedEnddate, getUserTimeSettings("dateFormat")),
        time: moment(endDateTime, getUserTimeSettings("timeFormat"))
      },
      eventsubject: subject,
      descriptionfieldarea: description,
      locationnote: location,
      starttime: {
        date: moment(calculatedStartDate, getUserTimeSettings("dateFormat")),
        time: moment(startDateTime, getUserTimeSettings("timeFormat"))
      },
      enddate: moment(calculatedEnddate, getUserTimeSettings("dateFormat")),
      startdate: moment(calculatedStartDate, getUserTimeSettings("dateFormat")),
      eventTypePicklist: defaultType ? [defaultType.name] : [],
      eventTypePicklistselect: (defaultType && defaultType.name) || null,
      technicianname: "",
      eventId: id,
      techId: TechId,
      OwnerId: ownerId
    };
    getNonWOUpdateInitialvalues(initialValue, data);
    return initialValue;
  };

  getCreateInitialValues = refFieldArr => {
    const startMinToAdd = 15 * Math.round(moment().minute() / 15);
    const startDate = moment()
      .startOf("hour")
      .add(startMinToAdd, "minutes");
    const endDate = moment(startDate).add(this.defaultDuration, "minutes");
    const currentStartDateString = moment(startDate).format(
      getUserTimeSettings("dateFormat")
    );
    const currentEndDateString = moment(endDate).format(
      getUserTimeSettings("dateFormat")
    );
    const curStartTimeString = moment(startDate).format(
      getUserTimeSettings("timeFormat")
    );
    const curEndTimeString = moment(endDate).format(
      getUserTimeSettings("timeFormat")
    );

    const defaultTypes = refFieldArr.filter(eventType => eventType.defaultType);
    const [defaultType] = defaultTypes.length
      ? defaultTypes
      : refFieldArr.length
      ? refFieldArr
      : [];

    const initialValue = {
      alldayevents: "on",
      endtime: {
        date: moment(currentEndDateString, getUserTimeSettings("dateFormat")),
        time: moment(curEndTimeString, getUserTimeSettings("timeFormat"))
      },
      starttime: {
        date: moment(currentStartDateString, getUserTimeSettings("dateFormat")),
        time: moment(curStartTimeString, getUserTimeSettings("timeFormat"))
      },
      enddate: moment(currentEndDateString, getUserTimeSettings("dateFormat")),
      startdate: moment(
        currentStartDateString,
        getUserTimeSettings("dateFormat")
      ),
      eventTypePicklist: defaultType ? [defaultType.name] : [],
      eventTypePicklistselect: (defaultType && defaultType.name) || null,
      technicianname: getDisplayValue("TAG041"),
      eventId: "",
      techId: "",
      OwnerId: ""
    };
    getNonWOUpdateInitialvalues(initialValue);
    return initialValue;
  };
  getDateTimeObject = dateValue => {
    return {
      date: moment(
        dateValue.value.format(getUserTimeSettings("dateFormat")),
        getUserTimeSettings("dateFormat")
      ),
      time: moment(
        dateValue.value.format(getUserTimeSettings("timeFormat")),
        getUserTimeSettings("timeFormat")
      )
    };
  };
  handleOnChangeAllDayDate = (dateValue, fieldName) => {
    const { chageFormField } = this.props;
    const { event } = dateValue;
    const { value } = event;
    const dateObj = getDateTimeValueFromDateTimeField(
      this.getDateTimeObject(event)
    );
    const endDateTimeValue = dateObj.add(this.defaultDuration - 1, "minutes");
    const updatedEnddate = {
      date: moment(endDateTimeValue, getUserTimeSettings("dateFormat")),
      time: moment(endDateTimeValue, getUserTimeSettings("timeFormat"))
    };
    const autoCalculateEndDate = JSON.parse(
      getUserSettingValue(AUTO_CALC_END_DATE, false)
    );
    if (autoCalculateEndDate && fieldName === "startdate") {
      chageFormField(FORM_NAME, "enddate", updatedEnddate.date);
      chageFormField(FORM_NAME, "endtime", {
        date: updatedEnddate.date,
        time: moment(moment().endOf("Day"))
      });
      chageFormField(FORM_NAME, "starttime", {
        date: moment(value),
        time: moment(moment().startOf("Day"))
      });
    } else if (fieldName === "startdate") {
      chageFormField(FORM_NAME, "starttime", {
        date: moment(value),
        time: moment(moment().startOf("Day"))
      });
    }
    if (fieldName === "enddate") {
      chageFormField(FORM_NAME, "endtime", {
        date: updatedEnddate.date,
        time: moment(moment().endOf("Day"))
      });
    }
  };

  handleOnChangeDate = (dateValue, fieldName) => {
    const { chageFormField } = this.props;
    const { event } = dateValue;
    const dateObj = getDateTimeValueFromDateTimeField(event);
    const endDateTimeValue = dateObj.add(this.defaultDuration, "minutes");
    const updatedEnddate = {
      date: moment(endDateTimeValue, getUserTimeSettings("dateFormat")),
      time: moment(endDateTimeValue, getUserTimeSettings("timeFormat"))
    };
    const autoCalculateEndDate = JSON.parse(
      getUserSettingValue(AUTO_CALC_END_DATE, false)
    );
    if (autoCalculateEndDate && fieldName === "starttime") {
      chageFormField(FORM_NAME, "endtime", updatedEnddate);
      chageFormField(FORM_NAME, "enddate", event.date);
      chageFormField(FORM_NAME, "startdate", event.date);
    } else if (fieldName === "starttime") {
      chageFormField(FORM_NAME, "startdate", event.date);
    }
    if (fieldName === "endtime") {
      chageFormField(FORM_NAME, "enddate", event.date);
    }
  };

  renderFormFields = () =>
    this.fields.map(field => {
      const componentObject = getComponentForField(field);
      const {
        componentField: ComponentField,
        componentProps,
        isInputfield
      } = componentObject;
      return (
        <GridRow>
          <GridItem className="FormFieldForm__component">
            {isInputfield && (
              <ComponentField {...componentProps} size="small">
                <Input />
              </ComponentField>
            )}
            {!isInputfield && <ComponentField {...componentProps} />}
          </GridItem>
        </GridRow>
      );
    });

  handleSubjectValueChange = () => {
    if (this.checkStatusMsg) {
      this.checkStatusMsg = false;
    }
  };

  normalizeEventTypes = dropDownList => {
    let eventTypes = [];
    if (!dropDownList || !dropDownList.length) {
      return eventTypes;
    }
    eventTypes = cloneDeep(dropDownList);
    reverse(eventTypes);
    let defaultTypes = remove(
      eventTypes,
      eventType => eventType.name === DEFAULT_VALUE
    );

    const regEx = /^TAG[0-9]+$/;
    const [defaultType] = defaultTypes.length ? defaultTypes : eventTypes;
    let { display } = defaultType || {};
    eventTypes = flatMap(eventTypes, eventType => {
      const type = { ...eventType };
      const { display: displayName } = eventType;
      if (displayName === display) {
        type.defaultType = !!defaultType;
      }
      if (regEx.test(displayName)) {
        type.display = getDisplayValue(displayName);
      }
      return type;
    });
    return eventTypes;
  };

  render() {
    const { isEventUpdated, isAllDayEventChk, isFieldDisabled } = this.state;
    const { handleSubjectChange } = this.props;
    const minStepInterval =
      parseInt(getSettingValue(DCON001_SET011, 15), 10) || 15;
    const { eventRecord, refFieldArr, isResizeEvent } = this.props;

    let initialValues = {};
    const eventTypes = this.normalizeEventTypes(refFieldArr);
    this.isEventStyle =
      getSettingValue(DCON005_SET005).toLowerCase() === "true";
    if (eventRecord && eventRecord.data) {
      initialValues = this.getInitialValues(
        eventRecord,
        eventTypes,
        isResizeEvent
      );
    } else {
      initialValues = this.getCreateInitialValues(eventTypes, minStepInterval);
    }

    return (
      <IntlProvider locale="en">
        <Form
          isDisabled={false}
          initialValues={initialValues}
          name={FORM_NAME}
          onSubmit={this.handleFormSubmit}
          onSubmitFail={this.handleFailedFormSubmit}
        >
          {!isEventUpdated && (
            <Grid isVertical>
              <GridRow>
                <GridItem>
                  <Spinner size="large" />
                </GridItem>
              </GridRow>
            </Grid>
          )}
          <Tabs type="scoped" activeKey="1">
            <Tab
              className="NonWoEvent__tabs"
              eventKey="1"
              title={getDisplayValue(EVENTSTAG016)}
            >
              <Grid class="" isVertical>
                <GridRow>
                  <GridItem>
                    <TextField
                      label={getDisplayValue("TAG034")}
                      isRequired
                      size="small"
                      placeholder=""
                      isDisabled
                      name="technicianname"
                    >
                      <Input />
                    </TextField>
                  </GridItem>
                </GridRow>
                <GridRow>
                  <GridItem>
                    <TextField
                      label={getDisplayValue("TAG035")}
                      isRequired
                      size="small"
                      placeholder=""
                      onChange={data => handleSubjectChange(data)}
                      name="eventsubject"
                    >
                      <Input />
                    </TextField>
                  </GridItem>
                </GridRow>
                {this.isEventStyle && (
                  <GridRow>
                    <GridItem>
                      <PicklistFactoryField
                        label={getDisplayValue(EVENTSTAG150)}
                        name="eventTypePicklist"
                        items={eventTypes}
                        size="small"
                        itemValueKey="name"
                        itemDisplayKey="display"
                      />
                    </GridItem>
                  </GridRow>
                )}
                <GridRow>
                  <GridItem>
                    <TextareaField
                      label={getDisplayValue(TAG036)}
                      size="small"
                      name="descriptionfieldarea"
                    >
                      <Input />
                    </TextareaField>
                  </GridItem>
                </GridRow>
                <GridRow>
                  {isAllDayEventChk ? (
                    <GridItem>
                      <DateInputField
                        label={getDisplayValue(TAG037)}
                        isRequired
                        menuAlign="left"
                        size="x-small"
                        name="startdate"
                        onChange={dateValue =>
                          this.handleOnChangeAllDayDate(dateValue, "startdate")
                        }
                        dateFormat={getUserTimeSettings("dateFormat")}
                      />
                    </GridItem>
                  ) : (
                    <DateTimeInputField
                      label={getDisplayValue(TAG037)}
                      isRequired
                      menuAlign="left"
                      size="x-small"
                      name="starttime"
                      dateInputProps={{
                        dateFormat: getUserTimeSettings("dateFormat")
                      }}
                      timeInputProps={{
                        timeFormat: getUserTimeSettings("timeFormat")
                      }}
                      onChange={dateValue =>
                        this.handleOnChangeDate(dateValue, "starttime")
                      }
                    />
                  )}
                </GridRow>
                <GridRow>
                  {isAllDayEventChk ? (
                    <GridItem>
                      <DateInputField
                        label={getDisplayValue(TAG038)}
                        isRequired
                        menuAlign="left"
                        size="x-small"
                        name="enddate"
                        onChange={dateValue =>
                          this.handleOnChangeAllDayDate(dateValue, "enddate")
                        }
                        dateFormat={getUserTimeSettings("dateFormat")}
                      />
                    </GridItem>
                  ) : (
                    <DateTimeInputField
                      label={getDisplayValue(TAG038)}
                      isRequired
                      menuAlign="left"
                      size="x-small"
                      name="endtime"
                      dateInputProps={{
                        dateFormat: getUserTimeSettings("dateFormat")
                      }}
                      timeInputProps={{
                        timeFormat: getUserTimeSettings("timeFormat")
                      }}
                      onChange={dateValue =>
                        this.handleOnChangeDate(dateValue, "endtime")
                      }
                    />
                  )}
                  <GridItem />
                </GridRow>
                <GridRow>
                  <GridItem>
                    <TextField
                      label={getDisplayValue(TAG039)}
                      size="small"
                      placeholder=""
                      name="locationnote"
                    >
                      <Input />
                    </TextField>
                  </GridItem>
                </GridRow>
                <GridRow>
                  <GridItem>
                    <CheckboxField
                      fieldExtras={{ value: "on" }}
                      onChange={this.allDayEventChecked}
                      name="alldayevents"
                      checked={isAllDayEventChk}
                    >
                      {getDisplayValue(TAG247)}
                    </CheckboxField>
                  </GridItem>
                </GridRow>
              </Grid>
            </Tab>
            <Tab
              className="NonWoEvent__tabs"
              isDisabled={isFieldDisabled}
              eventKey="2"
              title={getDisplayValue(TAG346)}
            >
              {this.renderFormFields()}
            </Tab>
          </Tabs>
        </Form>
      </IntlProvider>
    );
  }
}

export default EditEvent;
