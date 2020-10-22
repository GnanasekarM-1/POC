import React, { Component } from "react";
import {
  Button,
  Grid,
  GridItem,
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter
} from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import { connect } from "react-redux";
import {
  getSettingValue,
  GLOB001_GBL025,
  DCON005_SET006
} from "constants/AppSettings";
import {
  SALESFORCE_EVENT,
  TECH_SALESFORCE_USER_FIELD,
  WO_SCHEDULING_OPTIONS,
  JDM_LJS_ENABLED,
  JDM_ENABLED_LJS_DISABELD
} from "constants/AppConstants";
import { getDisplayValue } from "utils/DCUtils";
import {
  TAG066,
  TAG076,
  EVENTSTAG014,
  TAG157,
  TAG203,
  TAG069,
  TAG240,
  TAG241,
  EVENTSTAG004,
  EVENTSTAG005
} from "constants/DisplayTagConstants";
import EditEventContainer from "containers/EditEventContainer";
import "./EditEventModal.scss";

const FORM_NAME = "edit-event-form-field";

const mapStateToProps = ({ technicianData }) => {
  const { technicians } = technicianData;
  const { data } = technicians;
  const { teamIds, technicians: woTechnicians, territoryList } = data;
  const sortedTechnicians = Object.values(woTechnicians);
  return {
    teamIds,
    technicians: sortedTechnicians,
    territoryList
  };
};

const mapDispatchToProps = dispatch => ({
  getFields: dispatch({ type: "GET_FIELDS" })
});

