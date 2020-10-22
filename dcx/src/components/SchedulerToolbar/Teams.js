import React, { Component } from "react";
import { PropTypes } from "prop-types";
import {
  GridRow,
  GridItem,
  PicklistFactory
} from "@svmx/ui-components-lightning";
import { getDisplayValue } from "utils/DCUtils";
import { TEAM_INDEX, TERRITORY_INDEX } from "constants/AppConstants";
import "./SchedulerToolbar.scss";

const propTypes = {
  allTeams: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string
  }),
  handleViewchange: PropTypes.func.isRequired,
  selectedTeam: PropTypes.arrayOf(PropTypes.number)
};
const defaultProps = {
  allTeams: [
    { id: TEAM_INDEX, name: "Service Team View" },
    { id: TERRITORY_INDEX, name: "Territory View" }
  ],
  selectedTeam: [TEAM_INDEX]
};

class Teams extends Component {
  constructor(props) {
    super(props);
    const { selectedTeam } = props;
    this.state = {
      selectedTeam
    };
  }

  onSelectedChange = ({ selectedValues }) => {
    const { handleViewchange } = this.props;

    this.setState({ selectedTeam: selectedValues });
    handleViewchange(selectedValues[0]);
  };

  render() {
    const allTeams = [
      { id: TEAM_INDEX, name: getDisplayValue("TAG186", "Service Team View") },
      { id: TERRITORY_INDEX, name: getDisplayValue("TAG187", "Territory View") }
    ];
    const { selectedTeam } = this.state;
    return (
      <GridItem className="SchedulerToolbar__team">
        <GridRow>
          <GridItem>
            <PicklistFactory
              items={allTeams}
              name="picklist-single"
              onSelectedChange={this.onSelectedChange}
              selectedValues={selectedTeam}
              itemValueKey="id"
              itemDisplayKey="name"
            />
          </GridItem>
        </GridRow>
      </GridItem>
    );
  }
}
Teams.propTypes = propTypes;
Teams.defaultProps = defaultProps;

export default Teams;
