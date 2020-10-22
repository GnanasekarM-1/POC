import React, { Component } from "react";
import PropTypes from "prop-types";
import {
  Button,
  Icon,
  GridItem,
  GridRow,
  Label
} from "@svmx/ui-components-lightning";
import { CONFIGURE_TECH_VIEW, MAP_CONFIG } from "constants/AppConstants";
import {
  MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN,
  MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN_HIDE
} from "constants/MapConstants";
import {
  getDisplayValue,
  getUserSetting,
  stringToBoolean
} from "utils/DCUtils";
import { TAG015, TAG016, TAG093, TAG446 } from "constants/DisplayTagConstants";
import { DCON001_SET071, getSettingValue } from "constants/AppSettings";
import "./SchedulerToolbar.scss";

class SchedulerConfig extends Component {
  constructor(props) {
    super(props);
    const mapAllowedBySetting =
      getSettingValue(DCON001_SET071).toLowerCase() === "true";
    const mapSetting = stringToBoolean(getUserSetting(MAP_CONFIG), false);
    this.state = {
      showMapButton: mapAllowedBySetting,
      showMap: mapSetting
    };
  }

  componentDidMount() {
    const { onSchedulerTechConfiChildRef } = this.props;
    onSchedulerTechConfiChildRef(this);
    window.addEventListener(
      MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN,
      this.handleToggleFullscreen,
      false
    );
    window.addEventListener(
      MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN_HIDE,
      this.handleToggleFullscreen,
      false
    );
  }

  componentWillUnmount() {
    const { onSchedulerTechConfiChildRef } = this.props;
    onSchedulerTechConfiChildRef(undefined);
  }

  handleToggleFullscreen = e => {
    const { detail } = e;
    const { name } = detail;
    const { showMapButton } = this.state;
    this.setState({
      showMapButton: name === "MapSettings" ? showMapButton : !showMapButton
    });
  };

  handleMapSetting = (techSearch = false, autoSave = false) => {
    const { onMapConfig } = this.props;
    const mapSettings = stringToBoolean(getUserSetting(MAP_CONFIG), false);
    const changed = {};
    let event;
    techSearch
      ? (changed.tech_dcmap = true)
      : (changed.tech_dcmap = !mapSettings);
    event = new CustomEvent(MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN, {
      detail: { name: "MapSettings", showForTech: true }
    });
    onMapConfig(changed, autoSave);
    window.dispatchEvent(event);
    this.setState({
      showMap: changed.tech_dcmap
    });
  };

  render() {
    const { handleButtonClick, loading } = this.props;
    const { showMapButton, showMap } = this.state;
    return (
      <GridItem noFlex className="SchedulerToolbar__Group">
        <GridRow>
          <GridItem className="SchedulerToolbar__SubGroup">
            <Label>{getDisplayValue(TAG446)}</Label>
          </GridItem>
        </GridRow>
        <GridRow>
          <GridItem className="SchedulerToolbar__Group SchedulerToolbar__SubGroup">
            {showMapButton && (
              <Button
                type="icon-border-filled"
                size="medium"
                onClick={() => this.handleMapSetting(false, true)}
                title={
                  showMap ? getDisplayValue(TAG016) : getDisplayValue(TAG015)
                }
                isDisabled={loading}
              >
                {showMap && <Icon icon="hide" size="small" />}
                {!showMap && <Icon icon="location" size="small" />}
              </Button>
            )}
          </GridItem>
          <GridItem className="SchedulerToolbar__Group SchedulerToolbar__SubGroup">
            <Button
              type="icon-border-filled"
              size="medium"
              onClick={() => handleButtonClick(CONFIGURE_TECH_VIEW)}
              title={getDisplayValue(TAG093)}
              isDisabled={loading}
            >
              <Icon icon="settings" size="small" />
            </Button>
          </GridItem>
        </GridRow>
      </GridItem>
    );
  }
}

SchedulerConfig.propTypes = {
  loading: PropTypes.bool,
  handleButtonClick: PropTypes.func.isRequired,
  onMapConfig: PropTypes.func.isRequired
};

export default SchedulerConfig;
