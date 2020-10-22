import React from "react";
import PropTypes from "prop-types";
import moment from "moment";
import { getAllUpdateFields } from "utils/EventsUtils";
import {
  Container,
  DateTimeInput,
  DateInput,
  Grid,
  GridRow,
  GridItem,
  Label,
  PicklistFactory,
  Input,
  InputWrapper,
  Checkbox,
  Textarea,
  TimeInput
} from "@svmx/ui-components-lightning";
import { EVENTSTAG089, TAG280 } from "constants/DisplayTagConstants";
import { DCON001_SET011, getSettingValue } from "constants/AppSettings";
import {
  getDisplayValue,
  getFieldValue,
  getPickListItems
} from "utils/DCUtils";
import {
  YODA_DATE_FORMAT,
  TIME_FORMAT_24H,
  DEFAULT_DATE_TIME_FORMAT,
  MINUTES
} from "constants/DateTimeConstants";

import "./WorkOrderFieldUpdate.scss";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";

const WorkOrderFieldUpdate = props => {
  const {
    editEvent,
    editFields,
    selectedWO,
    updateEventFields,
    selectedTimeZone,
    rows
  } = props;

  const tzDtFormatArr = selectedTimeZone.split("@");
  const userTImeZone = tzDtFormatArr[0];

  const INPUT_TYPE_MAPPING = {
    DOUBLE: "number",
    EMAIL: "email",
    STRING: "text",
    TEXTAREA: "text"
  };

  let minStepInterval = 15;
  try {
    minStepInterval = parseInt(getSettingValue(DCON001_SET011, 15), 10);
  } catch (e) {
    console.log(e);
  }

  const getInputType = fieldType => INPUT_TYPE_MAPPING[fieldType] || "text";

  const onInputChange = ({ name, value }) => {
    updateEventFields(name, value);
  };

  const formatDatevalue = ({ date, time }) => {
    const dateMoment =
      date instanceof moment
        ? moment(
            date.format(getUserTimeSettings("dateFormat")),
            getUserTimeSettings("dateFormat")
          )
        : moment(date, getUserTimeSettings("dateFormat"));
    const timeMoment =
      time instanceof moment
        ? moment(
            time.format(getUserTimeSettings("timeFormat")),
            getUserTimeSettings("timeFormat")
          )
        : moment(time, getUserTimeSettings("timeFormat"));
    const minutes = timeMoment.hour() * 60 + timeMoment.minute();
    const convertedDate = moment(dateMoment).add(minutes, MINUTES);
    return moment(convertedDate, getUserTimeSettings("dateTimeFormat"));
  };

  const onDateTimeChange = ({ date, time }, name) => {
    const momentDate = formatDatevalue({ date, time });
    updateEventFields(name, momentDate);
  };

  const onTimeInputChange = ({ value }, name) => {
    updateEventFields(
      name,
      moment
        .utc(value, getUserTimeSettings("timeFormat"))
        .format(TIME_FORMAT_24H)
    );
  };

  const onDateChange = ({ name, value }) => {
    updateEventFields(name, value.format(YODA_DATE_FORMAT));
  };

  const onPickListValueChange = ({ selectedValues }, name) => {
    updateEventFields(name, selectedValues);
  };

  const handleToggleChange = ({ name, value, isChecked }) => {
    updateEventFields(name, isChecked);
  };

  const getFieldComponent = updateField => {
    const {
      eventField,
      fieldType,
      refField = [],
      settingKey,
      value: apiName
    } = updateField;
    const { scheduledEvent = false } = editEvent || {};
    const defaultValue = getFieldValue(
      eventField ? editEvent : selectedWO,
      eventField ? settingKey : apiName
    );
    let value =
      editFields[settingKey] ||
      (rows.length && rows[0][settingKey]) ||
      defaultValue;

    if (fieldType === "BOOLEAN") {
      if (editFields[settingKey] !== undefined) {
        value = editFields[settingKey];
      } else if (rows.length && rows[0][settingKey] !== undefined) {
        value = rows[0][settingKey];
      } else {
        value = defaultValue;
      }
    }

    if (fieldType === "DATETIME") {
      if (value && !(value instanceof moment)) {
        let convertedDateTime;
        if (moment(value, "MM/DD/YYYY hh:mm A", true).isValid()) {
          convertedDateTime = moment(value);
        } else {
          convertedDateTime = moment(value).tz(userTImeZone);
        }

        const utcToLocalDateTime = convertedDateTime.format(
          DEFAULT_DATE_TIME_FORMAT
        );
        value = moment(utcToLocalDateTime, DEFAULT_DATE_TIME_FORMAT);
      }
    }

    if (fieldType === "DATE") {
      value = moment(value, [
        "DD-MM-YYYY",
        "DD.MM.YYYY",
        "YYYY-MM-DD",
        getUserTimeSettings("dateFormat")
      ]);
    }

    if (fieldType === "TIME") {
      if (value && !(value instanceof moment)) {
        const utcToLocalDateTime = moment(
          value,
          getUserTimeSettings("timeFormat")
        ).format(TIME_FORMAT_24H);
        value = moment(utcToLocalDateTime, TIME_FORMAT_24H);
      }
    }

    if (fieldType === "BOOLEAN") {
      value = value && JSON.parse(value) ? ["on"] : false;
    }

    switch (fieldType) {
      case "DOUBLE":
      case "EMAIL":
      case "STRING":
        return (
          <InputWrapper size="small">
            <Input
              name={settingKey}
              value={value}
              onValueChange={event => onInputChange(event)}
              disabled={false}
              type={getInputType(fieldType)}
            />
          </InputWrapper>
        );
      case "TEXTAREA":
        return (
          <Textarea
            name={settingKey}
            value={value}
            size="small"
            onValueChange={event => onInputChange(event)}
            disabled={false}
          />
        );
      case "PICKLIST":
        const pickListObj = getPickListItems(
          refField,
          eventField,
          scheduledEvent
        );
        return (
          <PicklistFactory
            className="WorkOrderFieldUpdate__Column"
            // defaultText="Select a Field"
            items={pickListObj.pickListItems}
            name={settingKey}
            onSelectedChange={event => onPickListValueChange(event, settingKey)}
            selectedValues={value ? [value] : [pickListObj.defaultPickListItem]}
            itemValueKey="name"
            itemDisplayKey="display"
          />
        );
      case "DATE":
        return (
          <DateInput
            name={settingKey}
            size="x-small"
            value={value ? moment(value) : undefined}
            dateFormat={getUserTimeSettings("dateFormat")}
            onValueChange={event => onDateChange(event, settingKey)}
          />
        );
      case "DATETIME":
        return (
          <DateTimeInput
            name={settingKey}
            size="x-small"
            value={
              value
                ? {
                    date: moment(value),
                    time: moment(value, "HH:mm A")
                  }
                : undefined
            }
            dateInputProps={{ dateFormat: getUserTimeSettings("dateFormat") }}
            timeInputProps={{
              step: minStepInterval,
              size: "xx-small",
              timeFormat: getUserTimeSettings("timeFormat")
            }}
            onInputValueChange={event => onDateTimeChange(event, settingKey)}
          />
        );
      case "BOOLEAN":
        return (
          <Checkbox
            name={settingKey}
            value={value}
            isChecked={value}
            onCheckedChange={event => handleToggleChange(event)}
          />
        );
      case "TIME":
        return (
          <TimeInput
            name={settingKey}
            step={minStepInterval}
            timeFormat={getUserTimeSettings("timeFormat")}
            value={value ? moment(value, "HH:mm A") : undefined}
            onInputValueChange={event => onTimeInputChange(event, settingKey)}
          />
        );
      default:
        return (
          <InputWrapper size="small">
            <Input
              name={settingKey}
              value={value}
              onValueChange={event => onInputChange(event)}
              disabled={false}
              type={getInputType(fieldType)}
            />
          </InputWrapper>
        );
    }
  };

  const createFieldComponent = updateField => {
    const { display } = updateField;
    return (
      <GridRow cols={2} className="WorkOrderFieldUpdate__Row">
        <GridItem cols={1}>
          <Label>
            <b>{display}</b>
          </Label>
        </GridItem>
        <GridItem cols={1}>{getFieldComponent(updateField)}</GridItem>
        <GridItem />
      </GridRow>
    );
  };

  const createUpdateLayout = (updateFields = []) => {
    const { length } = updateFields;
    if (length) {
      return updateFields.map(updateField => createFieldComponent(updateField));
    }
    return (
      <Container style={{ padding: "4px 8px" }}>
        <Textarea name={EVENTSTAG089} value={getDisplayValue(EVENTSTAG089)} />
      </Container>
    );
  };

  return (
    <Grid isVertical className="WorkOrderFieldUpdate">
      {createUpdateLayout(getAllUpdateFields())}
    </Grid>
  );
};

WorkOrderFieldUpdate.propTypes = {
  editEvent: PropTypes.shape({}).isRequired,
  editFields: PropTypes.shape({}).isRequired,
  selectedWO: PropTypes.shape({}).isRequired,
  selectedTimeZone: PropTypes.string.isRequired,
  updateEventFields: PropTypes.func.isRequired
};

export default WorkOrderFieldUpdate;
