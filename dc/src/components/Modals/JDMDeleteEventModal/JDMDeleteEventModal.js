import React, { useState } from "react";
import {
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter,
  Button,
  GridRow,
  GridItem,
  Grid,
  RadioGroup,
  Radio,
  Checkbox
} from "@svmx/ui-components-lightning";
import { PropTypes } from "prop-types";
import moment from "moment-timezone";
import { getDisplayValue } from "utils/DCUtils";
import {
  TAG009,
  EVENTSTAG043,
  EVENTSTAG044,
  EVENTSTAG045,
  EVENTSTAG046,
  EVENTSTAG124
} from "constants/DisplayTagConstants";
import {
  DATE_TIME_FORMAT,
  YODA_DATE_TIME_ZONE_24_HR_FORMAT
} from "constants/DateTimeConstants";
import "./JDMDeleteEventModal.scss";

const defaultProps = {
  isOpen: false,
  onClose: () => {},
  onDelete: () => {}
};

const propTypes = {
  isOpen: PropTypes.bool,
  onClose: PropTypes.func,
  onDelete: PropTypes.func
};

const JDMDeleteEventModal = props => {
  const { eventStartDate, header, isOpen, onClose, onDelete } = props;
  const [radioValue, setRadioValue] = useState(null);
  const [laterValue, setLaterValue] = useState(false);
  const [earlierValue, setEarlierValue] = useState(false);
  const [unAssignValue, setUnAssignValue] = useState(false);
  const [showConfirmation, setShowConfirmation] = useState(false);

  const handleRadioChange = ({ value }) => {
    setRadioValue(value);
    if (value === "single") {
      setUnAssignValue(false);
    } else {
      setLaterValue(false);
      setEarlierValue(false);
      setUnAssignValue(true);
    }
  };
  const handleCheckboxChange = data => {
    const { name, isChecked } = data;
    switch (name) {
      case "Later":
        setLaterValue(isChecked);
        break;
      case "Earlier":
        setEarlierValue(isChecked);
        break;
      case "UnAssign":
        setUnAssignValue(isChecked);
        break;
      default:
        break;
    }
  };

  const handleDeleteClick = () => {
    if (radioValue === "all") {
      setShowConfirmation(true);
    } else {
      confirmDelete();
    }
  };

  const confirmDelete = () => {
    onDelete(radioValue, laterValue, earlierValue, unAssignValue);
    onClose();
  };

  const onConfirmationClose = () => {
    setShowConfirmation(false);
  };
  return (
    <Grid>
      <Modal size="regular" isOpen={isOpen} onClose={onClose}>
        <ModalHeader title={getDisplayValue(TAG009)} />
        <ModalContent className="JDMDeleteEventModal__content">
          <Grid isVertical>
            <GridRow className="JDMDeleteEventModal__startTime">
              <GridItem>
                {getDisplayValue("EVENTSTAG123")}{" "}
                {moment
                  .utc(eventStartDate, YODA_DATE_TIME_ZONE_24_HR_FORMAT)
                  .format(DATE_TIME_FORMAT)}
              </GridItem>
            </GridRow>
            <GridRow>
              <GridItem>
                <RadioGroup
                  value={radioValue}
                  name="clickOrHover"
                  onValueChange={handleRadioChange}
                >
                  <Radio value="single">
                    {getDisplayValue(EVENTSTAG043)}
                    <Checkbox
                      className="JDMDeleteEventModal__checkobox-later"
                      name="Later"
                      isChecked={laterValue}
                      isDisabled={radioValue !== "single"}
                      onCheckedChange={handleCheckboxChange}
                    >
                      {getDisplayValue(EVENTSTAG044)}
                    </Checkbox>
                    <Checkbox
                      className="JDMDeleteEventModal__checkobox-earlier"
                      name="Earlier"
                      isChecked={earlierValue}
                      isDisabled={radioValue !== "single"}
                      onCheckedChange={handleCheckboxChange}
                    >
                      {getDisplayValue(EVENTSTAG045)}
                    </Checkbox>
                  </Radio>
                  <Radio value="all">{getDisplayValue(EVENTSTAG046)}</Radio>
                </RadioGroup>
                <Checkbox
                  className="JDMDeleteEventModal__checkobox-unassign"
                  name="UnAssign"
                  isChecked={unAssignValue}
                  isDisabled={!radioValue}
                  onCheckedChange={handleCheckboxChange}
                >
                  {getDisplayValue(EVENTSTAG124)}
                </Checkbox>
              </GridItem>
            </GridRow>
          </Grid>
        </ModalContent>
        <ModalFooter className="JDMDeleteEventModal__footer">
          <GridRow>
            <GridItem>
              <Button
                type="neutral"
                label={getDisplayValue("TAG066")}
                onClick={onClose}
              />
              <Button
                type="neutral"
                isDisabled={!radioValue}
                label={getDisplayValue("TAG191")}
                onClick={handleDeleteClick}
              />
            </GridItem>
          </GridRow>
        </ModalFooter>
      </Modal>
      {showConfirmation && (
        <Modal
          className="JDMDeleteEventModal__Confirmation"
          isOpen={showConfirmation}
          onClose={onConfirmationClose}
          zIndex={9003}
        >
          <ModalHeader title={header} />
          <ModalContent className="slds-p-around--small">
            <span>{getDisplayValue("EVENTSTAG047")}.</span>
            <br />
            <span className="confirmation__Hightlight">
              {getDisplayValue("EVENTSTAG048")}
            </span>
          </ModalContent>
          <ModalFooter className="JDMDeleteEventModal__footer">
            <GridRow>
              <GridItem>
                <Button
                  type="neutral"
                  label={getDisplayValue("TAG066")}
                  onClick={onConfirmationClose}
                />
                <Button
                  type="neutral"
                  isDisabled={!radioValue}
                  label={getDisplayValue("TAG191")}
                  onClick={confirmDelete}
                />
              </GridItem>
            </GridRow>
          </ModalFooter>
        </Modal>
      )}
    </Grid>
  );
};

JDMDeleteEventModal.propTypes = propTypes;
JDMDeleteEventModal.defaultProps = defaultProps;

export default JDMDeleteEventModal;
