import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import {
  Label,
  Button,
  Icon,
  GridItem,
  GridRow
} from "@svmx/ui-components-lightning";
import { getDisplayValue } from "utils/DCUtils";
import { TAG159, TAG010 } from "constants/DisplayTagConstants";

import "./SchedulerToolbar.scss";

const Reset = props => {
  const { loading, newViewState, onSchedulerReset } = props;
  const [activeState, setActiveState] = useState(newViewState);

  useEffect(() => {
    // All positive values indicate resource modifications.
    if (Math.sign(newViewState) >= 0) {
      setActiveState(newViewState);
    }
    return () => {};
  }, [newViewState]);

  return (
    <GridItem noFlex className="SchedulerToolbar__Group">
      <GridRow>
        <GridItem className="SchedulerToolbar__SubGroup">
          <Label>{getDisplayValue(TAG159)}</Label>
        </GridItem>
      </GridRow>
      <GridRow>
        <GridItem className="SchedulerToolbar__SubGroup">
          <Button
            // className={className}
            type="icon-border-filled"
            size="medium"
            title={getDisplayValue(TAG010)}
            onClick={onSchedulerReset}
            isDisabled={loading}
            isSelected={activeState > 0}
          >
            <Icon icon="close" type="utility" />
          </Button>
        </GridItem>
      </GridRow>
    </GridItem>
  );
};

Reset.propTypes = {
  loading: PropTypes.bool,
  newViewState: PropTypes.number.isRequired,
  onSchedulerReset: PropTypes.func.isRequired
};

export default Reset;
