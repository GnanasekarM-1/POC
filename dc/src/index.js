import React from "react";
import ReactDOM from "react-dom";
import { Provider } from "react-redux";

import store from "store";
import AppContainer from "containers/AppContainer";

import { sagaMiddleware } from "middleware";
import rootSaga from "sagas";

import "@svmx/ui-components-lightning/lib/package.scss";
import "./theme/index.scss";

sagaMiddleware.run(rootSaga);

(() => {
  const { enableUsageStats = "Disallow" } = window.configData || {};
  const trackUsageStats = enableUsageStats === "Allow";
  if (process.env.NODE_ENV !== "development" && trackUsageStats) {
    if (window.NREUM && window.newrelic) {
      const NRUsageManager = window.NREUM;
      const newRelicBrowserAPI = window.newrelic;

      NRUsageManager.info = {
        applicationID: "511994582",
        licenseKey: "eaf13636d6"
      };

      const {
        UserId,
        AppLaunch,
        Language,
        OrganizationId,
        OrganizationName,
        OrganizationTheme,
        OrganizationType,
        ServicemaxVersion
      } = window.configData || {};
      newRelicBrowserAPI.setCustomAttribute("UserId", UserId);
      newRelicBrowserAPI.setCustomAttribute("Language", Language);
      newRelicBrowserAPI.setCustomAttribute("AppLaunchType", AppLaunch);
      newRelicBrowserAPI.setCustomAttribute("ApplicationType", "Standard");
      newRelicBrowserAPI.setCustomAttribute("OrganizationId", OrganizationId);
      newRelicBrowserAPI.setCustomAttribute(
        "OrganizationId",
        OrganizationTheme
      );
      newRelicBrowserAPI.setCustomAttribute(
        "OrganizationName",
        OrganizationName
      );
      newRelicBrowserAPI.setCustomAttribute(
        "OrganizationType",
        OrganizationType
      );
      newRelicBrowserAPI.setCustomAttribute(
        "ServicemaxVersion",
        ServicemaxVersion
      );
    }
  }
})();

ReactDOM.render(
  <Provider store={store}>
    <AppContainer />
  </Provider>,
  document.getElementById("root")
);
