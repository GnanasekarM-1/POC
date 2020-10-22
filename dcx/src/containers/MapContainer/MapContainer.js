import React, { Component } from "react";
import PropTypes from "prop-types";
import { flatMap } from "lodash";
import {
  Button,
  Container,
  Input,
  InputWrapper,
  Label,
  Modal,
  ModalContent,
  ModalFooter,
  ModalHeader,
  Spinner
} from "@svmx/ui-components-lightning";
import MapPlotView from "components/MapComponents/MapPlotView/MapPlotView";
import MapRenderer from "components/MapComponents/MapRenderer";
import PlotOnMap from "components/MapComponents/MapPlotView/PlotOnMap";
import Toolbar from "components/MapComponents/MapPlotView/Toolbar";
import {
  TAG066,
  TAG246,
  TAG319,
  TAG320,
  TAG470,
  TAG504,
  TAG505
} from "constants/DisplayTagConstants";
import {
  getSettingValue,
  MAP_UNIT_KILOMETER,
  MAP_UNIT_MILE,
  DCON001_SET005,
  SET048,
  SET048_DEFAULT,
  SET049,
  SET049_DEFAULT,
  SET050,
  SET050_DEFAULT,
  SET055,
  SET059,
  SET060,
  SET060_DEFAULT,
  SET061,
  SET061_DEFAULT,
  SET068,
  SET068_DEFAULT
} from "constants/AppSettings";
import {
  MAP_ACCOUNT_VIEW,
  MAP_CUSTOM_EVENT_SHOW_LOCATION_BAR,
  MAP_DEFAULT_LAT,
  MAP_DEFAULT_LNG,
  MAP_DEFAULT_LOCATION_BASE,
  MAP_DEFAULT_ZOOM_LEVEL,
  MAP_LOCATION_VIEW,
  MAP_SEARCH_RADIUS_LABEL,
  MAP_TECH_HOME,
  MAP_VIEW_DEFAULT_SELECTED_TAB,
  MAP_VIEW_PLOT_RADIUS_DEFAULT,
  MAP_WORKORDER_VIEW,
  MAP_CUSTOM_EVENT_LOAD_EVENTS
} from "constants/MapConstants";
import { USER_DATE_FORMAT } from "constants/UserSettingConstants";
import {
  DEFAULT_CANCEL,
  DEFAULT_DONE,
  DISPLAY_SIZE_SMALL,
  TYPE_NEUTRAL_GRAY
} from "constants/AppConstants";
import { getDisplayValue, getUserSetting } from "utils/DCUtils";
import {
  getShowPlotOnMap,
  setConfigRecordLimit,
  setSelectedConfigRadius,
  setShowPlotOnMap,
  setSelectedSearchRadius,
  clearViewItems,
  resetShowRouteData,
  setShowRouteDataMapDone,
  setShowRouteSelectedDate,
  setLastPlotCircleDataReset,
  getSelectedSearchRadius,
  getRecordLimit,
  setMapPlotReset,
  getSearchTechDone
} from "utils/MapUtils";
import {
  clearRoute,
  drawRadiusForSearch,
  drawTechRouteForDay,
  setLocationBaseRadio,
  clearRadiusModeCircle,
  clearSearchTechMarkers,
  clearSearchTeamMarkers,
  setMapContainerResetCallBackFunction,
  setStautsMsgEmpty,
  clearMap,
  setDefaultRadius,
  setDefaultMapLatLng,
  radiusModeNoLimitHandler,
  handleSearchRadiusChange
} from "services/MapService";
import * as moment from "moment";
import "./MapContainer.scss";

const defaultProps = {
  currentWindow: window,
  shouldShowPortalWindowButton: false
};

const propTypes = {
  currentWindow: PropTypes.objectOf(PropTypes.object).isRequired,
  shouldShowPortalWindowButton: PropTypes.bool.isRequired
};

class MapContainer extends Component {
  constructor(props) {
    super(props);
    this.shouldShowMapSpinner = true;
    this.state = {
      radioValue: getUserSetting(MAP_DEFAULT_LOCATION_BASE),
      searchRadius:
        getSettingValue(DCON001_SET005) || MAP_VIEW_PLOT_RADIUS_DEFAULT,
      shouldShowMapSearchRadiusEValue: false,
      // shouldShowMapSpinner: true,
      shouldShowMapToolbar: false,
      shouldShowPlotView: getShowPlotOnMap(),
      showLocationBaseBar: false,
      showSearchRadiusButton: false,
      showLocationBaseBarWithDate: false,
      selectedLocationBarDate: moment(),
      locationBarMinDate: moment().subtract(1, "years"),
      locationBarMaxDate: moment().add(1, "years"),
      technicianName: ""
    };
    if (!getRecordLimit()) {
      setConfigRecordLimit();
    }
    setSelectedConfigRadius();
    setLocationBaseRadio(getUserSetting(MAP_DEFAULT_LOCATION_BASE), false);
    window.addEventListener(
      MAP_CUSTOM_EVENT_SHOW_LOCATION_BAR,
      this.handleShowLocationBar,
      false
    );
    setMapContainerResetCallBackFunction(this.handleMapContainerReset);
  }

