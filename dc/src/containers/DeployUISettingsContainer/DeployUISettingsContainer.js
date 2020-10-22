import React from "react";
import { Tabs, Tab } from "@svmx/ui-components-lightning";
import { TAG445, DCON001_TAG313 } from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";

import DeployUISettingsSettings from "components/DeployUISettingsSettings";
import DeployUISettingsDeployTo from "components/DeployUISettingsDeployTo";

function DeployUISettingsContainer(props) {
  return (
    <Tabs type="scoped" activeKey="1">
      <Tab
        className="DeployUISettingsContainer__Tab"
        eventKey="1"
        title={getDisplayValue(TAG445)}
      >
        <DeployUISettingsDeployTo {...props} />
      </Tab>
      <Tab
        className="DeployUISettingsContainer__Tab"
        eventKey="2"
        title={getDisplayValue(DCON001_TAG313)}
      >
        <DeployUISettingsSettings {...props} />
      </Tab>
    </Tabs>
  );
}

export default DeployUISettingsContainer;
