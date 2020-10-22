import React, { useState, useEffect } from "react";
import {
  GridRow,
  GridItem,
  Text,
  InputWrapper,
  Input
} from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import moment from "moment";
import { getSettingValue, DCON001_SET054 } from "constants/AppSettings";
import { HOURS } from "constants/AppConstants";
import { MINUTES, DATE_TIME_FORMAT } from "constants/DateTimeConstants";

const END_DATE = "endDate";

const TextEdit = props => {
  const { event, updateScheduleDate } = props;
  const { id, startDate, endDate, dayEvent } = event;

  const svcDuration = moment(endDate, DATE_TIME_FORMAT).diff(
    moment(startDate, DATE_TIME_FORMAT),
    MINUTES
  );

  const measureUnitInHours = getSettingValue(DCON001_SET054, HOURS) === HOURS;

  const onEdit = () => {
    setEditable(true);
  };

  useEffect(() => {
    let serviceDuration = svcDuration;
    if (dayEvent) {
      serviceDuration = Math.ceil(svcDuration / 60) * 60;
    }
    setValue(
      measureUnitInHours
        ? convertMinutesToHours(serviceDuration)
        : serviceDuration
    );
    return () => {};
  }, [event]);

  const validateTimeValues = evt => {
    const charCode = evt.which ? evt.which : evt.charCode;
    if (charCode > 31 && (charCode < 48 || charCode > 58)) {
      evt.preventDefault();
      return false;
    }
    return true;
  };

  const convertMinutesToHours = value => {
    if (!value) return "00:00";
    if (value < 60) return `00:${value}`;
    let hours = Math.floor(value / 60);
    if (hours < 10) {
      hours = moment(hours, "hh").format("hh");
    }
    const minutes = value - hours * 60;
    return `${hours}:${moment(minutes, "mm").format("mm")}`;
  };

  const handleInputBlur = () => {
    let duration = value;
    if (measureUnitInHours) {
      if (!duration.trim()) {
        setValue(
          measureUnitInHours ? convertMinutesToHours(svcDuration) : svcDuration
        );
      } else {
        const splits = duration.split(":");
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
          setValue(convertMinutesToHours(duration));
        }
      }
    } else {
      try {
        duration = parseInt(duration, 10);
      } catch (e) {}
    }
    if (Number.isNaN(duration)) {
      duration = svcDuration;
      setTimeout(
        () =>
          setValue(
            measureUnitInHours
              ? convertMinutesToHours(svcDuration)
              : svcDuration
          ),
        0
      );
    }
    if (dayEvent) {
      duration = Math.ceil(duration / (24 * 60)) * 24 * 60;
    }
    updateScheduleDate(id, END_DATE, duration);
    setEditable(false);
  };

  const [editable, setEditable] = useState(false);
  const [value, setValue] = useState(
    measureUnitInHours ? convertMinutesToHours(svcDuration) : svcDuration
  );

  return (
    <GridRow className="DateTimeInlineEdit">
      <GridItem>
        {!editable && (
          <GridRow onClick={() => onEdit()}>
            <GridItem className="DateTimeInlineEdit__text">
              <Text>{value}</Text>
            </GridItem>
          </GridRow>
        )}
        {editable && (
          <GridRow>
            <GridItem>
              <InputWrapper
                size="xx-small"
                onKeyPress={evt => validateTimeValues(evt)}
                onBlur={() => handleInputBlur()}
                inputOnValueChange={({ value }) => setValue(value)}
              >
                <Input
                  name={END_DATE}
                  type={measureUnitInHours ? "text" : "number"}
                  value={value}
                  disabled={false}
                />
              </InputWrapper>
            </GridItem>
          </GridRow>
        )}
      </GridItem>
    </GridRow>
  );
};

TextEdit.propTypes = {
  event: PropTypes.shape({}).isRequired,
  updateScheduleDate: PropTypes.func.isRequired
};

export default TextEdit;
