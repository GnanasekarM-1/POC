import React, { Component } from "react";
import { ResizableLayout } from "@svmx/ui-components-lightning";
import FooterContainer from "containers/FooterContainer";
import GridContainer from "containers/GridContainer";
import HeaderContainer from "containers/HeaderContainer";
import MapContainer from "containers/MapContainer";
import MapWindowPortal from "components/MapComponents/MapWindowPortal";
import SchedulerContainer from "containers/SchedulerContainer";
import {
  MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN,
  MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN_HIDE,
  MAP_CUSTOM_EVENT_CLOSE_CHILD_WINDOW,
  MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN_SETVALUE
} from "constants/MapConstants";
import { getUserSetting, stringToBoolean } from "utils/DCUtils";
import { MAP_CONFIG } from "constants/AppConstants";
import { DCON001_SET071, getSettingValue } from "constants/AppSettings";
import NewWindowPortal from "components/MapComponents/MapWindowPortal/NewWindowPortal";

class ResizableLayoutControlled extends Component {
  constructor(props) {
    super(props);
    const mapAllowedBySetting =
      getSettingValue(DCON001_SET071).toLowerCase() === "true";
    const mapSettings = stringToBoolean(getUserSetting(MAP_CONFIG));
    this.state = {
      shouldShowFullScreen: mapAllowedBySetting ? !mapSettings : true,
      shouldShowWindowPortal: false,
      currentWindow: window
    };
    window.addEventListener(
      MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN,
      this.handleToggleFullscreen,
      false
    );
    window.addEventListener(
      MAP_CUSTOM_EVENT_CLOSE_CHILD_WINDOW,
      this.handleChildWindowClose,
      false
    );
  }

  componentDidMount() {
    const woId = this.isSingleWOLaunch() || "MULTI";
    localStorage.setItem("DCHTML", woId);
  }

  isSingleWOLaunch = () => {
    const queryParams = {};
    window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, (m, key, value) => {
      queryParams[key] = value;
    });
    const { wid } = queryParams;
    return wid;
  };

  handleChildWindowClose = () => {
    const { shouldShowFullScreen, shouldShowWindowPortal } = this.state;
    const eventSetValue = new CustomEvent(
      MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN_SETVALUE,
      {
        detail: true
      }
    );
    window.dispatchEvent(eventSetValue);
    this.setState({
      shouldShowFullScreen: !shouldShowFullScreen,
      shouldShowWindowPortal: !shouldShowWindowPortal,
      currentWindow: window
    });
    const event = new CustomEvent(MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN_HIDE, {
      detail: true
    });
    window.dispatchEvent(event);
  };

  handleToggleFullscreen = e => {
    const { detail } = e;
    const { name } = detail;
    const { shouldShowFullScreen, shouldShowWindowPortal } = this.state;
    this.setState({
      shouldShowFullScreen: !shouldShowFullScreen,
      shouldShowWindowPortal:
        name === "MapSettings"
          ? shouldShowWindowPortal
          : !shouldShowWindowPortal
    });
  };

  handleNewPortalWindowLoad = e => {
    if (e) {
      this.setState({
        currentWindow: e
      });
    }
  };

  render() {
    const style = {
      height: "100vh",
      maxHeight: "100vh"
    };
    const {
      currentWindow,
      shouldShowFullScreen,
      shouldShowWindowPortal
    } = this.state;
    return (
      <div>
        <ResizableLayout
          className="ResizableLayoutControlled_container"
          alert={FooterContainer}
          header={HeaderContainer}
          isFullScreen={shouldShowFullScreen}
          layout={{
            // footer: 0.1,
            grid: 0.5,
            // header: 0.1,
            map: 0.3,
            scheduler: 0.5
          }}
          grid={GridContainer}
          map={MapContainer}
          minPaneSizes={{
            grid: 100,
            main: 1000,
            map: 60,
            scheduler: 100
          }}
          rememberLayout
          scheduler={SchedulerContainer}
          style={style}
        />
        {shouldShowWindowPortal && (
          <NewWindowPortal
            parentWindow={currentWindow}
            onOpen={this.handleNewPortalWindowLoad}
            onUnload={this.handleChildWindowClose}
          >
            <MapContainer
              currentWindow={currentWindow}
              shouldShowPortalWindowButton={false}
            />
          </NewWindowPortal>
        )}
      </div>
    );
  }
}

export default ResizableLayoutControlled;
