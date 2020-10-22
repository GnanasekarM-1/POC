import React from "react";
import PropTypes from "prop-types";
import { Tabs, Tab } from "@svmx/ui-components-lightning";
import {
  TAG391,
  TAG393,
  TAG405,
  TAG454,
  TAG404
} from "constants/DisplayTagConstants";
import {
  OMAX003_SET042,
  OMAX003_SET043,
  OMAX003_SET044,
  OMAX003_SET047,
  getSettingValue
} from "constants/AppSettings";
import { getDisplayValue } from "utils/DCUtils";
import TechSkillTab from "./TechSkillTab";
import TechProdExpTab from "./TechProdExpTab";
import TechEligibilityTab from "./TechEligibilityTab";
import TechConstraintTab from "./TechConstraintTab";
import TechWOSummaryTab from "./TechWOSummaryTab";

import "./AdvancedSearch.scss";

const AdvSearchContainer = props => {
  const {
    atsEligibility,
    atsExpertise,
    atsPrefTech,
    atsSkills,
    technicians,
    techSkills,
    selectedWO,
    techFields,
    updateATSState,
    userTimezone,
    view,
    woCol,
    woFields,
    woFieldList,
    woMatchSkills
  } = props;
  const { data } = woMatchSkills;
  const {
    productExpertise,
    lstskill,
    lstEligibility,
    lstCandidatePrefTechId
  } = data;
  const showSkillsTab = JSON.parse(getSettingValue(OMAX003_SET047, 0));
  const showProductTab = JSON.parse(getSettingValue(OMAX003_SET043, 0));
  const showEligibitityTab = JSON.parse(getSettingValue(OMAX003_SET042, 0));
  const showConstraintsTab = JSON.parse(getSettingValue(OMAX003_SET044, 0));

  const getDisplayableTabs = () => {
    let tabIndex = 1;
    const children = [];
    if (showSkillsTab) {
      children.push(
        <Tab
          className="AdvancedSearch__Tab"
          eventKey={`${tabIndex}`}
          title={getDisplayValue(TAG391)}
        >
          <TechSkillTab
            techSkills={techSkills}
            lstskill={lstskill}
            atsSkills={atsSkills}
            updateATSState={updateATSState}
          />
        </Tab>
      );
      tabIndex += 1;
    }
    if (showProductTab) {
      children.push(
        <Tab
          className="AdvancedSearch__Tab"
          eventKey={`${tabIndex}`}
          title={getDisplayValue(TAG393)}
        >
          <TechProdExpTab
            productExpertise={productExpertise}
            selectedWO={selectedWO}
            atsExpertise={atsExpertise}
            updateATSState={updateATSState}
          />
        </Tab>
      );
      tabIndex += 1;
    }
    if (showEligibitityTab) {
      children.push(
        <Tab
          className="AdvancedSearch__Tab"
          eventKey={`${tabIndex}`}
          title={getDisplayValue(TAG405)}
        >
          <TechEligibilityTab
            techFields={techFields}
            woFields={woFieldList}
            lstEligibility={lstEligibility}
            atsEligibility={atsEligibility}
            updateATSState={updateATSState}
          />
        </Tab>
      );
      tabIndex += 1;
    }
    if (showConstraintsTab) {
      children.push(
        <Tab
          className="AdvancedSearch__Tab"
          eventKey={`${tabIndex}`}
          title={getDisplayValue(TAG454)}
        >
          <TechConstraintTab
            lstCandidatePrefTechId={lstCandidatePrefTechId}
            technicians={technicians}
            atsPrefTech={atsPrefTech}
            updateATSState={updateATSState}
          />
        </Tab>
      );
      tabIndex += 1;
    }
    children.push(
      <Tab
        className="AdvancedSearch__Tab"
        eventKey={`${tabIndex}`}
        title={getDisplayValue(TAG404)}
      >
        <TechWOSummaryTab
          selectedWO={selectedWO}
          woFields={woFields}
          userTimezone={userTimezone}
          view={view}
          woCol={woCol}
        />
      </Tab>
    );
    return children;
  };

  return (
    <Tabs type="scoped" activeKey="1">
      {getDisplayableTabs()}
    </Tabs>
  );
};

AdvSearchContainer.propTypes = {
  atsEligibility: PropTypes.shape({}).isRequired,
  atsExpertise: PropTypes.shape({}).isRequired,
  atsPrefTech: PropTypes.shape({}).isRequired,
  atsSkills: PropTypes.shape({}).isRequired,
  selectedWO: PropTypes.shape({}).isRequired,
  techFields: PropTypes.arrayOf(PropTypes.Object).isRequired,
  technicians: PropTypes.arrayOf(PropTypes.Object).isRequired,
  techSkills: PropTypes.arrayOf(PropTypes.Object).isRequired,
  updateATSState: PropTypes.func.isRequired,
  userTimezone: PropTypes.shape({}).isRequired,
  view: PropTypes.shape({}).isRequired,
  woCol: PropTypes.arrayOf(PropTypes.Object).isRequired,
  woFieldList: PropTypes.arrayOf(PropTypes.Object).isRequired,
  woFields: PropTypes.arrayOf(PropTypes.Object).isRequired,
  woMatchSkills: PropTypes.shape({}).isRequired
};

export default AdvSearchContainer;
