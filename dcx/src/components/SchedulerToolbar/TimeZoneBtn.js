import React, { useEffect, useState } from "react";
import PropTypes from "prop-types";
import {
  Label,
  Button,
  Icon,
  GridItem,
  GridRow,
  Grid
} from "@svmx/ui-components-lightning";
import TimeZoneModal from "components/Modals/TimeZoneModal";
import { getDisplayValue } from "utils/DCUtils";
import { TAG013, TAG463 } from "constants/DisplayTagConstants";
import { FALSE } from "constants/AppConstants";
import { DCON001_SET018, getSettingValue } from "constants/AppSettings";
import "./SchedulerToolbar.scss";

const TimeZoneBtn = props => {
  const [open, isOpen] = useState(false);
  const { applyTimeZone, loading, userTimezone, timeZones = [] } = props;
  const [timeZone, setTimeZone] = useState(userTimezone);

  useEffect(() => {
    const { name } = userTimezone;
    const found = timeZones.filter(item => item.name === name);
    if (found.length) {
      const [filterdTimeZone] = found;
      setTimeZone(filterdTimeZone);
    }
  }, [userTimezone]);

  const apply = selectedItem => {
    isOpen(false);
    applyTimeZone(selectedItem);
  };

  const formatTimeZone = () => {
    const { value } = timeZone;
    return value.substring(1, value.indexOf(")"));
  };

  const timeZoneEnabled = JSON.parse(
    getSettingValue(DCON001_SET018, FALSE).toLowerCase()
  );
  return timeZoneEnabled ? (
    <GridItem noFlex className="SchedulerToolbar__Group">
      <GridRow>
        <GridItem className="SchedulerToolbar__SubGroup">
          <Label style={{ "margin-bottom": "0px" }}>
            {getDisplayValue(TAG463)}
          </Label>
        </GridItem>
      </GridRow>
      <GridRow>
        <GridItem className="SchedulerToolbar__SubGroup">
          <Button
            type="icon-bare"
            size="medium"
            onClick={() => isOpen(true)}
            title={getDisplayValue(TAG013)}
            isDisabled={loading}
          >
            <Grid isVertical>
              <GridRow>
                <GridItem
                  className="SchedulerToolbar__SubGroup"
                  style={{ "margin-bottom": "0.125rem" }}
                >
                  <Icon icon="global_constant" type="utility" size="x-small" />
                </GridItem>
              </GridRow>
              <GridRow>
                <GridItem className="SchedulerToolbar__SubGroup">
                  <Label className="SchedulerToolbar__timeZone-label">
                    {formatTimeZone()}
                  </Label>
                </GridItem>
              </GridRow>
            </Grid>
          </Button>
        </GridItem>
      </GridRow>
      {open && (
        <TimeZoneModal
          apply={apply}
          open={open}
          isOpen={isOpen}
          timeZones={timeZones}
          userTimezone={userTimezone}
        />
      )}
    </GridItem>
  ) : (
    <GridItem noFlex />
  );
};

TimeZoneBtn.propTypes = {
  loading: PropTypes.bool,
  applyTimeZone: PropTypes.func.isRequired,
  timeZones: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  userTimezone: PropTypes.shape({}).isRequired
};

export default TimeZoneBtn;
