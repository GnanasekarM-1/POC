import store from "store";
import * as moment from "moment";
import { sum, find } from "lodash";
import { FormFields } from "@svmx/ui-components-lightning";
import {
  WO_UNSCHEDULED_DURATIONS,
  WO_ESTIMATED_DURATION_FIELD,
  WO_SCOPE_CHANGE_FIELD,
  WO_VARIANCE_FIELD,
  WO_REVISED_DURATION_FIELD,
  WO_ONSITE_RESPONCE_CUSTOMER_BY_FIELD,
  WO_RESTRORATION_CUSTOMER_BY_FIELD,
  WO_RESOLUTION_CUSTOMER_BY_FIELD,
  WO_ONSITE_RESPONCE_INTERNAL_BY_FIELD,
  WO_RESTRORATION_INTERNAL_BY_FIELD,
  WO_RESOLUTION_INTERNAL_BY_FIELD,
  WO_SERVICE_DURATION_FIELD,
  WO_OVERHEAD_TIME_BEFORE_FIELD,
  WO_BREAK_TIME_FIELD,
  WO_DRIVING_TIME_HOME_FIELD,
  WO_OVERHEAD_TIME_AFTER_FIELD,
  WO_DRIVING_TIME_FIELD,
  WO_IDLE_TIME_FIELD,
  WO_MINIMUM_SCHEDULE_DURATION_FIELD,
  WO_PREFERRED_BUSINESS_HOURS_FIELD,
  ORG_NAMESPACE,
  HOURS,
  NAME,
  WO_DISPATCH_STATUS_FIELD,
  SALESFORCE_EVENT,
  TECH_SALESFORCE_USER_FIELD,
  JDM_LJS_ENABLED,
  JDM_ENABLED_LJS_DISABELD,
  DOUBLE_BOOKING_ALLOW
} from "constants/AppConstants";
import { TAG280 } from "constants/DisplayTagConstants";
import {
  getSettingValue,
  DCON001_SET054,
  DCON001_SET025,
  GLOB001_GBL025,
  DCON001_SET011,
  DCON001_SET002
} from "constants/AppSettings";
import {
  DATE_TIME_FORMAT,
  DATE_FORMAT,
  TIME_FORMAT,
  YODA_DATE_FORMAT,
  YODA_DATE_TIME_ZONE_FORMAT,
  YODA_DATE_TIME_ZONE_24_HR_FORMAT,
  MINUTES
} from "constants/DateTimeConstants";
import { isArray, isObject } from "util";
import { getDisplayValue, getPickListItems } from "utils/DCUtils";
import {
  getMinutesToHours,
  getSecondsToHours,
  getHoursToMinutes
} from "utils/DateTimeUtils";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";

const {
  CheckboxField,
  DateInputField,
  DateTimeInputField,
  PicklistFactoryField,
  TextField,
  TextareaField,
  TimeInputField
} = FormFields;
const SET038 = "DCON001_SET038";
const SET039 = "DCON001_SET039";
const SET040 = "DCON001_SET040";
const SET041 = "DCON001_SET041";
const SET042 = "DCON001_SET042";
const SET043 = "DCON001_SET043";
const SET044 = "DCON001_SET044";
const SET045 = "DCON001_SET045";
const SET046 = "DCON001_SET046";
const SET047 = "DCON001_SET047";

const TEXTFIELD = "TEXTFIELD";
const TEXTAREA = "TEXTAREA";
const CHECKBOX = "CHECKBOX";
const PICKLIST = "PICKLIST";
const DATE = "DATE";
const TIME = "TIME";
const DATETIME = "DATETIME";

const getComponentType = type => {
  let componentType = TEXTFIELD;
  const fieldType = type.toLowerCase();
  if (
    fieldType === "string" ||
    fieldType === "currency" ||
    fieldType === "id" ||
    fieldType === "url" ||
    fieldType === "percent" ||
    fieldType === "number" ||
    fieldType === "double" ||
    fieldType === "email" ||
    fieldType === "phone"
  ) {
    componentType = TEXTFIELD;
  } else if (fieldType === "textarea") {
    componentType = TEXTAREA;
  } else if (fieldType === "boolean") {
    componentType = CHECKBOX;
  } else if (fieldType === "picklist") {
    componentType = PICKLIST;
  } else if (fieldType === "date") {
    componentType = DATE;
  } else if (fieldType === "datetime") {
    componentType = DATETIME;
  } else if (fieldType === "time") {
    componentType = TIME;
  }

  return componentType;
};

let woFields;
let evtFields;
const loadSettings = () => {
  const state = store.getState();
  const { metaData } = state;
  const { appSettings } = metaData;
  const { content } = appSettings;
  return content;
};

const loadWOFields = () => {
  const state = store.getState();
  const { metaData } = state;
  const { workOrderFields } = metaData;
  const { content } = workOrderFields;
  return content;
};

const loadEventFields = () => {
  const state = store.getState();
  const { metaData } = state;
  const { eventFields } = metaData;
  const { content } = eventFields;
  return content;
};

const getWOfieldDetails = (fieldApi, settingKey) => {
  let field;
  if (!woFields) woFields = loadWOFields();
  if (woFields && woFields[fieldApi]) {
    field = woFields[fieldApi];
    field.settingKey = settingKey;
    field.eventField = false;
    field.componentType = getComponentType(field.fieldType);
  }
  return field;
};

const getEventsfieldDetails = (fieldApi, settingKey) => {
  let field;
  if (!evtFields) evtFields = loadEventFields();
  field = evtFields[fieldApi];
  if (!field) {
    let apiName = fieldApi.replace(`${ORG_NAMESPACE}__`, "");
    apiName = apiName.replace("__c", "");
    if (apiName === "SM_Latitude") {
      field = evtFields.latitude;
    } else if (apiName === "SM_Longitude") {
      field = evtFields.longitude;
    } else if (apiName === "SM_Location") {
      field = evtFields.location;
    } else {
      field = evtFields[apiName];
    }
  }
  if (field) {
    field.settingKey = settingKey;
    field.componentType = getComponentType(field.fieldType);
    field.eventField = true;
  }
  return field;
};
export const getAllUpdateFields = () => {
  const settings = loadSettings();
  const fields = [];
  const allFields = {};
  if (settings[SET038]) allFields[SET038] = settings[SET038];
  if (settings[SET039]) allFields[SET039] = settings[SET039];
  if (settings[SET040]) allFields[SET040] = settings[SET040];
  if (settings[SET041]) allFields[SET041] = settings[SET041];
  if (settings[SET042]) allFields[SET042] = settings[SET042];
  if (settings[SET043]) allFields[SET043] = settings[SET043];
  if (settings[SET044]) allFields[SET044] = settings[SET044];
  if (settings[SET045]) allFields[SET045] = settings[SET045];
  if (settings[SET046]) allFields[SET046] = settings[SET046];
  if (settings[SET047]) allFields[SET047] = settings[SET047];
  const allSettingsKeys = Object.keys(allFields);
  allSettingsKeys.map(key => {
    const fieldApi = allFields[key];
    if (fieldApi.startsWith("Event.")) {
      const fieldDesc = getEventsfieldDetails(
        fieldApi.replace("Event.", ""),
        key
      );
      if (fieldDesc) {
        fields.push(fieldDesc);
      }
    } else {
      const fieldDesc = getWOfieldDetails(fieldApi, key);
      if (fieldDesc) {
        fields.push(getWOfieldDetails(fieldApi, key));
      }
    }
    return undefined;
  });
  return fields;
};

