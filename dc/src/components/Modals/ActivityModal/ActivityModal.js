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
import { flatMap, isEqual } from "lodash";
import { getDisplayValue } from "utils/DCUtils";
import createEmptyRule from "utils/EmptyRuleUtils";
import ConfigureWORowColor from "components/ConfigureWORowColor";
import {
  TAG069,
  TAG183,
  TAG240,
  TAG241,
  TAG251,
  TAG246
} from "constants/DisplayTagConstants";
import ActivityModalService from "./ActivityModalService";
import "./ActivityModal.scss";

class ActivityModal extends Component {
  state = {
    deleteGridRow: null,
    deletedRowInfo: null,
    openDeleteConfirmationModal: false,
    openErrorModal: false,
    submitForm: null,
    activeKey: "1"
  };

  componentDidMount() {
    const { userSettings } = this.props;
    const { wo_woRules } = userSettings;
    ActivityModalService.setActiveRuleIndex(-1);
    ActivityModalService.setModifiedColorRules(wo_woRules);
  }

  handleDoneClick = () => {
    const { submitForm } = this.state;
    let woRules = null;
    if (
      ActivityModalService.getIsRuleModified() &&
      ActivityModalService.getModifiedColorRules()
    ) {
      submitForm(ActivityModalService.getModifiedColorRules());
    } else {
      if (ActivityModalService.getRulesAfterDeletion()) {
        woRules = ActivityModalService.getRulesAfterDeletion();
      }

      this.saveRules(woRules);
    }
  };

  handleSuccess = (modifiedRule, activeRuleIndex) => {
    const { userSettings } = this.props;
    let woRules = userSettings.wo_woRules;

    if (ActivityModalService.getRulesAfterDeletion()) {
      woRules = ActivityModalService.getRulesAfterDeletion();
    }

    if (woRules) {
      if (activeRuleIndex !== -1) {
        woRules[activeRuleIndex] = modifiedRule;
      } else {
        woRules.push(modifiedRule);
      }
      this.saveRules(woRules);
    } else {
      this.saveRules();
    }
  };

  saveRules = woRules => {
    const { onSave, userSettings } = this.props;
    const { wo_grid_col_fields } = userSettings;
    const updatedRulesObj = {};
    const hoverColor = ActivityModalService.getModifiedHoverColor();
    const selectionColor = ActivityModalService.getModifiedSelectionColor();
    const modifiedViewCounter = ActivityModalService.getModifiedViewCounter();

    if (woRules) {
      updatedRulesObj.wo_woRules = woRules;
      const requiredFields = [];
      for (let i = 0; i < woRules.length; i += 1) {
        for (let j = 0; j < woRules[i].operand.length; j += 1) {
          requiredFields.push(woRules[i].operand[j].property);
        }
      }
      updatedRulesObj.wo_grid_col_fields = [...new Set(requiredFields)];
    }

    if (hoverColor) {
      updatedRulesObj.wo_woHoverColor = hoverColor;
    }

    if (selectionColor) {
      updatedRulesObj.wo_woSelectionColor = selectionColor;
    }

    if (modifiedViewCounter) {
      updatedRulesObj.wo_viewCounter = modifiedViewCounter;
      const errorMsg = this.duplicateCheck(modifiedViewCounter);

      if (
        Object.keys(errorMsg).length !== 0 &&
        errorMsg.constructor === Object
      ) {
        this.setState({
          errors: errorMsg,
          openErrorModal: true,
          activeKey: "3"
        });
        return;
      }
    }

    if (Object.keys(updatedRulesObj).length) {
      onSave(updatedRulesObj);
    }

    this.handleCloseModal();
  };

  duplicateCheck = counters => {
    let dupliacteMsg = {};
    if (counters.length === 1) {
      dupliacteMsg = {};
    }

    for (let i = 0; i < counters.length; i += 1) {
      for (let j = i + 1; j < counters.length; j += 1) {
        if (counters[i].color === counters[j].color) {
          dupliacteMsg.color = getDisplayValue("EVENTSTAG138");
        }

        if (
          counters[i].name !== "None" &&
          counters[i].name === counters[j].name
        ) {
          dupliacteMsg.value = `${getDisplayValue(
            "EVENTSTAG136"
          )} ${getDisplayValue("EVENTSTAG137")}`;
        }
      }
    }

    return dupliacteMsg;
  };

