/* eslint-disable object-curly-newline */
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
  TAG227,
  TAG199,
  TAG203,
  TAG224,
  TAG228,
  TAG241,
  TAG240,
  EVENTSTAG014,
  EVENTSTAG050,
  EVENTSTAG051,
  EVENTSTAG061,
  EVENTSTAG062
} from "constants/DisplayTagConstants";
import { isEmpty, filter } from "lodash";
import {
  SALESFORCE_EVENT,
  TECH_SALESFORCE_USER_FIELD,
  WO_SCHEDULING_OPTIONS,
  JDM_LJS_ENABLED,
  BUSINESS_HOUR_ALLOW,
  BUSINESS_HOUR_WARN,
  MACHINE_HOUR_ALLOW,
  MACHINE_HOUR_WARN,
  JDM_ENABLED_LJS_DISABELD,
  WO_DISPATCH_STATUS_FIELD
} from "constants/AppConstants";
import { getDisplayValue, getFieldValue, getFormValues } from "utils/DCUtils";
import { getMinutesToHours } from "utils/DateTimeUtils";
import { getDateTimeValueFromDateTimeField } from "utils/DateAndTimeUtils";
import {
  YODA_DATE_TIME_ZONE_24_HR_FORMAT,
  DATE_TIME_FORMAT
} from "constants/DateTimeConstants";
import {
  getSettingValue,
  GLOB001_GBL025,
  DCON005_SET006,
  DCON005_SET007,
  SET021,
  DCON005_SET012
} from "constants/AppSettings";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";
import { isSchedulingEnabled } from "utils/SchedulerUtils";
import { KEY_EVENT_SUBJECT } from "constants/ActionConstants";
import CreateEditEventContainer from "containers/CreateEditEventContainer";
import {
  getEventBusinessHourPayload,
  getTechniciansData
} from "utils/EventsUtils";

import "./CreateEditEventModal.scss";

