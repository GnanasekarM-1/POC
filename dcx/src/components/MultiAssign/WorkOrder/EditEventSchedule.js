import React, { useState } from "react";
import {
  Button,
  DateInput,
  Grid,
  GridRow,
  GridItem,
  Icon,
  Label,
  TimeInput,
  InputWrapper,
  Input,
  Container
} from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import moment from "moment";
import { cloneDeep, sum } from "lodash";
import {
  EVENTSTAG013,
  EVENTSTAG149,
  TAG053,
  TAG082,
  TAG102,
  TAG212,
  TAG213,
  TAG229,
  TAG234,
  TAG351,
  TAG352,
  TAG355,
  TAG397,
  TAG398,
  EVENTSTAG010
} from "constants/DisplayTagConstants";
import {
  AUTO_CALC_END_DATE,
  AUTO_SYNC_SVC_DURATION
} from "constants/UserSettingConstants";
import { DAYS, MINUTES } from "constants/DateTimeConstants";
import { validatedateObj } from "utils/DateTimeUtils";
import { isNumeric, getDisplayValue, getUserSetting } from "utils/DCUtils";
import {
  DCON001_SET011,
  DCON001_SET054,
  DCON001_SET064,
  DCON005_SET003,
  DCON005_SET004,
  getSettingValue
} from "constants/AppSettings";
import { DURATION, FALSE, HOURS } from "constants/AppConstants";
import "./EditEventSchedule.scss";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";
import {
  DATE_FORMAT,
  TIME_FORMAT,
  DATE_TIME_FORMAT
} from "constants/DateTimeConstants";

const END_DATE = "endDate";
const START_DATE = "startDate";
const BREAK_TIME = "breakTime";
const AFTER_OH_TIME = "afterOHTime";
const BEFORE_OH_TIME = "beforeOHTime";
const AFTER_DRIVE_TIME = "afterDriveTime";
const SERVICE_DURATION = "serviceDuration";
const BEFORE_DRIVE_TIME = "beforeDriveTime";

const dateFormat = getUserTimeSettings("dateFormat");
const timeFormat = getUserTimeSettings("timeFormat");
const dateTimeFormat = getUserTimeSettings("dateTimeFormat");

