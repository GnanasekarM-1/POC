import React, { Component } from "react";
import PropTypes from "prop-types";
import {
  Tabs,
  Tab,
  Grid,
  GridRow,
  GridItem,
  Container
} from "@svmx/ui-components-lightning";
import { TAG186, TAG187 } from "constants/DisplayTagConstants";
import { TEAM_API_NAME, TERRITORY_API_NAME } from "constants/AppConstants";

import { getDisplayValue, getFieldValue } from "utils/DCUtils";
import TeamTreeView from "components/MultiAssign/TreeView/Team/TeamTreeView";
import TerritoryTreeView from "components/MultiAssign/TreeView/Territory/TerritoryTreeView";
import EditEvent from "components/EditEvent";

class EditEventContainer extends Component {
  state = {
    technicianObject: {}
  };

  render() {
    const {
      eventData,
      teamIds,
      technicians,
      territoryList,
      onTechSelection,
      isResizeEvent,
      editEventResourceRecord
    } = this.props;
    const { resource } = eventData;
    const { data } = resource;
    const { Id } = data;
    const { Id: ReAssignTechId, data: ReAssignData } = editEventResourceRecord;
    let TechId = Id;
    let teamId = getFieldValue(data, TEAM_API_NAME);
    let territoryId = getFieldValue(data, TERRITORY_API_NAME);
    if (isResizeEvent) {
      teamId = getFieldValue(ReAssignData, TEAM_API_NAME);
      territoryId = getFieldValue(ReAssignData, TERRITORY_API_NAME);
      TechId = ReAssignTechId;
    }
    const { technicianObject } = this.state;
    return (
      <Grid>
        <GridRow cols={4}>
          <GridItem cols={1}>
            <Container>
              <Tabs type="scoped" activeKey="1">
                <Tab
                  className="EditEventContainer__Tab"
                  eventKey="1"
                  title={getDisplayValue(TAG186)}
                >
                  <TeamTreeView
                    leafSelectionOnly
                    teamIds={teamIds}
                    technicians={technicians}
                    onSelection={onTechSelection}
                    onSelectedValues={[TechId]}
                    onExpandedValues={teamId ? [teamId] : []}
                  />
                </Tab>
                <Tab
                  className="EditEventContainer__Tab"
                  eventKey="2"
                  title={getDisplayValue(TAG187)}
                >
                  <TerritoryTreeView
                    leafSelectionOnly
                    territoryList={territoryList}
                    technicians={technicians}
                    onSelection={onTechSelection}
                    onSelectedValues={[TechId]}
                    onExpandedValues={territoryId ? [territoryId] : []}
                  />
                </Tab>
              </Tabs>
            </Container>
          </GridItem>
          <GridItem cols={3}>
            <EditEvent {...this.props} technicianObject={technicianObject} />
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

EditEventContainer.propTypes = {
  teamIds: PropTypes.arrayOf(String).isRequired,
  technicians: PropTypes.arrayOf(PropTypes.object).isRequired
};

export default EditEventContainer;
