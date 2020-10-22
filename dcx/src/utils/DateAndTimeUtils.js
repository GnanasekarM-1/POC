import moment from "moment";
import {
  DATE_TIME_FORMAT,
  DEFAULT_FORMAT,
  DATE_FORMAT,
  MINUTES
} from "constants/DateTimeConstants";
import { getSettingValue, SET054 } from "constants/AppSettings";

//const DEFAULT_TIME_FORMAT = "A h:mm";
//const DEFAULT_DATE_FORMAT = "DD/MM/YYYY";

const DEFAULT_TIME_FORMAT = "hh:mm A";
const DEFAULT_DATE_FORMAT = "MM/DD/YYYY";
const DEFAULT_TIME_ZONE = "Asia/Kolkata";

const configData = window.configData || {
  userTimezone: DEFAULT_TIME_ZONE,
  userTimeFormat: DEFAULT_TIME_FORMAT,
  userDateFormat: DEFAULT_DATE_FORMAT
};

export function formatDateTime(dateValue, formatType) {
  if (formatType) {
    return moment(dateValue).format(formatType);
  }
  return moment(dateValue).format();
}

export function addDaysTo(nDays, value) {
  return moment(value).add(nDays, "day");
  // .format(DEFAULT_FORMAT);
}

export function differenceDaysIn(firstValue, secondValue) {
  const fValue = moment(firstValue);
  const sValue = moment(secondValue);
  return fValue.diff(sValue, "days") || 1;
}

export function differenceYeasrsIn(firstValue, secondValue) {
  const fValue = moment(firstValue, DATE_FORMAT);
  const sValue = moment(secondValue, DATE_FORMAT);
  return fValue.diff(sValue, "years");
}

export function sortEvents(
  eventList = [],
  field = "startDateTime",
  asc = true
) {
  return eventList.sort((a, b) => {
    const { event_WP: aEventObj } = a;
    const { event_WP: bEventObj } = b;
    const aMoment = moment(aEventObj[field], DATE_TIME_FORMAT);
    const bMoment = moment(bEventObj[field], DATE_TIME_FORMAT);
    return asc
      ? aMoment.diff(bMoment, "minutes")
      : bMoment.diff(aMoment, "minutes");
  });
}

export const getTimeUnit = () => {
  let unit = getSettingValue(SET054);
  if (unit === "") {
    unit = MINUTES;
  }
  return unit.toLowerCase();
};
export const getDateTimeValueFromDateTimeField = dateTimeField => {
  const { date, time } = dateTimeField;
  const formateDate = moment(date).format(DATE_FORMAT);
  const formateTime = time.hour() * 60 + time.minute();
  const formateDateTime = moment(formateDate).add(formateTime, "minutes");
  return formateDateTime;
};

const is24HrFormat = timeFormat => {
  let is24 = true;
  let hrFormat = timeFormat ? timeFormat.split(":")[0] : "HH";
  if (hrFormat === "h" || hrFormat === "hh") {
    is24 = false;
  }
  return is24;
};

export const getUserTimeSettings = formatType => {
  switch (formatType) {
    case "timeFormat":
      return configData.userTimeFormat.trim();
    case "dateFormat":
      return configData.userDateFormat.trim();
    case "dateTimeFormat":
      return `${configData.userDateFormat.trim()} ${configData.userTimeFormat.trim()}`;
    case "timeZone":
      return configData.userTimezone;
    case "is24":
      return is24HrFormat(configData.userTimeFormat);
  }
};
