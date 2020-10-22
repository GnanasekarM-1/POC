import React from "react";
import PropTypes from "prop-types";
import {
  Label,
  Button,
  ButtonGroup,
  Icon,
  GridItem,
  GridRow
} from "@svmx/ui-components-lightning";
import { TAG377, TAG378, TAG460 } from "constants/DisplayTagConstants";
import {
  FALSE,
  FILTER_TECHNICIAN_RESULT,
  FILTER_EVENTS_RESULT
} from "constants/AppConstants";
import { DCON001_SET066, getSettingValue } from "constants/AppSettings";
import { getDisplayValue } from "utils/DCUtils";
import "./SchedulerToolbar.scss";

const FilterTechnician = props => {
  const {
    filterTechnicians,
    filterWorkOrderEvents,
    loading,
    newViewState
  } = props;
  const enableFiltering = JSON.parse(
    getSettingValue(DCON001_SET066, FALSE).toLowerCase()
  );
  return enableFiltering ? (
    <GridItem noFlex className="SchedulerToolbar__Group">
      <GridRow>
        <GridItem noFlex className="SchedulerToolbar__SubGroup">
          <Label>{getDisplayValue(TAG460)}</Label>
        </GridItem>
      </GridRow>
      <GridRow>
        <GridItem>
          <ButtonGroup>
            <Button
              onClick={() => filterTechnicians()}
              type="icon-border-filled"
              size="medium"
              title={getDisplayValue(TAG377)}
              isDisabled={loading}
              isSelected={newViewState % 100 === FILTER_TECHNICIAN_RESULT}
            >
              <Icon
                category="svmx"
                icon="filter_results_by_technician"
                size="x-small"
              />
            </Button>
            <Button
              onClick={() => filterWorkOrderEvents()}
              type="icon-border-filled"
              title={getDisplayValue(TAG378)}
              size="medium"
              isDisabled={loading}
              isSelected={newViewState % 100 === FILTER_EVENTS_RESULT}
            >
              <Icon icon="event" size="x-small" />
            </Button>
          </ButtonGroup>
        </GridItem>
      </GridRow>
    </GridItem>
  ) : (
    <GridItem noFlex />
  );
};

FilterTechnician.propTypes = {
  loading: PropTypes.bool,
  filterTechnicians: PropTypes.func.isRequired,
  filterWorkOrderEvents: PropTypes.func.isRequired
};

export default FilterTechnician;
