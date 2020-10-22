import React, { useState } from "react";
import {
  Button,
  Checkbox,
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter,
  Label,
  RadioGroup,
  Radio
} from "@svmx/ui-components-lightning";
import { getDisplayValue } from "utils/DCUtils";
import {
  TAG183,
  TAG069,
  EVENTSTAG102,
  EVENTSTAG103,
  EVENTSTAG140,
  EVENTSTAG141,
  EVENTSTAG085
} from "constants/DisplayTagConstants";
import {
  SHOW_PROJECT_VIEW,
  LIST_WO,
  DO_NOTHING,
  ONUNDERSCHEDULING
} from "constants/AppConstants";
import "./UnderScheduledWOModal.scss";

const UnderScheduledWOModal = props => {
  const { onClose, isOpen } = props;
  const [radioValue, setRadioValue] = useState(
    window.sessionStorage.getItem(`${ONUNDERSCHEDULING}`) ||
      getDisplayValue("TAG513", SHOW_PROJECT_VIEW)
  );
  const [rememberMyChoice, setRememberMyChoice] = useState(
    window.sessionStorage.getItem(`${ONUNDERSCHEDULING}`)
  );

  const handleRadioChange = ({ value }) => {
    setRadioValue(value);
    if (rememberMyChoice) {
      window.sessionStorage.setItem(`${ONUNDERSCHEDULING}`, value);
    }
  };

  const handleCheckedChange = data => {
    const { isChecked } = data;
    if (isChecked) {
      window.sessionStorage.setItem(`${ONUNDERSCHEDULING}`, radioValue);
    } else {
      window.sessionStorage.removeItem(`${ONUNDERSCHEDULING}`);
    }
    setRememberMyChoice(isChecked);
  };

  return (
    <Modal
      className="UnderScheduledWOModal"
      size="regular"
      isOpen={isOpen}
      onClose={onClose}
    >
      <ModalHeader title={getDisplayValue(TAG183)} />
      <ModalContent className="UnderScheduledWOModal__content">
        <Label>{getDisplayValue(EVENTSTAG140)}</Label>
        <RadioGroup
          value={radioValue}
          name="underScheduleAction"
          onValueChange={handleRadioChange}
        >
          <Radio value={SHOW_PROJECT_VIEW}>
            {getDisplayValue(EVENTSTAG102)}
          </Radio>
          <Radio value={LIST_WO}>{getDisplayValue(EVENTSTAG103)}</Radio>
          <Radio value={DO_NOTHING}>{getDisplayValue(EVENTSTAG141)}</Radio>
        </RadioGroup>
      </ModalContent>
      <ModalFooter className="UnderScheduledWOModal__footer">
        <Checkbox
          isChecked={rememberMyChoice}
          name={`${ONUNDERSCHEDULING}`}
          onCheckedChange={handleCheckedChange}
        >
          {getDisplayValue(EVENTSTAG085)}
        </Checkbox>
        <Button
          type="brand"
          label={getDisplayValue(TAG069)}
          onClick={() => onClose(radioValue)}
        />
      </ModalFooter>
    </Modal>
  );
};
export default UnderScheduledWOModal;
