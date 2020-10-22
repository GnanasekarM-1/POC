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
import {
  TEAM_API_NAME,
  TERRITORY_API_NAME,
  SALESFORCE_EVENT,
  TECH_SALESFORCE_USER_FIELD,
  WO_DISPATCH_STATUS_FIELD
} from "constants/AppConstants";
import { getDisplayValue, getFieldValue } from "utils/DCUtils";
import TeamTreeView from "components/MultiAssign/TreeView/Team/TeamTreeView";
import TerritoryTreeView from "components/MultiAssign/TreeView/Territory/TerritoryTreeView";
import CreateEvent from "components/CreateEvent";
import EditEvent from "components/EditEvent";
import CreateEditEvent from "components/CreateEditEvent";

import { getSettingValue, GLOB001_GBL025 } from "constants/AppSettings";

const FORM_NAME = "create-event-form-field";
class CreateEditEventContainer extends Component {
  state = {
    technicianObject: {}
  };

  componentDidMount() {
    this.setTitleTextForTabs();
  }

  setTitleTextForTabs = () => {
    let contentId = "";
    if (document.querySelector(".CreateEventModal__Content")) {
      contentId = "CreateEventModal__Content";
    } else if (document.querySelector(".EditEventModal__Content")) {
      contentId = "EditEventModal__Content";
    }
    document
      .querySelectorAll("." + contentId + " .Tabs .Tab__item a")
      .forEach(element => {
        element.title = element.innerText;
      });
  };

  render() {
    const {
      onTechSelection,
      isResizeEvent,
      editEventResourceRecord,
      eventData,
      selectedIndex,
      teamIds,
      technicians,
      territoryList,
      isCreateEvent
    } = this.props;
    const { resource } = eventData;
    const { data } = resource;
    const { Id } = data;
    let teamId = getFieldValue(data, TEAM_API_NAME);
    let territoryId = getFieldValue(data, TERRITORY_API_NAME);
    const { technicianObject } = this.state;

    const { Id: ReAssignTechId, data: ReAssignData } = editEventResourceRecord;
    let TechId = Id;
    if (isResizeEvent) {
      teamId = getFieldValue(ReAssignData, TEAM_API_NAME);
      territoryId = getFieldValue(ReAssignData, TERRITORY_API_NAME);
      TechId = ReAssignTechId;
    }

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
            <CreateEditEvent
              {...this.props}
              technicianObject={technicianObject}
            />
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

CreateEditEventContainer.propTypes = {
  teamIds: PropTypes.arrayOf(String).isRequired,
  technicians: PropTypes.arrayOf(PropTypes.object).isRequired
};

export default CreateEditEventContainer;