  handleCloseModal = () => {
    const { handleHide } = this.props;
    ActivityModalService.setIsRuleModified(false);
    ActivityModalService.setActiveRuleIndex(NaN);
    ActivityModalService.setModifiedColorRules(null);
    ActivityModalService.setModifiedOperands(null);
    handleHide();
  };

  handleModifiedRules = (modifiedColorRules, activeRuleIndex) => {
    ActivityModalService.setModifiedColorRules(modifiedColorRules);
    ActivityModalService.setActiveRuleIndex(activeRuleIndex);
    ActivityModalService.setIsRuleModified(true);
    // Default ruleType is "WO Rule"
    const intialRule = createEmptyRule("WO Rule");
    intialRule.operand[0].type = "WO";
    intialRule.operand[0].fieldType = "STRING";
    if (isEqual(intialRule, modifiedColorRules)) {
      ActivityModalService.setIsRuleModified(false);
      ActivityModalService.setModifiedColorRules(null);
    }
  };

  handleModifiedHighlights = (hoveredColor, selectedColor) => {
    ActivityModalService.setModifiedHoverColor(hoveredColor);
    ActivityModalService.setModifiedSelectionColor(selectedColor);
  };

  handleModifiedViewCounter = modifiedViewConter => {
    ActivityModalService.setModifiedViewCounter(modifiedViewConter);
  };

  handleCustomError = errors => {
    this.setState({ errors, openErrorModal: true, activeKey: "1" });
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
    const { header, isOpen, sourceItems, userSettings, views } = this.props;
    const {
      errors,
      openDeleteConfirmationModal,
      openErrorModal,
      activeKey
    } = this.state;
    const {
      wo_viewCounter: viewCounter,
      wo_woRules: woRules,
      wo_woHoverColor: woHoverColor,
      wo_woSelectionColor: woSelectionColor
    } = userSettings;
    return (
      <div>
        <Modal size="large" isOpen={isOpen} onClose={this.handleCloseModal}>
          <ModalHeader title={header} />
          <ModalContent>
            <ConfigureWORowColor
              deleteConfirmation={this.showDeleteConfirmation}
              formRef={formSubmission => {
                this.setState({ submitForm: formSubmission });
              }}
              getDeleteRef={deleteRef => {
                this.setState({ deleteGridRow: deleteRef });
              }}
              onRulesModified={this.handleModifiedRules}
              onSubmitSuccess={this.handleSuccess}
              onCustomValidationError={this.handleCustomError}
              onHighlightsModified={this.handleModifiedHighlights}
              onViewCounterModified={this.handleModifiedViewCounter}
              sourceItems={sourceItems}
              views={views}
              viewCounter={viewCounter}
              woRules={woRules}
              woHoverColor={woHoverColor}
              woSelectionColor={woSelectionColor}
              activeKey={activeKey}
            />
          </ModalContent>
          <ModalFooter>
            <GridRow>
              <GridItem>
                <Button
                  type="brand"
                  label={getDisplayValue(TAG246)}
                  onClick={this.handleDoneClick}
                />
              </GridItem>
            </GridRow>
          </ModalFooter>
        </Modal>
        {openDeleteConfirmationModal && (
          <Modal
            isOpen={openDeleteConfirmationModal}
            onClose={() =>
              this.setState({ openDeleteConfirmationModal: false })
            }
            zIndex={9003}
          >
            <ModalHeader title={getDisplayValue(TAG183)} />
            <ModalContent className="slds-p-around--small errorDiv">
              {getDisplayValue(TAG251)}
            </ModalContent>
            <ModalFooter>
              <Button
                type="brand"
                label={getDisplayValue(TAG240)}
                onClick={() => this.handleDeleteConfirmation("yes")}
              />
              <Button
                type="brand"
                label={getDisplayValue(TAG241)}
                onClick={() => this.handleDeleteConfirmation("no")}
              />
            </ModalFooter>
          </Modal>
        )}

        {openErrorModal && (
          <Modal
            isOpen={openErrorModal}
            onClose={() => this.setState({ openErrorModal: false })}
            zIndex={9003}
          >
            <ModalHeader title={getDisplayValue(TAG183)} />
            <ModalContent className="slds-p-around--small errorDiv">
              {errors &&
                flatMap(Object.values(errors), error => <p>{error}</p>)}
            </ModalContent>
            <ModalFooter className="ErrorModalDialog__Footer">
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

export default ActivityModal;
