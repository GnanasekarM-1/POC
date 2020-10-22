import React, { useEffect, useRef, useState } from "react";
import {
  Button,
  GridRow,
  GridItem,
  Icon,
  Text,
  DateInput,
  DateTimeInput
} from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import moment from "moment";
import { getSettingValue, DCON001_SET011 } from "constants/AppSettings";
import {
  DATE_FORMAT,
  TIME_FORMAT,
  DATE_TIME_FORMAT
} from "constants/DateTimeConstants";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";

import "./DateTimeInlineEdit.scss";

const END_DATE = "endDate";

const DateTimeInlineEdit = props => {
  const {
    event,
    name,
    step,
    isDayEvent,
    minDate,
    maxDate,
    minTime,
    maxTime,
    showTodayButton = true,
    updateScheduleDate,
    editable,
    setDateEditable
  } = props;

  const dateFormat = getUserTimeSettings("dateFormat");
  const timeFormat = getUserTimeSettings("timeFormat");
  const dateTimeFormat = getUserTimeSettings("dateTimeFormat");
  const roundOffTime = parseInt(getSettingValue(DCON001_SET011, 15), 10);
  const [value, setValue] = useState(moment(event[name], DATE_TIME_FORMAT));
  const wrapperRef = useRef(null);

  useEffect(() => {
    document.addEventListener("mousedown", handleKeyEvent);
    return () => {
      document.removeEventListener("mousedown", handleKeyEvent);
    };
  }, [value]);

  const handleKeyEvent = e => {
    const { id } = event;
    if (wrapperRef.current && !wrapperRef.current.contains(e.target)) {
      if (editable) {
        updateScheduleDate(
          id,
          name,
          value ? moment(value).format(DATE_TIME_FORMAT) : event[name]
        );
      }
    }
  };

  const onEdit = () => {
    const { id } = event;
    setDateEditable(true, id, name);
  };

  const onBlur = (e, name) => {
    const { id } = event;
    const { date, time, value } = e;
    if (value) {
      if (!value.isValid()) {
        // Handle Error Case
      } else {
        // updateScheduleDate(id, name, `${value.format(DATE_TIME_FORMAT)}`);
        //onDateTimeChange(e, name);
      }
    } else if (!date.isValid() || !time.isValid()) {
      // Handle Error Case
    } else {
      // const formttedDate = date.format(DATE_FORMAT);
      // const formattedTime = time.format(TIME_FORMAT);
      // updateScheduleDate(id, name, `${formttedDate} ${formattedTime}}`);
      //onDateTimeChange(e, name);
    }
  };

  const onDateChange = e => {
    const { id } = event;
    const { value } = e;
    if (moment(value, dateFormat, true).isValid()) {
      const formattedDate = moment(value, dateFormat);
      const formattedTime = moment(event[name], timeFormat);
      const formttedDateTime = `${formattedDate.format(
        DATE_FORMAT
      )} ${formattedTime.format(TIME_FORMAT)}`;
      setValue(moment(formttedDateTime));
    }
  };

  const validateDateTimeObj = dateValue => {
    const newTime = moment(dateValue.time, timeFormat, true);
    const newDate = moment(dateValue.date, dateFormat, true);
    if (!newTime.isValid() || !newDate.isValid()) {
      return false;
    }
    return true;
  };

  const onDateTimeChange = e => {
    const { id } = event;
    const { date, time } = e;
    const dateObj = moment(date, dateFormat);
    const timeObj = moment(time, timeFormat);
    if (validateDateTimeObj(e)) {
      const newValue = `${dateObj.format(DATE_FORMAT)} ${timeObj.format(
        TIME_FORMAT
      )}`;
      setValue(moment(newValue));
    }
  };

  const { id } = event;
  const dayEvent = isDayEvent(id);
  return (
    <div ref={wrapperRef}>
      <GridRow className="DateTimeInlineEdit">
        <GridItem>
          {!editable && (
            <GridRow onClick={() => onEdit()}>
              <GridItem className="DateTimeInlineEdit__text label">
                {/* <Text> */}
                {value.format(dayEvent ? dateFormat : dateTimeFormat)}
                {/* </Text> */}
              </GridItem>
              {/* <GridItem className="Grid__item-btn" noFlex>
                <Button
                  type="icon-container"
                  size="medium"
                  onClick={() => onEdit()}
                >
                  <Icon icon="edit" size="x-small" />
                </Button>
              </GridItem> */}
            </GridRow>
          )}
          {editable && (
            <GridRow>
              <GridItem className={dayEvent ? "allDay" : null}>
                {dayEvent && (
                  <DateInput
                    name={name}
                    size="x-small"
                    value={
                      value
                        ? moment(value.format(dateFormat), dateFormat)
                        : undefined
                    }
                    minDate={minDate}
                    maxDate={maxDate}
                    dateFormat={dateFormat}
                    onInputValueChange={e => onDateChange(e, name)}
                    onValueChange={e => onDateChange(e, name)}
                    showTodayButton={showTodayButton}
                  />
                )}
                {!dayEvent && (
                  <DateTimeInput
                    name={name}
                    value={{
                      date: moment(value.format(dateFormat), dateFormat),
                      time: moment(value.format(timeFormat), timeFormat)
                    }}
                    minDate={minDate || undefined}
                    dateInputProps={{
                      dateFormat,
                      size: "xx-small",
                      minDate,
                      maxDate,
                      showTodayButton
                    }}
                    onInputValueChange={e => onDateTimeChange(e, name)}
                    timeInputProps={{
                      step: step || roundOffTime,
                      timeFormat,
                      minTime,
                      maxTime,
                      size: "xx-small"
                    }}
                  />
                )}
              </GridItem>
            </GridRow>
          )}
        </GridItem>
      </GridRow>
    </div>
  );
};

DateTimeInlineEdit.propTypes = {
  name: PropTypes.string.isRequired,
  event: PropTypes.shape({}).isRequired,
  isDayEvent: PropTypes.func.isRequired,
  updateScheduleDate: PropTypes.func.isRequired
};

export default DateTimeInlineEdit;
