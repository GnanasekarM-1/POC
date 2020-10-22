import React, { Component } from "react";
import PropTypes from "prop-types";
import { Tabs, Tab, Toggle, Label } from "@svmx/ui-components-lightning";
import {
  TAG186,
  TAG187,
  TAG394,
  TAG395,
  DCON001_TAG522
} from "constants/DisplayTagConstants";
import { flatMap, orderBy } from "lodash";
import { getDisplayValue } from "utils/DCUtils";
import FilterableTeamTree from "./Team/FilterableTeamTree";
import TeamTreeView from "components/MultiAssign/TreeView/Team/TeamTreeView";
import TerritoryTreeView from "components/MultiAssign/TreeView/Territory/TerritoryTreeView";
import "./TreeView.scss";

class TreeView extends Component {
  constructor(props) {
    super(props);
    const { snapshotTree } = this.props;
    this.state = {
      showSearch: snapshotTree
    };
  }

  componentDidMount() {
    this.setTitleTextForTabs();
  }

  setTitleTextForTabs = () => {
    document
      .querySelectorAll(".MultipleAssignmentModal__content .Tabs .Tab__item a")
      .forEach(element => {
        element.title = element.innerText;
      });
  };

  updateTreeState = ({ value }) => {
    this.setState({ showSearch: !value });
  };

  render() {
    const {
      teamIds,
      teamView,
      fullTeamView,
      technicians,
      territoryView,
      fullTerritoryView,
      territoryList,

      techFields,
      userSettings,

      isDisabled,
      leafSelectionOnly,
      selectedIndex = 0,

      onSelection,
      expandValues,
      selectedValues = [],
      expandedValues = [],
      snapshotTree,
      searchTechnicians
    } = this.props;

    const { showSearch } = this.state;

    return (
      <div className="TreeView">
        <Tabs type="scoped" activeKey={`${selectedIndex + 1}`}>
          <Tab
            className="TreeView__Tab"
            eventKey="1"
            isDisabled={isDisabled}
            title={getDisplayValue(TAG186)}
          >
            {showSearch && (
              <TeamTreeView
                teamIds={teamIds}
                teamView={teamView || fullTeamView}
                onSelection={onSelection}
                showSearchTree={showSearch}
                onSelectedValues={selectedValues}
                leafSelectionOnly={leafSelectionOnly}
                updateTreeState={this.updateTreeState}
                technicians={Object.values(technicians)}
                onExpandedValues={
                  expandValues
                    ? expandedValues.length
                      ? expandedValues
                      : flatMap(teamView, team => team.Id)
                    : []
                }
              />
            )}
            {!showSearch && (
              <FilterableTeamTree
                expandOnSearch
                teamView={fullTeamView}
                techFields={techFields}
                userSettings={userSettings}
                onSelection={onSelection}
                selectedIndex={selectedIndex}
                searchTechnicians={searchTechnicians}
              />
            )}
          </Tab>
          <Tab
            className="TreeView__Tab"
            eventKey="2"
            isDisabled={isDisabled}
            title={getDisplayValue(TAG187)}
          >
            {showSearch && (
              <TerritoryTreeView
                includeDescendants
                showSearchTree={showSearch}
                onSelection={onSelection}
                territoryView={territoryView || fullTerritoryView}
                territoryList={territoryList}
                technicians={Object.values(technicians)}
                onSelectedValues={selectedValues}
                onExpandedValues={
                  expandValues
                    ? expandedValues.length
                      ? expandedValues
                      : flatMap(territoryView, team => team.Id)
                    : []
                }
              />
            )}
            {!showSearch && (
              <FilterableTeamTree
                expandOnSearch
                techFields={techFields}
                userSettings={userSettings}
                onSelection={onSelection}
                selectedIndex={selectedIndex}
                territoryView={fullTerritoryView}
                searchTechnicians={searchTechnicians}
              />
            )}
          </Tab>
        </Tabs>
        {snapshotTree && (
          <div className="TeamView__Footer">
            <Label>
              <b>{getDisplayValue(DCON001_TAG522, "Show Full List")}</b>
            </Label>
            <Toggle
              hideLabel
              name={getDisplayValue(DCON001_TAG522, "Show Full List")}
              negativeLabel={getDisplayValue(TAG395)}
              positiveLabel={getDisplayValue(TAG394)}
              negativeValue={false}
              positiveValue
              value={!showSearch}
              onValueChange={event => this.updateTreeState(event)}
            />
          </div>
        )}
      </div>
    );
  }
}

TreeView.defaultProps = {
  isDisabled: false,
  expandValues: false,
  snapshotTree: false,
  showSearchTree: true,
  selectedValues: [],
  expandedValues: []
};

TreeView.propTypes = {
  expandValues: PropTypes.bool,
  snapshotTree: PropTypes.bool,
  showSearchTree: PropTypes.bool,

  selectedIndex: PropTypes.number,
  isDisabled: PropTypes.bool.isRequired,
  onSelection: PropTypes.func.isRequired,
  teamView: PropTypes.arrayOf(String).isRequired,
  teamIds: PropTypes.arrayOf(String).isRequired,
  technicians: PropTypes.shape({}).isRequired,
  territoryList: PropTypes.shape({}).isRequired,
  territoryView: PropTypes.arrayOf(String).isRequired,
  selectedValues: PropTypes.arrayOf(String),
  expandedValues: PropTypes.arrayOf(String)
};

export default TreeView;
