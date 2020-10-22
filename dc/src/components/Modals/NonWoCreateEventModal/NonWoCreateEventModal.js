import React, { Component } from "react";
import {
  Button,
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter,
  Grid,
  GridItem,
  Label,
  GridRow
} from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import { connect } from "react-redux";
import { TEAM_API_REF } from "constants/AppConstants";
import { getDisplayValue, getFieldValue } from "utils/DCUtils";
import {
  TAG066,
  TAG155,
  TAG156,
  EVENTSTAG014,
  TAG132, // Please enter a subject
  TAG227,
  TAG069
} from "constants/DisplayTagConstants";
import { isEmpty } from "lodash";
import NonWoEventCreateContainer from "containers/NonWoEventCreateContainer";

import "./NonWoCreateEventModal.scss";

const mapStateToProps = ({
  metaData,
  schedulerState,
  technicianData,
  userSettings
}) => {
  const { technicians } = technicianData;
  const { data } = technicians;
  const { teamIds, technicians: woTechnicians, territoryList } = data;
  const { eventFields } = metaData;
  const { content } = eventFields;
  const { Type: eventType } = content;
  const { refField } = eventType;
  const { wo_isAlldayEvent } = userSettings;
  let refFieldArr = [];
  if (refField) {
    const keyValueJSON = JSON.parse(refField);
    try {
      const keySequence = [];
      const keyValues = refField.split('":"');
      for (let i = 0; i < keyValues.length - 1; i++) {
        let keyValue = keyValues[i];
        if (i == 0) {
          keyValue = keyValue.replace(/(^{")|("$)/g, "");
        } else {
          keyValue = keyValue.split(",");
          keyValue =
            keyValue.length > 1
              ? keyValue[1].replace(/(^")|("$)/g, "")
              : keyValue[0];
        }
        keySequence.push(keyValue);
      }

      refFieldArr = keySequence.map(name => ({
        name,
        display: keyValueJSON[name]
      }));
    } catch (e) {
      refFieldArr = Object.keys(keyValueJSON).map(name => ({
        name,
        display: keyValueJSON[name]
      }));
    }
  }
  const sortedTechnicians = Object.values(woTechnicians);
  const { activeView: selectedIndex } = schedulerState;
  return {
    refFieldArr,
    wo_isAlldayEvent,
    selectedIndex,
    teamIds,
    technicians: sortedTechnicians,
    territoryList
  };
};

const mapDispatchToProps = dispatch => ({
  getFields: dispatch({ type: "GET_FIELDS" })
});

class NonWoCreateEventModal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      tagValue: "",
      errorMessage: "",
      technicianObject: {},
      techSelectedvalues: [],
      teamExpandValues: [],
      confirmModal: false,
      isAPICallInProgress: false
    };
  }

  componentWillMount() {
    this.onTechExpanAndSelect();
  }

  enableAndDisableSchedule = isSubmitInProgress => {
    this.setState({ isAPICallInProgress: isSubmitInProgress });
  };

  handleScheduleClick = () => {
    const { submitForm } = this.props;
    submitForm("non-wo-create-event");
  };

  handleModalFieldCheck = value => {
    // this.setState({ tagValue: value });
    this.setState({
      confirmModal: {
        message: value,
        yes: getDisplayValue(TAG069)
      }
    });
  };

  onTechExpanAndSelect = () => {
    const { eventRecord, technicians, onSchedulerSelectedTech } = this.props;
    if (eventRecord && eventRecord.data) {
      const techObj = technicians.filter(
        techItem => techItem.technician_O.Id === eventRecord.data.TechId
      );
      if (techObj.length) {
        const [technicianObj] = techObj;
        const { technician_O } = technicianObj;
        const teamRefObj = getFieldValue(technician_O, TEAM_API_REF);
        const { Id } = teamRefObj;
        this.setState({
          technicianObject: technician_O,
          techSelectedvalues: [eventRecord.TechId],
          teamExpandValues: [Id]
        });
      }
    } else if (onSchedulerSelectedTech) {
      const techObj = technicians.filter(
        techItem => techItem.technician_O.Id === onSchedulerSelectedTech
      );
      if (techObj.length) {
        const [technicianObj] = techObj;
        const { technician_O } = technicianObj;
        const teamRefObj = getFieldValue(technician_O, TEAM_API_REF);
        const { Id } = teamRefObj;
        this.setState({
          technicianObject: technician_O,
          techSelectedvalues: [onSchedulerSelectedTech],
          teamExpandValues: [Id]
        });
      }
    }
  };

  onAlertMessageClick = value => {
    if (value === getDisplayValue(TAG069)) {
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

  handleSubjectChange = ({ value }) => {
    const emptySubjectErrorMess = getDisplayValue(TAG132);
    const lengthSubjectErrorMess = getDisplayValue(TAG227);
    if (isEmpty(value)) {
      this.setState({ errorMessage: emptySubjectErrorMess });
    } else if (value.length > 80) {
      this.setState({ errorMessage: lengthSubjectErrorMess });
    } else {
      this.setState({ errorMessage: "" });
    }
  };

  render() {
    const { onClose, isOpen, isEditNonWOCreateEvent } = this.props;
    const {
      tagValue,
      techSelectedvalues,
      teamExpandValues,
      technicianObject,
      confirmModal,
      errorMessage,
      isAPICallInProgress
    } = this.state;
    return (
      <div>
        <Modal
          className="NonWoCreateEventModal"
          size="large"
          isOpen={isOpen}
          onClose={onClose}
        >
          <ModalHeader
            title={
              isEditNonWOCreateEvent
                ? getDisplayValue(TAG156)
                : getDisplayValue(TAG155)
            }
          />
          <ModalContent className="NonWoCreateEventModal__Content">
            <NonWoEventCreateContainer
              {...this.props}
              technicianObject={technicianObject}
              techSelectedvalues={techSelectedvalues}
              teamExpandValues={teamExpandValues}
              handleSubjectChange={this.handleSubjectChange}
              onHandleModalFieldCheck={this.handleModalFieldCheck}
              onHandleServerAlertModal={this.handleServerAlertModal}
              enableAndDisableSchedule={this.enableAndDisableSchedule}
            />
          </ModalContent>
          <ModalFooter className="NonWoCreateEventModal__Footer">
            <Grid className="slds-gutters" isVertical>
              <GridRow>
                <GridItem className="NonWOCreateEventModal__Footer-text">
                  <Label className="error">
                    <b>{errorMessage}</b>
                  </Label>
                </GridItem>
                <GridItem noFlex>
                  <Button
                    type="neutral"
                    label={getDisplayValue(TAG066)}
                    onClick={onClose}
                  />
                </GridItem>
                <GridItem noFlex>
                  <Button
                    type="brand"
                    label={getDisplayValue(EVENTSTAG014)}
                    isDisabled={errorMessage || isAPICallInProgress}
                    onClick={this.handleScheduleClick}
                  />
                </GridItem>
              </GridRow>
            </Grid>
          </ModalFooter>
        </Modal>
        {confirmModal && (
          <Modal
            isOpen={confirmModal}
            size="small"
            onClose={() => this.onAlertMessageClick()}
            zIndex={9003}
          >
            <ModalHeader title={getDisplayValue("TAG183")} />
            <ModalContent className="slds-p-around--small">
              {getDisplayValue(confirmModal.message)}
            </ModalContent>
            <ModalFooter className="NonWOConfirmationDialog__Footer">
              {confirmModal.yes && (
                <Button
                  type="brand"
                  label={getDisplayValue(confirmModal.yes)}
                  onClick={() => this.onAlertMessageClick(confirmModal.yes)}
                />
              )}
            </ModalFooter>
          </Modal>
        )}
      </div>
    );
  }
}

NonWoCreateEventModal.propTypes = {
  apply: PropTypes.func.isRequired,
  isOpen: PropTypes.func.isRequired,
  open: PropTypes.bool.isRequired,
  selectedWO: PropTypes.shape({}).isRequired
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(NonWoCreateEventModal);
