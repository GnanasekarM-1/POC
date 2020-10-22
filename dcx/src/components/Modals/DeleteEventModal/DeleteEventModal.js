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
import { TAG009 } from "constants/DisplayTagConstants";
import "./DeleteEventModal.scss";

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

class DeleteEventModal extends Component {
  state = {};

  handleYesClick = () => {
    const { handleDeleteConfirmation } = this.props;
    handleDeleteConfirmation("Yes");
  };

  handleNoClick = () => {
    const { handleDeleteConfirmation } = this.props;
    handleDeleteConfirmation("No");
  };

  render() {
    const { header, isOpen, onClose, tagValue } = this.props;

    return (
      <Modal size="xx-small" isOpen={isOpen} onClose={onClose}>
        <ModalHeader title={getDisplayValue(TAG009)} />
        <ModalContent className="DeleteEventModal__content">
          {getDisplayValue(tagValue)}
        </ModalContent>
        <ModalFooter className="DeleteEventModal__footer">
          <GridRow>
            <GridItem>
              <Button
                type="neutral"
                label={getDisplayValue("TAG240")}
                onClick={this.handleYesClick}
              />
              <Button
                type="neutral"
                label={getDisplayValue("TAG241")}
                onClick={this.handleNoClick}
              />
              {tagValue === "TAG326" && (
                <Button
                  type="neutral"
                  label={getDisplayValue("TAG066")}
                  onClick={onClose}
                />
              )}
            </GridItem>
          </GridRow>
        </ModalFooter>
      </Modal>
    );
  }
}

DeleteEventModal.propTypes = propTypes;
DeleteEventModal.defaultProps = defaultProps;

export default DeleteEventModal;
