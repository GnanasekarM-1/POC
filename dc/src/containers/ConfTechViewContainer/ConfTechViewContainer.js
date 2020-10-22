import React from "react";
import { connect } from "react-redux";
import ConfTechView from "components/ConfTechView";
import { DISPLAY, NAME, EVENT_EXP_TYPE } from "constants/AppConstants";
import { cloneDeep, orderBy, flatMap } from "lodash";

const mapStateToProps = ({ metaData, technicianData, userSettings }) => {
  const {
    tech_autoCalculateEndDate,
    tech_autoSyncServiceDuration,
    tech_condition,
    tech_dataTipOnClick,
    tech_defaultEventColor,
    tech_defaultWOEventColor,
    tech_driveColor,
    tech_eventRowColor,
    tech_holidayHoursColor,
    tech_noOfDays,
    tech_overheadColor,
    tech_overNightStayColor,
    tech_refreshEventsOnChange,
    tech_relatedEventColor,
    tech_retainDateOnShowRoute,
    tech_showTimeIndicator,
    tech_techCol,
    tech_techRules,
    tech_teamSequence,
    tech_territorySequence,
    tech_timeIndicatorColor,
    tech_toolTipHideDelay,
    tech_toolTipShowDelay,
    tech_workingHoursColor
  } = userSettings;
  const { eventFields, technicianFields, workOrderFields } = metaData;
  const { technicians } = technicianData;
  const { content: techContent } = technicianFields;
  const { content: eventContent } = eventFields;
  const { content: woContent } = workOrderFields;
  const techFields = (techContent && cloneDeep(techContent)) || {};
  const nameObj = techFields[NAME];
  if (nameObj) {
    nameObj.locked = true;
  }
  const eveFields = orderBy(Object.values(eventContent), [DISPLAY]);
  const woFields = orderBy(Object.values(woContent), [DISPLAY]);
  let eveSourceItems = [];

  const eveFieldsArray = flatMap(eveFields, evtField => {
    const {
      display,
      value: key,
      type = EVENT_EXP_TYPE,
      fieldType,
      refField,
      wrapperName: value
    } = evtField;
    return {
      display: `Event.${display}`,
      fieldType,
      key,
      refField,
      type,
      value: `Event.${value}`
    };
  });

  const woFieldsArray = woFields.filter(
    woField => woField.fieldType !== "textarea"
  );

  eveSourceItems = woFieldsArray.concat(eveFieldsArray);

  return {
    eveSourceItems,
    tech_autoCalculateEndDate,
    tech_autoSyncServiceDuration,
    tech_condition,
    tech_dataTipOnClick,
    tech_defaultEventColor,
    tech_defaultWOEventColor,
    tech_driveColor,
    tech_eventRowColor,
    tech_holidayHoursColor,
    tech_noOfDays,
    tech_overheadColor,
    tech_overNightStayColor,
    tech_refreshEventsOnChange,
    tech_relatedEventColor,
    tech_retainDateOnShowRoute,
    tech_showTimeIndicator,
    tech_teamSequence,
    tech_techCol,
    tech_techRules,
    tech_territorySequence,
    tech_timeIndicatorColor,
    tech_toolTipHideDelay,
    tech_toolTipShowDelay,
    tech_workingHoursColor,
    techFields,
    technicians
  };
};

const ConfTechViewContainer = props => <ConfTechView {...props} />;

export default connect(mapStateToProps)(ConfTechViewContainer);