  handleClearSelectedViews = list => {
    this.mapPlotViewRef.handleClearSelectedViews(list);
  };

  handleMapContainerReset = () => {
    this.setState({
      showLocationBaseBar: false,
      showLocationBaseBarWithDate: false
    });
    clearRoute();
    clearRadiusModeCircle();
    clearSearchTechMarkers();
    clearSearchTeamMarkers();
    clearMap();
    setConfigRecordLimit();
    setSelectedConfigRadius();
    setDefaultRadius();
    resetShowRouteData();
    setShowRouteDataMapDone(false);
    setDefaultMapLatLng();
    setLastPlotCircleDataReset();
    setMapPlotReset();
    if (getShowPlotOnMap() && this.mapPlotViewRef) {
      this.mapPlotViewRef.handleClearMap();
      this.mapPlotViewRef.handleClearSelectedViews([
        MAP_ACCOUNT_VIEW,
        MAP_LOCATION_VIEW,
        MAP_WORKORDER_VIEW
      ]);
      this.mapPlotViewRef.handleSelectedTab({
        tabKey: MAP_VIEW_DEFAULT_SELECTED_TAB
      });
    }
    setStautsMsgEmpty();
  };

  handleMapLoadComplete = () => {
    this.shouldShowMapSpinner = false;
    this.setState({
      // shouldShowMapSpinner: false,
      shouldShowMapToolbar: true
    });
    const event = new CustomEvent(MAP_CUSTOM_EVENT_LOAD_EVENTS, {
      detail: true
    });
    window.dispatchEvent(event);
  };

  handlePlotOnMap = () => {
    this.onPlotOnMapChildRef.handlePlotOnMap();
  };

  handlePlotView = () => {
    const { shouldShowPlotView } = this.state;
    setShowPlotOnMap(!shouldShowPlotView);
    this.setState({
      shouldShowPlotView: !shouldShowPlotView
    });
  };

  handleSearchRadius = () => {
    const { showSearchRadiusButton } = this.state;
    this.setState({
      showSearchRadiusButton: !showSearchRadiusButton
    });
  };

  handleSearchRadiusItem = ({ value }) => {
    if (value === "No Limit" || value === "Enter Value") {
      if (value === "No Limit") {
        this.handleSearchRadius();
        radiusModeNoLimitHandler();
      }
    } else {
      setSelectedSearchRadius(value);
      const event = new CustomEvent(MAP_CUSTOM_EVENT_SHOW_LOCATION_BAR, {
        detail: { show: getSearchTechDone(), showDate: false }
      });
      window.dispatchEvent(event);
      // drawRadiusForSearch(value);
      handleSearchRadiusChange(value);
      this.handleSearchRadius();
    }
  };

  handleRadiusReset = () => {
    this.mapPlotViewRef.handleRadiusReset();
  };

  handleRadioValueChange = data => {
    this.setState({ radioValue: data.value });
    setLocationBaseRadio(data.value, true);
  };

  handleRecordLimitReset = () => {
    this.mapPlotViewRef.handleRecordLimitReset();
  };

  handleSearchRadiusDone = () => {
    const { searchRadius, shouldShowMapSearchRadiusEValue } = this.state;
    /* setSelectedSearchRadius(searchRadius);
    const event = new CustomEvent(MAP_CUSTOM_EVENT_SHOW_LOCATION_BAR, {
      detail: { show: true, showDate: false }
    });
    window.dispatchEvent(event);
    drawRadiusForSearch(searchRadius);
    this.setState({
      shouldShowMapSearchRadiusEValue: !shouldShowMapSearchRadiusEValue
    }); */
    this.setState({
      shouldShowMapSearchRadiusEValue: !shouldShowMapSearchRadiusEValue
    });
    setSelectedSearchRadius(searchRadius);
    const event = new CustomEvent(MAP_CUSTOM_EVENT_SHOW_LOCATION_BAR, {
      detail: { show: true, showDate: false }
    });
    window.dispatchEvent(event);
    // drawRadiusForSearch(value);
    handleSearchRadiusChange(searchRadius);
    // this.handleSearchRadius();
  };

