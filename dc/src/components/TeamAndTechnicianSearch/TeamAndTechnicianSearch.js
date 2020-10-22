import React from "react";
import { PropTypes } from "prop-types";
import { getDisplayValue } from "utils/DCUtils";
import { Tabs, Tab } from "@svmx/ui-components-lightning";
import { TAG092, TAG046, TAG050 } from "constants/DisplayTagConstants";
import WorkOrderSearch from "./WorkOrderSearch";
import TechnicianSearch from "./TechnicianSearch";
import TeamSearch from "./TeamSearch";
import "./TeamAndTechnicianSearch.scss";

const propTypes = {
  teamFields: PropTypes.arrayOf(PropTypes.object),
  teamKeyword: PropTypes.arrayOf(PropTypes.object),
  techFields: PropTypes.arrayOf(PropTypes.object),
  techKeyword: PropTypes.arrayOf(PropTypes.object),
  woFields: PropTypes.arrayOf(PropTypes.object),
  woSearchCol: PropTypes.arrayOf(PropTypes.object)
};

const defaultProps = {
  teamFields: [],
  teamKeyword: [],
  techFields: [],
  techKeyword: [],
  woFields: [],
  woSearchCol: []
};

const TeamAndTechnicianSearch = props => {
  const {
    onSearchFieldUpdate,
    teamFields,
    teamKeyword,
    techFields,
    techKeyword,
    teamMatchCriteria,
    techMatchCriteria,
    woFields,
    woSearchCol
  } = props;
  return (
    <Tabs type="scoped" activeKey="1">
      <Tab
        className="TeamAndTechnicianSearch__Tab"
        eventKey="1"
        title={getDisplayValue(TAG092)}
      >
        <WorkOrderSearch
          sourceItems={woFields}
          targetValues={woSearchCol}
          onSearchFieldUpdate={onSearchFieldUpdate}
        />
      </Tab>
      <Tab
        className="TeamAndTechnicianSearch__Tab"
        eventKey="2"
        title={getDisplayValue(TAG046)}
      >
        <TeamSearch
          sourceItems={teamFields}
          targetValues={teamKeyword}
          matchCriteria={teamMatchCriteria}
          onSearchFieldUpdate={onSearchFieldUpdate}
        />
      </Tab>
      <Tab
        className="TeamAndTechnicianSearch__Tab"
        eventKey="3"
        title={getDisplayValue(TAG050)}
      >
        <TechnicianSearch
          sourceItems={techFields}
          targetValues={techKeyword}
          matchCriteria={techMatchCriteria}
          onSearchFieldUpdate={onSearchFieldUpdate}
        />
      </Tab>
    </Tabs>
  );
};

TeamAndTechnicianSearch.propTypes = propTypes;
TeamAndTechnicianSearch.defaultProps = defaultProps;

export default TeamAndTechnicianSearch;
