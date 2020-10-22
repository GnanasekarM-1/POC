import React, { Component } from "react";
import {
  OrderingPicklist,
  Grid,
  GridRow,
  GridItem
} from "@svmx/ui-components-lightning";
import { PropTypes } from "prop-types";
import { cloneDeep, groupBy, orderBy } from "lodash";
import {
  NAME,
  TERRITORY_PARENT,
  TEAM_API_REF,
  TERRITORY_API_REF
} from "constants/AppConstants";
import { getDisplayValue } from "utils/DCUtils";

const propTypes = {
  onValueChange: PropTypes.func,
  teamSeq: PropTypes.arrayOf(PropTypes.string),
  territorySeq: PropTypes.arrayOf(PropTypes.string),
  userData: PropTypes.objectOf(PropTypes.object)
};

const defaultProps = {
  onValueChange: () => {},
  teamSeq: [],
  territorySeq: [],
  userData: {}
};

class ConfTechTeam extends Component {
  constructor(props) {
    super(props);
    const { teamSeq, territorySeq, userData } = props;
    const { data } = userData;
    const { teamList = [], territoryList = [] } = data;
    this.state = {
      teamList,
      teamOrder: this.getSeqTeamTerritories(teamList, teamSeq),
      territoryList,
      territoryOrder: this.getSeqTeamTerritories(
        territoryList.filter(territory => !territory[TERRITORY_PARENT]),
        territorySeq
      )
    };
  }

  getSeqTeamTerritories = (list = [], sequence = []) => {
    const orderedList = [];
    const objectGrp = groupBy(
      orderBy(cloneDeep(list), [NAME]),
      team => team.Id
    );
    if (sequence && sequence.length) {
      sequence.map(seq => {
        const seqObj = objectGrp[seq];
        if (seqObj) {
          orderedList.push(seq);
          delete objectGrp[seq];
        }
      });
      return orderedList.concat(Object.keys(objectGrp));
    }
    return Object.keys(objectGrp);
  };

  render() {
    const { teamOrder, teamList, territoryOrder, territoryList } = this.state;

    const onTeamOrderChange = values => {
      const { onValueChange } = this.props;
      const { orderedValues: itemOrder } = values;
      this.setState({ teamOrder: itemOrder });
      onValueChange(itemOrder, "tech_teamSequence");
    };

    const onTerritoryOrderChange = values => {
      const { onValueChange } = this.props;
      const { orderedValues: itemOrder } = values;
      this.setState({ territoryOrder: itemOrder });
      onValueChange(itemOrder, "tech_territorySequence");
    };

    return (
      <Grid>
        <GridRow>
          <GridItem noFlex>
            <OrderingPicklist
              items={teamList}
              listLabel={getDisplayValue("TAG343")}
              menuSize="large"
              itemDisplayKey="Name"
              itemValueKey="Id"
              onOrderedValuesChange={onTeamOrderChange}
              orderedValues={teamOrder}
              selectMode="single"
              size="large"
            />
          </GridItem>
          <GridItem>
            <OrderingPicklist
              items={territoryList}
              listLabel={getDisplayValue("TAG344")}
              menuSize="large"
              itemDisplayKey="Name"
              itemValueKey="Id"
              onOrderedValuesChange={onTerritoryOrderChange}
              orderedValues={territoryOrder}
              selectMode="single"
              size="large"
            />
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

ConfTechTeam.propTypes = propTypes;
ConfTechTeam.defaultProps = defaultProps;

export default ConfTechTeam;
