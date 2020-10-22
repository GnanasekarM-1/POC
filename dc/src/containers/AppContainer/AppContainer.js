import React, { Component } from "react";
import Dashboard from "components/Dashboard";

import DataLoaderContainer from "containers/DataLoaderContainer";
import ApplicationError from "components/ErrorBoundry/ApplicationError";

class AppContainer extends Component {
  state = {
    error: false,
    info: null,
    loadComplete: false
  };

  componentWillUnmount() {
    localStorage.removeItem("DCHTML");
    localStorage.removeItem("DCHTML_ACTIVE");
    clearInterval(window.dcxRefreshInterval);
  }

  componentDidCatch(error, info) {
    localStorage.removeItem("DCHTML");
    localStorage.removeItem("DCHTML_ACTIVE");
    this.setState({
      error,
      info
    });
    const { enableUsageStats = "Disallow" } = window.configData || {};
    const trackUsageStats = enableUsageStats === "Allow";
    if (
      process.env.NODE_ENV !== "development" &&
      trackUsageStats &&
      window.newrelic
    ) {
      window.newrelic.noticeError(error);
    }
    clearInterval(window.dcxRefreshInterval);
  }

  onLoadComplete = () => {
    this.setState({
      loadComplete: true
    });
  };

  render() {
    const { error, info, loadComplete } = this.state;
    return error ? (
      <ApplicationError error={error} info={info} />
    ) : loadComplete ? (
      <Dashboard />
    ) : (
      <DataLoaderContainer onLoadComplete={this.onLoadComplete} />
    );
  }
}

export default AppContainer;
