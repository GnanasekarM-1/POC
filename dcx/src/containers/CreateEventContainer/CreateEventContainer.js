import React, { Component } from "react";
import PropTypes from "prop-types";
import * as moment from "moment";
import {
  Tabs,
  Tab,
  Grid,
  GridRow,
  GridItem,
  Container
} from "@svmx/ui-components-lightning";
import { TAG186, TAG187 } from "constants/DisplayTagConstants";
import {
  TEAM_API_NAME,
  TERRITORY_API_NAME,
  SALESFORCE_EVENT,
  TECH_SALESFORCE_USER_FIELD,
  WO_DISPATCH_STATUS_FIELD
} from "constants/AppConstants";
import { getDisplayValue, getFieldValue, getFormValues } from "utils/DCUtils";
import TeamTreeView from "components/MultiAssign/TreeView/Team/TeamTreeView";
import TerritoryTreeView from "components/MultiAssign/TreeView/Territory/TerritoryTreeView";
import CreateEvent from "components/CreateEvent";
import { getSettingValue, GLOB001_GBL025 } from "constants/AppSettings";

const FORM_NAME = "create-event-form-field";
class CreateEventContainer extends Component {
  state = {
    technicianObject: {}
  };

  onTechSelection = technicianObject => {
    const { draggedWO } = this.props;
    const isSaleforceEvent =
      getSettingValue(GLOB001_GBL025) === SALESFORCE_EVENT;
    const { Name: technicianname, Id: techId } = technicianObject[0];
    let OwnerId = techId;
    if (
      isSaleforceEvent &&
      technicianObject &&
      technicianObject.length &&
      technicianObject[0][TECH_SALESFORCE_USER_FIELD]
    ) {
      OwnerId = technicianObject[0][TECH_SALESFORCE_USER_FIELD];
    }
    let techSFId = null;
    if (technicianObject[0][TECH_SALESFORCE_USER_FIELD]) {
      techSFId = technicianObject[0][TECH_SALESFORCE_USER_FIELD];
    }
    const { chageFormField } = this.props;
    // Need to check for single change call
    chageFormField(FORM_NAME, "technicianname", technicianname);
    chageFormField(FORM_NAME, "OwnerId", OwnerId);
    chageFormField(FORM_NAME, "techId", techId);
    chageFormField(FORM_NAME, "techSFId", techSFId);
    let isNewWO = false;
    if (draggedWO) {
      isNewWO = draggedWO[WO_DISPATCH_STATUS_FIELD] === "New";
    }
    chageFormField(FORM_NAME, "updateprimarytechnicians", isNewWO || null);
    chageFormField(
      FORM_NAME,
      "deleteeventforothertechnicians",
      isNewWO || null
    );
    this.handleEventBusinessHours();
  };

  handleEventBusinessHours = () => {
    const { onHandleEventBusinessHours } = this.props;
    const fieldValues = getFormValues(FORM_NAME);
    const { startdatetime, techId } = fieldValues;
    const startDateForEvent = moment(startdatetime.date).add(
      startdatetime,
      "minutes"
    );
    onHandleEventBusinessHours(startDateForEvent, techId);
  };

  render() {
    const {
      eventData,
      selectedIndex,
      teamIds,
      technicians,
      territoryList
    } = this.props;
    const { resource } = eventData;
    const { data } = resource;
    const { Id } = data;
    const teamId = getFieldValue(data, TEAM_API_NAME);
    const territoryId = getFieldValue(data, TERRITORY_API_NAME);
    const { technicianObject } = this.state;
    return (
      <Grid>
        <GridRow cols={4}>
          <GridItem cols={1}>
            <Container>
              <Tabs type="scoped" activeKey={`${selectedIndex + 1}`}>
                <Tab
                  className="EditEventContainer__Tab"
                  eventKey="1"
                  title={getDisplayValue(TAG186)}
                >
                  <TeamTreeView
                    leafSelectionOnly
                    teamIds={teamIds}
                    technicians={technicians}
                    onSelection={this.onTechSelection}
                    onSelectedValues={[Id]}
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
                    onSelection={this.onTechSelection}
                    onSelectedValues={[Id]}
                    onExpandedValues={territoryId ? [territoryId] : []}
                  />
                </Tab>
              </Tabs>
            </Container>
          </GridItem>
          <GridItem cols={3}>
            <CreateEvent {...this.props} technicianObject={technicianObject} />
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

CreateEventContainer.propTypes = {
  teamIds: PropTypes.arrayOf(String).isRequired,
  technicians: PropTypes.arrayOf(PropTypes.object).isRequired
};

export default CreateEventContainer;
