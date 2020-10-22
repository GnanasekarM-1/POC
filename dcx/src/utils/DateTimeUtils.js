import * as moment from "moment";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";
export const getMinutesToHours = (valueMinutes = 0) => {
  let hours = Math.floor(valueMinutes / 60);
  let minutes = Math.floor(valueMinutes - hours * 60);
  if (hours < 10) hours = `0${hours}`;
  if (minutes < 10) minutes = `0${minutes}`;
  return `${hours} : ${minutes}`;
};
export const getSecondsToHours = valueSeconds =>
  getMinutesToHours(valueSeconds / 60);
export const convertHoursToMinutes = value => {
  if (!value) return 0;
  return value * 60;
};
export const getHoursToMinutes = value => {
  if (!value) return 0;
  let valueMinutes = 0;
  const valueInArray = value.split(":");
  valueMinutes = Number(valueInArray[0].trim()) * 60;
  valueMinutes += Number(valueInArray[1].trim());
  return valueMinutes;
};
export const validatedateObj = dateValue => {
  // const newTime = moment(dateValue.time, "hh:mm A", true);
  const newTime = moment(
    dateValue.time,
    getUserTimeSettings("timeFormat"),
    true
  );
  if (!newTime.isValid()) {
    return false;
  }
  return true;
};
