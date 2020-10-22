import React, { Component } from "react";
import {
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter,
  Button,
  GridRow,
  GridItem
} from "@svmx/ui-components-lightning";
import { PropTypes } from "prop-types";
import { getDisplayValue } from "utils/DCUtils";
import {
  EVENTSTAG042,
  EVENTSTAG053,
  EVENTSTAG076,
  EVENTSTAG087,
  EVENTSTAG090
} from "constants/DisplayTagConstants";
import "./ViolationStatusModal.scss";

const defaultProps = {
  handleDeleteConfirmation: () => {},
  isOpen: false,
  onClose: () => {},
  tagValue: ""
};

const propTypes = {
  handleDeleteConfirmation: PropTypes.func,
  isOpen: PropTypes.bool,
  onClose: PropTypes.func,
  tagValue: PropTypes.string
};

class ViolationStatusModal extends Component {
  state = {};

  render() {
    const { isOpen, onClose, violationMsg } = this.props;

    return (
      <Modal size="xx-small" isOpen={isOpen} onClose={onClose}>
        <ModalHeader title={getDisplayValue(EVENTSTAG042)} />
        <ModalContent className="ViolationStatusModal__content">
          <GridRow>
            <GridItem className="ViolationStatusModal__divStart">
              <GridRow className="ViolationStatusModal__div">
                <GridItem>{getDisplayValue(EVENTSTAG053)}</GridItem>
              </GridRow>
              {violationMsg.map(item => (
                <GridRow className="ViolationStatusModal__divInner">
                  <GridItem>{item.category}</GridItem>
                </GridRow>
              ))}
            </GridItem>
            <GridItem className="ViolationStatusModal__divCenter">
              <GridRow className="ViolationStatusModal__div">
                <GridItem>{getDisplayValue(EVENTSTAG076)}</GridItem>
              </GridRow>
              {violationMsg.map(item => (
                <GridRow className="ViolationStatusModal__divInner">
                  <GridItem>{item.type}</GridItem>
                </GridRow>
              ))}
            </GridItem>
            <GridItem className="ViolationStatusModal__divCenter">
              <GridRow className="ViolationStatusModal__div">
                <GridItem>{getDisplayValue(EVENTSTAG087)}</GridItem>
              </GridRow>
              {violationMsg.map(item => (
                <GridRow className="ViolationStatusModal__divInner">
                  <GridItem>{item.name}</GridItem>
                </GridRow>
              ))}
            </GridItem>
            <GridItem className="ViolationStatusModal__divEnd">
              <GridRow className="ViolationStatusModal__div">
                <GridItem>{getDisplayValue(EVENTSTAG090)}</GridItem>
              </GridRow>
              {violationMsg.map(item => (
                <GridRow className="ViolationStatusModal__divInner">
                  <GridItem>{item.severity}</GridItem>
                </GridRow>
              ))}
            </GridItem>
          </GridRow>
        </ModalContent>
        <ModalFooter className="ViolationStatusModal__footer">
          <GridRow>
            <GridItem>
              <Button label={getDisplayValue("TAG069")} onClick={onClose} />
            </GridItem>
          </GridRow>
        </ModalFooter>
      </Modal>
    );
  }
}

ViolationStatusModal.propTypes = propTypes;
ViolationStatusModal.defaultProps = defaultProps;

export default ViolationStatusModal;