const mapStateToProps = ({ schedulerState, technicianData, userSettings }) => {
  const { technicians } = technicianData;
  const { data } = technicians;
  const { teamIds, technicians: woTechnicians, territoryList } = data;
  const sortedTechnicians = Object.values(woTechnicians);
  const { activeView: selectedIndex, newViewState } = schedulerState;
  const {
    wo_isAlldayEvent,
    wo_doNotOverlapExistingEvents,
    wo_respectTechnincianWorkHours,
    wo_respectMachineAccessHours,
    wo_unassignWO,
    wo_deleteEventForTech,
    wo_isAdvMode
  } = userSettings;
  return {
    newViewState,
    selectedIndex,
    teamIds,
    technicians: sortedTechnicians,
    territoryList,
    wo_isAlldayEvent,
    wo_doNotOverlapExistingEvents,
    wo_respectTechnincianWorkHours,
    wo_respectMachineAccessHours,
    wo_unassignWO,
    wo_deleteEventForTech,
    wo_isAdvMode
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
  woInfo: PropTypes.arrayOf(PropTypes.object),
  apply: PropTypes.func.isRequired,
  selectedWO: PropTypes.shape({}).isRequired
};

const defaultProps = {
  eventData: {},
  header: "Create Event",
  isOpen: false,
  onClose: () => {},
  woInfo: []
};

class CreateEditEventModal extends Component {
  constructor(props) {
    super(props);
    const {
      isCreateEvent,
      wo_unassignWO,
      wo_deleteEventForTech,
      wo_isAdvMode
    } = this.props;
    this.state = {
      eventsCounter: 0,
      remainderServiceDuration: 0,
      initialDataLoaded: !this.props.isCreateEvent,
      isClassicMode: !(wo_isAdvMode && wo_isAdvMode.toLowerCase() === "true"),
      showCalculate: false,
      eventSubject: "",
      errorMessage: "",
      warningMessage: "",
      confirmModal: false,
      isTechnicianChanged: false,
      isAPICallInProgress: false,
      updatePrimaryTech:
        typeof wo_unassignWO === "string"
          ? wo_unassignWO.toLowerCase() === "true"
          : wo_unassignWO || false,
      deleteEventForTech:
        typeof wo_deleteEventForTech === "string"
          ? wo_deleteEventForTech.toLowerCase() === "true"
          : wo_deleteEventForTech || false,
      shouldRememberTechUpdateAndDelete: false
    };
    const { eventData } = this.props;
    const { resource } = eventData;
    const { data } = resource;
    this.currentTechId = data.Id;
    this.currentWOId = "";
  }

  componentDidMount() {
    const me = this;
    const {
      eventData,
      eventActions,
      woInfo,
      isCreateEvent,
      editEventResourceRecord,
      isResizeEvent,
      technicians
    } = this.props;
    const { wo, dropDate, resource, woFields } = eventData;
    const selectedWo = isCreateEvent
      ? woInfo.find(info => info.Name === wo)
      : undefined;
    const schedulingOption = isCreateEvent
      ? selectedWo[WO_SCHEDULING_OPTIONS]
      : woFields[WO_SCHEDULING_OPTIONS];
    const isJDMenabled = getSettingValue(DCON005_SET006) === "Enabled";
    const isLJMenabled =
      getSettingValue(DCON005_SET007) === "Enabled" &&
      schedulingOption === JDM_LJS_ENABLED;
    const shouldShowAdvance =
      isJDMenabled &&
      (schedulingOption === JDM_LJS_ENABLED ||
        schedulingOption === JDM_ENABLED_LJS_DISABELD);
    if (isCreateEvent) {
      const woId = selectedWo.Id;
      this.currentWOId = woId;
      const { data } = resource;
      const { Id: techId } = data;

      // const isSET007Enabled = getSettingValue(DCON005_SET007) === 'Enabled';
      if (!shouldShowAdvance) {
        this.handleEventBusinessHours(dropDate, techId, this.currentWOId);
      }
      eventActions.getEventSubjectCall(woId, me.getEventSubjectCallCompleted);
    }
    if (!isCreateEvent) {
      const { woFields, resizeStartDate, data } = eventData;
      const { Id: TechId } = editEventResourceRecord;
      const allTechnicians = getTechniciansData(technicians);
      const techObj = filter(allTechnicians, { techId: TechId });
      const { startDate } = data;
      let startDateTime = startDate;
      const { Id } = woFields;
      if (isResizeEvent) {
        startDateTime = resizeStartDate;
        this.updateTechnician(techObj.length ? [techObj[0].tech] : []);
      }
      if (!shouldShowAdvance) {
        this.handleEventBusinessHours(startDateTime, TechId, Id);
        this.updateTechnician(techObj.length ? [techObj[0].tech] : []);
      }
    }
  }

  componentWillUnmount() {
    const { eventActions } = this.props;
    eventActions.cleanEventStore([KEY_EVENT_SUBJECT]);
  }

  handleEventBusinessHours = (
    droStartDate,
    techId,
    woId,
    dropEnddate,
    isBasicWH = true
  ) => {
    const { eventActions, eventData } = this.props;
    const bussinessHoursAction =
      getSettingValue(SET021) !== BUSINESS_HOUR_ALLOW;
    const machineAction =
      getSettingValue(DCON005_SET012) !== MACHINE_HOUR_ALLOW;
    const getCallForAction = isBasicWH
      ? bussinessHoursAction
      : bussinessHoursAction || machineAction;
    if (getCallForAction) {
      const startDate = moment(droStartDate).format(DATE_TIME_FORMAT);
      const endDate = moment(dropEnddate).format(DATE_TIME_FORMAT);
      const eventValues = {};
      eventValues.startDate = moment
        .utc(startDate, DATE_TIME_FORMAT)
        .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
      eventValues.techId = techId;
      eventValues.isBasicWH = isBasicWH;
      if (!isBasicWH) {
        eventValues.endDate = moment
          .utc(endDate, DATE_TIME_FORMAT)
          .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
        eventValues.workOrderId = woId || eventData.WOId;
        eventValues.isMachineAccessHrsEnabled = machineAction;
        eventValues.isBusinessHrsEnabled = bussinessHoursAction;
      }
      const payload = getEventBusinessHourPayload(eventValues);
      eventActions.getEventBusinessHour(
        this.handleEventBusinessHoursResponse,
        payload,
        isBasicWH
      );
      this.setState({ isAPICallInProgress: true });
    }
  };

  handleEventBusinessHoursResponse = (e, isBasicWH) => {
    this.setState({
      isAPICallInProgress: false,
      warningMessage: "",
      errorMessage: ""
    });
    if (isBasicWH) {
      if (!e) {
        const bussinessHoursAction =
          getSettingValue(SET021) === BUSINESS_HOUR_WARN;
        let erroMsg;
        if (bussinessHoursAction) {
          erroMsg = getDisplayValue(TAG224);
          this.setState({ warningMessage: erroMsg });
        } else {
          erroMsg = getDisplayValue(TAG228);
          this.setState({ errorMessage: erroMsg });
        }
      }
    } else if (e) {
      this.handEventBusinessHourForAdvanceMode(e);
    }
  };

  handEventBusinessHourForAdvanceMode = e => {
    const bussinessHoursDisallowAction =
      getSettingValue(SET021) !== BUSINESS_HOUR_ALLOW;
    const machineDisallowAction =
      getSettingValue(DCON005_SET012) !== MACHINE_HOUR_ALLOW;
    const getCallForAction =
      bussinessHoursDisallowAction || machineDisallowAction;
    let erroMsg;
    let BusinessStartWarringText = "";
    let BusinessEndWarringText = "";
    let MachineStartWarringText = "";
    let MachineEndWarringText = "";
    const {
      STOutsideMachineAccesshrs,
      STOutsideBusinessHrs,
      ETOutsideMachineAccesshrs,
      ETOutsideBusinessHrs
    } = e;
    if (
      (getCallForAction && STOutsideBusinessHrs) ||
      ETOutsideBusinessHrs ||
      STOutsideMachineAccesshrs ||
      ETOutsideMachineAccesshrs
    ) {
      let businessHrs = "";
      let businessDateHrs = "";
      if (STOutsideBusinessHrs) {
        businessHrs = moment.utc(
          moment(STOutsideBusinessHrs),
          DATE_TIME_FORMAT
        );
        businessDateHrs = businessHrs.format(
          getUserTimeSettings("dateTimeFormat")
        );
        BusinessStartWarringText =
          getDisplayValue(EVENTSTAG061) + businessDateHrs;
        // this.setState({ errorMessage: BusinessStartWarringText,scheduleButtonDisabled:false });
      }
      if (ETOutsideBusinessHrs) {
        businessHrs = moment.utc(
          moment(ETOutsideBusinessHrs),
          DATE_TIME_FORMAT
        );
        businessDateHrs = businessHrs.format(
          getUserTimeSettings("dateTimeFormat")
        );
        BusinessEndWarringText =
          getDisplayValue(EVENTSTAG062) + businessDateHrs;
        // this.setState({ errorMessage: BusinessEndWarringText,scheduleButtonDisabled:false });
      }
      if (STOutsideMachineAccesshrs) {
        businessHrs = moment.utc(
          moment(STOutsideMachineAccesshrs),
          DATE_TIME_FORMAT
        );
        businessDateHrs = businessHrs.format(
          getUserTimeSettings("dateTimeFormat")
        );
        MachineStartWarringText =
          getDisplayValue(EVENTSTAG062) + businessDateHrs;
        // this.setState({ errorMessage: BusinessEndWarringText,scheduleButtonDisabled:false });
      }
      if (STOutsideMachineAccesshrs) {
        businessHrs = moment.utc(
          moment(STOutsideMachineAccesshrs),
          DATE_TIME_FORMAT
        );
        businessDateHrs = businessHrs.format(
          getUserTimeSettings("dateTimeFormat")
        );
        MachineEndWarringText = getDisplayValue(EVENTSTAG062) + businessDateHrs;
        // this.setState({ errorMessage: BusinessEndWarringText,scheduleButtonDisabled:false });
      }
      let errMsg = "";
      const bussinessHoursAction =
        getSettingValue(SET021) === BUSINESS_HOUR_WARN;
      const machineAction =
        getSettingValue(DCON005_SET012) === MACHINE_HOUR_WARN;
      const getCallForActionCheck = bussinessHoursAction || machineAction;
      if (getCallForActionCheck) {
        if (
          BusinessStartWarringText != "" ||
          BusinessEndWarringText != "" ||
          MachineStartWarringText != "" ||
          MachineEndWarringText != ""
        ) {
          errMsg =
            BusinessStartWarringText != ""
              ? `${BusinessStartWarringText})\n`
              : `${BusinessEndWarringText}` != ""
              ? `${BusinessEndWarringText})\n`
              : `${MachineStartWarringText}` != ""
              ? `${MachineStartWarringText})\n`
              : `${MachineEndWarringText}` != ""
              ? `${MachineEndWarringText})`
              : "";
          this.setState({ warningMessage: errMsg });
        }
      } else if (
        BusinessStartWarringText != "" ||
        BusinessEndWarringText != "" ||
        MachineStartWarringText != "" ||
        MachineEndWarringText != ""
      ) {
        errMsg =
          BusinessStartWarringText != ""
            ? `${BusinessStartWarringText})\n`
            : `${BusinessEndWarringText}` != ""
            ? `${BusinessEndWarringText})\n`
            : `${MachineStartWarringText}` != ""
            ? `${MachineStartWarringText})\n`
            : `${MachineEndWarringText}` != ""
            ? `${MachineEndWarringText})`
            : "";
        this.setState({ errorMessage: errMsg });
      }
    }
  };

  updateTechnician = technicianObject => {
    const { draggedWO, chageFormField, isCreateEvent, eventData } = this.props;
    const isSaleforceEvent =
      getSettingValue(GLOB001_GBL025) === SALESFORCE_EVENT;
    const { Name: technicianname, Id: techId } = technicianObject[0];
    const FORM_NAME = isCreateEvent
      ? "create-event-form-field"
      : "edit-event-form-field";

    let OwnerId = techId;

    let techSFId = null;

    let isNewWO = false;

    if (
      isSaleforceEvent &&
      technicianObject &&
      technicianObject.length &&
      technicianObject[0][TECH_SALESFORCE_USER_FIELD]
    ) {
      OwnerId = technicianObject[0][TECH_SALESFORCE_USER_FIELD];
    }

    if (technicianObject[0][TECH_SALESFORCE_USER_FIELD]) {
      techSFId = technicianObject[0][TECH_SALESFORCE_USER_FIELD];
    }

    chageFormField(FORM_NAME, "technicianname", technicianname);
    chageFormField(FORM_NAME, "OwnerId", OwnerId);
    chageFormField(FORM_NAME, "techId", techId);
    chageFormField(FORM_NAME, "techSFId", techSFId);
    if (isCreateEvent) {
      if (draggedWO) {
        isNewWO = draggedWO[WO_DISPATCH_STATUS_FIELD] === "New";
      }
      chageFormField(FORM_NAME, "updateprimarytechnicians", isNewWO || null);
      chageFormField(
        FORM_NAME,
        "deleteeventforothertechnicians",
        isNewWO || null
      );
    } else {
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
      // this.setState({ updatePrimaryTech: false });
      // this.setState({ deleteEventForTech: false });
    }
  };

  onTechSelection = (technicianObject = []) => {
    const { isCreateEvent } = this.props;
    if (technicianObject) {
      const [selectedTech] = technicianObject;
      if (isSchedulingEnabled(selectedTech)) {
        if (isCreateEvent) {
          this.updateTechnician(technicianObject);
        } else {
          // const [selectedTech] = technicianObject;
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
        }
      } else {
        this.setState({
          confirmModal: {
            message: TAG199,
            yes: getDisplayValue(TAG069)
          }
        });
      }
    }
  };

  updateTechCheckbox = (data, CheckboxField) => {
    const { value } = data;
    const { shouldRememberTechUpdateAndDelete } = this.state;
    const { onTreeConfChanged } = this.props;
    const changed = {};
    if (CheckboxField === "updateprimarytechnicians") {
      if (shouldRememberTechUpdateAndDelete) {
        changed.wo_unassignWO = value && value === "on";
        onTreeConfChanged(changed);
      }
      this.setState({ updatePrimaryTech: value && value === "on" });
    } else if (CheckboxField === "deleteeventforothertechnicians") {
      if (shouldRememberTechUpdateAndDelete) {
        changed.wo_deleteEventForTech = value && value === "on";
        onTreeConfChanged(changed);
      }
      this.setState({ deleteEventForTech: value && value === "on" });
    }
  };

  rememberMyPreferenceTechUpdateAndDeleteChecked = data => {
    const { value } = data;

    if (value && value === "on") {
      const { onTreeConfChanged } = this.props;
      const { deleteEventForTech, updatePrimaryTech } = this.state;
      const changed = {};
      changed.wo_deleteEventForTech = deleteEventForTech ? "true" : "false";
      changed.wo_unassignWO = updatePrimaryTech ? "true" : "false";
      onTreeConfChanged(changed);
      this.setState({
        shouldRememberTechUpdateAndDelete: value && value === "on"
      });
    }
  };

  getEventSubjectCallCompleted = data => {
    const { content } = data;
    if (content) this.handleSubjectChange({ value: content });
    this.setState({ eventSubject: content, initialDataLoaded: true });
  };

  switchViewMode = () => {
    const { isCreateEvent } = this.props;
    const { isClassicMode } = this.state;
    this.setState({
      isClassicMode: !isClassicMode,
      errorMessage: "",
      warningMessage: ""
    });
    if (!isClassicMode) {
      this.handFormValuesForEventBusinessHour(true);
    } else {
      this.handFormValuesForEventBusinessHour(false);
    }
    const { onTreeConfChanged } = this.props;
    const changed = {};
    changed.wo_isAdvMode = !isClassicMode ? "false" : "true";
    onTreeConfChanged(changed);
  };

  handFormValuesForEventBusinessHour = (
    basiceMode = true,
    dateValue,
    fieldType
  ) => {
    const { isCreateEvent } = this.props;
    const FORM_NAME = isCreateEvent
      ? "create-event-form-field"
      : "edit-event-form-field";
    const fieldValues = getFormValues(FORM_NAME);
    const {
      startdatetime,
      enddatetime,
      techId,
      shceduleAsLongJobChecked,
      respectMachineAccessHoursChecked
    } = fieldValues;
    // const startDateForEvent = moment(startdatetime.date).add(
    //     startdatetime,
    //     'minutes',
    // );
    // const endDateForEvent = moment(enddatetime.date).add(
    //     enddatetime,
    //     'minutes',
    // );
    const startDateForEvent = getDateTimeValueFromDateTimeField(
      fieldType === "startdatetime" ? dateValue : startdatetime
    );
    const endDateForEvent = getDateTimeValueFromDateTimeField(
      fieldType === "enddatetime" ? dateValue : enddatetime
    );
    const isJDMenabled = getSettingValue(DCON005_SET006) === "Enabled";
    if (basiceMode && !isJDMenabled) {
      this.handleEventBusinessHours(
        startDateForEvent,
        techId,
        this.currentWOId,
        endDateForEvent,
        true
      );
    } else if ((basiceMode && isJDMenabled) || (!basiceMode && isJDMenabled)) {
      this.handleEventBusinessHours(
        startDateForEvent,
        techId,
        this.currentWOId,
        endDateForEvent,
        false
      );
    }
  };

  enableAndDisableSchedule = isSubmitInProgress => {
    this.setState({ isAPICallInProgress: isSubmitInProgress });
  };

  handleScheduleClick = () => {
    const { submitForm, isCreateEvent } = this.props;
    if (isCreateEvent) {
      submitForm("create-event-form-field");
    } else {
      submitForm("edit-event-form-field");
    }
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

  removeErrorMessage = value => {
    const { errorMessage } = this.state;
    if (value === errorMessage) {
      this.setState({ errorMessage: "" });
    }
  };

  removeWarningMessage = () => this.setState({ warningMessage: "" });

  handleSubjectChange = ({ value }) => {
    const emptySubjectErrorMess = getDisplayValue(TAG132);
    const lengthSubjectErrorMess = getDisplayValue(TAG227);
    if (isEmpty(value)) {
      this.setState({ errorMessage: emptySubjectErrorMess });
    } else if (value.length > 80) {
      this.setState({ errorMessage: lengthSubjectErrorMess });
    } else {
      this.removeErrorMessage(emptySubjectErrorMess);
      this.removeErrorMessage(lengthSubjectErrorMess);
    }
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

  handleServerAlertModal = (value, title = "") => {
    this.setState({
      confirmModal: {
        message: value,
        title,
        yes: getDisplayValue(TAG069)
      }
    });
  };

  getErrorOrWarning = () => {
    const { errorMessage, warningMessage } = this.state;
    return warningMessage || errorMessage ? (
      <Label className="error">
        <b>{warningMessage || errorMessage}</b>
      </Label>
    ) : null;
  };

  render() {
    const {
      eventData,
      header,
      isOpen,
      onClose,
      woInfo,
      isCreateEvent
    } = this.props;
    const {
      errorMessage,
      showCalculate,
      eventsCounter,
      eventSubject,
      remainderServiceDuration,
      confirmModal,
      isClassicMode,
      initialDataLoaded,
      isAPICallInProgress,
      warningMessage,
      updatePrimaryTech,
      deleteEventForTech
    } = this.state;
    const { wo, woFields } = eventData;
    const draggedWO = isCreateEvent
      ? woInfo.find(info => info.Name === wo)
      : undefined;
    const schedulingOption = isCreateEvent
      ? draggedWO[WO_SCHEDULING_OPTIONS]
      : woFields[WO_SCHEDULING_OPTIONS]
      ? woFields[WO_SCHEDULING_OPTIONS]
      : null;
    const isJDMenabled = getSettingValue(DCON005_SET006) === "Enabled";
    const isLJMenabled =
      getSettingValue(DCON005_SET007) === "Enabled" &&
      schedulingOption === JDM_LJS_ENABLED;
    const isSET007Enabled = getSettingValue(DCON005_SET007) === "Enabled";
    // const shouldShowAdvance = (isJDMenabled && (schedulingOption === JDM_LJS_ENABLED || schedulingOption === JDM_ENABLED_LJS_DISABELD));
    const shouldShowAdvance = isJDMenabled;
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
          className={isCreateEvent ? "CreateEventModal" : "EditEventModal"}
          size="large"
          isOpen={isOpen}
          onClose={onClose}
        >
          <ModalHeader
            title={
              isCreateEvent ? header : getDisplayValue("TAG156", "Edit Event")
            }
            tagline={tagline}
          />
          <ModalContent
            className={
              isCreateEvent
                ? "CreateEventModal__Content"
                : "EditEventModal__Content"
            }
          >
            {(!initialDataLoaded || isAPICallInProgress) && (
              <Spinner size="large" />
            )}

            {initialDataLoaded && (
              <CreateEditEventContainer
                {...this.props}
                isSET007Enabled={isSET007Enabled}
                eventSubject={eventSubject}
                handleSubjectChange={this.handleSubjectChange}
                isClassicMode={isClassicMode}
                isJDMenabled={shouldShowAdvance}
                isLJMenabled={isLJMenabled}
                draggedWO={draggedWO}
                isAPICallInProgress={isAPICallInProgress}
                onTechSelection={this.onTechSelection}
                onUpdateTechnician={this.updateTechnician}
                handleErrorMessage={this.handleErrorMessage}
                removeErrorMessage={this.removeErrorMessage}
                removeWarningMessage={this.removeWarningMessage}
                schedulingOption={schedulingOption}
                showCalculateMessage={this.showCalculateMessage}
                onHandleServerAlertModal={this.handleServerAlertModal}
                onHandleEventBusinessHours={
                  this.handFormValuesForEventBusinessHour
                }
                isTechnicianChanged={this.state.isTechnicianChanged}
                updateTechCheckbox={this.updateTechCheckbox}
                rememberMyPreferenceTechUpdateAndDeleteChecked={
                  this.rememberMyPreferenceTechUpdateAndDeleteChecked
                }
                switchViewMode={this.switchViewMode}
                updatePrimaryTech={updatePrimaryTech}
                deleteEventForTech={deleteEventForTech}
                enableAndDisableSchedule={this.enableAndDisableSchedule}
              />
            )}
          </ModalContent>
          <ModalFooter
            className={
              isCreateEvent
                ? "CreateEventModal__Footer"
                : "EditEventModal__Footer"
            }
          >
            <Grid className="slds-gutters" isVertical>
              <GridRow>
                <GridItem
                  className={
                    isCreateEvent
                      ? "CreateEventModal__Footer-text"
                      : "EditEventModal__Footer-text"
                  }
                >
                  {this.getErrorOrWarning()}
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
                    isDisabled={
                      (!warningMessage && errorMessage) || isAPICallInProgress
                    }
                    onClick={this.handleScheduleClick}
                  />
                </GridItem>
              </GridRow>
            </Grid>
          </ModalFooter>
        </Modal>
        {confirmModal && (
          <Modal
            size="x-small"
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

CreateEditEventModal.propTypes = propTypes;
CreateEditEventModal.defaultProps = defaultProps;

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(CreateEditEventModal);
