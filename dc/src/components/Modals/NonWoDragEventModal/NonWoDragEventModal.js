import React, { Component } from "react";
import {
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter,
  Button,
  Grid,
  GridRow,
  GridItem,
  Spinner
} from "@svmx/ui-components-lightning";
import { isNull } from "lodash";
import { PropTypes } from "prop-types";
import * as moment from "moment";
import { getDisplayValue } from "utils/DCUtils";
import { getNonWoUpdateDragEventPayload } from "utils/EventsUtils";
import { TAG069, TAG240, TAG238, TAG241 } from "constants/DisplayTagConstants";
import { getSettingValue, GLOB001_GBL025 } from "constants/AppSettings";
import {
  SALESFORCE_EVENT,
  TECH_SALESFORCE_USER_FIELD
} from "constants/AppConstants";
import {
  YODA_DATE_TIME_ZONE_24_HR_FORMAT,
  DATE_TIME_FORMAT,
  DATE_FORMAT,
  YODA_DATE_TIME_ZONE_FORMAT,
  YODA_DATE_FORMAT
} from "constants/DateTimeConstants";
import "./NonWoDragEventModal.scss";

import { getUserTimeSettings } from "utils/DateAndTimeUtils";

const defaultProps = {
  header: "Dispatch Console",
  isOpen: false,
  onClose: () => {},
  tagValue: ""
};

const propTypes = {
  header: PropTypes.string,
  isOpen: PropTypes.bool,
  onClose: PropTypes.func,
  tagValue: PropTypes.string
};

const settingValues = {
  SET038: "DCON001_SET038",
  SET039: "DCON001_SET039",
  SET040: "DCON001_SET040",
  SET041: "DCON001_SET041",
  SET042: "DCON001_SET042",
  SET043: "DCON001_SET043",
  SET044: "DCON001_SET044",
  SET045: "DCON001_SET045",
  SET046: "DCON001_SET046",
  SET047: "DCON001_SET047"
};

class NonWoDragEventModal extends Component {
  constructor(props) {
    super(props);
    const { tagValue } = this.props;
    this.state = {
      tagValueAlert: tagValue,
      isEventUpdated: true,
      confirmModal: false
    };
  }