const EditEventSchedule = props => {
  const {
    event,
    editError,
    setEditError,
    isAllDayEvent,
    updateScheduledEvent
  } = props;
  const {
    afterDriveTime = 0,
    afterOHTime = 0,
    beforeDriveTime = 0,
    beforeOHTime = 0,
    breakTime = 0,
    endDate,
    serviceDuration,
    startDate
  } = event;

  const autoCalcEndDate = JSON.parse(getUserSetting(AUTO_CALC_END_DATE, false));
  const autoSyncSvcDuration = JSON.parse(
    getUserSetting(AUTO_SYNC_SVC_DURATION, false)
  );

  const measureUnitInHours = getSettingValue(DCON001_SET054, HOURS) === HOURS;
  const showDuration =
    getSettingValue(DCON001_SET064, "End Date Time") === DURATION;
  const showOverHeadTime = JSON.parse(
    getSettingValue(DCON005_SET003, FALSE).toLowerCase()
  );
  const showBreakTime = JSON.parse(
    getSettingValue(DCON005_SET004, FALSE).toLowerCase()
  );

  const isValidHourFormat = value => {
    const REGEX = /^([0-9]+):[0-5]*[0-9]$/;
    return REGEX.test(value);
  };

  const convertMinutesToHours = value => {
    if (!value) return "00:00";
    if (value < 60) return `00:${value}`;
    let hours = Math.floor(value / 60);

    const minutes = value - hours * 60;
    if (hours < 10) {
      hours = moment(hours, "hh").format("hh");
    }
    return `${hours}:${moment(minutes, "mm").format("mm")}`;
  };

  const convertHoursToMinutes = value => {
    let duration = 0;
    if (isEmpty(value)) {
      return duration;
    }
    // if (!isValidHourFormat(value)) {
    //   return value * 60;
    // }
    // Clear Errors if any.
    // const tokens = value.split(':');
    // return parseInt(tokens[0], 10) * 60 + parseInt(tokens[1], 10);
    const splits = value.split(":");
    let hours = (splits[0] && parseInt(splits[0], 10)) || 0;
    let minutes = (splits[1] && parseInt(splits[1], 10)) || 0;
    if (
      !Number.isNaN(hours) &&
      !Number.isNaN(minutes) &&
      Math.sign(hours) !== -1 &&
      Math.sign(minutes) !== -1
    ) {
      if (minutes > 59) {
        const roundHours = Math.floor(minutes / 60);
        hours += roundHours;
        minutes -= roundHours * 60;
      }
      duration = hours * 60 + minutes;
    }
    return duration;
  };

  const difference = moment(endDate, DATE_TIME_FORMAT).diff(
    moment(startDate, DATE_TIME_FORMAT),
    MINUTES
  );
  const idleTime = Number.isNaN(breakTime) ? 0 : breakTime;
  const svcDuration =
    serviceDuration -
    sum([beforeDriveTime, afterDriveTime, beforeOHTime, afterOHTime, idleTime]);
  const [brkTime, setBrkTime] = useState(
    measureUnitInHours ? convertMinutesToHours(idleTime) : idleTime
  );
  const [bDriveTime, setBDriveTime] = useState(
    measureUnitInHours
      ? convertMinutesToHours(beforeDriveTime)
      : beforeDriveTime
  );
  const [aDriveTime, setADriveTime] = useState(
    measureUnitInHours ? convertMinutesToHours(afterDriveTime) : afterDriveTime
  );
  const [bOverHeadTime, setBOverHeadTime] = useState(
    measureUnitInHours ? convertMinutesToHours(beforeOHTime) : beforeOHTime
  );
  const [aOverHeadTime, setAOverHeadTime] = useState(
    measureUnitInHours ? convertMinutesToHours(afterOHTime) : afterOHTime
  );

  const eventDuration = isAllDayEvent
    ? Math.ceil(difference / 60) * 60
    : difference;

  const [endDateTime, setEndDateTime] = useState(
    showDuration
      ? measureUnitInHours
        ? convertMinutesToHours(eventDuration)
        : eventDuration
      : moment(endDate, DATE_TIME_FORMAT)
  );
  const [startDateTime, setStartDateTime] = useState(
    moment(startDate, DATE_TIME_FORMAT)
  );
  const [actualSvcDuration, setActualSvcDuration] = useState(
    measureUnitInHours ? convertMinutesToHours(svcDuration) : svcDuration
  );
  const [lastModifiedField, setLastModifiedField] = useState(undefined);

  const [calcError, setCalcError] = useState(
    isAllDayEvent
      ? moment(endDate, DATE_TIME_FORMAT)
          .endOf("day")
          .isBefore(moment(startDate, DATE_TIME_FORMAT).startOf("day"))
        ? { [TAG102]: TAG102 }
        : {}
      : difference !== serviceDuration
      ? { [EVENTSTAG149]: EVENTSTAG149 }
      : {}
  );
  const [inputError, setInputError] = useState({});

  const isEmpty = value =>
    typeof value === "string" || value instanceof String
      ? value.trim().length <= 0
      : false;

  const getExtraDuration = () => {
    const bDTime = measureUnitInHours
      ? convertHoursToMinutes(bDriveTime)
      : +bDriveTime;
    const aDTime = measureUnitInHours
      ? convertHoursToMinutes(aDriveTime)
      : +aDriveTime;
    const bOHTime = measureUnitInHours
      ? convertHoursToMinutes(bOverHeadTime)
      : +bOverHeadTime;
    const aOHTime = measureUnitInHours
      ? convertHoursToMinutes(aOverHeadTime)
      : +aOverHeadTime;
    const bTime = measureUnitInHours
      ? convertHoursToMinutes(brkTime)
      : +brkTime;
    return sum([bDTime, aDTime, bOHTime, aOHTime, bTime]);
  };

  const getServiceDuration = () => {
    let currentSvcDuration = 0;
    if (measureUnitInHours) {
      currentSvcDuration = convertHoursToMinutes(actualSvcDuration);
    } else if (!isEmpty(actualSvcDuration)) {
      currentSvcDuration = +actualSvcDuration;
    }
    return currentSvcDuration;
  };

  const getEventServiceDuration = () =>
    sum([getServiceDuration(), getExtraDuration()]);

  const onServiceDurationInSync = () => {
    const newEndDateTime = showDuration
      ? measureUnitInHours
        ? cloneDeep(startDateTime).add(
            convertHoursToMinutes(endDateTime),
            MINUTES
          )
        : cloneDeep(startDateTime).add(endDateTime, MINUTES)
      : cloneDeep(endDateTime);
    updateScheduledEvent({
      [AFTER_DRIVE_TIME]: measureUnitInHours
        ? convertHoursToMinutes(aDriveTime)
        : isEmpty(aDriveTime)
        ? 0
        : +aDriveTime,
      [AFTER_OH_TIME]: measureUnitInHours
        ? convertHoursToMinutes(aOverHeadTime)
        : isEmpty(aOverHeadTime)
        ? 0
        : +aOverHeadTime,
      [BEFORE_DRIVE_TIME]: measureUnitInHours
        ? convertHoursToMinutes(bDriveTime)
        : isEmpty(bDriveTime)
        ? 0
        : +bDriveTime,
      [BEFORE_OH_TIME]: measureUnitInHours
        ? convertHoursToMinutes(bOverHeadTime)
        : isEmpty(bOverHeadTime)
        ? 0
        : +bOverHeadTime,
      [BREAK_TIME]: measureUnitInHours
        ? convertHoursToMinutes(brkTime)
        : isEmpty(brkTime)
        ? 0
        : brkTime,
      [END_DATE]: newEndDateTime.format(DATE_TIME_FORMAT),
      [SERVICE_DURATION]: getEventServiceDuration(),
      [START_DATE]: cloneDeep(startDateTime).format(DATE_TIME_FORMAT)
    });
  };

  const isServiceDurationInSync = newValue => {
    let diffInMinutes = endDateTime;
    if (showDuration) {
      if (measureUnitInHours) {
        diffInMinutes = convertHoursToMinutes(diffInMinutes);
      } else {
        diffInMinutes = +diffInMinutes;
      }
    } else {
      diffInMinutes = cloneDeep(newValue || endDateTime).diff(
        startDateTime,
        MINUTES
      );
    }

    const eventSvcDuration = measureUnitInHours
      ? convertHoursToMinutes(actualSvcDuration)
      : +actualSvcDuration;
    const totalDuration = eventSvcDuration + getExtraDuration();
    return totalDuration === diffInMinutes;
  };

  const onEndDateInputChange = () => {
    let value = endDateTime;
    if (measureUnitInHours) {
      value = convertHoursToMinutes(value);
    } else if (isEmpty(value) || isNaN(value) || parseInt(value, 10) < 0) {
      setInputError({ ...inputError, [END_DATE]: TAG355 });
      return;
    }
    // In case value is of String type, convert it to  Number type.
    value = +value;

    // In case of All Day Event, Round OFF to 1 or more days.
    if (isAllDayEvent) {
      let days = (value / (24 * 60)) >> 0;
      const hours = value % (24 * 60);
      days = hours > 0 ? days + 1 : days;
      value = days * 24 * 60;
      setEndDateTime(measureUnitInHours ? convertMinutesToHours(value) : value);
      return;
    }

    const newInputErros = { ...inputError };
    setEndDateTime(measureUnitInHours ? convertMinutesToHours(value) : value);
    if (autoSyncSvcDuration) {
      // Sync Service duration based on the end date value change.
      const svcDurationDiff = value - getExtraDuration();
      if (svcDurationDiff <= 0) {
        setCalcError({ ...calcError, [END_DATE]: EVENTSTAG149 });
        return;
      }
      // Update Service duration with new value.
      setActualSvcDuration(
        measureUnitInHours
          ? convertMinutesToHours(svcDurationDiff)
          : svcDurationDiff
      );

      // Clear calculation errors if any exists
      if (calcError[END_DATE]) {
        delete calcError[END_DATE];
        setCalcError(calcError);
      }
      // Service duration will sync automatically on end date change, Hence clear errors if any on service time.
      if (newInputErros[SERVICE_DURATION]) {
        delete newInputErros[SERVICE_DURATION];
      }
    } else if (!isServiceDurationInSync()) {
      setCalcError({ ...calcError, [EVENTSTAG149]: EVENTSTAG149 });
    } else if (calcError[EVENTSTAG149]) {
      const newCalcErrors = { ...calcError };
      delete newCalcErrors[EVENTSTAG149];
      setCalcError(newCalcErrors);
    }

    delete newInputErros[END_DATE];
    setInputError(newInputErros);
  };

  const onSvcDurationInputChange = () => {
    let value = actualSvcDuration;
    if (measureUnitInHours) {
      value = convertHoursToMinutes(value);
      setActualSvcDuration(convertMinutesToHours(value));
    } else if (isNaN(value) || parseInt(value, 10) < 0) {
      setInputError({ ...inputError, [SERVICE_DURATION]: TAG355 });
      return;
    }
    value = isNumeric(value) ? +value : 0;
    const newInputErros = { ...inputError };
    // update End date & time on extra duration change.
    if (autoSyncSvcDuration && value) {
      // Sync Event end date & time based on new service duration.
      const svcDurationDiff = value + getExtraDuration();
      const newEndDateTime = cloneDeep(startDateTime).add(
        svcDurationDiff,
        MINUTES
      );
      setEndDateTime(
        showDuration
          ? measureUnitInHours
            ? convertMinutesToHours(svcDurationDiff)
            : svcDurationDiff
          : newEndDateTime
      );

      // Clear if there are any calculation errors.
      if (
        calcError[SERVICE_DURATION] ||
        calcError[EVENTSTAG149] ||
        calcError[END_DATE]
      ) {
        const newCalcError = { ...calcError };
        delete newCalcError[END_DATE];
        delete newCalcError[EVENTSTAG149];
        delete newCalcError[SERVICE_DURATION];
        setCalcError(newCalcError);
      }
      // Clear if there are any End Date Time Input errors.
      if (newInputErros[END_DATE]) {
        delete newInputErros[END_DATE];
      }
    } else if (!isServiceDurationInSync()) {
      setCalcError({ ...calcError, [EVENTSTAG149]: EVENTSTAG149 });
    } else if (calcError[EVENTSTAG149]) {
      const newCalcErrors = { ...calcError };
      delete newCalcErrors[EVENTSTAG149];
      setCalcError(newCalcErrors);
    }
    delete newInputErros[SERVICE_DURATION];
    setInputError(newInputErros);
  };

  const onExtraInputChange = (name, newValue) => {
    if (measureUnitInHours) {
      newValue = convertHoursToMinutes(newValue);
      newValue = convertMinutesToHours(newValue);
      if (name == AFTER_DRIVE_TIME) {
        setADriveTime(newValue);
      } else if (name == AFTER_OH_TIME) {
        setAOverHeadTime(newValue);
      } else if (name == BEFORE_DRIVE_TIME) {
        setBDriveTime(newValue);
      } else if (name == BEFORE_OH_TIME) {
        setBOverHeadTime(newValue);
      }
    } else if (
      !isEmpty(newValue) &&
      (isNaN(newValue) || parseInt(newValue, 10) < 0)
    ) {
      setInputError({ ...inputError, [name]: TAG355 });
      return;
    }

    const newInputError = { ...inputError };
    // update End date & time on extra duration change, if service duration doesn't have errors.
    if (!newInputError[SERVICE_DURATION]) {
      // Sync Event end date & time based on new extra duration + service duration.
      const actualDuration = measureUnitInHours
        ? convertHoursToMinutes(actualSvcDuration)
        : +actualSvcDuration;
      const endTimeInMinutes = actualDuration + getExtraDuration();
      const newEndDateTime = cloneDeep(startDateTime).add(
        endTimeInMinutes,
        MINUTES
      );
      setEndDateTime(
        showDuration
          ? measureUnitInHours
            ? convertMinutesToHours(endTimeInMinutes)
            : endTimeInMinutes
          : newEndDateTime
      );

      // Clear if there are any End Date Time Input errors.
      if (newInputError[END_DATE]) {
        delete newInputError[END_DATE];
      }
    } else if (!isServiceDurationInSync()) {
      setCalcError({ ...calcError, [EVENTSTAG149]: EVENTSTAG149 });
    } else if (calcError[EVENTSTAG149]) {
      const newCalcErrors = { ...calcError };
      delete newCalcErrors[EVENTSTAG149];
      setCalcError(newCalcErrors);
    }
    delete newInputError[name];
    setInputError(newInputError);
  };

  const handleInputBlur = name => {
    switch (name) {
      case AFTER_DRIVE_TIME:
        onExtraInputChange(AFTER_DRIVE_TIME, aDriveTime);
        setLastModifiedField(END_DATE);
        break;
      case AFTER_OH_TIME:
        onExtraInputChange(AFTER_OH_TIME, aOverHeadTime);
        setLastModifiedField(END_DATE);
        break;
      case BEFORE_DRIVE_TIME:
        onExtraInputChange(BEFORE_DRIVE_TIME, bDriveTime);
        setLastModifiedField(END_DATE);
        break;
      case BEFORE_OH_TIME:
        onExtraInputChange(BEFORE_OH_TIME, bOverHeadTime);
        setLastModifiedField(END_DATE);
        break;
      case END_DATE:
        onEndDateInputChange();
        setLastModifiedField(END_DATE);
        break;
      case SERVICE_DURATION:
        onSvcDurationInputChange();
        setLastModifiedField(SERVICE_DURATION);
        break;
      default:
        break;
    }
  };

  const handleAutoPopulate = () => {
    if (lastModifiedField === END_DATE) {
      let diffInMinutes = endDateTime;
      if (showDuration) {
        if (measureUnitInHours) {
          diffInMinutes = convertHoursToMinutes(diffInMinutes);
        } else {
          diffInMinutes = +diffInMinutes;
        }
      } else {
        diffInMinutes = cloneDeep(endDateTime).diff(startDateTime, MINUTES);
      }
      const newServiceDuration = diffInMinutes - getExtraDuration();
      if (newServiceDuration > 0 && calcError[EVENTSTAG149]) {
        const newCalcErrors = { ...calcError };
        delete newCalcErrors[EVENTSTAG149];
        delete newCalcErrors[lastModifiedField];
        setCalcError(newCalcErrors);
        setActualSvcDuration(
          measureUnitInHours
            ? convertMinutesToHours(newServiceDuration)
            : newServiceDuration
        );
      } else {
        let durationInMinutes = 0;
        if (measureUnitInHours) {
          durationInMinutes = convertHoursToMinutes(actualSvcDuration);
        } else if (!isEmpty(actualSvcDuration)) {
          durationInMinutes = +actualSvcDuration;
        }
        if (durationInMinutes > 0) {
          const totalSvcDuration = durationInMinutes + getExtraDuration();
          const newEndDateTime = showDuration
            ? measureUnitInHours
              ? convertMinutesToHours(totalSvcDuration)
              : totalSvcDuration
            : cloneDeep(startDateTime).add(totalSvcDuration, MINUTES);
          if (calcError[EVENTSTAG149] || calcError[lastModifiedField]) {
            const newCalcErrors = { ...calcError };
            delete newCalcErrors[EVENTSTAG149];
            delete newCalcErrors[lastModifiedField];
            setCalcError(newCalcErrors);
          }
          setEndDateTime(newEndDateTime);
        }
      }
    } else {
      let durationInMinutes = 0;
      if (measureUnitInHours) {
        durationInMinutes = convertHoursToMinutes(actualSvcDuration);
      } else if (!isEmpty(actualSvcDuration)) {
        durationInMinutes = +actualSvcDuration;
      }

      // In case if service duraction is empty, compute service duration from event end date.
      if (!durationInMinutes) {
        durationInMinutes = endDateTime;
        if (showDuration) {
          if (measureUnitInHours) {
            durationInMinutes = convertHoursToMinutes(durationInMinutes);
          } else {
            durationInMinutes = +durationInMinutes;
          }
        } else {
          durationInMinutes = cloneDeep(endDateTime).diff(
            startDateTime,
            MINUTES
          );
        }
        const serviceDurationInMinutes = durationInMinutes - getExtraDuration();
        if (serviceDurationInMinutes > 0 && calcError[EVENTSTAG149]) {
          const newCalcErrors = { ...calcError };
          delete newCalcErrors[EVENTSTAG149];
          setCalcError(newCalcErrors);
          setActualSvcDuration(
            measureUnitInHours
              ? convertMinutesToHours(serviceDurationInMinutes)
              : serviceDurationInMinutes
          );
        }
      } else {
        const totalSvcDuration = durationInMinutes + getExtraDuration();
        const newEndDateTime = showDuration
          ? measureUnitInHours
            ? convertMinutesToHours(totalSvcDuration)
            : totalSvcDuration
          : cloneDeep(startDateTime).add(totalSvcDuration, MINUTES);
        if (calcError[EVENTSTAG149]) {
          const newCalcErrors = { ...calcError };
          delete newCalcErrors[EVENTSTAG149];
          setCalcError(newCalcErrors);
        }
        setEndDateTime(newEndDateTime);
      }
    }
  };

  const handleDateInputChange = ({ value, name }) => {
    if (value instanceof moment && name) {
      const formattedDate = value.format(DATE_FORMAT);
      if (name === START_DATE) {
        const newStartDateTime = moment(
          `${formattedDate} ${startDateTime.format(TIME_FORMAT)}`,
          DATE_TIME_FORMAT
        );
        setStartDateTime(newStartDateTime);
        if (isAllDayEvent) {
          const newEndDate = cloneDeep(endDateTime).endOf("day");
          if (newEndDate.isAfter(cloneDeep(value).startOf("day"))) {
            setCalcError({});
          } else {
            const newCalcErrors = { ...calcError };
            newCalcErrors[TAG102] = TAG102;
            setCalcError(newCalcErrors);
          }
          return;
        }
        if (autoCalcEndDate) {
          const newEndDateTime = cloneDeep(newStartDateTime).add(
            getEventServiceDuration(),
            MINUTES
          );
          const diffInMinutes = cloneDeep(newEndDateTime).diff(
            newStartDateTime,
            MINUTES
          );
          setEndDateTime(
            showDuration
              ? measureUnitInHours
                ? convertMinutesToHours(diffInMinutes)
                : diffInMinutes
              : newEndDateTime
          );
        }
      } else {
        const newEndDateTime1 = moment(
          `${formattedDate} ${endDateTime.format(TIME_FORMAT)}`,
          DATE_TIME_FORMAT
        );
        setEndDateTime(newEndDateTime1);

        if (isAllDayEvent) {
          setCalcError({});
          return;
        }

        // Auto Sync Service Duration based on End Date Time change.
        if (autoSyncSvcDuration) {
          const newEventSvcDuration = cloneDeep(newEndDateTime1).diff(
            startDateTime,
            MINUTES
          );
          const newServiceDuration = newEventSvcDuration - getExtraDuration();
          setActualSvcDuration(
            measureUnitInHours
              ? convertMinutesToHours(newServiceDuration)
              : newServiceDuration
          );
          // In case if new service duration turns zero or negative, flag error if error doesnt exists
          if (newServiceDuration <= 0 && !calcError[EVENTSTAG149]) {
            const newCalcErrors = { ...calcError };
            newCalcErrors[EVENTSTAG149] = EVENTSTAG149;
            setCalcError(newCalcErrors);
            return;
          }
          // Clear if any calucation error exists and set new service duration based on end date time change.
          if (calcError[EVENTSTAG149]) {
            const newCalcErrors = { ...calcError };
            delete newCalcErrors[EVENTSTAG149];
            setCalcError(newCalcErrors);
          }
        } else if (!isServiceDurationInSync(newEndDateTime1)) {
          setCalcError({ ...calcError, [EVENTSTAG149]: EVENTSTAG149 });
        } else if (calcError[EVENTSTAG149]) {
          const newCalcErrors = { ...calcError };
          delete newCalcErrors[EVENTSTAG149];
          setCalcError(newCalcErrors);
        }
        setLastModifiedField(END_DATE);
      }
    }
  };

  const handleTimeInputChange = ({ value }, name) => {
    if (!validatedateObj({ time: value })) {
      return false;
    }
    if (name === START_DATE) {
      const newStartDateTime = moment(
        `${startDateTime.format(dateFormat)} ${value}`,
        dateTimeFormat
      );
      if (autoCalcEndDate) {
        const newEndDateTime = cloneDeep(newStartDateTime).add(
          getEventServiceDuration(),
          MINUTES
        );
        const diffInMinutes = cloneDeep(newEndDateTime).diff(
          newStartDateTime,
          MINUTES
        );
        setEndDateTime(
          showDuration
            ? measureUnitInHours
              ? convertMinutesToHours(diffInMinutes)
              : diffInMinutes
            : newEndDateTime
        );
      }
      setStartDateTime(newStartDateTime);
    } else {
      const newEndDateTime1 = moment(
        `${endDateTime.format(dateFormat)} ${value}`,
        dateTimeFormat
      );
      setEndDateTime(newEndDateTime1);

      // Auto Sync Service Duration based on End Date Time change.
      if (autoSyncSvcDuration) {
        const newEventSvcDuration = cloneDeep(newEndDateTime1).diff(
          startDateTime,
          MINUTES
        );
        const newServiceDuration = newEventSvcDuration - getExtraDuration();
        // In case if new service duration turns zero or negative, flag error if error doesnt exists
        if (newServiceDuration <= 0 && !calcError[EVENTSTAG149]) {
          const newCalcErrors = { ...calcError };
          newCalcErrors[EVENTSTAG149] = EVENTSTAG149;
          setCalcError(newCalcErrors);
          return;
        }
        // Clear if any calucation error exists and set new service duration based on end date time change.
        if (calcError[EVENTSTAG149]) {
          const newCalcErrors = { ...calcError };
          delete newCalcErrors[EVENTSTAG149];
          setCalcError(newCalcErrors);
        }
        setActualSvcDuration(
          measureUnitInHours
            ? convertMinutesToHours(newServiceDuration)
            : newServiceDuration
        );
      } else if (!isServiceDurationInSync(newEndDateTime1)) {
        setCalcError({ ...calcError, [EVENTSTAG149]: EVENTSTAG149 });
      } else if (calcError[EVENTSTAG149]) {
        const newCalcErrors = { ...calcError };
        delete newCalcErrors[EVENTSTAG149];
        setCalcError(newCalcErrors);
      }
      setLastModifiedField(END_DATE);
    }
  };

  const validateTimeValues = evt => {
    const charCode = evt.which ? evt.which : evt.charCode;
    if (charCode > 31 && (charCode < 48 || charCode > 58)) {
      evt.preventDefault();
      return false;
    }
    return true;
  };

  let minStepInterval = 15;
  try {
    minStepInterval = parseInt(getSettingValue(DCON001_SET011, 15), 10) || 60;
  } catch (e) {
    console.log(e);
  }
  const showScheduleBreakup = () => !isAllDayEvent;
  const hasCalcErros = Object.keys(calcError).length;
  const hasInputErros = Object.keys(inputError).length;
  const minEndDate = cloneDeep(startDateTime).subtract(1, DAYS);
  const showTodayButton = moment()
    .startOf("day")
    .isSameOrAfter(moment(startDateTime, DATE_TIME_FORMAT).startOf("day"));
  const isSameDay =
    endDateTime instanceof moment
      ? endDateTime.diff(cloneDeep(startDateTime).endOf("day"), MINUTES) < 0
      : false;
  const inSync = !hasInputErros && !hasCalcErros;
  if (inSync) {
    if (editError) {
      setEditError(false);
    }
    setTimeout(() => onServiceDurationInSync(), 100);
  } else if (!editError) {
    setEditError(true);
  }

  return (
    <Container>
      <Grid className="EditEventSchedule" isVertical>
        <GridRow>
          <Grid isVertical>
            <GridRow className="EditEventSchedule__Row">
              <GridItem noFlex className="EditEventSchedule__Label">
                <Label>
                  <b>{getDisplayValue(TAG351)}</b>
                </Label>
              </GridItem>
              <GridItem noFlex>
                <DateInput
                  name={START_DATE}
                  dateFormat={dateFormat}
                  isDisabled={false}
                  value={moment(startDateTime.format(dateFormat), dateFormat)}
                  onValueChange={evt => handleDateInputChange(evt, START_DATE)}
                  size="x-small"
                />
              </GridItem>

              <GridItem noFlex>
                <TimeInput
                  name={START_DATE}
                  value={moment(startDateTime.format(timeFormat), timeFormat)}
                  onInputValueChange={evt =>
                    handleTimeInputChange(evt, START_DATE)
                  }
                  // onInputValueChange={({ value }) => setStartDateTime(moment(`${startDateTime.format(DATE_FORMAT)} ${value}`, DATE_TIME_FORMAT))}
                  step={minStepInterval}
                  timeFormat={timeFormat}
                  isDisabled={isAllDayEvent}
                />
              </GridItem>
              <GridItem />
            </GridRow>
            {showDuration && (
              <GridRow className="EditEventSchedule__Row">
                <GridItem noFlex className="EditEventSchedule__Label">
                  <Label>
                    <b>{getDisplayValue(TAG053)}</b>
                  </Label>
                </GridItem>
                <GridItem noFlex>
                  <Grid isVertical>
                    <GridRow>
                      <GridItem className="EditEventSchedule__SubLabel">
                        <span>
                          {measureUnitInHours
                            ? getDisplayValue(EVENTSTAG013)
                            : getDisplayValue(TAG082)}
                        </span>
                      </GridItem>
                    </GridRow>
                    <GridRow>
                      <GridItem>
                        <InputWrapper
                          size="xx-small"
                          onKeyPress={evt => validateTimeValues(evt)}
                          onBlur={() => handleInputBlur(END_DATE)}
                          inputOnValueChange={({ value }) =>
                            setEndDateTime(value)
                          }
                        >
                          <Input
                            name={END_DATE}
                            type={measureUnitInHours ? "text" : "number"}
                            value={endDateTime}
                            disabled={false}
                          />
                        </InputWrapper>
                      </GridItem>
                    </GridRow>
                  </Grid>
                </GridItem>
                <GridItem />
                <GridItem />
              </GridRow>
            )}
            {!showDuration && (
              <GridRow className="EditEventSchedule__Row">
                <GridItem noFlex className="EditEventSchedule__Label">
                  <Label>
                    <b>{getDisplayValue(TAG352)}</b>
                  </Label>
                </GridItem>
                <GridItem noFlex>
                  <DateInput
                    name={END_DATE}
                    minDate={moment(minEndDate.format(dateFormat), dateFormat)}
                    dateFormat={dateFormat}
                    isDisabled={false}
                    value={moment(endDateTime.format(dateFormat), dateFormat)}
                    onValueChange={evt => handleDateInputChange(evt, END_DATE)}
                    size="x-small"
                    showTodayButton={showTodayButton}
                  />
                </GridItem>

                <GridItem noFlex>
                  <TimeInput
                    name={END_DATE}
                    minTime={
                      isSameDay
                        ? moment(
                            cloneDeep(startDateTime).format(timeFormat),
                            timeFormat
                          )
                        : undefined
                    }
                    value={moment(endDateTime.format(timeFormat), timeFormat)}
                    onInputValueChange={evt =>
                      handleTimeInputChange(evt, END_DATE)
                    }
                    step={minStepInterval}
                    isDisabled={isAllDayEvent}
                    timeFormat={timeFormat}
                  />
                </GridItem>
                <GridItem />
              </GridRow>
            )}
          </Grid>
        </GridRow>
        {showScheduleBreakup() && (
          <GridRow hasBorderTop>
            <Grid className="EditEventSchedule__Breakup">
              <GridRow>
                <Grid isVertical>
                  <GridRow>
                    <GridItem>
                      <Label>
                        <b>{getDisplayValue(EVENTSTAG010)}</b>
                      </Label>
                    </GridItem>
                  </GridRow>
                  <GridRow className="EditEventSchedule__Row">
                    <GridItem className="EditEventSchedule__Breakup-start">
                      <Label>
                        {measureUnitInHours
                          ? getDisplayValue(EVENTSTAG013)
                          : getDisplayValue(TAG082)}
                      </Label>
                    </GridItem>
                  </GridRow>
                  <GridRow className="EditEventSchedule__Row">
                    <GridItem noFlex>
                      <InputWrapper
                        size="xx-small"
                        onKeyPress={evt => validateTimeValues(evt)}
                        onBlur={() => handleInputBlur(SERVICE_DURATION)}
                        inputOnValueChange={({ value }) =>
                          setActualSvcDuration(value)
                        }
                      >
                        <Input
                          name={SERVICE_DURATION}
                          min={0}
                          type={measureUnitInHours ? "text" : "number"}
                          value={actualSvcDuration}
                          disabled={false}
                        />
                      </InputWrapper>
                    </GridItem>
                    <GridItem className="EditEventSchedule__Breakup-center">
                      <Button
                        className="EditEventSchedule__Breakup-bell bell"
                        isDisabled={hasInputErros || !hasCalcErros}
                        type="icon-border-filled"
                        size="medium"
                        title={getDisplayValue(TAG234)}
                        onClick={() => handleAutoPopulate()}
                      >
                        <Icon icon="clock" />
                      </Button>
                    </GridItem>
                    <GridItem />
                  </GridRow>
                  <GridRow className="EditEventSchedule__Row" />
                </Grid>
              </GridRow>
              <GridRow>
                <Grid isVertical>
                  <GridRow>
                    <GridItem>
                      <Label>
                        <b>{getDisplayValue(TAG229)}</b>
                      </Label>
                    </GridItem>
                  </GridRow>
                  <GridRow className="EditEventSchedule__Row">
                    <GridItem className="EditEventSchedule__Breakup-center">
                      <Label>
                        {measureUnitInHours
                          ? getDisplayValue(EVENTSTAG013)
                          : getDisplayValue(TAG082)}
                      </Label>
                    </GridItem>
                  </GridRow>
                  <GridRow cols={3} className="EditEventSchedule__Row">
                    <GridItem cols={1}>
                      <Label>{getDisplayValue(TAG212)}</Label>
                    </GridItem>
                    <GridItem noFlex>
                      <InputWrapper
                        size="xx-small"
                        onKeyPress={evt => validateTimeValues(evt)}
                        onBlur={() => handleInputBlur(BEFORE_DRIVE_TIME)}
                        inputOnValueChange={({ value }) => setBDriveTime(value)}
                      >
                        <Input
                          defaultValue={measureUnitInHours ? "" : 0}
                          name={BEFORE_DRIVE_TIME}
                          min={0}
                          type={measureUnitInHours ? "text" : "number"}
                          value={bDriveTime}
                          disabled={false}
                        />
                      </InputWrapper>
                    </GridItem>
                    <GridItem cols={1} />
                  </GridRow>
                  <GridRow cols={3} className="EditEventSchedule__Row">
                    <GridItem cols={1}>
                      <Label>{getDisplayValue(TAG213)}</Label>
                    </GridItem>
                    <GridItem noFlex>
                      <InputWrapper
                        size="xx-small"
                        onKeyPress={evt => validateTimeValues(evt)}
                        onBlur={() => handleInputBlur(AFTER_DRIVE_TIME)}
                        inputOnValueChange={({ value }) => setADriveTime(value)}
                      >
                        <Input
                          defaultValue={measureUnitInHours ? "" : 0}
                          min={0}
                          name={AFTER_DRIVE_TIME}
                          type={measureUnitInHours ? "text" : "number"}
                          value={aDriveTime}
                          disabled={false}
                        />
                      </InputWrapper>
                    </GridItem>
                    <GridItem cols={1} />
                  </GridRow>
                </Grid>
              </GridRow>
              {showOverHeadTime && (
                <GridRow>
                  <Grid isVertical>
                    <GridRow>
                      <GridItem>
                        <Label>
                          <b>{getDisplayValue(TAG397)}</b>
                        </Label>
                      </GridItem>
                    </GridRow>
                    <GridRow className="EditEventSchedule__Row">
                      <GridItem className="EditEventSchedule__Breakup-center">
                        <Label>
                          {measureUnitInHours
                            ? getDisplayValue(EVENTSTAG013)
                            : getDisplayValue(TAG082)}
                        </Label>
                      </GridItem>
                    </GridRow>
                    <GridRow cols={3} className="EditEventSchedule__Row">
                      <GridItem cols={1}>
                        <Label>{getDisplayValue(TAG212)}</Label>
                      </GridItem>
                      <GridItem noFlex>
                        <InputWrapper
                          size="xx-small"
                          onKeyPress={evt => validateTimeValues(evt)}
                          onBlur={() => handleInputBlur(BEFORE_OH_TIME)}
                          inputOnValueChange={({ value }) =>
                            setBOverHeadTime(value)
                          }
                        >
                          <Input
                            defaultValue={measureUnitInHours ? "" : 0}
                            min={0}
                            name={BEFORE_OH_TIME}
                            type={measureUnitInHours ? "text" : "number"}
                            value={bOverHeadTime}
                            disabled={false}
                          />
                        </InputWrapper>
                      </GridItem>
                      <GridItem cols={1} />
                    </GridRow>
                    <GridRow cols={3} className="EditEventSchedule__Row">
                      <GridItem cols={1}>
                        <Label>{getDisplayValue(TAG213)}</Label>
                      </GridItem>
                      <GridItem noFlex>
                        <InputWrapper
                          size="xx-small"
                          onKeyPress={evt => validateTimeValues(evt)}
                          onBlur={() => handleInputBlur(AFTER_OH_TIME)}
                          inputOnValueChange={({ value }) =>
                            setAOverHeadTime(value)
                          }
                        >
                          <Input
                            defaultValue={measureUnitInHours ? "" : 0}
                            min={0}
                            name={AFTER_OH_TIME}
                            type={measureUnitInHours ? "text" : "number"}
                            value={aOverHeadTime}
                            disabled={false}
                          />
                        </InputWrapper>
                      </GridItem>
                      <GridItem cols={1} />
                    </GridRow>
                  </Grid>
                </GridRow>
              )}
              {showBreakTime && (
                <GridRow>
                  <Grid isVertical>
                    <GridRow>
                      <GridItem>
                        <Label>
                          <b>{getDisplayValue(TAG398)}</b>
                        </Label>
                      </GridItem>
                    </GridRow>
                    <GridRow className="EditEventSchedule__Row">
                      <GridItem className="EditEventSchedule__Breakup-center">
                        <Label>
                          {measureUnitInHours
                            ? getDisplayValue(EVENTSTAG013)
                            : getDisplayValue(TAG082)}
                        </Label>
                      </GridItem>
                    </GridRow>
                    <GridRow className="EditEventSchedule__Row">
                      <GridItem noFlex>
                        <InputWrapper size="xx-small">
                          <Input
                            disabled
                            name={BREAK_TIME}
                            type={measureUnitInHours ? "text" : "number"}
                            value={brkTime}
                          />
                        </InputWrapper>
                      </GridItem>
                    </GridRow>
                    <GridRow className="EditEventSchedule__Row" />
                  </Grid>
                </GridRow>
              )}
            </Grid>
          </GridRow>
        )}
        <GridRow>
          <GridItem className="EditEventSchedule__InValidSchedule">
            {hasInputErros
              ? getDisplayValue(Object.values(inputError)[0])
              : hasCalcErros
              ? getDisplayValue(Object.values(calcError)[0])
              : ""}
          </GridItem>
        </GridRow>
      </Grid>
    </Container>
  );
};

EditEventSchedule.propTypes = {
  editError: PropTypes.bool,
  event: PropTypes.shape({}).isRequired,
  isAllDayEvent: PropTypes.bool.isRequired,
  setEditError: PropTypes.func.isRequired,
  updateScheduledEvent: PropTypes.func.isRequired
};

export default EditEventSchedule;
