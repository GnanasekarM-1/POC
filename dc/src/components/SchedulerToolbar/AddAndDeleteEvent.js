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
import { CONF024_TAG025, TAG008, TAG009 } from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";
import "./SchedulerToolbar.scss";

const AddAndDeleteEvent = props => {
  const { addNonWoEvent, deleteEvent, loading, isEventDeleteEnabled } = props;
  return (
    <GridItem noFlex className="SchedulerToolbar__Group">
      <GridRow>
        <GridItem noFlex className="SchedulerToolbar__SubGroup">
          <Label>{getDisplayValue(CONF024_TAG025)}</Label>
        </GridItem>
      </GridRow>
      <GridRow>
        <GridItem>
          <ButtonGroup>
            <Button
              onClick={() => addNonWoEvent()}
              type="icon-border-filled"
              size="medium"
              title={getDisplayValue(TAG008)}
              isDisabled={loading}
            >
              <Icon icon="add" size="x-small" />
            </Button>
            <Button
              onClick={() => deleteEvent()}
              isDisabled={loading || !isEventDeleteEnabled}
              type="icon-border-filled"
              title={getDisplayValue(TAG009)}
              size="medium"
            >
              <Icon icon="event_delete" category="svmx" size="x-small" />
            </Button>
          </ButtonGroup>
        </GridItem>
      </GridRow>
    </GridItem>
  );
};

AddAndDeleteEvent.propTypes = {
  loading: PropTypes.bool,
  addNonWoEvent: PropTypes.func.isRequired,
  deleteEvent: PropTypes.func.isRequired
};

export default AddAndDeleteEvent;
