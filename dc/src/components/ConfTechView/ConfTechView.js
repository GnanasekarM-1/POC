import React, { Component } from "react";
import { getDisplayValue } from "utils/DCUtils";
import { compact, orderBy, isEqual, flatMap } from "lodash";
import { Tabs, Tab } from "@svmx/ui-components-lightning";
import { DISPLAY, FALSE } from "constants/AppConstants";
import { DCON001_SET017, getSettingValue } from "constants/AppSettings";
import ColorRules from "../ConfigureWORowColor/ColorRules";
import ConfTechColumn from "./ConfTechColumn";
import ConfTechTeam from "./ConfTechTeam";
import ConfTechCalendar from "./ConfTechCalendar";
import ConfTechEventColors from "./ConfTechEventColors";
import { TAG429, TAG500 } from "constants/DisplayTagConstants";
import "./ConfTechView.scss";

class ConfTechView extends Component {
  shouldComponentUpdate(nextProps) {
    const { tech_techRules } = this.props;
    return !isEqual(tech_techRules, nextProps.tech_techRules);
  }

  handleConfigurationChange = (modifiedColorRules, activeRuleIndex) => {
    const { onRulesModified } = this.props;
    const modifiedSettings = {};
    if (modifiedColorRules) {
      modifiedSettings.tech_techRules = modifiedColorRules;
      onRulesModified(modifiedSettings, activeRuleIndex);
    } else {
      onRulesModified(null, activeRuleIndex);
    }
  };

  handleColumnChange = selectedColumns => {
    const { onRulesModified } = this.props;
    const modifiedSettings = {};
    modifiedSettings.tech_techCol = [];
    flatMap(selectedColumns, column => {
      const obj = {};
      obj.name = column;
      if (column === "Name") {
        obj.width = 200;
      } else {
        obj.width = 100;
      }
      modifiedSettings.tech_techCol.push(obj);
    });
    onRulesModified(modifiedSettings);
  };

  handleValueChange = (value, prop) => {
    const { onRulesModified } = this.props;
    const modifiedSettings = {};
    modifiedSettings[`${prop}`] = value;
    onRulesModified(modifiedSettings);
  };

  getTechConfigTabs = () => {
    const {
      deleteConfirmation,
      eveSourceItems,
      formRef,
      getDeleteRef,
      onSubmitSuccess,
      onCustomValidationError,
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
    } = this.props;

    let tabIndex = 1;
    const children = [];
    const enableTechFieldSelection = JSON.parse(
      getSettingValue(DCON001_SET017, FALSE).toLowerCase()
    );
    if (enableTechFieldSelection) {
      children.push(
        <Tab
          className="ConfTechView__tab"
          eventKey={`${tabIndex}`}
          title={getDisplayValue("TAG192")}
        >
          <ConfTechColumn
            sourceItems={orderBy(Object.values(techFields), [DISPLAY])}
            targetValues={compact(
              tech_techCol.map(col => {
                const { name } = col;
                return techFields[name] ? name : undefined;
              })
            )}
            onColumnChange={this.handleColumnChange}
          />
        </Tab>
      );
      tabIndex += 1;
    }

    children.push(
      <Tab
        className="ConfTechView__tab"
        eventKey={`${tabIndex}`}
        title={getDisplayValue("TAG342")}
      >
        <ConfTechTeam
          userData={technicians}
          teamSeq={tech_teamSequence}
          territorySeq={tech_territorySequence}
          onValueChange={this.handleValueChange}
        />
      </Tab>
    );
    tabIndex += 1;

    children.push(
      <Tab
        className="ConfTechView__tab"
        eventKey={`${tabIndex}`}
        title={getDisplayValue("TAG302")}
      >
        <ConfTechCalendar
          autoCalculateEndDate={tech_autoCalculateEndDate}
          autoSyncServiceDuration={tech_autoSyncServiceDuration}
          condition={tech_condition}
          dataTipOnClick={tech_dataTipOnClick}
          eventRowColor={tech_eventRowColor}
          noOfDays={tech_noOfDays}
          refreshEventsOnChange={tech_refreshEventsOnChange}
          retainDateOnShowRoute={tech_retainDateOnShowRoute}
          showTimeIndicator={tech_showTimeIndicator}
          timeIndicatorColor={tech_timeIndicatorColor}
          toolTipHideDelay={tech_toolTipHideDelay}
          toolTipShowDelay={tech_toolTipShowDelay}
          onValueChange={this.handleValueChange}
        />
      </Tab>
    );
    tabIndex += 1;

    children.push(
      <Tab
        className="ConfTechView__tab"
        eventKey="4"
        title={getDisplayValue(TAG429)}
      >
        <ColorRules
          deleteConfirmation={deleteConfirmation}
          formRef={formRef}
          getDeleteRef={getDeleteRef}
          colorRules={tech_techRules}
          sourceItems={eveSourceItems}
          ruleType="Event Rule"
          onConfigurationChange={this.handleConfigurationChange}
          onSubmitSuccess={onSubmitSuccess}
          onCustomValidationError={onCustomValidationError}
        />
      </Tab>
    );
    tabIndex += 1;

    children.push(
      <Tab
        className="ConfTechView__tab"
        eventKey="5"
        title={getDisplayValue(TAG500)}
      >
        <ConfTechEventColors
          defaultEventColor={tech_defaultEventColor}
          defaultWOEventColor={tech_defaultWOEventColor}
          driveColor={tech_driveColor}
          holidayHoursColor={tech_holidayHoursColor}
          overheadColor={tech_overheadColor}
          overNightStayColor={tech_overNightStayColor}
          relatedEventColor={tech_relatedEventColor}
          workingHoursColor={tech_workingHoursColor}
          onValueChange={this.handleValueChange}
        />
      </Tab>
    );
    return children;
  };

  render() {
    return (
      <Tabs type="scoped" activeKey="1">
        {this.getTechConfigTabs()}
      </Tabs>
    );
  }
}

export default ConfTechView;