export const getAllNonWorkOrderUpdateFields = () => {
  const fields = getAllUpdateFields();
  const nonWorkorderFields = [];
  fields.map(field => {
    const { eventField } = field;
    if (eventField) {
      nonWorkorderFields.push(field);
    }
  });
  return nonWorkorderFields;
};

export const getComponentForField = field => {
  let component;
  const {
    componentType,
    display,
    settingKey,
    value,
    refField,
    eventField
  } = field;
  const roundOffTime = parseInt(getSettingValue(DCON001_SET011, 15), 10);
  const minStepInterval = roundOffTime || 15;
  let pickListObj;
  if (refField) {
    pickListObj = getPickListItems(refField, eventField);
  }
  if (componentType === TEXTFIELD) {
    component = {
      componentField: TextField,
      componentProps: {
        label: display,
        name: settingKey
      },

      isInputfield: true
    };
  } else if (componentType === TEXTAREA) {
    component = {
      componentField: TextareaField,
      componentProps: {
        label: display,
        name: settingKey
      },

      isInputfield: true
    };
  } else if (componentType === DATE) {
    component = {
      componentField: DateInputField,
      dateFormat: getUserTimeSettings("dateFormat"),
      componentProps: {
        label: display,
        dateFormat: getUserTimeSettings("dateFormat"),
        name: settingKey
      },
      isInputfield: false
    };
  } else if (componentType === DATETIME) {
    component = {
      componentField: DateTimeInputField,
      componentProps: {
        dateInputProps: {
          dateFormat: getUserTimeSettings("dateFormat")
        },
        timeInputProps: {
          timeFormat: getUserTimeSettings("timeFormat")
        },
        label: display,
        name: settingKey
      },
      isInputfield: false
    };
  } else if (componentType === CHECKBOX) {
    component = {
      componentField: CheckboxField,
      componentProps: {
        label: display,
        name: settingKey,
        fieldExtras: { value: "on" }
      },
      isInputfield: false
    };
  } else if (componentType === PICKLIST) {
    component = {
      componentField: PicklistFactoryField,
      componentProps: {
        label: display,
        items: pickListObj.pickListItems || [],
        name: settingKey,
        itemValueKey: "name",
        itemDisplayKey: "display"
      },
      isInputfield: false
    };
  } else if (componentType === TIME) {
    component = {
      componentField: TimeInputField,
      componentProps: {
        label: display,
        name: settingKey,
        timeFormat: getUserTimeSettings("timeFormat"),
        step: minStepInterval
      },
      isInputfield: false
    };
  }
  return component;
};
export const getInitialvalues = (
  dropDate,
  dropTime,
  technician,
  woInfo,
  jdm,
  eventSubject,
  isAllDayEvent,
  ljs,
  schedulingOption
) => {
  let selectedWO = null;
  if (Array.isArray(woInfo)) {
    [selectedWO] = Object.values(woInfo);
  } else {
    selectedWO = woInfo;
  }
  const { Name: wo } = selectedWO;
  let scheduledDuration =
    jdm &&
    (schedulingOption === JDM_LJS_ENABLED ||
      schedulingOption === JDM_ENABLED_LJS_DISABELD)
      ? woInfo[WO_UNSCHEDULED_DURATIONS]
      : !woInfo[WO_SERVICE_DURATION_FIELD] ||
        woInfo[WO_SERVICE_DURATION_FIELD] == 0
      ? parseInt(getSettingValue(DCON001_SET002))
      : woInfo[WO_SERVICE_DURATION_FIELD] / 60;
  const totoalTime =
    jdm && !ljs
      ? +scheduledDuration || 0
      : (+scheduledDuration || 0) + (+woInfo[WO_DRIVING_TIME_FIELD] || 0);
  const measureUnitInHours =
    getSettingValue(DCON001_SET054, HOURS) === HOURS || jdm;
  let sDuration = 0;
  if (
    measureUnitInHours &&
    !(
      jdm &&
      (schedulingOption === JDM_LJS_ENABLED ||
        schedulingOption === JDM_ENABLED_LJS_DISABELD)
    )
  ) {
    if (
      !woInfo[WO_SERVICE_DURATION_FIELD] ||
      woInfo[WO_SERVICE_DURATION_FIELD] == 0
    ) {
      sDuration = getMinutesToHours(parseInt(getSettingValue(DCON001_SET002)));
    } else {
      sDuration = getSecondsToHours(woInfo[WO_SERVICE_DURATION_FIELD]);
    }
  } else if (jdm && measureUnitInHours) {
    sDuration = getMinutesToHours(woInfo[WO_UNSCHEDULED_DURATIONS]);
  } else if (jdm && !measureUnitInHours) {
    sDuration = parseInt(woInfo[WO_UNSCHEDULED_DURATIONS]);
  } else {
    const woServiceDurationField = woInfo[WO_SERVICE_DURATION_FIELD];
    if (!woServiceDurationField || woServiceDurationField == 0) {
      sDuration = parseInt(getSettingValue(DCON001_SET002));
    } else {
      sDuration = parseInt(woServiceDurationField / 60);
    }
  }
  let sDate;
  let eDate;
  if (isAllDayEvent && !jdm) {
    scheduledDuration -= 1;
    sDate = moment(moment(dropDate).format(DATE_FORMAT)).startOf("day");
    eDate = moment(sDate, DATE_FORMAT)
      .add(scheduledDuration, "minutes")
      .endOf("day");
    const diffInMinutes =
      (moment(moment(eDate).format(DATE_FORMAT)).diff(
        moment(sDate).format(DATE_FORMAT),
        "day"
      ) +
        1) *
      60 *
      24;
    sDuration = measureUnitInHours
      ? getMinutesToHours(diffInMinutes)
      : diffInMinutes;
  }
  const isNewWO = woInfo[WO_DISPATCH_STATUS_FIELD] === "New";

  const initialValue = {
    alldayevents: "on",
    enddatetime:
      isAllDayEvent && !jdm
        ? {
            date: moment(eDate, getUserTimeSettings("dateFormat")),
            time: moment(
              moment(eDate, getUserTimeSettings("timeFormat")),
              getUserTimeSettings("timeFormat")
            )
          }
        : {
            date: moment(dropDate, getUserTimeSettings("dateFormat")).add(
              totoalTime,
              "m"
            ),
            time: moment(
              moment(dropTime, getUserTimeSettings("timeFormat")).add(
                totoalTime,
                "m"
              ),
              getUserTimeSettings("timeFormat")
            )
          },
    startdatetime:
      isAllDayEvent && !jdm
        ? {
            date: moment(sDate, getUserTimeSettings("dateFormat")),
            time: moment(sDate, getUserTimeSettings("timeFormat"))
          }
        : {
            date: moment(dropDate, getUserTimeSettings("dateFormat")),
            time: moment(dropTime, getUserTimeSettings("timeFormat"))
          },
    enddate:
      isAllDayEvent && !jdm
        ? moment(eDate, getUserTimeSettings("dateFormat"))
        : moment(dropDate, getUserTimeSettings("dateFormat")).add(
            totoalTime,
            "m"
          ),
    startdate: moment(
      isAllDayEvent && !jdm ? sDate : dropDate,
      getUserTimeSettings("dateFormat")
    ),
    estimatedduration: getMinutesToHours(woInfo[WO_ESTIMATED_DURATION_FIELD]),
    eventsubject: eventSubject || woInfo[NAME],
    serviceduration: sDuration,
    technicianname: technician,
    revisedduration: getMinutesToHours(woInfo[WO_REVISED_DURATION_FIELD]),
    scopechange: getMinutesToHours(woInfo[WO_SCOPE_CHANGE_FIELD]),
    variance: getMinutesToHours(woInfo[WO_VARIANCE_FIELD]),
    drivebeforetext:
      isAllDayEvent && !jdm
        ? measureUnitInHours
          ? "00 : 00"
          : "0"
        : measureUnitInHours
        ? getMinutesToHours(woInfo[WO_DRIVING_TIME_FIELD])
        : parseInt(woInfo[WO_DRIVING_TIME_FIELD]) || 0,
    driveaftertext: measureUnitInHours
      ? getMinutesToHours(woInfo[WO_DRIVING_TIME_HOME_FIELD])
      : parseInt(woInfo[WO_DRIVING_TIME_HOME_FIELD]) || 0,
    overheadbeforetext: measureUnitInHours
      ? getMinutesToHours(woInfo[WO_OVERHEAD_TIME_BEFORE_FIELD])
      : parseInt(woInfo[WO_OVERHEAD_TIME_BEFORE_FIELD]) || 0,
    overheadaftertext: measureUnitInHours
      ? getMinutesToHours(woInfo[WO_OVERHEAD_TIME_AFTER_FIELD])
      : parseInt(woInfo[WO_OVERHEAD_TIME_AFTER_FIELD]) || 0,
    // breaktime: measureUnitInHours ? getMinutesToHours(woInfo[WO_IDLE_TIME_FIELD]) : (woInfo[WO_IDLE_TIME_FIELD] || 0),
    breaktime: 0,
    minimumscheduleduration: measureUnitInHours
      ? getMinutesToHours(woInfo[WO_MINIMUM_SCHEDULE_DURATION_FIELD])
      : parseInt(woInfo[WO_MINIMUM_SCHEDULE_DURATION_FIELD]) || 0,
    remembermypreference: null,
    updateprimarytechnicians: isNewWO || null,
    deleteeventforothertechnicians: isNewWO || null
  };

  const allFields = getAllUpdateFields();
  allFields.map(field => {
    const {
      value: fieldName,
      fieldType,
      settingKey,
      refField,
      eventField
    } = field;
    let lstKeyValue = woInfo[fieldName];
    if (!lstKeyValue && fieldType === "PICKLIST") {
      const { defaultPickListItem } = getPickListItems(refField, eventField);
      lstKeyValue = defaultPickListItem;
    }
    if (lstKeyValue && fieldType !== "BOOLEAN") {
      if (fieldType === "DATETIME") {
        initialValue[settingKey] = {
          date: moment(lstKeyValue),
          time: moment(lstKeyValue, "HH:mm A")
        };
      } else if (fieldType === "DATE") {
        initialValue[settingKey] = moment(
          moment(lstKeyValue, [
            "DD-MM-YYYY",
            "DD.MM.YYYY",
            "YYYY-MM-DD",
            getUserTimeSettings("dateFormat")
          ]).format(getUserTimeSettings("dateFormat")),
          getUserTimeSettings("dateFormat")
        );
      } else if (fieldType === "PICKLIST") {
        initialValue[settingKey] = [lstKeyValue];
      } else if (fieldType === "TEXTFIELD" || fieldType === "TEXTAREA") {
        initialValue[settingKey] = [lstKeyValue];
      } else if (fieldType === "TIME") {
        initialValue[settingKey] = moment(
          moment(lstKeyValue, "HH:mm").format(
            getUserTimeSettings("timeFormat")
          ),
          getUserTimeSettings("timeFormat")
        );
      } else {
        initialValue[settingKey] = lstKeyValue;
      }
    } else if (fieldType === "BOOLEAN") {
      initialValue[settingKey] = lstKeyValue || null;
    }
    return undefined;
  });
  return initialValue;
};

