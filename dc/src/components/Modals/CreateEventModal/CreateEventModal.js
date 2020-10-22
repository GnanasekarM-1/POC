import React, { Component } from "react";
import { PropTypes } from "prop-types";
import { connect } from "react-redux";
import * as moment from "moment";
import {
  Container,
  Grid,
  GridRow,
  GridItem,
  Modal,
  Label,
  ModalHeader,
  ModalContent,
  ModalFooter,
  Button,
  Spinner
} from "@svmx/ui-components-lightning";
import {
  EVENTSTAG004,
  EVENTSTAG005,
  TAG066,
  TAG069,
  TAG132, // Please enter a subject
  TAG224,
  TAG227,
  TAG228,
  EVENTSTAG014,
  EVENTSTAG050,
  EVENTSTAG051
} from "constants/DisplayTagConstants";
import { isEmpty } from "lodash";
import {
  WO_SCHEDULING_OPTIONS,
  JDM_LJS_ENABLED,
  JDM_ENABLED_LJS_DISABELD,
  BUSINESS_HOUR_ALLOW,
  BUSINESS_HOUR_RESTRICT,
  BUSINESS_HOUR_WARN
} from "constants/AppConstants";
import {
  YODA_DATE_TIME_ZONE_24_HR_FORMAT,
  DATE_TIME_FORMAT
} from "constants/DateTimeConstants";
import { getDisplayValue } from "utils/DCUtils";
import { getMinutesToHours } from "utils/DateTimeUtils";
import {
  getSettingValue,
  DCON005_SET006,
  DCON005_SET007,
  SET021
} from "constants/AppSettings";
import { KEY_EVENT_SUBJECT } from "constants/ActionConstants";
import CreateEventContainer from "containers/CreateEventContainer";
import { getEventBusinessHourPayload } from "utils/EventsUtils";

import "./CreteEventModal.scss";

const mapStateToProps = ({ technicianData, userSettings }) => {
  const { technicians } = technicianData;
  const { data } = technicians;
  const { teamIds, technicians: woTechnicians, territoryList } = data;
  const sortedTechnicians = Object.values(woTechnicians);
  const {
    wo_isAlldayEvent,
    wo_doNotOverlapExistingEvents,
    wo_respectTechnincianWorkHours,
    wo_respectMachineAccessHours
  } = userSettings;
  return {
    teamIds,
    technicians: sortedTechnicians,
    territoryList,
    wo_isAlldayEvent,
    wo_doNotOverlapExistingEvents,
    wo_respectTechnincianWorkHours,
    wo_respectMachineAccessHours
  };
};

const mapDispatchToProps = dispatch => ({
  getFields: dispatch({ type: "GET_FIELDS" })
});

const propTypes = {
  eventActions: PropTypes.func,
  eventData: PropTypes.objectOf(PropTypes.object),
  header: PropTypes.string,
  isOpen: PropTypes.bool,
  onClose: PropTypes.func,
  woInfo: PropTypes.arrayOf(PropTypes.object)
};

const defaultProps = {
  eventData: {},
  header: "Create Event",
  isOpen: false,
  onClose: () => {},
  woInfo: []
};

class CreateEventModal extends Component {
  state = {
    eventsCounter: 0,
    remainderServiceDuration: 0,
    initialDataLoaded: false,
    isClassicMode: false,
    showCalculate: false,
    eventSubject: "",
    errorMessage: "",
    confirmModal: false
  };

  componentDidMount() {
    const me = this;
    const { eventData, eventActions, woInfo } = this.props;
    const { wo, dropDate, resource } = eventData;
    const { data } = resource;
    const { Id: techId } = data;
    const selectedWo = woInfo.find(info => info.Name === wo);
    const woId = selectedWo.Id;
    eventActions.getEventSubjectCall(woId, me.getEventSubjectCallCompleted);
    this.handleEventBusinessHours(dropDate, techId);
  }

  componentWillUnmount() {
    const { eventActions } = this.props;
    eventActions.cleanEventStore([KEY_EVENT_SUBJECT]);
  }

  handleEventBusinessHours = (dropDate, techId) => {
    const { eventActions } = this.props;
    const bussinessHoursAction =
      getSettingValue(SET021) !== BUSINESS_HOUR_ALLOW;
    if (bussinessHoursAction) {
      const startDate = moment(dropDate).format(DATE_TIME_FORMAT);
      const isBasicWH = true;
      const eventValues = {};
      eventValues.startDate = moment
        .utc(startDate, DATE_TIME_FORMAT)
        .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
      eventValues.techId = techId;
      eventValues.isBasicWH = isBasicWH;
      const payload = getEventBusinessHourPayload(eventValues);
      eventActions.getEventBusinessHour(
        this.handleEventBusinessHoursResponse,
        payload,
        isBasicWH
      );
    }
  };

  handleEventBusinessHoursResponse = e => {
    if (!e) {
      const bussinessHoursAction =
        getSettingValue(SET021) === BUSINESS_HOUR_WARN;
      let erroMsg;
      if (bussinessHoursAction) {
        erroMsg = getDisplayValue(TAG224);
      } else {
        erroMsg = getDisplayValue(TAG228);
      }
      this.setState({ errorMessage: erroMsg });
    }
  };