class EditEventModal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      confirmModal: false,
      errorMessage: "",
      isClassicMode: false,
      isTechnicianChanged: false
    };
    const { eventData } = this.props;
    const { resource } = eventData;
    const { data } = resource;
    this.currentTechId = data.Id;
  }

  componentDidMount() {
    const { editEventResourceRecord, isResizeEvent } = this.props;
    if (isResizeEvent) this.updateTechnician([editEventResourceRecord]);
  }

  onTechSelection = (technicianObject = []) => {
    const [selectedTech] = technicianObject;
    // const { eventData } = this.props
    // const { resource } = eventData;
    // const { data } = resource;
    if (this.currentTechId && selectedTech) {
      if (this.currentTechId !== selectedTech.Id) {
        this.setState({
          confirmModal: {
            cancel: getDisplayValue(TAG066),
            message: getDisplayValue(TAG203),
            no: getDisplayValue(TAG241),
            yes: getDisplayValue(TAG240),
            technicianObject
          }
        });
      } else {
        this.updateTechnician(technicianObject);
      }
    }
  };

  handleScheduleClick = () => {
    const { submitForm } = this.props;
    submitForm("edit-event-form-field");
  };

  handleErrorMessage = value => {
    this.setState({ errorMessage: value });
  };

  updateTechnician = technicianObject => {
    const isSaleforceEvent =
      getSettingValue(GLOB001_GBL025) === SALESFORCE_EVENT;
    const { Name: technicianname, Id: techId } = technicianObject[0];
    const { eventData } = this.props;
    let OwnerId = techId;
    if (
      isSaleforceEvent &&
      technicianObject &&
      technicianObject.length &&
      technicianObject[0][TECH_SALESFORCE_USER_FIELD]
    ) {
      OwnerId = technicianObject[0][TECH_SALESFORCE_USER_FIELD];
    }
    let techSFId = null;
    if (technicianObject[0][TECH_SALESFORCE_USER_FIELD]) {
      techSFId = technicianObject[0][TECH_SALESFORCE_USER_FIELD];
    }
    const { chageFormField } = this.props;
    // Need to check for single change call
    chageFormField(FORM_NAME, "technicianname", technicianname);
    chageFormField(FORM_NAME, "OwnerId", OwnerId);
    chageFormField(FORM_NAME, "techId", techId);
    chageFormField(FORM_NAME, "techSFId", techSFId);
    let technicianChanged = true;
    if (eventData.TechId !== techId) {
      chageFormField(FORM_NAME, "updateprimarytechnicians", true);
      chageFormField(FORM_NAME, "deleteeventforothertechnicians", true);
    } else {
      technicianChanged = false;
      chageFormField(FORM_NAME, "updateprimarytechnicians", null);
      chageFormField(FORM_NAME, "deleteeventforothertechnicians", null);
    }
    this.setState({ isTechnicianChanged: technicianChanged });
  };

  onAlertMessageClick = value => {
    const { onClose } = this.props;
    const { confirmModal } = this.state;
    if (value === getDisplayValue(TAG240)) {
      const { technicianObject } = confirmModal;
      this.updateTechnician(technicianObject);
      const [selectedTech] = technicianObject;
      this.currentTechId = selectedTech.Id;
    } else if (value === getDisplayValue(TAG069)) {
    } else if (value === getDisplayValue(TAG066)) {
      onClose();
    }
    this.setState({ confirmModal: false });
  };

  handleServerAlertModal = value => {
    this.setState({
      confirmModal: {
        message: value,
        yes: getDisplayValue(TAG069)
      }
    });
  };

  switchViewMode = () => {
    const { isClassicMode } = this.state;
    this.setState({
      isClassicMode: !isClassicMode
    });
  };

  render() {
    const { onClose, isOpen, eventData } = this.props;
    const { errorMessage, confirmModal, isClassicMode } = this.state;
    const { woFields } = eventData;
    const schedulingOption = woFields[WO_SCHEDULING_OPTIONS];
    const isJDMenabled = getSettingValue(DCON005_SET006) === "Enabled";
    const shouldShowAdvance =
      isJDMenabled &&
      (schedulingOption === JDM_LJS_ENABLED ||
        schedulingOption === JDM_ENABLED_LJS_DISABELD);
    const tagline = (
      <span>
        {shouldShowAdvance && (
          <Button
            type="neutral"
            label={
              !isClassicMode
                ? getDisplayValue(EVENTSTAG004)
                : getDisplayValue(EVENTSTAG005)
            }
            onClick={this.switchViewMode}
          />
        )}
      </span>
    );
    return (
      <div>
        <Modal
          className="EditEventModal"
          size="large"
          isOpen={isOpen}
          onClose={onClose}
        >
          <ModalHeader title="Edit Event" tagline={tagline} />
          <ModalContent className="EditEventModal__Content">
            <EditEventContainer
              {...this.props}
              isJDMenabled={shouldShowAdvance}
              handleErrorMessage={this.handleErrorMessage}
              onTechSelection={this.onTechSelection}
              isClassicMode={isClassicMode}
              onHandleServerAlertModal={this.handleServerAlertModal}
              isTechnicianChanged={this.state.isTechnicianChanged}
            />
          </ModalContent>
          <ModalFooter className="EditEventModal__Footer">
            <Grid className="StatusBar">
              <GridItem>
                <div className="StatusBar warning">
                  <blink>
                    <b>{errorMessage}</b>
                  </blink>
                </div>
              </GridItem>
              <Button
                type="neutral"
                label={getDisplayValue(TAG066)}
                onClick={onClose}
              />
              <Button
                type="brand"
                label={getDisplayValue(EVENTSTAG014)}
                onClick={this.handleScheduleClick}
              />
            </Grid>
          </ModalFooter>
        </Modal>
        {confirmModal && (
          <Modal
            isOpen={confirmModal}
            onClose={() => this.onAlertMessageClick()}
            zIndex={9003}
          >
            <ModalHeader title={getDisplayValue("TAG183")} />
            <ModalContent className="slds-p-around--small">
              {getDisplayValue(confirmModal.message)}
            </ModalContent>
            <ModalFooter>
              {confirmModal.yes && (
                <Button
                  type="brand"
                  label={getDisplayValue(confirmModal.yes)}
                  onClick={() => this.onAlertMessageClick(confirmModal.yes)}
                />
              )}
              {confirmModal.no && (
                <Button
                  type="brand"
                  label={getDisplayValue(confirmModal.no)}
                  onClick={() => this.onAlertMessageClick(confirmModal.no)}
                />
              )}
              {confirmModal.cancel && (
                <Button
                  type="brand"
                  label={getDisplayValue(confirmModal.cancel)}
                  onClick={() => this.onAlertMessageClick(confirmModal.cancel)}
                />
              )}
            </ModalFooter>
          </Modal>
        )}
      </div>
    );
  }
}

EditEventModal.propTypes = {
  apply: PropTypes.func.isRequired,
  isOpen: PropTypes.func.isRequired,
  open: PropTypes.bool.isRequired,
  selectedWO: PropTypes.shape({}).isRequired
};

export default connect(mapStateToProps, mapDispatchToProps)(EditEventModal);