export const getNonWOUpdateInitialvalues = (initialValue, data) => {
  const allFields = getAllNonWorkOrderUpdateFields();
  if (data) {
    getWOUpdateInitialvalues(initialValue, data, allFields);
    return;
  }

  allFields.map(field => {
    let lstKeyValue = "";
    const { value: fieldName, settingKey, componentType, refField } = field;
    // lstKeyValue = data && data[fieldName] ? data[fieldName] : '';
    // if (!lstKeyValue && componentType === 'PICKLIST') {
    if (componentType === "PICKLIST") {
      const { defaultPickListItem } = getPickListItems(refField, true);
      lstKeyValue = defaultPickListItem;
    }
    initialValue[settingKey] = lstKeyValue ? [lstKeyValue] : null;
    return undefined;
  });
};

export const getWOUpdateInitialvalues = (
  initialValue,
  data,
  eventFields = []
) => {
  const allFields = eventFields.length ? eventFields : getAllUpdateFields();
  const tzDtFormat = loadTimeZone();
  const tzDtFormatArr = tzDtFormat.split("@");
  const userTImeZone = tzDtFormatArr[0];
  let lstKey;

  let settingValue;

  let lstKeyValue = "";
  const fieldKeyObj = [
    { key: "SET038", value: "DCON001_SET038" },
    { key: "SET039", value: "DCON001_SET039" },
    { key: "SET040", value: "DCON001_SET040" },
    { key: "SET041", value: "DCON001_SET041" },
    { key: "SET042", value: "DCON001_SET042" },
    { key: "SET043", value: "DCON001_SET043" },
    { key: "SET044", value: "DCON001_SET044" },
    { key: "SET045", value: "DCON001_SET045" },
    { key: "SET046", value: "DCON001_SET046" },
    { key: "SET047", value: "DCON001_SET047" }
  ];
  allFields.map(field => {
    lstKeyValue = "";
    const { fieldUpdates, lstKeyValuePair } = data;
    const {
      value: fieldName,
      fieldType,
      settingKey,
      componentType,
      eventField,
      refField
    } = field;
    if (eventField) {
      lstKey = find(fieldKeyObj, { value: settingKey })
        ? find(fieldKeyObj, { value: settingKey }).key
        : "";
      settingValue =
        lstKey && lstKeyValuePair ? find(lstKeyValuePair, { key: lstKey }) : "";
      lstKeyValue = settingValue ? settingValue.value : "";
    } else if (fieldUpdates && fieldUpdates[fieldName]) {
      lstKeyValue = fieldUpdates[fieldName];
    }
    if (!lstKeyValue && componentType === "PICKLIST") {
      const { defaultPickListItem } = getPickListItems(
        refField,
        eventField,
        true
      );
      lstKeyValue = defaultPickListItem;
    }
    if (lstKeyValue) {
      if (componentType === "DATETIME") {
        // const utcToLocalDateTime = moment.utc(lstKeyValue).toDate();
        let convertedDateTime;
        if (moment(lstKeyValue, "MM/DD/YYYY hh:mm A", true).isValid()) {
          convertedDateTime = moment(lstKeyValue);
        } else {
          convertedDateTime = moment(lstKeyValue).tz(userTImeZone);
        }

        const utcToLocalDateTime = convertedDateTime.format(
          "YYYY-MM-DD HH:mm:ss"
        );
        const momentDateObj = moment(utcToLocalDateTime, "YYYY-MM-DD HH:mm:ss");
        initialValue[settingKey] = {
          date: moment(momentDateObj),
          time: moment(momentDateObj, "HH:mm A")
        };
      }
      if (componentType === "DATE") {
        initialValue[settingKey] = moment(
          moment(lstKeyValue, [
            "DD-MM-YYYY",
            "DD.MM.YYYY",
            "YYYY-MM-DD",
            getUserTimeSettings("dateFormat")
          ]).format(getUserTimeSettings("dateFormat")),
          getUserTimeSettings("dateFormat")
        );
      }
      if (componentType === "TIME") {
        initialValue[settingKey] = moment(
          moment(lstKeyValue, "HH:mm").format(
            getUserTimeSettings("timeFormat")
          ),
          getUserTimeSettings("timeFormat")
        );
      }

      if (componentType === "PICKLIST") {
        let exists = false;
        if (refField) {
          exists = refField.includes(lstKeyValue);
          if (lstKeyValue === getDisplayValue(TAG280)) {
            exists = true;
          }
        }
        initialValue[settingKey] = exists ? [lstKeyValue] : "";
        //initialValue[settingKey] = [lstKeyValue];
      }
      if (componentType === "TEXTFIELD" || componentType === "TEXTAREA") {
        initialValue[settingKey] = [lstKeyValue];
      }
      if (componentType === "CHECKBOX") {
        initialValue[settingKey] = JSON.parse(lstKeyValue) ? ["on"] : null;
      }
    } else if (componentType === "CHECKBOX") {
      initialValue[settingKey] = lstKeyValue || null;
    }
    return undefined;
  });
};
const loadTimeZone = () => {
  const state = store.getState();
  const { schedulerState } = state;
  const { timeZone } = schedulerState;
  return timeZone;
};

