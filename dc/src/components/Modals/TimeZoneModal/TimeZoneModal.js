import React, { useState } from "react";
import {
  Button,
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter,
  Label,
  PicklistFactory
} from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import { getDisplayValue } from "utils/DCUtils";
import { TAG066, TAG067, TAG076, TAG244 } from "constants/DisplayTagConstants";
// import TIMEZONES from './timeZone';

import "./TimeZoneModal.scss";

const TimeZoneModal = props => {
  const { timeZones, userTimezone } = props;
  const { name } = userTimezone;
  const [targetArray, setTargetArray] = useState([name]);
  const { apply, isOpen, open } = props;
  const sourceItems = timeZones;

  const handleTargetChange = ({ value }) => {
    setTargetArray([value]);
  };

  return (
    <Modal
      className="TimeZoneModal"
      size="x-small"
      isOpen={open}
      onClose={() => isOpen(false)}
    >
      <ModalHeader title={getDisplayValue(TAG067)} />
      <ModalContent className="TimeZoneModal__content">
        <Label className="slds-text-heading--small">
          {getDisplayValue(TAG244)}
        </Label>
        <PicklistFactory
          defaultText="Select a Filter"
          items={sourceItems}
          name="picklist-single"
          onSelectedChange={handleTargetChange}
          selectedValues={targetArray}
          itemValueKey="name"
          itemDisplayKey="value"
        />
      </ModalContent>
      <ModalFooter className="TimeZoneModal__footer">
        <Button
          type="brand"
          label={getDisplayValue(TAG076)}
          onClick={() => apply(targetArray[0])}
        />
        <Button
          type="brand"
          label={getDisplayValue(TAG066)}
          onClick={() => isOpen(false)}
        />
      </ModalFooter>
    </Modal>
  );
};

TimeZoneModal.propTypes = {
  apply: PropTypes.func.isRequired,
  isOpen: PropTypes.func.isRequired,
  open: PropTypes.bool.isRequired,
  timeZones: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  userTimezone: PropTypes.shape({}).isRequired
};

export default TimeZoneModal;