  handleSearchRadiusEnterValue = () => {
    const {
      shouldShowMapSearchRadiusEValue,
      showSearchRadiusButton
    } = this.state;
    this.setState({
      shouldShowMapSearchRadiusEValue: !shouldShowMapSearchRadiusEValue,
      showSearchRadiusButton: false
    });
  };

  handleSearchRadiusValueChange = ({ target }) => {
    const { value } = target;
    this.setState({
      searchRadius: value
    });
  };

  handleSearchRadiusValueChangeOnBlur = ({ target }) => {
    const { value } = target;
    if (value >= 1 && value <= 2000) {
      this.setState({
        searchRadius: value
      });
    } else {
      this.setState({
        searchRadius: getSettingValue(DCON001_SET005)
      });
    }
  };

  handleShowLocationBar = evt => {
    const { detail } = evt;
    const { show, showDate, maxDate, minDate, selectedDate, techName } = detail;
    if (showDate) {
      setShowRouteDataMapDone(true);
      setShowRouteSelectedDate(selectedDate);
    }
    this.setState({
      showLocationBaseBar: show,
      showLocationBaseBarWithDate: showDate,
      locationBarMinDate: moment(minDate, "MM/DD/YYYY").subtract(1, "day"),
      locationBarMaxDate: moment(maxDate, "MM/DD/YYYY").add(1, "day"),
      selectedLocationBarDate: moment(selectedDate, "MM/DD/YYYY"),
      technicianName: techName
    });
  };

  handleShowMapSpinner = value => {
    this.shouldShowMapSpinner = value;
    // this.setState({
    // shouldShowMapSpinner: value,
    // });
  };

  handlePreviousDate = () => {
    const {
      selectedLocationBarDate: currentSelectedDate,
      locationBarMinDate: defaultMinDate
    } = this.state;
    const prevDate = moment(currentSelectedDate).subtract(1, "days");
    const isPrevDateBefore = moment(prevDate).isAfter(defaultMinDate);
    if (isPrevDateBefore) {
      this.setState({ selectedLocationBarDate: prevDate });
      setShowRouteSelectedDate(moment(prevDate).format("MM/DD/YYYY"));
      drawTechRouteForDay(moment(prevDate).format("MM/DD/YYYY"));
    }
  };

  handleNextDate = () => {
    const {
      selectedLocationBarDate: currentSelectedDate,
      locationBarMaxDate: defaultMaxDate
    } = this.state;
    const nextDate = moment(currentSelectedDate).add(1, "days");
    const isNextDateAfter = moment(nextDate).isBefore(defaultMaxDate);
    if (isNextDateAfter) {
      this.setState({ selectedLocationBarDate: nextDate });
      setShowRouteSelectedDate(moment(nextDate).format("MM/DD/YYYY"));
      drawTechRouteForDay(moment(nextDate).format("MM/DD/YYYY"));
    }
  };

  handleRouteValueChange = e => {
    const { value } = e;
    this.setState({
      selectedLocationBarDate: moment(value)
    });
    setShowRouteSelectedDate(moment(value).format("MM/DD/YYYY"));
    drawTechRouteForDay(moment(value).format("MM/DD/YYYY"));
  };

  setUserMapConfig = () => {
    const config = {};
    config.defaultLat = getUserSetting(MAP_DEFAULT_LAT);
    config.defaultLng = getUserSetting(MAP_DEFAULT_LNG);
    config.defaultZoomLevel = getUserSetting(MAP_DEFAULT_ZOOM_LEVEL);
    config.techIcon = getSettingValue(SET068, SET068_DEFAULT);
    config.techHomeIcon = getSettingValue(SET050, SET050_DEFAULT);
    config.accIcon = getSettingValue(SET060, SET060_DEFAULT);
    config.locIcon = getSettingValue(SET061, SET061_DEFAULT);
    config.teamIcon = getSettingValue(SET049, SET049_DEFAULT);
    config.woIcon = getSettingValue(SET048, SET048_DEFAULT);
    config.userDateFormat = getUserSetting(USER_DATE_FORMAT);
    config.locationBase = getUserSetting(MAP_DEFAULT_LOCATION_BASE);
    const mapUnit = getSettingValue(SET055, MAP_UNIT_MILE);
    const mapUnitText =
      mapUnit.toLowerCase() === MAP_UNIT_MILE
        ? getDisplayValue(TAG320, MAP_UNIT_MILE)
        : getDisplayValue(TAG319, MAP_UNIT_KILOMETER);
    config.mapUnit = mapUnit.toLowerCase();
    config.mapUnitText = mapUnitText;
    config.defaultRadius = getSettingValue(DCON001_SET005) || 1;
    config.defaultRecordCount = getSettingValue(SET059) || 1;
    return config;
  };

