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
import { getSettingValue, GLOB001_GBL025 } from "constants/AppSettings";
import {
  SALESFORCE_EVENT,
  TECH_SALESFORCE_USER_FIELD
} from "constants/AppConstants";
import { getDisplayValue, getFieldValue } from "utils/DCUtils";
import TeamTreeView from "components/MultiAssign/TreeView/Team/TeamTreeView";
import TerritoryTreeView from "components/MultiAssign/TreeView/Territory/TerritoryTreeView";
import NonWoEventCreate from "components/NonWoEventCreate";
import { isSchedulingEnabled } from "utils/SchedulerUtils";

const FORM_NAME = "non-wo-create-event";
class NonWoEventCreateContainer extends Component {
  state = {
    technicianObject: {}
  };

  componentDidMount() {
    // this.onTechExpanAndSelect();
    const {
      technicianObject,
      onHandleModalFieldCheck,
      chageFormField
    } = this.props;
    this.handleTechnicianInForm(
      technicianObject,
      onHandleModalFieldCheck,
      chageFormField
    );
    this.setTitleTextForTabs();
  }

  setTitleTextForTabs = () => {
    document
      .querySelectorAll(".NonWoCreateEventModal__Content .Tabs .Tab__item a")
      .forEach(element => {
        element.title = element.innerText;
      });
  };

  handleTechnicianInForm = (
    technicianObject,
    onHandleModalFieldCheck,
    chageFormField
  ) => {
    if (isSchedulingEnabled(technicianObject)) {
      // this.setState({ technicianObject: data });
      const { Name, Id } = technicianObject;
      const isSaleforceEvent =
        getSettingValue(GLOB001_GBL025) === SALESFORCE_EVENT;
      this.OwnerId = Id;
      if (isSaleforceEvent && technicianObject) {
        this.OwnerId = technicianObject[TECH_SALESFORCE_USER_FIELD]
          ? technicianObject[TECH_SALESFORCE_USER_FIELD]
          : Id;
      }
      chageFormField(FORM_NAME, "technicianname", Name);
      chageFormField(FORM_NAME, "techId", Id);
      chageFormField(FORM_NAME, "OwnerId", this.OwnerId);
      //onHandleModalFieldCheck('');
    } else {
      // this.setState({ technicianObject: [] });
      chageFormField(FORM_NAME, "technicianname", getDisplayValue("TAG041"));
      if (technicianObject.Id) {
        onHandleModalFieldCheck(getDisplayValue("TAG199"));
      }
    }
  };

  onTechSelection = data => {
    const { onHandleModalFieldCheck, chageFormField } = this.props;
    if (data && data.length === 1) {
      const [technicianObject] = data;
      this.handleTechnicianInForm(
        technicianObject,
        onHandleModalFieldCheck,
        chageFormField
      );
    }
  };

  render() {
    const {
      teamIds,
      technicians,
      territoryList,
      technicianObject,
      selectedIndex,
      techSelectedvalues,
      teamExpandValues
    } = this.props;
    // const { technicianObject } = this.state;
    return (
      <Grid>
        <GridRow cols={6}>
          <GridItem cols={2}>
            <Container>
              <Tabs type="scoped" activeKey={`${selectedIndex + 1}`}>
                <Tab
                  className="NonWoEventCreateContainer__Tab"
                  eventKey="1"
                  title={getDisplayValue(TAG186)}
                >
                  <TeamTreeView
                    leafSelectionOnly
                    teamIds={teamIds}
                    technicians={technicians}
                    onSelection={this.onTechSelection}
                    onSelectedValues={techSelectedvalues}
                    onExpandedValues={teamExpandValues}
                  />
                </Tab>
                <Tab
                  className="NonWoEventCreateContainer__Tab"
                  eventKey="2"
                  title={getDisplayValue(TAG187)}
                >
                  <TerritoryTreeView
                    leafSelectionOnly
                    territoryList={territoryList}
                    technicians={technicians}
                    onSelection={this.onTechSelection}
                  />
                </Tab>
              </Tabs>
            </Container>
          </GridItem>
          <GridItem cols={4}>
            <NonWoEventCreate
              {...this.props}
              technicianObject={technicianObject}
            />
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

NonWoEventCreateContainer.propTypes = {
  teamIds: PropTypes.arrayOf(String).isRequired,
  technicians: PropTypes.arrayOf(PropTypes.object).isRequired
};

export default NonWoEventCreateContainer;