  getEventSubjectCallCompleted = data => {
    const { content } = data;
    if (content) this.handleSubjectChange({ value: content });
    this.setState({ eventSubject: content, initialDataLoaded: true });
  };

  switchViewMode = () => {
    const { isClassicMode } = this.state;
    this.setState({
      isClassicMode: !isClassicMode
    });
  };

  handleScheduleClick = () => {
    const { submitForm } = this.props;
    submitForm("create-event-form-field");
  };

  showCalculateMessage = (eventsCounter, remainderServiceDuration) => {
    this.setState({
      eventsCounter,
      remainderServiceDuration,
      showCalculate: true
    });
  };

  hideCalculateMessage = () => {
    this.setState({ showCalculate: false });
  };

  handleErrorMessage = value => {
    this.setState({ errorMessage: value });
  };

  handleSubjectChange = ({ value }) => {
    if (isEmpty(value)) {
      this.setState({ errorMessage: getDisplayValue(TAG132) });
    } else if (value.length > 80) {
      this.setState({ errorMessage: getDisplayValue(TAG227) });
    } else {
      // this.setState({ errorMessage: '' });
    }
  };

  onAlertMessageClick = value => {
    if (value === getDisplayValue(TAG069)) {
    }
    this.setState({ confirmModal: false });
  };

  handleServerAlertModal = (value, title = "") => {
    this.setState({
      confirmModal: {
        message: value,
        title,
        yes: getDisplayValue(TAG069)
      }
    });
  };

  render() {
    const { eventData, header, isOpen, onClose, woInfo } = this.props;
    const {
      errorMessage,
      showCalculate,
      eventsCounter,
      eventSubject,
      remainderServiceDuration,
      confirmModal
    } = this.state;
    const { wo } = eventData;
    const draggedWO = woInfo.find(info => info.Name === wo);
    const schedulingOption = draggedWO[WO_SCHEDULING_OPTIONS];
    const isJDMenabled = getSettingValue(DCON005_SET006) === "Enabled";
    const isLJMenabled =
      getSettingValue(DCON005_SET007) === "Enabled" &&
      schedulingOption === JDM_LJS_ENABLED;
    const isSET007Enabled = getSettingValue(DCON005_SET007) === "Enabled";
    const { initialDataLoaded, isClassicMode } = this.state;
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
          className="CreateEventModal"
          size="large"
          isOpen={isOpen}
          onClose={onClose}
        >
          <ModalHeader title={header} tagline={tagline} />
          <ModalContent className="CreateEventModal__Content">
            {!initialDataLoaded && <Spinner size="large" />}

            {initialDataLoaded && (
              <CreateEventContainer
                {...this.props}
                isSET007Enabled={isSET007Enabled}
                eventSubject={eventSubject}
                handleSubjectChange={this.handleSubjectChange}
                isClassicMode={isClassicMode}
                isJDMenabled={shouldShowAdvance}
                isLJMenabled={isLJMenabled}
                draggedWO={draggedWO}
                handleErrorMessage={this.handleErrorMessage}
                schedulingOption={schedulingOption}
                showCalculateMessage={this.showCalculateMessage}
                onHandleServerAlertModal={this.handleServerAlertModal}
                onHandleEventBusinessHours={this.handleEventBusinessHours}
                switchViewMode={this.switchViewMode}
              />
            )}
          </ModalContent>
          <ModalFooter className="NonWoCreateEventModal__Footer">
            <Grid className="slds-gutters" isVertical>
              <GridRow>
                <GridItem className="NonWoCreateEventModal__Footer-text">
                  {errorMessage && (
                    <Label className="error">
                      <b>{errorMessage}</b>
                    </Label>
                  )}
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
                    isDisabled={errorMessage}
                    onClick={this.handleScheduleClick}
                  />
                </GridItem>
              </GridRow>
            </Grid>
          </ModalFooter>
          {confirmModal && (
            <Modal
              isOpen={confirmModal}
              onClose={() => this.onAlertMessageClick()}
              zIndex={9003}
            >
              <ModalHeader
                title={
                  confirmModal.title
                    ? confirmModal.title
                    : getDisplayValue("TAG183")
                }
              />
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
              </ModalFooter>
            </Modal>
          )}
        </Modal>
        {showCalculate && (
          <Modal isOpen onClose={this.hideCalculateMessage} zIndex={9003}>
            <ModalHeader title="Dispatch Console" />
            <ModalContent className="slds-p-around--small">
              <Container>
                {`${getDisplayValue(EVENTSTAG050)} ${eventsCounter}`}
                <br />
                {remainderServiceDuration > 0
                  ? `${getDisplayValue(EVENTSTAG051)} ${getMinutesToHours(
                      remainderServiceDuration
                    )}`
                  : ""}
              </Container>
            </ModalContent>
            <ModalFooter>
              <Button
                type="brand"
                label="OK"
                onClick={this.hideCalculateMessage}
              />
            </ModalFooter>
          </Modal>
        )}
      </div>
    );
  }
}

CreateEventModal.propTypes = propTypes;
CreateEventModal.defaultProps = defaultProps;

export default connect(mapStateToProps, mapDispatchToProps)(CreateEventModal);