export const getCreateEventPayload = (formValues, isJDMenabled) => {
  const {
    activityDate,
    endDate,
    durationInMinutes,
    isAllDayEvent,
    startDate,
    serviceduration,
    serviceDuration,
    deleteEventForOtherTechs,
    eventsubject,
    descriptionfieldarea,
    locationnote,
    WhatId,
    OwnerId,
    techId,
    driveaftertext,
    drivebeforetext,
    overheadaftertext,
    scopechange,
    variance,
    overheadbeforetext,
    updatePrimaryTech,
    techSFId,
    woDispatchStatus
  } = formValues;
  const tzDtFormat = loadTimeZone();
  const tzDtFormatArr = tzDtFormat.split("@");
  const measureUnitInHours =
    getSettingValue(DCON001_SET054, HOURS) === HOURS || isJDMenabled;
  const budgetScope = [
    { Key: `SCOPE_${WhatId}`, Value: getHoursToMinutes(scopechange) },
    { Key: `VARIANCE_${WhatId}`, Value: getHoursToMinutes(variance) }
  ];
  const driveToWork = measureUnitInHours
    ? getHoursToMinutes(drivebeforetext)
    : drivebeforetext;
  const sDate = moment(startDate).subtract(driveToWork, "minutes");
  const jdmStartDate = moment
    .utc(sDate, DATE_TIME_FORMAT)
    .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);

  const payload = {
    events: [
      {
        type: "",
        // type: "Event",
        EndDateTime: endDate,
        WhatId,
        DurationInMinutes: isAllDayEvent ? serviceDuration : durationInMinutes,
        [WO_SERVICE_DURATION_FIELD]: isAllDayEvent
          ? serviceDuration * 60
          : measureUnitInHours
          ? getHoursToMinutes(serviceduration) * 60
          : serviceduration * 60,
        [WO_OVERHEAD_TIME_AFTER_FIELD]: measureUnitInHours
          ? getHoursToMinutes(overheadaftertext)
          : overheadaftertext,
        [WO_OVERHEAD_TIME_BEFORE_FIELD]: measureUnitInHours
          ? getHoursToMinutes(overheadbeforetext)
          : overheadbeforetext,
        [WO_BREAK_TIME_FIELD]: "0",
        [WO_DRIVING_TIME_FIELD]: measureUnitInHours
          ? getHoursToMinutes(drivebeforetext)
          : drivebeforetext,
        [WO_DRIVING_TIME_HOME_FIELD]: measureUnitInHours
          ? getHoursToMinutes(driveaftertext)
          : driveaftertext,
        IsAllDayEvent: isAllDayEvent,
        Description: descriptionfieldarea,
        fieldsToNull: "Id",
        Location: locationnote,
        ActivityDateTime: isJDMenabled ? jdmStartDate : startDate,
        Subject: eventsubject,
        ActivityDate: activityDate,
        StartDateTime: isJDMenabled ? jdmStartDate : startDate,
        OwnerId: OwnerId || techId
      }
    ],
    lstKeyValue: createKeyValuePayoad(formValues, isJDMenabled).concat(
      budgetScope
    ),
    techId,
    updatePrimaryTech,
    deleteEventForOtherTechs,
    timeZone: tzDtFormatArr[0],
    techSFId,
    woDispatchStatus
  };
  return payload;
};
export const getWoUpdateEventPayload = (
  formValues,
  eventData,
  isJDMenabled,
  isTechnicianChanged,
  isNonLongJobEvent
) => {
  const {
    activityDate,
    startDate,
    endDate,
    eventsubject,
    descriptionfieldarea,
    durationInMinutes,
    locationnote,
    OwnerId,
    eventId,
    isAllDayEvent,
    serviceduration,
    techId,
    woId,
    drivebeforetext,
    overheadbeforetext,
    driveaftertext,
    overheadaftertext,
    updatePrimaryTech,
    deleteEventForOtherTechs,
    techSFId,
    scopechange,
    variance,
    woDispatchStatus
  } = formValues;
  const tzDtFormat = loadTimeZone();
  const tzDtFormatArr = tzDtFormat.split("@");
  const { data } = eventData;
  const measureUnitInHours =
    getSettingValue(DCON001_SET054, HOURS) === HOURS || isJDMenabled;
  let owner_ID;
  let techSF_Id;
  const isSaleforceEvent = getSettingValue(GLOB001_GBL025) === SALESFORCE_EVENT;
  if (isSaleforceEvent && data[TECH_SALESFORCE_USER_FIELD]) {
    owner_ID = data[TECH_SALESFORCE_USER_FIELD];
    techSF_Id = data[TECH_SALESFORCE_USER_FIELD];
  } else {
    owner_ID = OwnerId;
    techSF_Id = techSFId;
  }
  const budgetScope = [
    { Key: `SCOPE_${woId}`, Value: getHoursToMinutes(scopechange) },
    { Key: `VARIANCE_${woId}`, Value: getHoursToMinutes(variance) }
  ];
  const driveToWork = measureUnitInHours
    ? getHoursToMinutes(drivebeforetext)
    : drivebeforetext;
  const sDate = moment(startDate).subtract(driveToWork, "minutes");
  const jdmStartDate = moment
    .utc(sDate, DATE_TIME_FORMAT)
    .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
  const payload = {
    timeZone: tzDtFormatArr[0],
    EventList: [
      {
        type: "",
        // type: "Event",
        EndDateTime: endDate,
        WhatId: woId,
        [WO_SERVICE_DURATION_FIELD]: measureUnitInHours
          ? getHoursToMinutes(serviceduration) * 60
          : serviceduration * 60,
        [WO_DRIVING_TIME_FIELD]: !isAllDayEvent
          ? measureUnitInHours
            ? getHoursToMinutes(drivebeforetext)
            : drivebeforetext
          : "0",
        DurationInMinutes: durationInMinutes,
        [WO_OVERHEAD_TIME_BEFORE_FIELD]: !isAllDayEvent
          ? measureUnitInHours
            ? getHoursToMinutes(overheadbeforetext)
            : overheadbeforetext
          : "0",
        [WO_BREAK_TIME_FIELD]: "0",
        [WO_DRIVING_TIME_HOME_FIELD]: !isAllDayEvent
          ? measureUnitInHours
            ? getHoursToMinutes(driveaftertext)
            : driveaftertext
          : "0",
        IsAllDayEvent: isAllDayEvent,
        Description: descriptionfieldarea,
        fieldsToNull: "Id",
        Id: eventId,
        Location: locationnote,
        [WO_OVERHEAD_TIME_AFTER_FIELD]: !isAllDayEvent
          ? measureUnitInHours
            ? getHoursToMinutes(overheadaftertext)
            : overheadaftertext
          : "0",
        ActivityDateTime: isJDMenabled ? jdmStartDate : startDate,
        Subject: eventsubject,
        ActivityDate: activityDate,
        StartDateTime: isJDMenabled ? jdmStartDate : startDate,
        OwnerId: isTechnicianChanged ? OwnerId : owner_ID
      }
    ],
    lstKeyValue: createKeyValuePayoad(formValues, isJDMenabled).concat(
      budgetScope
    ),
    TechnicianId: isTechnicianChanged ? techId : data["Id"],
    WorkOrderId: woId,
    updatePrimaryTech,
    deleteEventForOtherTechs,
    techSFId: isTechnicianChanged ? techSFId : techSF_Id,
    woDispatchStatus
  };
  return payload;
};

