import React, { Component } from "react";
import { PropTypes } from "prop-types";
import {
  Grid,
  GridItem,
  GridRow,
  Label,
  PicklistFactory,
  DuelingPicklist
} from "@svmx/ui-components-lightning";
import { TAG307, TAG308, TAG046, TAG315 } from "constants/DisplayTagConstants";
import {
  DEFAULT_SORT_ORDER,
  DESC_SORT_ORDER,
  NAME1
} from "constants/AppConstants";
import { getDisplayValue } from "utils/DCUtils";
import { orderBy } from "lodash";
import "./DeployUISettingsDeployTo.scss";

const propTypes = {
  dispatcherList: PropTypes.arrayOf(PropTypes.shape({})),
  handleDispatcherSelection: PropTypes.func,
  teamList: PropTypes.arrayOf(PropTypes.shape({}))
};
const defaultProps = {
  dispatcherList: [],
  handleDispatcherSelection: null,
  teamList: []
};

class DeployUISettingsDeployTo extends Component {
  constructor(props) {
    super(props);
    const { dispatcherList } = props;
    this.state = {
      filteredDispatcher: dispatcherList,
      selectedDispatcher: [],
      selectedTeam: ["all"]
    };
  }

  handleTargetChange = ({ selectedValues, value }) => {
    const filteredDispatcher = this.filterDispatcherList(value);
    this.setState({
      filteredDispatcher,
      selectedTeam: selectedValues,
      selectedDispatcher: []
    });
  };

  filterDispatcherList = teamId => {
    const { dispatcherList, teamList } = this.props;
    let filteredDispatcher = [];
    if (teamId === "all") {
      filteredDispatcher = dispatcherList;
    } else {
      const team = teamList.find(item => item.id === teamId);
      const { valueList } = team;
      filteredDispatcher = dispatcherList.filter(itemX =>
        valueList.includes(itemX.id)
      );
    }

    return filteredDispatcher;
  };

  handleTargetValuesChange = ({ targetValues }) => {
    const { handleDispatcherSelection } = this.props;
    handleDispatcherSelection(targetValues);
    this.setState({ selectedDispatcher: targetValues });
  };

  render() {
    const { teamList } = this.props;
    const { filteredDispatcher } = this.state;
    const sortedDispatchers = filteredDispatcher.sort((prev, next) =>
      prev.name !== next.name ? (prev.name < next.name ? -1 : 1) : 0
    );
    const orderedTeamList = orderBy(teamList, [NAME1], [DEFAULT_SORT_ORDER]);
    const sourceTeams = [{ id: "all", name: "All" }].concat(orderedTeamList);
    const { selectedTeam, selectedDispatcher } = this.state;
    return (
      <Grid>
        <GridRow>
          <GridItem className="DeployUISettingsDeployTo_team" noFlex>
            <Label>
              {`${getDisplayValue(TAG046)} / ${getDisplayValue(TAG315)}`}
            </Label>
            <PicklistFactory
              items={sourceTeams}
              name="teamandterritory"
              onSelectedChange={this.handleTargetChange}
              selectedValues={selectedTeam}
              itemValueKey="id"
              itemDisplayKey="name"
            />
            <DuelingPicklist
              className=""
              allowOrdering={false}
              selectMode="multi"
              sourceItems={sortedDispatchers}
              sourceLabel={getDisplayValue(TAG307)}
              targetLabel={getDisplayValue(TAG308)}
              onTargetValuesChange={this.handleTargetValuesChange}
              targetValues={selectedDispatcher}
              itemValueKey="id"
              itemDisplayKey="name"
            />
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

DeployUISettingsDeployTo.defaultProps = defaultProps;
DeployUISettingsDeployTo.propTypes = propTypes;
export default DeployUISettingsDeployTo;