  handleAllDayEvent = (startdate, enddate) => {
    const allDayEndDateConversion = moment(enddate).subtract(1, "minutes");
    const alllDayStartDate = moment(startdate).startOf("day");
    const alllDayEndDate = moment(allDayEndDateConversion).endOf("day");
    const days = alllDayEndDate.diff(alllDayStartDate, "days") + 1;
    const modifiedChangeStartDate = alllDayStartDate.format("L LT");
    const modifiedChangeEndDate = moment(startdate)
      .startOf("day")
      .add(days, "days")
      .subtract(1, "minutes")
      .format("L LT");
    const serviceDuration =
      moment(modifiedChangeEndDate, DATE_TIME_FORMAT).diff(
        moment(modifiedChangeStartDate, DATE_TIME_FORMAT),
        "minutes"
      ) + 1;
    const formValues = {};
    formValues.allDayServiceDuration = serviceDuration;
    formValues.startDate = moment
      .utc(modifiedChangeStartDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    formValues.endDate = moment
      .utc(modifiedChangeEndDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    formValues.activityDate = moment
      .utc(modifiedChangeStartDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_FORMAT);
    return formValues;
  };

  handleNonWorkOrderEvent = (startDate, startTime, endDate, endtime) => {
    const formValues = {};
    const startDateInit = moment(startDate).format(
      getUserTimeSettings("dateFormat")
    );
    const endDateInit = moment(endDate).format(
      getUserTimeSettings("dateFormat")
    );
    const startMinutes = startTime.hour() * 60 + startTime.minute();
    const endMinutes = endtime.hour() * 60 + endtime.minute();
    const startDateConversion = moment(
      startDateInit,
      getUserTimeSettings("dateFormat")
    ).add(startMinutes, "minutes");
    const endDateConversion = moment(
      endDateInit,
      getUserTimeSettings("dateFormat")
    ).add(endMinutes, "minutes");
    const serviceDuration = endDateConversion.diff(
      startDateConversion,
      "minutes"
    );
    const nonWOStartDate = moment(startDateConversion).format(DATE_TIME_FORMAT);
    const nonWOEndDate = moment(endDateConversion).format(DATE_TIME_FORMAT);
    formValues.nonWOServiceDuration = serviceDuration;
    formValues.startDate = moment
      .utc(nonWOStartDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    formValues.endDate = moment
      .utc(nonWOEndDate, DATE_TIME_FORMAT)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    return formValues;
  };

  handleYesClick = () => {
    const me = this;
    const { eventRecord, resourceRecord, eventActions } = this.props;
    const {
      id,
      location,
      subject,
      IsAllDayEvent,
      Type,
      description,
      ownerId,
      resizeStartDate,
      resizeEndDate,
      lstKeyValuePair = []
    } = eventRecord;
    let filteredLstKeyValuePair = [];
    const formValues = {};
    if (lstKeyValuePair) {
      lstKeyValuePair.forEach(function(item) {
        const { value, key } = item;
        if (!isNull(value)) {
          filteredLstKeyValuePair.push(item);
          formValues[settingValues[key]] = value === "false" ? "" : value;
        }
      });
    }
    const { id: TechId, data } = resourceRecord;
    formValues.OwnerId = ownerId;
    formValues.techId = TechId;
    const isSaleforceEvent =
      getSettingValue(GLOB001_GBL025) === SALESFORCE_EVENT;
    if (isSaleforceEvent && data) {
      formValues.OwnerId = data[TECH_SALESFORCE_USER_FIELD]
        ? data[TECH_SALESFORCE_USER_FIELD]
        : TechId;
    } else {
      formValues.OwnerId = TechId;
    }
    if (IsAllDayEvent) {
      const allDayFormValues = this.handleAllDayEvent(
        resizeStartDate,
        resizeEndDate
      );
      if (allDayFormValues) {
        formValues.startDate = allDayFormValues.startDate;
        formValues.endDate = allDayFormValues.endDate;
        formValues.serviceDuration = allDayFormValues.allDayServiceDuration;
        formValues.activityDate = allDayFormValues.activityDate;
      }
    } else {
      const momentStartDate = moment(
        resizeStartDate,
        getUserTimeSettings("dateFormat")
      );
      const momentStartTime = moment(
        resizeStartDate,
        getUserTimeSettings("timeFormat")
      );
      const momentEndDate = moment(
        resizeEndDate,
        getUserTimeSettings("dateFormat")
      );
      const momentEndTime = moment(
        resizeEndDate,
        getUserTimeSettings("timeFormat")
      );
      const nonWorkOrderFormValues = this.handleNonWorkOrderEvent(
        momentStartDate,
        momentStartTime,
        momentEndDate,
        momentEndTime
      );
      formValues.startDate = nonWorkOrderFormValues.startDate;
      formValues.endDate = nonWorkOrderFormValues.endDate;
      formValues.serviceDuration = nonWorkOrderFormValues.nonWOServiceDuration;
    }
    formValues.eventData = eventRecord;
    formValues.isAllDayEventChk = IsAllDayEvent;
    formValues.eventsubject = subject;
    formValues.descriptionfieldarea = description;
    formValues.locationnote = location;
    formValues.eventTypePicklist = Type;
    formValues.eventId = id;
    formValues.lstKeyValuePair = filteredLstKeyValuePair;
    const payload = getNonWoUpdateDragEventPayload(formValues);
    me.setState({ isEventUpdated: false });
    eventActions.updateEvent(me.afterEventEditCall, payload);
  };

  afterEventEditCall = (response, error = false) => {
    const { onClose, editEventCompleted } = this.props;
    if (response && response === getDisplayValue(TAG238)) {
      this.handleServerAlertModal(TAG238);
    } else if (response && !error) {
      editEventCompleted(response);
      onClose();
    }
    this.setState({ isEventUpdated: true });
  };

  handleNoClick = () => {
    const { onClose } = this.props;
    onClose();
  };

  handleServerAlertModal = value => {
    this.setState({ confirmModal: true, tagValueAlert: value });
  };

  render() {
    const { header, isOpen, onClose } = this.props;
    const { isEventUpdated, confirmModal, tagValueAlert } = this.state;

    return (
      <Modal size="xx-small" isOpen={isOpen} onClose={onClose}>
        <ModalHeader title={getDisplayValue(header)} />
        <ModalContent className="NonWoDragEventModal__content">
          {!isEventUpdated && (
            <Grid isVertical>
              <GridRow>
                <GridItem>
                  <Spinner size="small" />
                </GridItem>
              </GridRow>
            </Grid>
          )}
          {getDisplayValue(tagValueAlert)}
        </ModalContent>
        <ModalFooter className="NonWoDragEventModal__footer">
          <GridRow>
            <GridItem>
              {!confirmModal && (
                <div>
                  <Button
                    type="neutral"
                    label={getDisplayValue(TAG240)}
                    onClick={this.handleYesClick}
                  />
                  <Button
                    type="neutral"
                    label={getDisplayValue(TAG241)}
                    onClick={this.handleNoClick}
                  />
                </div>
              )}
              {confirmModal && (
                <Button
                  type="neutral"
                  label={getDisplayValue(TAG069)}
                  onClick={this.handleNoClick}
                />
              )}
            </GridItem>
          </GridRow>
        </ModalFooter>
      </Modal>
    );
  }
}

NonWoDragEventModal.propTypes = propTypes;
NonWoDragEventModal.defaultProps = defaultProps;

export default NonWoDragEventModal;