export const convertDateToUserTimeZone = (date, momentObj) => {
  let dateStr;
  const tzDtFormat = loadTimeZone();
  const tzDtFormatArr = tzDtFormat.split("@");
  const userTImeZone = tzDtFormatArr[0];
  if (date) {
    dateStr = moment(date).format(getUserTimeSettings("dateFormat"));
    dateStr = moment(dateStr).tz(userTImeZone);
    return momentObj ? dateStr : new Date(dateStr);
  }
  return undefined;
};

export const getEventBusinessHourPayload = values => {
  const {
    startDate,
    endDate,
    techId,
    isBasicWH,
    workOrderId,
    isMachineAccessHrsEnabled,
    isBusinessHrsEnabled
  } = values;
  const tzDtFormat = loadTimeZone();
  const tzDtFormatArr = tzDtFormat.split("@");

  let roundOffTime = 0;
  let roundOffEndDate = endDate;
  let roundOffStartDate = startDate;

  try {
    roundOffTime = parseInt(getSettingValue(DCON001_SET011, 15), 10);
  } catch (e) {}
  if (roundOffTime > 0) {
    // In case of NON Basic Mode, EndDateTime also need to be rounded.
    // if (!isBasicWH) {
    //   roundOffEndDate = moment.utc(endDate, YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    //   roundOffEndDate.minutes(
    //     Math.round(roundOffEndDate.minutes() / roundOffTime) * roundOffTime
    //   );
    //   roundOffEndDate = roundOffEndDate.format(
    //     YODA_DATE_TIME_ZONE_24_HR_FORMAT
    //   );
    // }
    roundOffStartDate = moment.utc(startDate, YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    roundOffStartDate.minutes(
      Math.round(roundOffStartDate.minutes() / roundOffTime) * roundOffTime
    );
    roundOffStartDate = roundOffStartDate.format(
      YODA_DATE_TIME_ZONE_24_HR_FORMAT
    );
  }
  const payload = {
    // WorkOrderId: isBasicWH ? null : workOrderId,
    WorkOrderId: workOrderId,
    TechId: techId,
    EventStartDateTime: roundOffStartDate,
    EventEndDateTime: isBasicWH ? null : roundOffEndDate,
    timeZone: tzDtFormatArr[0],
    isMachineAccessHrsEnabled,
    isBusinessHrsEnabled,
    isBasicWH
  };
  return payload;
};

export const getCreateNonWoEventPayload = (formValues, values) => {
  const {
    activityDate,
    startDate,
    endDate,
    eventsubject,
    descriptionfieldarea,
    locationnote,
    OwnerId,
    eventTypePicklist,
    isAllDayEventChk,
    serviceDuration,
    techId
  } = formValues;
  const tzDtFormat = loadTimeZone();
  const tzDtFormatArr = tzDtFormat.split("@");
  const payload = {
    timeZone: tzDtFormatArr[0],
    events: [
      {
        type: "",
        // type: "Event",
        Type: eventTypePicklist || null,
        EndDateTime: endDate,
        WhatId: null,
        [WO_SERVICE_DURATION_FIELD]: "0",
        [WO_DRIVING_TIME_FIELD]: "0",
        DurationInMinutes: serviceDuration,
        [WO_OVERHEAD_TIME_BEFORE_FIELD]: "0",
        [WO_BREAK_TIME_FIELD]: "0",
        [WO_DRIVING_TIME_HOME_FIELD]: "0",
        IsAllDayEvent: isAllDayEventChk,
        Description: descriptionfieldarea,
        fieldsToNull: "Id",
        Location: locationnote,
        [WO_OVERHEAD_TIME_AFTER_FIELD]: "0",
        ActivityDateTime: startDate,
        Subject: eventsubject,
        ActivityDate: activityDate,
        StartDateTime: startDate,
        OwnerId
      }
    ],
    lstKeyValue: createKeyValuePayoad(values),
    techId,
    updatePrimaryTech: false,
    deleteEventForOtherTechs: false,
    techSFId: null,
    isNonWorkOrderEvent: true
  };
  return payload;
};

const formatDatevalue = (dateValue, componentType) => {
  let convertedDate;
  if (componentType === "DATETIME") {
    const dateInput = moment(dateValue.date).format(DATE_FORMAT);
    const dateInputMinutes =
      dateValue.time.hour() * 60 + dateValue.time.minute();
    convertedDate = moment(dateInput).add(dateInputMinutes, "minutes");
  }
  const formattedDate =
    componentType === "DATETIME"
      ? moment(convertedDate).format(DATE_TIME_FORMAT)
      : moment(dateValue).format(DATE_TIME_FORMAT);
  return moment
    .utc(formattedDate, DATE_TIME_FORMAT)
    .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
};

const createKeyValuePayoad = (formValues, isJDMenabled) => {
  const lstKeyValue = [];
  const { woId, WhatId } = formValues;
  const fields = getAllUpdateFields();
  const fieldKeyObj = [
    { key: "SET038", value: "DCON001_SET038" },
    { key: "SET039", value: "DCON001_SET039" },
    { key: "SET040", value: "DCON001_SET040" },
    { key: "SET041", value: "DCON001_SET041" },
    { key: "SET042", value: "DCON001_SET042" },
    { key: "SET043", value: "DCON001_SET043" },
    { key: "SET044", value: "DCON001_SET044" },
    { key: "SET045", value: "DCON001_SET045" },
    { key: "SET046", value: "DCON001_SET046" },
    { key: "SET047", value: "DCON001_SET047" }
  ];
  let componentType;

  // In case of WorkOrder Event, Add ServiceDuration, Drive & Overhead as default values for key/Value Pairs.
  if (woId || WhatId) {
    const measureUnitInHours =
      getSettingValue(DCON001_SET054, HOURS) === HOURS || isJDMenabled;
    const {
      serviceduration,
      serviceDuration: serviceDurationAllDay,
      drivebeforetext,
      overheadbeforetext,
      driveaftertext,
      overheadaftertext,
      isAllDayEvent
    } = formValues;
    const serviceDuration = isAllDayEvent
      ? serviceDurationAllDay * 60
      : measureUnitInHours
      ? getHoursToMinutes(serviceduration) * 60
      : serviceduration * 60;
    const beforeDriveTime = measureUnitInHours
      ? getHoursToMinutes(drivebeforetext)
      : drivebeforetext;
    // const afterDriveTime = measureUnitInHours ? getHoursToMinutes(driveaftertext) : driveaftertext;
    const beforeOHTime = measureUnitInHours
      ? getHoursToMinutes(overheadbeforetext)
      : overheadbeforetext;
    const afterOHTime = measureUnitInHours
      ? getHoursToMinutes(overheadaftertext)
      : overheadaftertext;

    // lstKeyValue.push({ Key: `DRIVE_${woId || WhatId}`, Value: sum([beforeDriveTime, afterDriveTime]) });
    lstKeyValue.push({
      Key: `DRIVE_${woId || WhatId}`,
      Value: beforeDriveTime
    });
    lstKeyValue.push({
      Key: `OVERHEAD_${woId || WhatId}`,
      Value: sum([beforeOHTime, afterOHTime])
    });
    lstKeyValue.push({
      Key: `SERVICE_${woId || WhatId}`,
      Value: serviceDuration
    });
  }

  fieldKeyObj.forEach(obj => {
    componentType = find(fields, { settingKey: obj.value })
      ? find(fields, { settingKey: obj.value }).componentType
      : "";
    if (formValues[obj.value] || componentType === "CHECKBOX") {
      if (componentType === "DATETIME") {
        lstKeyValue.push({
          Key: obj.key,
          DateTimeValue: isArray(formValues[obj.value])
            ? formatDatevalue(formValues[obj.value][0], "DATETIME")
            : formatDatevalue(formValues[obj.value], "DATETIME"),
          Value: componentType.toLowerCase()
        });
      } else if (componentType === "DATE") {
        lstKeyValue.push({
          Key: obj.key,
          Value: isArray(formValues[obj.value])
            ? formatDatevalue(formValues[obj.value][0], "DATE")
            : formatDatevalue(formValues[obj.value], "DATE")
        });
      } else if (componentType === "TIME") {
        lstKeyValue.push({
          Key: obj.key,
          Value: isArray(formValues[obj.value])
            ? moment(formValues[obj.value][0]).format("HH:mm")
            : moment(formValues[obj.value]).format("HH:mm")
        });
      } else if (componentType === "PICKLIST") {
        lstKeyValue.push({
          Key: obj.key,
          Value: isArray(formValues[obj.value])
            ? formValues[obj.value][0] === getDisplayValue(TAG280)
              ? ""
              : formValues[obj.value][0]
            : formValues[obj.value] === getDisplayValue(TAG280)
            ? ""
            : formValues[obj.value]
        });
      } else if (componentType === "CHECKBOX") {
        lstKeyValue.push({
          Key: obj.key,
          Value: isArray(formValues[obj.value])
            ? !!formValues[obj.value][0]
            : !!formValues[obj.value]
        });
      } else {
        lstKeyValue.push({
          Key: obj.key,
          Value: isArray(formValues[obj.value])
            ? formValues[obj.value][0]
            : formValues[obj.value]
        });
      }
    }
  });
  return lstKeyValue;
};

export const getNonWoUpdateEventPayload = (formValues, values) => {
  const {
    activityDate,
    startDate,
    endDate,
    eventsubject,
    descriptionfieldarea,
    locationnote,
    OwnerId,
    eventId,
    eventTypePicklist,
    isAllDayEventChk,
    serviceDuration,
    techId
  } = formValues;
  const tzDtFormat = loadTimeZone();
  const tzDtFormatArr = tzDtFormat.split("@");
  const payload = {
    timeZone: tzDtFormatArr[0],
    EventList: [
      {
        type: "",
        // type: "Event",
        Type: eventTypePicklist || null,
        EndDateTime: endDate,
        WhatId: null,
        [WO_SERVICE_DURATION_FIELD]: "0",
        [WO_DRIVING_TIME_FIELD]: "0",
        DurationInMinutes: serviceDuration,
        [WO_OVERHEAD_TIME_BEFORE_FIELD]: "0",
        [WO_BREAK_TIME_FIELD]: "0",
        [WO_DRIVING_TIME_HOME_FIELD]: "0",
        IsAllDayEvent: isAllDayEventChk,
        Description: descriptionfieldarea,
        fieldsToNull: "Id",
        Id: eventId,
        Location: locationnote,
        [WO_OVERHEAD_TIME_AFTER_FIELD]: "0",
        ActivityDateTime: startDate,
        Subject: eventsubject,
        ActivityDate: activityDate,
        StartDateTime: startDate,
        OwnerId
      }
    ],
    lstKeyValue: createKeyValuePayoad(values),
    TechnicianId: techId,
    WorkOrderId: null,
    updatePrimaryTech: false,
    deleteEventForOtherTechs: false,
    techSFId: null,
    isNonWorkOrderEvent: true
  };
  return payload;
};

export const getNonWoUpdateDragEventPayload = formValues => {
  const {
    activityDate,
    startDate,
    endDate,
    eventsubject,
    descriptionfieldarea,
    locationnote,
    OwnerId,
    eventId,
    eventTypePicklist,
    isAllDayEventChk,
    serviceDuration,
    techId,
    lstKeyValuePair
  } = formValues;
  const tzDtFormat = loadTimeZone();
  const tzDtFormatArr = tzDtFormat.split("@");
  const payload = {
    timeZone: tzDtFormatArr[0],
    EventList: [
      {
        type: "",
        // type: "Event",
        Type: eventTypePicklist || null,
        EndDateTime: endDate,
        WhatId: null,
        [WO_SERVICE_DURATION_FIELD]: "0",
        [WO_DRIVING_TIME_FIELD]: "0",
        DurationInMinutes: serviceDuration,
        [WO_OVERHEAD_TIME_BEFORE_FIELD]: "0",
        [WO_BREAK_TIME_FIELD]: "0",
        [WO_DRIVING_TIME_HOME_FIELD]: "0",
        IsAllDayEvent: isAllDayEventChk,
        Description: descriptionfieldarea,
        fieldsToNull: "Id",
        Id: eventId,
        Location: locationnote,
        [WO_OVERHEAD_TIME_AFTER_FIELD]: "0",
        ActivityDateTime: startDate,
        Subject: eventsubject,
        ActivityDate: activityDate,
        StartDateTime: startDate,
        OwnerId
      }
    ],
    lstKeyValue: createKeyValuePayoad(formValues),
    TechnicianId: techId,
    WorkOrderId: null,
    updatePrimaryTech: false,
    deleteEventForOtherTechs: false
  };
  return payload;
};

export const getLJScreateEventPayload = (
  formValues,
  shouldCalculateEndTime,
  isJDMenabled
) => {
  const {
    jdmActivityDatetime,
    startDate,
    endDate,
    eventsubject,
    descriptionfieldarea,
    durationInMinutes,
    locationnote,
    OwnerId,
    serviceduration,
    WhatId,
    techId,
    driveaftertext,
    drivebeforetext,
    overheadaftertext,
    overheadbeforetext,
    scopechange,
    variance,
    techSFId,
    respectTechWorkHoursChecked,
    donotOverlapChecked,
    respectMachineAccessHoursChecked,
    shceduleAsLongJobChecked,
    updatePrimaryTech,
    deleteEventForOtherTechs,
    woDispatchStatus
  } = formValues;
  const measureUnitInHours =
    getSettingValue(DCON001_SET054, HOURS) === HOURS || isJDMenabled;
  const shouldAllowDoubleBooking =
    getSettingValue(DCON001_SET025) === DOUBLE_BOOKING_ALLOW;

  const budgetScope = [
    { Key: `SCOPE_${WhatId}`, Value: getHoursToMinutes(scopechange) },
    { Key: `VARIANCE_${WhatId}`, Value: getHoursToMinutes(variance) }
  ];
  const tzDtFormat = loadTimeZone();
  const tzDtFormatArr = tzDtFormat.split("@");
  const payload = {
    timeZone: tzDtFormatArr[0],
    lstEvent: [
      {
        type: "",
        // type: "Event",
        DurationInMinutes: durationInMinutes,
        [WO_SERVICE_DURATION_FIELD]: measureUnitInHours
          ? getHoursToMinutes(serviceduration) * 60
          : serviceduration * 60,
        Description: descriptionfieldarea,
        [WO_OVERHEAD_TIME_AFTER_FIELD]: measureUnitInHours
          ? getHoursToMinutes(overheadaftertext)
          : overheadaftertext,
        fieldsToNull: "Id",
        Location: locationnote,
        ActivityDateTime: jdmActivityDatetime,
        Subject: eventsubject,
        IsAllDayEvent: "false",
        [WO_DRIVING_TIME_HOME_FIELD]: measureUnitInHours
          ? getHoursToMinutes(driveaftertext)
          : driveaftertext,
        ActivityDate: moment(startDate).format("YYYY-MM-DD"),
        StartDateTime: startDate,
        [WO_DRIVING_TIME_FIELD]: measureUnitInHours
          ? getHoursToMinutes(drivebeforetext)
          : drivebeforetext,
        [WO_OVERHEAD_TIME_BEFORE_FIELD]: measureUnitInHours
          ? getHoursToMinutes(overheadbeforetext)
          : overheadbeforetext,
        OwnerId,
        [WO_BREAK_TIME_FIELD]: "0",
        WhatId,
        EndDateTime: endDate
      }
    ],
    lsttechId: [techId],
    eventMinDuration: 150,
    isTechWorkingHrsEnabled: shceduleAsLongJobChecked
      ? respectTechWorkHoursChecked === "on"
      : false,
    isMachineWorkingHrsEnabled: shceduleAsLongJobChecked
      ? respectMachineAccessHoursChecked === "on"
      : false,
    isOverlappingEnabled:
      shceduleAsLongJobChecked && shouldAllowDoubleBooking
        ? donotOverlapChecked === "on"
          ? false
          : true
        : false,
    isCalculateEndTime: shouldCalculateEndTime,
    lstKeyValue: createKeyValuePayoad(formValues, isJDMenabled).concat(
      budgetScope
    ),
    IsUnAssignWorkOrder: false,
    IsdeleteEvents: false,
    updatePrimaryTech,
    deleteEventForOtherTechs,
    techSFId,
    woDispatchStatus
  };
  return payload;
};

export const getTechniciansData = data => {
  const allTechnicians = [];
  const keys = Object.keys(data);
  keys.forEach(key => {
    const tech = data[key];
    const { technician_O } = tech;
    const { Id, Name } = technician_O;
    const techObject = {
      techId: Id,
      techName: Name,
      tech: technician_O
    };
    allTechnicians.push(techObject);
  });
  return allTechnicians;
};

// export const getUpdateEventPayload = formValues => {
//   const {
//     eventData,
//     technicianname,
//     arrivetime: StartTime,
//     departtime: EndDateTime,
//     eventsubject,
//     WorkOrderIds
//   } = formValues;
//   const { data, id: Id } = eventData;
//   const { ownerId } = data;
//   const endDate = moment(EndDateTime.date).add(
//     EndDateTime.time.format("HH"),
//     "h"
//   );
//   const startDate = moment(StartTime.date).add(
//     StartTime.time.format("HH"),
//     "h"
//   );
//   const payload = {
//     events: [
//       {
//         EndDateTime: endDate,
//         [WO_BREAK_TIME_FIELD]: "0",
//         WhatId: WorkOrderIds[0],
//         [WO_SERVICE_DURATION_FIELD]: "60",
//         DurationInMinutes: "60",
//         OwnerId: ownerId,
//         [WO_OVERHEAD_TIME_AFTER_FIELD]: "0",
//         [WO_OVERHEAD_TIME_BEFORE_FIELD]: "0",
//         Description: "",
//         Id,
//         Location: "",
//         ActivityDateTime: startDate,
//         Subject: eventsubject,
//         IsAllDayEvent: "false",
//         ActivityDate: StartTime.date.format("YYYY-MM-DD"),
//         StartDateTime: startDate,
//         [WO_DRIVING_TIME_HOME_FIELD]: "0"
//       }
//     ],
//     timeZone: "Asia/Kolkata"
//   };
//   return payload;
// };
// export const getUpdateEventPayloadOnTechChange = (formValues) => {
//   const {
//     eventData,
//     startdatetime,
//     departtime: EndDateTime,
//     eventsubject,
//     techId,
//     WorkOrderIds,
//   } = formValues;
//   const endDate = moment(EndDateTime.date).add(
//     EndDateTime.time.format('HH'),
//     'h',
//   );
//   const startDate = moment(StartTime.date).add(
//     StartTime.time.format('HH'),
//     'h',
//   );
//   const { id: eventId, TechId: TechnicianId } = eventData;
//   const payload = {
//     WorkOrderIds,
//     TechnicianId,
//     timeZone: 'Asia/Kolkata',
//     setOwner: false,
//     lstKeyValue: [],
//     EventList: [
//       {
//         type: 'Event',
//         EndDateTime: endDate,
//         [WO_BREAK_TIME_FIELD]: '0',
//         [WO_DRIVING_TIME_FIELD]: '0',
//         WhatId: WorkOrderIds[0],
//         [WO_SERVICE_DURATION_FIELD]: '60',
//         DurationInMinutes: '60',
//         Id: eventId,
//         OwnerId: techId,
//         [WO_OVERHEAD_TIME_AFTER_FIELD]: '0',
//         [WO_OVERHEAD_TIME_BEFORE_FIELD]: '0',
//         Description: '',
//         fieldsToNull: 'Id',
//         Location: '',
//         ActivityDateTime: startDate,
//         Subject: eventsubject,
//         IsAllDayEvent: 'false',
//         ActivityDate: StartTime.date.format('YYYY-MM-DD'),
//         StartDateTime: startDate,
//         [WO_DRIVING_TIME_HOME_FIELD]: '0',
//       },
//     ],
//   };
//   return payload;
// };
export const parseCreateEventData = reponsePayload => {
  const { content } = reponsePayload;
  const { lstEvent } = content;
  let eventPayload = null;
  if (lstEvent) {
    const events = [];
    lstEvent.forEach(evt => {
      events.push(evt);
    });
    eventPayload = {
      events
    };
  }
  return eventPayload;
};
export const getSlaValues = (woObject, isCustomer, type) => {
  let value = "";
  if (isCustomer) {
    if (
      woObject[WO_ONSITE_RESPONCE_CUSTOMER_BY_FIELD] &&
      woObject[WO_ONSITE_RESPONCE_CUSTOMER_BY_FIELD] != null &&
      type === "onsite"
    ) {
      value = moment(woObject[WO_ONSITE_RESPONCE_CUSTOMER_BY_FIELD]).format(
        DATE_TIME_FORMAT
      );
    } else if (
      woObject[WO_RESOLUTION_CUSTOMER_BY_FIELD] &&
      woObject[WO_RESOLUTION_CUSTOMER_BY_FIELD] != null &&
      type === "resolution"
    ) {
      value = moment(woObject[WO_RESOLUTION_CUSTOMER_BY_FIELD]).format(
        DATE_TIME_FORMAT
      );
    } else if (
      woObject[WO_RESTRORATION_CUSTOMER_BY_FIELD] &&
      woObject[WO_RESTRORATION_CUSTOMER_BY_FIELD] != null &&
      type === "restoration"
    ) {
      value = moment(woObject[WO_RESTRORATION_CUSTOMER_BY_FIELD]).format(
        DATE_TIME_FORMAT
      );
    }
  } else if (!isCustomer) {
    if (
      woObject[WO_ONSITE_RESPONCE_INTERNAL_BY_FIELD] &&
      woObject[WO_ONSITE_RESPONCE_INTERNAL_BY_FIELD] != null &&
      type === "onsite"
    ) {
      value = moment(woObject[WO_ONSITE_RESPONCE_INTERNAL_BY_FIELD]).format(
        DATE_TIME_FORMAT
      );
    } else if (
      woObject[WO_RESOLUTION_INTERNAL_BY_FIELD] &&
      woObject[WO_RESOLUTION_INTERNAL_BY_FIELD] != null &&
      type === "resolution"
    ) {
      value = moment(woObject[WO_RESOLUTION_INTERNAL_BY_FIELD]).format(
        DATE_TIME_FORMAT
      );
    } else if (
      woObject[WO_RESTRORATION_INTERNAL_BY_FIELD] &&
      woObject[WO_RESTRORATION_INTERNAL_BY_FIELD] != null &&
      type === "restoration"
    ) {
      value = moment(woObject[WO_RESTRORATION_INTERNAL_BY_FIELD]).format(
        DATE_TIME_FORMAT
      );
    }
  }
  return value;
};

export const isValidteEndDateForEventCreation = dateValues => {};
export const getTotalDurationInMinForHourEnabled = values => {
  const {
    serviceduration,
    driveaftertext,
    drivebeforetext,
    overheadaftertext,
    overheadbeforetext,
    breaktime
  } = values;
  const totalMinutes =
    (serviceduration ? getHoursToMinutes(serviceduration) : 0) +
    (driveaftertext ? getHoursToMinutes(driveaftertext) : 0) +
    (drivebeforetext ? getHoursToMinutes(drivebeforetext) : 0) +
    (overheadaftertext ? getHoursToMinutes(overheadaftertext) : 0) +
    (overheadbeforetext ? getHoursToMinutes(overheadbeforetext) : 0) +
    (breaktime ? getHoursToMinutes(breaktime) : 0);
  return totalMinutes;
};
export const getServiceDurationInMinForHourEnabled = values => {
  const {
    totlaMinutes,
    driveaftertext,
    drivebeforetext,
    overheadaftertext,
    overheadbeforetext,
    breaktime
  } = values;
  const serviceduration =
    totlaMinutes -
    (driveaftertext ? getHoursToMinutes(driveaftertext) : 0) -
    (drivebeforetext ? getHoursToMinutes(drivebeforetext) : 0) -
    (overheadaftertext ? getHoursToMinutes(overheadaftertext) : 0) -
    (overheadbeforetext ? getHoursToMinutes(overheadbeforetext) : 0) -
    (breaktime ? getHoursToMinutes(breaktime) : 0);
  return totlaMinutes == 0 ? 0 : serviceduration;
};
