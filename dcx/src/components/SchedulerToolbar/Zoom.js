import React from "react";
import PropTypes from "prop-types";
import {
  Label,
  Button,
  Icon,
  GridItem,
  GridRow,
  ButtonGroup
} from "@svmx/ui-components-lightning";
import {
  TAG011,
  TAG012,
  TAG462,
  TAG465,
  TAG497
} from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";
import { FILTER_RESULTS } from "constants/AppConstants";
import "./SchedulerToolbar.scss";

const Zoom = props => {
  const {
    loading,
    isEmpty,
    handleProjectView,
    handleViewZoomOut,
    handleViewZoomIn,
    handleResetTime,
    newViewState,
    zoomInState,
    zoomOutState
  } = props;

  return (
    <GridItem noFlex className="SchedulerToolbar__Group">
      <GridRow>
        <GridItem className="SchedulerToolbar__SubGroup">
          <Label>{getDisplayValue(TAG462)}</Label>
        </GridItem>
      </GridRow>
      <GridRow className="SchedulerToolbar__SubGroup">
        <GridItem className="SchedulerToolbar__Item">
          <ButtonGroup>
            <Button
              type="icon-border"
              onClick={handleViewZoomIn}
              size="medium"
              isDisabled={loading || zoomInState}
              title={getDisplayValue(TAG011)}
            >
              <Icon icon="zoomin" type="utility" />
            </Button>
            <Button
              type="icon-border"
              onClick={handleViewZoomOut}
              size="medium"
              isDisabled={loading || zoomOutState}
              title={getDisplayValue(TAG012)}
            >
              <Icon icon="zoomout" type="utility" />
            </Button>
            <Button
              type="icon-border"
              onClick={handleProjectView}
              size="medium"
              title={getDisplayValue(TAG465)}
              isDisabled={
                !FILTER_RESULTS.includes(newViewState) || loading || isEmpty()
              }
            >
              <Icon icon="full_width_view" type="utility" />
            </Button>
            <Button
              type="icon-border-filled"
              onClick={handleResetTime}
              size="medium"
              title={getDisplayValue(
                TAG497,
                "Zoom to Default Scheduler Timeline"
              )}
              isDisabled={loading}
            >
              <Icon icon="close" type="utility" />
            </Button>
          </ButtonGroup>
        </GridItem>
      </GridRow>
    </GridItem>
  );
};

Zoom.propTypes = {
  loading: PropTypes.bool,
  handleProjectView: PropTypes.func.isRequired,
  handleResetTime: PropTypes.func.isRequired,
  handleViewZoomIn: PropTypes.func.isRequired,
  handleViewZoomOut: PropTypes.func.isRequired,
  newViewState: PropTypes.number.isRequired
};

export default Zoom;
