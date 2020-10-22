import React, { Component } from "react";
import {
  Button,
  Label,
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter
} from "@svmx/ui-components-lightning";
import { flatMap } from "lodash";
import { TAG069, TAG498 } from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";
import ConfTechViewContainer from "containers/ConfTechViewContainer";
import moment from "moment-timezone";
import ConfTechViewService from "./ConfTechViewService";
import "./ConfTechViewModal.scss";

class ConfTechViewModal extends Component {
  state = {
    deleteGridRow: null,
    deletedRowInfo: null,
    openDeleteConfirmationModal: false,
    openErrorModal: false,
    submitForm: null
  };

  componentDidMount() {
    ConfTechViewService.setActiveRuleIndex(-1);
  }

  handleRulesModified = (modifiedUserSettings, activeRuleIndex) => {
    let isInValidIndex = true;
    if (activeRuleIndex !== undefined && activeRuleIndex !== null) {
      isInValidIndex = activeRuleIndex <= -2;
    }
    if (modifiedUserSettings) {
      ConfTechViewService.setmodifiedUserSettings(modifiedUserSettings);
    } else {
      const retrivedUserSettings = ConfTechViewService.getmodifiedUserSettings();
      delete retrivedUserSettings.tech_techRules;
      ConfTechViewService.setmodifiedUserSettings(retrivedUserSettings);
    }
    if (!isInValidIndex) {
      ConfTechViewService.setActiveRuleIndex(activeRuleIndex);
      ConfTechViewService.setIsRuleModified(true);
    }
  };

  handleSubmit = () => {
    const { submitForm } = this.state;
    const modifiedSettings = ConfTechViewService.getmodifiedUserSettings();
    if (
      ConfTechViewService.getIsRuleModified() &&
      modifiedSettings.tech_techRules &&
      !Array.isArray(modifiedSettings.tech_techRules)
    ) {
      submitForm(modifiedSettings.tech_techRules);
    } else {
      this.saveEventRules(null);
    }
  };

  handleSuccess = modifiedRule => {
    this.saveEventRules(modifiedRule);
  };

  saveEventRules = modifiedRule => {
    const {
      onSave,
      onTechConfigChange,
      userSettings,
      userTimezone
    } = this.props;
    const currentIndex = ConfTechViewService.getActiveRuleIndex();
    const modifiedUserSettings = ConfTechViewService.getmodifiedUserSettings();

    // Change Start Date
    let {
      tech_noOfDays: noOfDays,
      tech_condition: condition
    } = modifiedUserSettings;
    let newStartDate = null;

    if (noOfDays || condition) {
      noOfDays = noOfDays || userSettings.tech_noOfDays;
      condition = condition || userSettings.tech_condition;
    }

    if (noOfDays && condition) {
      const today = moment()
        .tz(userTimezone.id)
        .format();
      newStartDate = new Date(today);
      if (condition === "before") {
        newStartDate.setDate(newStartDate.getDate() - Number(noOfDays));
      } else {
        newStartDate.setDate(newStartDate.getDate() + Number(noOfDays));
      }
    }

    if (modifiedRule) {
      modifiedUserSettings.tech_techRules =
        ConfTechViewService.getRulesAfterDeletion() ||
        userSettings.tech_techRules;
      if (currentIndex === -1) {
        modifiedUserSettings.tech_techRules.push(modifiedRule);
      } else {
        modifiedUserSettings.tech_techRules[currentIndex] = modifiedRule;
      }
    } else if (ConfTechViewService.getRulesAfterDeletion()) {
      modifiedUserSettings.tech_techRules = ConfTechViewService.getRulesAfterDeletion();
    }

    onSave(modifiedUserSettings, currentIndex, newStartDate);

    this.closeEventModal();
    onTechConfigChange();
  };

  closeEventModal = () => {
    const { handleHide } = this.props;
    ConfTechViewService.setIsRuleModified(false);
    ConfTechViewService.setActiveRuleIndex(NaN);
    ConfTechViewService.setmodifiedUserSettings(null);
    ConfTechViewService.setModifiedOperands(null);
    handleHide();
  };

  handleCustomError = errors => {
    this.setState({ errors, openErrorModal: true });
  };

  handleDeleteConfirmation = value => {
    if (value === "yes") {
      const { deleteGridRow, deletedRowInfo } = this.state;
      deleteGridRow(deletedRowInfo);
    }
    this.setState({ deletedRowInfo: null, openDeleteConfirmationModal: false });
  };

  showDeleteConfirmation = row => {
    this.setState({ deletedRowInfo: row, openDeleteConfirmationModal: true });
  };

  render() {
    const { header, isOpen } = this.props;
    const { errors, openDeleteConfirmationModal, openErrorModal } = this.state;
    return (
      <div>
        <Modal size="large" isOpen={isOpen} onClose={this.closeEventModal}>
          <ModalHeader title={header} />
          <ModalContent>
            <ConfTechViewContainer
              {...this.props}
              deleteConfirmation={this.showDeleteConfirmation}
              formRef={formSubmission => {
                this.setState({ submitForm: formSubmission });
              }}
              getDeleteRef={deleteRef => {
                this.setState({ deleteGridRow: deleteRef });
              }}
              onRulesModified={this.handleRulesModified}
              onSubmitSuccess={this.handleSuccess}
              onCustomValidationError={this.handleCustomError}
            />
          </ModalContent>
          <ModalFooter>
            <Button
              type="brand"
              label={getDisplayValue("TAG246")}
              onClick={this.handleSubmit}
            />
          </ModalFooter>
        </Modal>
        {openDeleteConfirmationModal && (
          <Modal
            className="ConfTechViewModal_Confirmation"
            size="x-small"
            isOpen={openDeleteConfirmationModal}
            onClose={() =>
              this.setState({ openDeleteConfirmationModal: false })
            }
            zIndex={9003}
          >
            <ModalHeader title={getDisplayValue("TAG183")} />
            <ModalContent className="slds-p-around--small errorDiv">
              <Label>{getDisplayValue("TAG251")}</Label>
            </ModalContent>
            <ModalFooter>
              <Button
                type="brand"
                label={getDisplayValue("TAG240")}
                onClick={() => this.handleDeleteConfirmation("yes")}
              />
              <Button
                type="brand"
                label={getDisplayValue("TAG241")}
                onClick={() => this.handleDeleteConfirmation("no")}
              />
            </ModalFooter>
          </Modal>
        )}
        {openErrorModal && (
          <Modal
            className="ConfTechViewModal__Confirmation"
            size="x-small"
            isOpen={openErrorModal}
            onClose={() => this.setState({ openErrorModal: false })}
            zIndex={9003}
          >
            <ModalHeader title={getDisplayValue(TAG498, "Validation Error")} />
            <ModalContent className="slds-p-around--small eventRuleErrorDiv">
              {errors &&
                flatMap(Object.values(errors), error => <p>{error}</p>)}
            </ModalContent>
            <ModalFooter className="align__center">
              <Button
                type="brand"
                label={getDisplayValue(TAG069)}
                onClick={() => this.setState({ openErrorModal: false })}
              />
            </ModalFooter>
          </Modal>
        )}
      </div>
    );
  }
}

export default ConfTechViewModal;
