import React, { Component } from "react";
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
  EVENTSTAG063,
  TAG082
} from "constants/DisplayTagConstants";
import { getDisplayValue, getFormValues, getUserSetting } from "utils/DCUtils";

const {
  CheckboxField,
  DateInputField,
  DateTimeInputField,
  TextField,
  TextareaField
} = FormFields;

export const formDisplayFields = [
  {
    label: "TAG034",
    size: "x-large",
    className: "CreateEvent__wrapper-Technical-name",
    name: "technicianname"
  },
  {
    label: "TAG035",
    isRequired: true,
    size: "x-large",
    name: "eventsubject"
  },
  {
    label: "TAG039",
    size: "x-large",
    name: "locationnote"
  },
  {
    label: "TAG036",
    size: "x-large",
    name: "descriptionfieldarea",
    row: 1
  },
  {
    name: "updateprimarytechnicians"
  },
  {
    name: "deleteeventforothertechnicians"
  },
  {
    label: "EVENTSTAG019",
    isRequired: true,
    size: "x-small",
    name: "enddate"
  },
  {
    label: "EVENTSTAG019",
    isRequired: true,
    size: "x-small",
    name: "enddatetime"
  },
  {
    label: "EVENTSTAG018",
    isRequired: true,
    size: "x-small",
    name: "startdate"
  },
  {
    label: "EVENTSTAG018",
    isRequired: true,
    size: "x-small",
    name: "startdatetime"
  },
  {
    label: "EVENTSTAG010",
    size: "xx-small",
    name: "serviceduration",
    unitFormat: "EVENTSTAG013",
    unitMinFormat: "TAG082"
  },
  {
    label: "",
    fieldExtras: { value: "true" },
    name: "alldayevents"
  },
  {
    name: "drivebeforetext",
    additionalLabel: "TAG212",
    label: "TAG229",
    size: "xx-small",
    unitFormat: "EVENTSTAG013",
    unitMinFormat: "TAG082"
  },
  {
    name: "driveaftertext",
    label: "TAG213",
    size: "xx-small",
    unitFormat: "EVENTSTAG013",
    unitMinFormat: "TAG082"
  },
  {
    name: "breaktime",
    label: "TAG398",
    size: "xx-small",
    unitFormat: "EVENTSTAG013",
    unitMinFormat: "TAG082"
  },
  {
    name: "minimumscheduleduration",
    label: "EVENTSTAG024",
    size: "xx-small",
    unitFormat: "EVENTSTAG013",
    unitMinFormat: "TAG082"
  },
  {
    name: "overheadbeforetext",
    additionalLabel: "TAG212",
    label: "EVENTSTAG070",
    size: "xx-small",
    unitFormat: "EVENTSTAG013",
    unitMinFormat: "TAG082"
  },
  {
    name: "overheadaftertext",
    label: "TAG213",
    size: "xx-small",
    unitFormat: "EVENTSTAG013",
    unitMinFormat: "TAG082"
  },
  {
    name: "estimatedduration",
    size: "x-small",
    label: "EVENTSTAG006"
  },
  {
    name: "scopechange",
    size: "x-small",
    label: "EVENTSTAG023"
  },
  {
    name: "variance",
    size: "x-small",
    label: "EVENTSTAG022"
  },
  {
    name: "revisedduration",
    size: "x-small",
    label: "EVENTSTAG007"
  }
];

export const getTextField = ({
  onKeyPress = "",
  inputPattern = "",
  type = "text",
  label = "",
  showHHMMFormat = false,
  size = "x-large",
  className,
  name,
  isDisabled = "",
  onChange = "",
  isRequired = "",
  placeholder = "",
  onBlur = "",
  unitFormat = "",
  additionalLabel = "",
  unitMinFormat = ""
}) => (
  <TextField
    label={`${getDisplayValue(label)} ${getDisplayValue(additionalLabel)} ${
      showHHMMFormat
        ? `(${getDisplayValue(unitFormat)})`
        : unitMinFormat !== ""
        ? `(${getDisplayValue(unitMinFormat)})`
        : ""
    }`}
    size={size}
    placeholder={placeholder}
    className={className}
    name={name}
    isDisabled={isDisabled}
    onChange={onChange}
    onBlur={onBlur}
    onKeyPress={onKeyPress}
    isRequired={isRequired}
  >
    <Input type={type} pattern={inputPattern} />
  </TextField>
);

export const getTextAreaField = ({
  label = "",
  size = "x-large",
  rows = 1,
  name
}) => (
  <TextareaField
    label={getDisplayValue(label)}
    size={size}
    rows={rows}
    name={name}
  >
    <Input />
  </TextareaField>
);

export const getCheckBoxField = ({
  checked,
  onChange = "",
  label = "",
  isDisabled = "",
  fieldExtras = { value: "on" },
  name,
  value = ""
}) => (
  <CheckboxField
    label={getDisplayValue(label)}
    isDisabled={isDisabled}
    fieldExtras={fieldExtras}
    onChange={onChange}
    checked={checked}
    name={name}
  >
    {value}
  </CheckboxField>
);

export const getDateInputField = ({
  label = "",
  isRequired = "",
  menuAlign = "left",
  size = "x-small",
  name,
  isDisabled = "",
  dateFormat,
  onChange = ""
}) => (
  <DateInputField
    label={getDisplayValue(label)}
    isRequired={isRequired}
    menuAlign={menuAlign}
    isDisabled={isDisabled}
    size={size}
    name={name}
    dateFormat={dateFormat}
    onChange={onChange}
  />
);

export const getDateTimeInputField = ({
  dateInputProps = "",
  timeInputProps = "",
  label = "",
  isRequired = "",
  menuAlign = "left",
  size = "x-small",
  name,
  onInputValueChange = ""
}) => (
  <DateTimeInputField
    label={getDisplayValue(label)}
    isRequired={isRequired}
    menuAlign={menuAlign}
    size={size}
    name={name}
    dateInputProps={dateInputProps}
    timeInputProps={timeInputProps}
    onInputValueChange={onInputValueChange}
  />
);
