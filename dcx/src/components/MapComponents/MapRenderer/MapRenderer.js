import React, { Component } from "react";
import PropTypes from "prop-types";

import {
  createRequiredGoogleService,
  createCurrentMapContext,
  getMapOptions,
  mapInitilizedConfigure,
  setMapConfig,
  setMapInstance,
  setCurrentWindow
} from "services/MapService";
import { getSelectedSearchRadius } from "utils/MapUtils";
import {
  MAPS_API_KEY_DC,
  getSettingValue,
  GLOB001_GBL011
} from "constants/AppSettings";

let mapDefaultLat = 34.079962;
let mapDefaultLng = -118.23761;
let mapDefaultZoomLevel;
let mapUnitTextValue = "mile";
let selectedCircleRadius = "180";
let plotNearByLatLng = null;

const defaultProps = {
  currentWindow: window
};

const propTypes = {
  currentWindow: PropTypes.objectOf(PropTypes.object).isRequired,
  onMapLoadComplete: PropTypes.func.isRequired,
  onUserConfig: PropTypes.func.isRequired
};

const divStyle = {
  height: "calc(100vh - 50px)"
};

const getMapOptionsLocal = (mapFrameWindow, config) => {
  let mapTypeId = mapFrameWindow.google.maps.MapTypeId.ROADMAP;
  let zoom = 12;
  const {
    defaultLat,
    defaultLng,
    defaultZoomLevel,
    mapUnitText,
    defaultRadius
  } = config;
  mapDefaultLat = defaultLat;
  mapDefaultLng = defaultLng;
  mapDefaultZoomLevel = Number(defaultZoomLevel);
  mapUnitTextValue = mapUnitText;
  if (!getSelectedSearchRadius()) {
    selectedCircleRadius = defaultRadius;
  }
  if (mapDefaultZoomLevel) {
    zoom = mapDefaultZoomLevel;
  }
  const mapOptions = {
    center: new mapFrameWindow.google.maps.LatLng(mapDefaultLat, mapDefaultLng),
    mapTypeControlOptions: {
      position: mapFrameWindow.google.maps.ControlPosition.RIGHT_TOP,
      style: mapFrameWindow.google.maps.MapTypeControlStyle.HORIZONTAL_BAR
    },
    mapTypeId,
    panControl: false,
    gestureHandling: "greedy",
    streetViewControl: false,
    fullscreenControl: false,
    zoomControl: true,
    zoom,
    zoomControlOptions: {
      position: mapFrameWindow.google.maps.ControlPosition.LEFT_TOP,
      style: mapFrameWindow.google.maps.ZoomControlStyle.SMALL
    }
  };
  return mapOptions;
};

/* const divStyleContainer = {
  position: 'relative',
  height: 'calc(100vh - 50px)',
  width: '100%',
};
const divStyleMapDiv = {
  overflow: 'hidden',
  position: 'absolute',
  top: '0',
  right: '0',
  bottom: '0',
  left: '0',
}; */

class MapRenderer extends Component {
  componentDidMount() {
    const { currentWindow } = this.props;
    // Load the map Script for only the parent Window
    if (!currentWindow.google) {
      // Create the script element in parent window document
      const script = currentWindow.document.createElement("script");
      let mapKey = getSettingValue(MAPS_API_KEY_DC);
      // Script source url includes the client id client=gme-servicemaxinc
      // script.src = 'https://maps.googleapis.com/maps/api/js?client=gme-servicemaxinc';
      if (!mapKey) {
        mapKey = getSettingValue(GLOB001_GBL011);
        script.src = `https://maps.googleapis.com/maps/api/js?client=${mapKey}&channel=DC-HTML`;
      } else {
        script.src = `https://maps.googleapis.com/maps/api/js?key=${mapKey}`;
      }
      // Add the event listener for loading the script
      script.addEventListener("load", () => {
        /* Once map script is loaded set the mapIsReady property to true & call the inner function
        /*rendermap to bind the map in div
        */
        this.renderMap();
      });
      // append the script to the document body
      currentWindow.document.body.appendChild(script);
    } else {
      // Call the inner function rendermap to bind the map in div
      setTimeout(() => this.renderMap(), 0);
      // this.renderMap();
    }
  }

  renderMap() {
    const { currentWindow, onMapLoadComplete, onUserConfig } = this.props;
    onMapLoadComplete();
    setCurrentWindow(currentWindow);
    // set Org and User Map Settings
    setMapConfig(onUserConfig());
    getMapOptions(currentWindow);
    // Display the map
    const mapInstance = new currentWindow.google.maps.Map(
      currentWindow.document.getElementById("mapdiv"),
      getMapOptionsLocal(currentWindow, onUserConfig())
    );
    setMapInstance(mapInstance);
    createRequiredGoogleService();
    mapInstance.addListener("tilesloaded", () => {
      // onMapLoadComplete();
    });
    mapInitilizedConfigure();
    setTimeout(() => createCurrentMapContext(), 1000);
  }

  render() {
    return <div id="mapdiv" style={divStyle} />;
  }
}

MapRenderer.defaultPropTypes = defaultProps;
MapRenderer.propTypes = propTypes;

export default MapRenderer;
