import React from "react";
import * as moment from "moment";
import { PropTypes } from "prop-types";
import {
  Label,
  DateInput,
  Button,
  Icon,
  GridItem,
  GridRow
} from "@svmx/ui-components-lightning";
import { getDisplayValue } from "utils/DCUtils";
import { TAG014, TAG324, TAG461 } from "constants/DisplayTagConstants";

import "./SchedulerToolbar.scss";

import { getUserTimeSettings } from "utils/DateAndTimeUtils";

const DateRange = props => {
  const {
    eventsEndDate,
    eventsStartDate,
    loading,
    handleStartDateChange,
    handleEndDateChange,
    startEventCall
  } = props;

  const dateFormat = getUserTimeSettings("dateFormat");

  return (
    <GridItem noFlex className="SchedulerToolbar__Group">
      <GridRow>
        <GridItem className="SchedulerToolbar__SubGroup">
          <Label>{getDisplayValue(TAG461)}</Label>
        </GridItem>
      </GridRow>
      <GridRow className="SchedulerToolbar__SubGroup">
        <GridItem className="SchedulerToolbar__Item">
          <DateInput
            size="xx-small"
            value={moment(eventsStartDate)}
            onValueChange={({ value }) => handleStartDateChange(value)}
            isDisabled={loading}
            dateFormat={dateFormat}
          />
        </GridItem>
        <GridItem className="SchedulerToolbar__Item">
          {getDisplayValue(TAG324)}
        </GridItem>
        <GridItem className="SchedulerToolbar__Item">
          <DateInput
            size="xx-small"
            value={moment(eventsEndDate)}
            onValueChange={({ value }) => handleEndDateChange(value)}
            isDisabled={loading}
            dateFormat={dateFormat}
            minDate={moment(eventsStartDate)}
            maxDate={moment(eventsStartDate).add(5, "years")}
          />
        </GridItem>
        <GridItem className="SchedulerToolbar__Item">
          <Button
            type="icon-border-filled"
            size="medium"
            title={getDisplayValue(TAG014)}
            onClick={startEventCall}
            isDisabled={loading}
          >
            <Icon icon="change_record_type" size="small" />
          </Button>
        </GridItem>
      </GridRow>
    </GridItem>
  );
};

DateRange.propTypes = {
  loading: PropTypes.bool,
  eventsEndDate: PropTypes.string.isRequired,
  eventsStartDate: PropTypes.string.isRequired,
  handleEndDateChange: PropTypes.func.isRequired,
  handleStartDateChange: PropTypes.func.isRequired,
  startEventCall: PropTypes.func.isRequired
};
export default DateRange;