  render() {
    const { currentWindow, shouldShowPortalWindowButton = true } = this.props;

    const {
      radioValue,
      searchRadius,
      shouldShowMapSearchRadiusEValue,
      shouldShowMapToolbar,
      shouldShowPlotView,
      showLocationBaseBar,
      showSearchRadiusButton,
      showLocationBaseBarWithDate,
      selectedLocationBarDate,
      locationBarMinDate,
      locationBarMaxDate,
      technicianName
    } = this.state;

    return (
      <Container>
        {this.shouldShowMapSpinner && (
          <div className="MapContainer__spinner">
            <Spinner />
          </div>
        )}
        {shouldShowMapToolbar && (
          <Toolbar
            mapUnit={this.setUserMapConfig().mapUnitText}
            onMapContainerReset={this.handleMapContainerReset}
            onShowLocationBaseBar={showLocationBaseBar}
            onShowSearchRadiusButton={showSearchRadiusButton}
            onShowLocationBaseBarWithDate={showLocationBaseBarWithDate}
            onPlotView={this.handlePlotView}
            handleSearchRadius={this.handleSearchRadius}
            handleSearchRadiusItem={this.handleSearchRadiusItem}
            onRadioValueChange={this.handleRadioValueChange}
            onSearchRadiusEnterValue={this.handleSearchRadiusEnterValue}
            onPreviousDate={this.handlePreviousDate}
            onNextDate={this.handleNextDate}
            radioValue={radioValue}
            shouldShowPortalWindowButton={shouldShowPortalWindowButton}
            onLocationBaseBarSelectedDate={selectedLocationBarDate}
            onLocationBarMinDate={locationBarMinDate}
            onLocationBarMaxDate={locationBarMaxDate}
            technicianName={technicianName}
            onRouteDateValueChange={this.handleRouteValueChange}
          />
        )}
        <Modal
          isOpen={shouldShowMapSearchRadiusEValue}
          onClose={this.handleSearchRadiusEnterValue}
        >
          <ModalHeader title={MAP_SEARCH_RADIUS_LABEL} />
          <ModalContent>
            <Label isRequired>{getDisplayValue(TAG504)}</Label>
            <InputWrapper>
              <Input
                name="enterValue"
                onBlur={e => {
                  this.handleSearchRadiusValueChangeOnBlur(e);
                }}
                onChange={e => {
                  this.handleSearchRadiusValueChange(e);
                }}
                value={searchRadius}
              />
            </InputWrapper>
          </ModalContent>
          <ModalFooter>
            <Button
              type={TYPE_NEUTRAL_GRAY}
              size={DISPLAY_SIZE_SMALL}
              onClick={this.handleSearchRadiusEnterValue}
              title={getDisplayValue(TAG066, DEFAULT_CANCEL)}
            >
              {getDisplayValue(TAG066, DEFAULT_CANCEL)}
            </Button>
            <Button
              name={DEFAULT_DONE}
              type={TYPE_NEUTRAL_GRAY}
              size={DISPLAY_SIZE_SMALL}
              onClick={this.handleSearchRadiusDone}
              title={getDisplayValue(TAG246, DEFAULT_DONE)}
            >
              {getDisplayValue(TAG246, DEFAULT_DONE)}
            </Button>
          </ModalFooter>
        </Modal>
        {shouldShowPlotView && (
          <MapPlotView
            onChildRef={mapPlotRef => {
              this.mapPlotViewRef = mapPlotRef;
              return undefined;
            }}
            onPlotOnMap={this.handlePlotOnMap}
            onClearSelectedViews={this.handleClearSelectedViews}
            onRadiusReset={this.handleRadiusReset}
            onRecordsLimitReset={this.handleRecordLimitReset}
            onShowMapSpinner={this.handleShowMapSpinner}
            mapUnit={this.setUserMapConfig().mapUnitText}
          />
        )}
        <MapRenderer
          currentWindow={currentWindow || window}
          onMapLoadComplete={this.handleMapLoadComplete}
          onUserConfig={this.setUserMapConfig}
        />
      </Container>
    );
  }
}

MapContainer.defaultPropTypes = defaultProps;
MapContainer.propTypes = propTypes;

export default MapContainer;
