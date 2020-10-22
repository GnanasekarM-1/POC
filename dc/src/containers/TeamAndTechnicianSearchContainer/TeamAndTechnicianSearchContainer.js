import React, { Component } from "react";
import { connect } from "react-redux";
import { compact, orderBy } from "lodash";
import { getDisplayValue } from "utils/DCUtils";
import { DISPLAY } from "constants/AppConstants";
import { TECH_SEARCH_CHANGED } from "constants/ActionConstants";
import { schedulerStateChanged } from "actions/SchedulerAction";
import TeamAndTechnicianSearch from "components/TeamAndTechnicianSearch";

const mapStateToProps = ({ metaData, userSettings }) => {
  const { serviceTeamFields, technicianFields, workOrderFields } = metaData;
  const {
    search_keyword: keyword,
    search_teamKeyword: teamKeyword,
    search_techKeyword: techKeyword
  } = userSettings;

  const { col: woSearchCol = [] } = keyword || {};
  const { col: teamSearchCol = [], matchcriteria: teamMatchCriteria = "any" } =
    teamKeyword || {};
  const { col: techSearchCol = [], matchcriteria: techMatchCriteria = "all" } =
    techKeyword || {};
  const { content: woContent } = workOrderFields;
  let { content: teamContent } = serviceTeamFields;
  let { content: techContent } = technicianFields;

  // Manually adding these 3 fields to team and technician fields since the response doesn't have it
  const staticFieldObj = {
    EXPERTISE: { display: getDisplayValue("TAG322"), value: "EXPERTISE" },
    PRODUCT: { display: getDisplayValue("TAG323"), value: "PRODUCT" },
    TERRITORY: { display: getDisplayValue("TAG321"), value: "TERRITORY" }
  };

  teamContent = Object.assign({}, teamContent, staticFieldObj);
  techContent = Object.assign({}, techContent, staticFieldObj);

  const techFields = orderBy(Object.values(techContent), [DISPLAY]);
  const woFields = orderBy(Object.values(woContent), [DISPLAY]);
  const teamFields = orderBy(Object.values(teamContent), [DISPLAY]);
  return {
    teamFields,
    teamKeyword: compact(
      teamSearchCol.map(col => {
        const { name } = col;
        return teamContent[name] ? name : undefined;
      })
    ),
    techFields,
    techKeyword: compact(
      techSearchCol.map(col => {
        const { name } = col;
        return techContent[name] ? name : undefined;
      })
    ),
    woFields,
    woSearchCol: compact(
      woSearchCol.map(col => {
        const { name } = col;
        return woContent[name] ? name : undefined;
      })
    ),
    teamMatchCriteria,
    techMatchCriteria
  };
};

const mapDispatchToProps = dispatch => ({
  techSearchChanged: updatedTechSearch =>
    dispatch(
      schedulerStateChanged({ ...updatedTechSearch }, TECH_SEARCH_CHANGED)
    )
});

class TeamAndTechnicianSearchContainer extends Component {
  state = { updatedSetting: {} };

  componentDidMount = () => {
    const { setCallable } = this.props;
    setCallable(this.saveChanges);
  };

  handleUpdatedSearchFields = (fields, type) => {
    const { updatedSetting } = this.state;
    switch (type) {
      case "wo":
        updatedSetting.search_keyword = {};
        updatedSetting.search_keyword.col = fields;
        updatedSetting.search_keyword.matchcriteria = "";
        break;
      case "tech": {
        const { col, matchCriteria } = fields;
        updatedSetting.search_techKeyword = {};
        updatedSetting.search_techKeyword.col = col;
        updatedSetting.search_techKeyword.matchcriteria = matchCriteria;
        break;
      }
      case "team": {
        const { col, matchCriteria } = fields;
        updatedSetting.search_teamKeyword = {};
        updatedSetting.search_teamKeyword.col = col;
        updatedSetting.search_teamKeyword.matchcriteria = matchCriteria;
        break;
      }

      default:
        break;
    }
    this.setState({ updatedSetting });
  };

  saveChanges = () => {
    const { techSearchChanged } = this.props;
    const { updatedSetting } = this.state;
    techSearchChanged(updatedSetting);
  };

  render() {
    return (
      <TeamAndTechnicianSearch
        onSearchFieldUpdate={this.handleUpdatedSearchFields}
        {...this.props}
      />
    );
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(TeamAndTechnicianSearchContainer);
