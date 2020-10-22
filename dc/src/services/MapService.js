/* eslint-disable no-unused-vars */
import store from "store";
import { flatMap } from "lodash";
import React from "react";
import { Icon } from "@svmx/ui-components-lightning";
import ReactDOMServer from "react-dom/server";
import {
  MAP_INFO_ICON_URL,
  MAP_PLOT_CENTER_ICON,
  MAP_WORKORDER,
  MAP_TEAM,
  MAP_TECHNICIAN,
  TECH_ROUTE_COLORS,
  MAP_HOME_MARKER_SVG,
  MAP_CURRENT_MARKER_SVG,
  MAP_BALLOON_URL,
  MAP_TECH_CURRENT,
  MAP_TECH_HOME,
  MAP_PREVIOUS,
  MAP_NEXT,
  MAP_CUSTOM_EVENT_SHOW_LOCATION_BAR,
  MAP_CUSTOM_EVENT_MAP_CONFIG_CHANGE,
  MAP_INFO_PHOTO_ICON,
  MAP_TECH_IMAGE_PATH_SVG
} from "constants/MapConstants";
import {
  LOCATION_API_NAME,
  WORKORDER_API_NAME,
  ACCOUNT_API_NAME,
  MAP_CONFIG
} from "constants/AppConstants";

import { getDisplayValue, getUserSetting } from "utils/DCUtils";
import {
  getSelectedSearchRadius,
  getTechnicianRouteData,
  openPopUp,
  resetShowRouteTechIdsData,
  getShowRouteDataMapDone,
  getShowRouteSelectedDate,
  getShowRouteTechIdsData,
  getSelectedRadius,
  getLastPlotCircleData,
  setLastPlottedLatLng,
  getLastPlottedLatLng,
  setLastPlotCircleData,
  setLastPlotCircleDataReset,
  setMapPlotReset,
  getSelectedViewItems,
  setSearchTechDone
} from "utils/MapUtils";
import { UPDATE_USER_SETTINGS } from "constants/ActionConstants";
import {
  TAG177,
  TAG366,
  TAG367,
  TAG368,
  TAG260
} from "constants/DisplayTagConstants";
import * as moment from "moment";

// Bounds are used to show plotted info correctly. Its initialized before plotting anything
let bounds;
// This stack maintains the references to callBacks
// that need to be executed after the lat lngs for markers are resolved
const callBackStack = [];
let circleRadius = "180";
let selectedCircleRadius = "180";
// Set of default user defined information used to initialize map
// {defaultLat:num,defaultLng:num,
// defaultZoomLevel:num,mapWidth:num,techIcon:str,teamIcon:str,woIcon:str,tags:Object}
let defaultConfig;
// Reference to DirectionsDisplay class used to plot route
let directionsDisplay;
//  Reference to service used to get path for the route between source and destination
let directionsService;
// Reference to geocoder for resolving lat lng
let geocoder;
// Reference to a common infoWindow used to display hover info for map markers
let infoWindow;
// List of team/tech/wo objects {Name,type} having incalid location info
let invalidMarkers = [];
let invalidMarkersIds = [];
// Counter to keep track of how many markers are pending for lat lng resolution from address
// Used to store the last Plotted Route when switching between inline and popup view
let lastPlottedRoute = null;
let latLngLookupCounter = 0;
let apiQueryLimitCount = 0;
const getTechColorCounter = {};
// Map for Team/Tech/WO record and their lat lng
const latLngMap = {};
let mapDefaultLat = 34.079962;
let mapDefaultLng = -118.23761;
let mapDefaultUserLat = 34.079962;
let mapDefaultUserLng = -118.23761;
let mapDefaultUserZoomLevel = 0;
let mapInstance;
let mapUnitTextValue = "mile";
const plotCircleRadius = 0;
let nearByMarkersMap = {};
// Currently selected lat-lng to be ued by "Plot near by"
let plotCenterMarker = null;
let plotCircle = null;
const plotView = false;
let plotMode = false;
let plotNearByLatLng = null;
let plotNearByMarkers = [];
let plotRouteCounter = 0;
let homeRadio = true;
let currentRadio = false;
let bothRadio = false;
let noLimit = false;
let plotRouteData;
// Reference to Circle object used for radius mode
let radiusModeCircle;
const resetMode = false;
let radiusMode = false;
// Data for technician for whom the route is plotted
// {technician:{},currentDateInMilliSeconds:0,eventsForWorkOrders:[],pastOverNightStayEvent:[],futureOverNightStayEvent:[],ganttStartDateInMilliSeconds:0,ganttEndDateInMilliSeconds:0,currentTimeMarkerInMillis:0}
let routeData = {};
let routeDataArr = [];
// Has search info for teams {teams:Array,selectedWO:Object}
let searchTeamData;
// Array having references to all the markers plotted for team search
let searchTeamMarkers;
// Has search info for technicians {technicians:Array,selectedWO:Object}
let searchTechData;
// Array having references to all the markers plotted for tech search
let searchTechMarkers;
let routeTechMarkers;
// Used to store the map type when switching between inline and popup view
let selectedMapTypeId;

const suppressEventsDateField = false;
// Used to store the total routes plotted when switching between inline and popup view
let totalRoutesPlotted = 0;
// Map for which color is used for which technician when plotting route
const techColorMap = {};
let tempSelectedWO;
let tempTechData;
let tempTechList;
// Reference to traffic layer displayed on map
let trafficLayer;
// Reference to div displaying Traffic control (button)
let trafficLayerDiv;
// Used to store the map zoom level when switching between inline and popup view
let mapDefaultZoomLevel;
let techRouteData;
let localCurrentDate;
let errorCallBackFunction;
let resetCallBackFunction;
let showRouteCallBackFunction;
let currentWindow;
let searchAllTechMarkers = [];
let searchAllTeamMarkers = [];

const updateUserSettings = changed => {
  // store.dispatch({ changed, type: UPDATE_USER_SETTINGS });
};

function CustomCircleOverlay(
  circlMapInstance,
  latLng,
  circleOverlayRadius,
  mapUnit,
  mapValue,
  strokeColor,
  strokeWidth,
  strokeOpacity,
  fillColor,
  fillOpacity,
  numofPoints
) {
  this.map = circlMapInstance;
  this.setMap(circlMapInstance);
  this.latLng = latLng;
  this.radius = circleOverlayRadius;
  this.strokeColor = strokeColor;
  this.strokeWidth = strokeWidth;
  this.strokeOpacity = strokeOpacity;
  this.fillColor = fillColor;
  this.fillOpacity = fillOpacity;
  this.div_ = null;
  this.mapUnit = mapUnit;
  this.mapValue = mapValue;

  // Set resolution of polygon
  if (typeof numofPoints === "undefined") {
    this.numPoints = 45;
  } else {
    this.numPoints = numofPoints;
  }

  // Reset overlay
  CustomCircleOverlay.prototype.clear = function clear() {
    if (this.polygon != null && this.map != null) {
      this.polygon.setMap(null);
    }
  };

  // Calculate all the points of the circle and draw them
  CustomCircleOverlay.prototype.draw = function draw() {
    const d2r = Math.PI / 180;
    const customcircleLatLngs = [];
    let anglevalue = 0;

    // Convert statute miles into degrees latitude
    let customcircleLat;
    if (this.mapUnit === this.mapValue) {
      customcircleLat = this.radius * 0.014483;
    } else {
      customcircleLat = this.radius * 0.621371192 * 0.014483;
    }
    const customcircleLng = customcircleLat / Math.cos(this.latLng.lat() * d2r);

    // Create polygon points (extra point to close polygon)
    for (let i = 0; i < this.numPoints + 1; i += 1) {
      // Convert degrees to radians
      const circletheta = Math.PI * (i / (this.numPoints / 2));
      const vertexLat =
        this.latLng.lat() + customcircleLat * Math.sin(circletheta);
      const vertexLng =
        this.latLng.lng() + customcircleLng * Math.cos(circletheta);
      const vertextLatLng = new currentWindow.google.maps.LatLng(
        vertexLat,
        vertexLng
      );
      customcircleLatLngs.push(vertextLatLng);

      // get the center points
      const centerpoint = this.getProjection().fromLatLngToDivPixel(
        this.latLng
      );
      // get the projection points
      const point = this.getProjection().fromLatLngToDivPixel(vertextLatLng);
      // find the angle using the center point and projection point
      const p0 = {
        x: centerpoint.x,
        y:
          centerpoint.y -
          Math.sqrt(
            Math.abs(point.x - centerpoint.x) *
              Math.abs(point.x - centerpoint.x) +
              Math.abs(point.y - point.y) * Math.abs(point.y - point.y)
          )
      };
      const anglevalueforeachpoint =
        (2 * Math.atan2(point.y - p0.y, point.x - p0.x) * 180) / Math.PI;
      // Round the angle value
      const anglestr = anglevalueforeachpoint.toFixed(0);
      if (anglestr >= -200 && anglestr <= 0) {
        // this angle is the projection of text in a circle
        anglevalue = i;
      }
    }
    this.clear();
    this.polygon = new currentWindow.google.maps.Polygon({
      fillColor: this.fillColor,
      fillOpacity: this.fillOpacity,
      paths: [customcircleLatLngs],
      strokeColor: this.strokeColor,
      strokeOpacity: this.strokeOpacity,
      strokeWeight: this.strokeWidth
    });
    this.polygon.setMap(this.map);

    const self = this;
    currentWindow.google.maps.event.addDomListener(
      this.polygon,
      "click",
      event => {
        currentWindow.google.maps.event.trigger(self, "click", event);
      }
    );

    let div = this.div;
    if (!div) {
      div = this.div = document.createElement("div");

      div.className = "marker";

      div.style.position = "absolute";
      div.style.background = this.fillColor;
      // div.style.borderRadius = "25px";

      const span = (this.span_ = document.createElement("span"));
      span.style.cssText = "color:#ffffff;fontSize:9px";
      div.appendChild(span);
      this.span_.innerHTML = `${this.radius} ${this.mapUnit}`;
      const panes = this.getPanes();
      panes.overlayImage.appendChild(div);
    }
    const point = this.getProjection().fromLatLngToDivPixel(
      customcircleLatLngs[anglevalue]
    );
    if (point) {
      div.style.left = `${point.x - 10}px`;
      div.style.top = `${point.y - 5}px`;
      // div.style.left = (point.x - 30) + 'px';
    }
  };

  // Remove circle with text method
  CustomCircleOverlay.prototype.remove = function remove() {
    if (this.div) {
      this.div.parentNode.removeChild(this.div);
      this.div = null;
    }
    this.clear();
  };
}

export const getMapOptions = currentWindow => {
  // const defaultData = defaultConfig;
  let mapTypeId = currentWindow.google.maps.MapTypeId.ROADMAP;
  let zoom = 12;
  if (selectedMapTypeId) {
    mapTypeId = selectedMapTypeId;
  }
  if (mapDefaultZoomLevel) {
    zoom = mapDefaultZoomLevel;
  }
  const myLatLng = { lat: mapDefaultLat, lng: mapDefaultLng };
  const ll = new currentWindow.google.maps.LatLng(myLatLng.lat, myLatLng.lng);
  if (!plotNearByLatLng) {
    plotNearByLatLng = ll;
  }
  // plotNearByLatLng = ll;
  const mapOptions = {
    center: plotNearByLatLng,
    mapTypeControlOptions: {
      position: currentWindow.google.maps.ControlPosition.RIGHT_TOP,
      style: currentWindow.google.maps.MapTypeControlStyle.HORIZONTAL_BAR
    },
    mapTypeId,
    panControl: false,
    gestureHandling: "greedy",
    streetViewControl: false,
    fullscreenControl: false,
    zoomControl: true,
    zoom,
    zoomControlOptions: {
      position: currentWindow.google.maps.ControlPosition.LEFT_TOP,
      style: currentWindow.google.maps.ZoomControlStyle.SMALL
    }
  };
  return mapOptions;
};

export const setMapInstance = mapObj => {
  mapInstance = mapObj;
};

export const setMapConfig = config => {
  defaultConfig = config;
  const {
    defaultLat,
    defaultLng,
    defaultZoomLevel,
    mapUnitText,
    defaultRadius
  } = defaultConfig;
  mapDefaultLat = defaultLat;
  mapDefaultLng = defaultLng;
  mapDefaultZoomLevel = Number(defaultZoomLevel);
  mapUnitTextValue = mapUnitText;
  if (!getSelectedSearchRadius()) {
    selectedCircleRadius = defaultRadius;
  }
  mapDefaultUserLat = defaultLat;
  mapDefaultUserLng = defaultLng;
  mapDefaultUserZoomLevel = Number(defaultZoomLevel);
};

export const setDefaultMapLatLng = () => {
  bounds = new currentWindow.google.maps.LatLngBounds();
  const latlon = new currentWindow.google.maps.LatLng(
    mapDefaultUserLat,
    mapDefaultUserLng
  );
  bounds.extend(latlon);
  mapInstance.fitBounds(bounds);
  mapInstance.setZoom(mapDefaultUserZoomLevel);
};

export const setDefaultRadius = () => {
  const { defaultRadius } = defaultConfig;
  selectedCircleRadius = defaultRadius;
};

export const getMapConfig = () => defaultConfig;

const getTrafficOverlayDiv = () => {
  const trafficOverlayDiv = document.createElement("div");
  const style = trafficOverlayDiv.style;

  // style.width = "75px";
  style.overflow = "hidden";
  style.textAlign = "center";

  try {
    style.border = "1px solid rgba(0, 0, 0, 0.15)";
  } catch (e) {
    style.border = "#666 1px solid";
  }

  style.fontFamily = "Roboto,Arial,sans-serif";
  style.fontSize = "11px";
  style.boxShadow = "0px 1px 4px -1px rgba(0, 0, 0, 0.3)";
  style.padding = "1px 6px";
  style.backgroundColor = "rgb(255, 255, 255)";
  style.MozUserSelect = "none";
  style.cursor = "pointer";
  style.backgroundClip = "padding-box";
  style.margin = "0px 5px 0px 0px";
  trafficOverlayDiv.innerHTML = getDisplayValue("TAG369", "Traffic");

  return trafficOverlayDiv;
};

const setTrafficLayerVisibility = () => {
  if (!trafficLayer.getMap()) {
    trafficLayer.setMap(mapInstance);
    trafficLayerDiv.style.backgroundColor = "#E8E8E8";
  } else {
    trafficLayer.setMap(null);
    trafficLayerDiv.style.backgroundColor = "#FFFFFF";
  }
};

const clearPlotCenter = () => {
  if (plotCenterMarker) {
    plotCenterMarker.setMap(null);
  }
  plotCenterMarker = null;
};

const createMarker = (latLng, title, icon, address, scale, type) => {
  let image = icon;
  if (typeof image === "string") {
    image = {
      url: icon
    };
  }
  if (latLng && latLng.lat() !== undefined && latLng.lng() !== undefined) {
    latLng = new currentWindow.google.maps.LatLng(latLng.lat(), latLng.lng());
  }
  const marker = new currentWindow.google.maps.Marker({
    // Set address as well. Its not a property of MarkerOptions
    // but can be used if latLng not available
    address,
    anchorPoint: new currentWindow.google.maps.Point(0, 0),
    icon: image,
    position: latLng,
    title: ""
  });
  if (scale === true) {
    const iconObj = {};
    iconObj.url = icon;
    // Do not scale as it creates problem when using svg
    // iconObj.scaledSize = new google.maps.Size(25,25);
    marker.icon = iconObj;
  }
  marker.Name = title;
  marker.type = type;
  return marker;
};

const addToMapAfterLatLngLookup = marker => {
  if (marker && marker.position) {
    if (
      marker.position.lat() !== undefined &&
      marker.position.lng() !== undefined
    ) {
      marker.position = new currentWindow.google.maps.LatLng(
        marker.position.lat(),
        marker.position.lng()
      );
    }
    marker.setMap(mapInstance);
    bounds = new currentWindow.google.maps.LatLngBounds();
    if (bounds) {
      bounds.extend(marker.position);
      mapInstance.setCenter(bounds.getCenter());
    }
  }
  if (noLimit) {
    radiusModeNoLimitHandler();
  }
  if (searchTechData && searchTechData.selectedWO && !noLimit) {
    checkMarkerForRadius(circleRadius);
  }
};

const lookupLatLng = marker => {
  if (!geocoder) {
    geocoder = new currentWindow.google.maps.Geocoder();
  }
  const request = {
    address: marker.address
  };

  geocoder.geocode(request, (results, status) => {
    if (status === currentWindow.google.maps.GeocoderStatus.OK) {
      const location = results[0].geometry.location;
      marker.position = location;
      // Store the lat lng info in Object because passing back info to dcWindow will be straight
      // forward than passing complex objects
      latLngMap[marker.info.Id ? marker.info.Id : marker.info.id] = {
        lat: location.lat(),
        lng: location.lng()
      };
      // Populate in respective details object as well
      marker.info.lat = location.lat();
      marker.info.lng = location.lng();
      // if this marker is a way point, then update the way point info
      // wayPoint is set in drawTechnicianRoute()
      if (marker.wayPoint) {
        marker.wayPoint.location = location;
      }
      latLngLookupCounter -= 1;
      addToMapAfterLatLngLookup(marker);
    } else if (
      status === currentWindow.google.maps.GeocoderStatus.ZERO_RESULTS
    ) {
      // indicates that the geocode was successful but returned no results.
      // This may occur if the geocoder was passed a non-existent address.
      latLngLookupCounter -= 1;
      if (marker.info.WOId) {
        // If when resolving address for a WO related event (when plotting route),
        // also send Id to DC for the user to open the WO.
        invalidMarkers.push({
          Id: marker.info.WOId,
          Name: marker.Name,
          type: marker.type
        });
        invalidMarkersIds.push(marker.info.WOId);
      } else {
        invalidMarkers.push({ Name: marker.Name, type: marker.type });
      }
      if (invalidMarkers.length) {
        displayErrorInScheduler();
      }
    } else if (
      status === currentWindow.google.maps.GeocoderStatus.OVER_QUERY_LIMIT
    ) {
      // indicates that you are over your quota
      latLngLookupCounter -= 1;
      apiQueryLimitCount += 1;
      console.log("You are over your quota");
      displayErrorInScheduler(
        "Too many Google Geocoding API requests per second"
      );
    } else if (
      status === currentWindow.google.maps.GeocoderStatus.REQUEST_DENIED
    ) {
      // indicates that your request was denied, generally because of lack of a sensor parameter
      latLngLookupCounter -= 1;
      console.log("Request denied due to lack of a sensor parameter");
    } else if (
      status === currentWindow.google.maps.GeocoderStatus.UNKNOWN_ERROR
    ) {
      latLngLookupCounter -= 1;
      // A request could not be processed due to a server error.
      // The request may succeed if you try again
      console.log(
        "A request could not be processed due to a server error. The request may succeed if you try again"
      );
    }
    if (latLngLookupCounter === 0) {
      // The stack was introduced to fix issue #9995.
      // This issue occurs when plotting route and search results in succession
      // when the map is switched form inline to popup and vice-versa.
      // This issue occurred because callAfterLatLngLookup was
      // not executed if value of latLngLookupCounter was not zero due
      // to operations performed in succession
      if (apiQueryLimitCount != 0) {
        apiQueryLimitCount = 0;
        displayErrorInScheduler(
          "Too many Google Geocoding API requests per second"
        );
      }
      if (callBackStack && callBackStack.length > 0) {
        while (callBackStack.length !== 0) {
          const callBackInfo = callBackStack.pop();
          callBackInfo.callBack();
        }
      }
    }
  });

  latLngLookupCounter += 1;
};

const addMarker = marker => {
  if (!marker) {
    return false;
  }
  let added = false;
  if (marker.position) {
    if (
      marker.position.lat() !== undefined &&
      marker.position.lng() !== undefined
    ) {
      marker.position = new currentWindow.google.maps.LatLng(
        marker.position.lat(),
        marker.position.lng()
      );
    }
    marker.setMap(mapInstance);
    bounds = new currentWindow.google.maps.LatLngBounds();
    if (bounds) {
      bounds.extend(marker.position);
    }
    added = true;
  } else if (
    latLngMap.hasOwnProperty(marker.info.Id ? marker.info.Id : marker.info.id)
  ) {
    const location =
      latLngMap[marker.info.Id ? marker.info.Id : marker.info.id];
    marker.position = new currentWindow.google.maps.LatLng(
      location.lat,
      location.lng
    );
    marker.setMap(mapInstance);
    // Populate in respective details object as well
    marker.info.lat = location.lat;
    marker.info.lng = location.lng;
    if (bounds) {
      bounds.extend(marker.position);
    }
    added = true;
  } else if (marker.address && marker.address != "") {
    lookupLatLng(marker);
  } else {
    // Report error
    // Add Id field to open the record from salesforce.
    // Currently its implemented for Workorder in DC error message
    // When route is plotted and WO related to event doesnot have location info,
    // take the Id from WOId field
    const Id = marker.info.WOId ? marker.info.WOId : marker.info.Id;
    // const markerId = Id ? Id : marker.info.id;
    let markerName = marker.Name;
    if (marker.salesforceUser) {
      markerName = marker.techName;
    }
    invalidMarkers.push({ Id, Name: markerName, type: marker.type });
    invalidMarkersIds.push(Id);
    if (invalidMarkersIds.length) {
      displayErrorInScheduler();
    }
    added = true;
  }
  return added;
};

const drawPlotCenter = (latLng, fromClick = false) => {
  clearPlotCenter();
  plotNearByLatLng = latLng;
  const image = {
    anchor: new currentWindow.google.maps.Point(13, 30), // image size is 39x34.
    origin: new currentWindow.google.maps.Point(0, 0),
    url: MAP_PLOT_CENTER_ICON
  };
  plotCenterMarker = createMarker(plotNearByLatLng, "PlotCenter", image);
  addMarker(plotCenterMarker);
  setLastPlottedLatLng(plotNearByLatLng);
  const info =
    `${"<div style='text-align:left; user-select:text;'>" +
      "<B>" +
      "Search Area" +
      "</B><br/><br/>" +
      "<B>" +
      "Latitude" +
      "</B>: "}${plotNearByLatLng.lat()}<br/>` +
    "<B>" +
    "Longitude" +
    `</B>: ${plotNearByLatLng.lng()}<br/>` +
    "<B>" +
    "Radius" +
    `</B>: ${plotCircleRadius}&nbsp;` +
    "mile" +
    "</div>";

  const infowindow = new currentWindow.google.maps.InfoWindow({
    content: info,
    pixelOffset: new currentWindow.google.maps.Size(0, -15)
  });

  // mouseover used to fix issue #10659. Since we are not using mouseout, there should be no problem
  currentWindow.google.maps.event.addListener(
    plotCenterMarker,
    "mouseover",
    () => {
      infowindow.open(mapInstance, plotCenterMarker);
    }
  );
  const plotCircleData = getLastPlotCircleData();
  if (plotCircleData && fromClick) {
    setLastPlotCircleDataReset();
  }
};

export const createRequiredGoogleService = () => {
  // Create required service for map
  // Inherit from GOverlay
  CustomCircleOverlay.prototype = new currentWindow.google.maps.OverlayView();

  if (!directionsDisplay) {
    directionsDisplay = new currentWindow.google.maps.DirectionsRenderer();
    directionsDisplay.setOptions({
      suppressMarkers: true,
      suppressPolylines: true
    });
    directionsDisplay.setMap(mapInstance);
  }
  if (!directionsService) {
    directionsService = new currentWindow.google.maps.DirectionsService();
  }
  if (!trafficLayer) {
    trafficLayer = new currentWindow.google.maps.TrafficLayer();
  }

  trafficLayerDiv = getTrafficOverlayDiv();
  mapInstance.controls[
    currentWindow.google.maps.ControlPosition.RIGHT_TOP
  ].push(trafficLayerDiv);
  currentWindow.google.maps.event.addDomListener(
    trafficLayerDiv,
    "click",
    setTrafficLayerVisibility
  );

  const center = mapInstance.getCenter();
  currentWindow.google.maps.event.trigger(mapInstance, "resize");
  mapInstance.setCenter(center);
  mapInstance.setZoom(mapInstance.getZoom());

  currentWindow.google.maps.event.addListener(mapInstance, "click", event => {
    drawPlotCenter(event.latLng, true);
  });
};

export const mapInitilizedConfigure = () => {
  currentWindow.google.maps.event.addListener(mapInstance, "idle", () => {
    const latlon = mapInstance.getCenter();
    const changed = {};
    changed.tech_mapDefaultLat = latlon.lat();
    changed.tech_mapDefaultLng = latlon.lng();
    changed.tech_mapDefaultZoomLevel = mapInstance.getZoom();
    mapUserConfigChange(changed);
  });

  currentWindow.google.maps.event.addListener(
    mapInstance,
    "mouseout",
    () => {}
  );
};

export const mapUserConfigChange = changed => {
  const event = new CustomEvent(MAP_CUSTOM_EVENT_MAP_CONFIG_CHANGE, {
    detail: changed
  });
  window.dispatchEvent(event);
};

const clearCircle = () => {
  clearPlotCenter();
  if (plotCircle) {
    plotCircle.remove();
    plotCircle.setMap(null);
  }
  plotCircle = null;
};

export const getPlotNearByLatLng = () => {
  const currentLatLng = {
    lat: plotNearByLatLng.lat(),
    lng: plotNearByLatLng.lng()
  };
  return currentLatLng;
};

const drawCircle = radius => {
  circleRadius = radius;
  const currentLatLng = getPlotNearByLatLng();
  let latLng = new currentWindow.google.maps.LatLng(
    currentLatLng.lat,
    currentLatLng.lng
  );
  if (searchTechData && searchTechData.selectedWO) {
    latLng = new currentWindow.google.maps.LatLng(
      searchTechData.selectedWO.lat,
      searchTechData.selectedWO.lng
    );
  }
  plotCircle = new CustomCircleOverlay(
    mapInstance,
    latLng,
    radius,
    mapUnitTextValue,
    "mile",
    "#FF0000",
    2,
    0.8,
    "#FF0000",
    0.35
  );
  currentWindow.google.maps.event.addListener(plotCircle, "click", event => {
    drawPlotCenter(event.latLng);
  });
};

const clearMarkers = () => {
  flatMap(plotNearByMarkers, item => {
    item.setMap(null);
  });
  plotNearByMarkers = [];
};

const clearPlot = () => {
  nearByMarkersMap = {};
  clearMarkers();
  clearPlotCenter();
};

export const getViewDataToPlotInternal = (radiusValue, isPlotMode) => {
  plotMode = isPlotMode;
  clearCircle();
  clearPlot();
  drawPlotCenter(plotNearByLatLng);
  drawCircle(radiusValue);
};

const hideTrafficLayer = () => {
  if (trafficLayer) {
    trafficLayer.setMap(null);
    trafficLayerDiv.style.backgroundColor = "#FFFFFF";
  }
};

export const clearMap = () => {
  clearCircle();
  hideTrafficLayer();
  clearPlot();
  invalidMarkers = [];
  invalidMarkersIds = [];
  clearRadiusModeCircle();
  clearSearchTechMarkers();
  clearSearchTeamMarkers();
  setLastPlotCircleDataReset();
  setMapPlotReset();
  setSearchTechDone(false);
};

const getIconForSelectedObject = context => {
  const selectObject = context.objectName;
  let ret = "";
  if (selectObject === WORKORDER_API_NAME) {
    ret = defaultConfig.woIcon;
    // ret = Literals.BALLOON_URL;
  } else if (selectObject === LOCATION_API_NAME) {
    ret = defaultConfig.locIcon;
  } else {
    // account
    ret = defaultConfig.accIcon;
  }
  return ret;
};

/* const openRecord = Id => {
  // const url = `/${Id}?isdtp=mn`;

  openPopUp(Id);
  // const url = `${document.location.protocol}//${document.location.host}/${Id}?isdtp=mn`;
  // window.open(encodeURI(url), '_blank', 'width=800,height=600,resizable=1,status=0,scrollbars=1');
}; */

/* window.openRecord = Id => {
  // const url = `/${Id}?isdtp=mn`;

  openPopUp(Id);
  // const url = `${document.location.protocol}//${document.location.host}/${Id}?isdtp=mn`;
  // window.open(encodeURI(url), '_blank', 'width=800,height=600,resizable=1,status=0,scrollbars=1');
}; */

const checkForValidImage = src => {
  // Create new offscreen image to test
  const imageSrc = new Image();
  imageSrc.src = src;
  // Get accurate measurements from that.
  if (imageSrc.width > 0 && imageSrc.height > 0) {
    return true;
  }
  return false;
};

function showInfo() {
  // If already open for this marker then return
  if (infoWindow && infoWindow.anchor === this) {
    return;
  }
  const { address, info, initial, SmallPhotoUrl, subject, type } = this;

  let { Name } = this;
  let { hoverInfo } = info;
  const { id, Id, WOId } = info; // Be it team, tech or WO marker, this property will be there
  let validImage = false;
  if (!hoverInfo) {
    hoverInfo = address;
  }
  if (type === "Overnight") {
    if (address === undefined) {
      hoverInfo = subject;
    } else {
      hoverInfo = `${subject} , ${address}`;
    }
  }
  let smallPhotoUrl = SmallPhotoUrl;
  let imagestring;
  //smallPhotoUrl = "https://www.qries.com/images/banner_logo.png";
  if (smallPhotoUrl) {
    imagestring = `<img src=${smallPhotoUrl} alt=${Name} style="width: 1.5rem;
    height: 1.5rem;
    line-height: 1;vertical-align:middle;border-radius: 50%;">`;
  } else {
    imagestring = ReactDOMServer.renderToString(
      <div className="MapContainer__Name">
        <figure>
          <Icon
            align="center"
            category="utility"
            className="MapContainer__Image"
            fillColor=""
            hasContainer={false}
            icon="user"
            isDisabled={false}
            onClick={function noRefCheck() {}}
            size="small"
            tabIndex={null}
            textColor="default"
          />
        </figure>
      </div>
    ); // `<img src=${smallPhotoUrl} alt=${initial} style="vertical-align:middle;border-radius: 50%;">`;
  }
  /*if (smallPhotoUrl) {
    validImage = checkForValidImage(smallPhotoUrl);
    if (validImage) {
      imagestring =
        '<svg height="210" width="400"><path d="M150 0 L75 200 L225 200 Z" /></svg>'; // `<img src=${smallPhotoUrl} alt=${initial} style="vertical-align:middle;border-radius: 50%;">`;
    } else {
      smallPhotoUrl =
        '<svg height="210" width="400"><path d="M150 0 L75 200 L225 200 Z" /></svg>'; // MAP_INFO_PHOTO_ICON;// `${window.getResourcePath()}resources/themes/images/svmx-dc-map/custom/Technician25.png`;
      imagestring =
        '<svg height="210" width="400"><path d="M150 0 L75 200 L225 200 Z" /></svg></svg>'; // `<img src=${smallPhotoUrl} alt=${initial} style="vertical-align:middle;border-radius: 50%;">`;
    }
  } else {
    smallPhotoUrl =
      '<svg height="210" width="400"><path d="M150 0 L75 200 L225 200 Z" /></svg>'; // MAP_INFO_PHOTO_ICON;// `${window.getResourcePath()}resources/themes/images/svmx-dc-map/custom/Technician25.png`;
    imagestring = ReactDOMServer.renderToString(
      <div className="MapContainer__Name">
        <figure>
          <Icon
            align="center"
            category="utility"
            className="MapContainer__Image"
            fillColor=""
            hasContainer={false}
            icon="user"
            isDisabled={false}
            onClick={function noRefCheck() {}}
            size="small"
            tabIndex={null}
            textColor="default"
          />
        </figure>
      </div>
    ); // `<img src=${smallPhotoUrl} alt=${initial} style="vertical-align:middle;border-radius: 50%;">`;
  }*/
  if (type === "WO" || type === "Team" || type === "Overnight") {
    imagestring = "";
  }
  // imagestring=`<svg class="svg-icon" viewBox="0 0 20 20"><path fill="none" d=${MAP_TECH_IMAGE_PATH_SVG}></path></svg>`;
  if (type === "Overnight") {
    Name = "Overnight Stay Event";
  }
  const infoIconUrl = MAP_INFO_ICON_URL;
  // `${window.getResourcePath()}resources/themes/images/svmx-dc-map/custom/info_icon.png`;

  // If WOId is there then use it to open workorder
  // else open the respective team or technician record
  const recordId = WOId || Id || id;
  const callBack = `openRecord('${recordId}')`;
  // const callBack = openRecord(recordId);
  // to break down a really long word, styles were added to <p> tag to avoid text getting clipped
  // Fix for issue #9976
  let contentString;
  if (type === "Overnight") {
    contentString =
      `<div id="content" style="user-select: text !important;width:230px;line-height:1.35;overflow:hidden;text-align:left;margin:0px;">${imagestring}<b style="margin-left: 5px;">${Name}</b><p style="word-break: break-all;margin-right:17px">${hoverInfo}</p>` +
      "</div>";
  } else {
    contentString =
      `<div id="content" style="user-select: text !important;width:230px;line-height:1.35;overflow:hidden;text-align:left;margin:0px;">${imagestring}<b style="margin-left: 5px;">${Name}</b><p style="word-break: break-all;margin-right:17px">${hoverInfo}</p>` +
      `<img src="${infoIconUrl}" style="position:absolute;top:0px;right:22px;height:15px;width:15px;cursor:pointer` +
      `" onclick="${callBack}"/>` +
      "</div>";
  }

  if (!infoWindow) {
    infoWindow = new currentWindow.google.maps.InfoWindow({
      pixelOffset: new currentWindow.google.maps.Size(0, -15)
    });
  } else {
    infoWindow.setContent(""); // = null;
    infoWindow.close();
    infoWindow = new currentWindow.google.maps.InfoWindow({
      pixelOffset: new currentWindow.google.maps.Size(0, -15)
    });
  }

  infoWindow.open(mapInstance, this);
  infoWindow.setContent(contentString);

  currentWindow.google.maps.event.addListener(infoWindow, "closeclick", () => {
    infoWindow.setContent(""); // = null;
    infoWindow.close();
  });
}

export const setCurrentWindow = value => {
  currentWindow = value;
  currentWindow.openRecord = Id => {
    // const url = `/${Id}?isdtp=mn`;
    openPopUp(Id);
    // const url = `${document.location.protocol}//${document.location.host}/${Id}?isdtp=mn`;
    // window.open(encodeURI(url), '_blank', 'width=800,height=600,resizable=1,status=0,scrollbars=1');
  };
};

const createPlotMarker = (data, refItem, markerIcon) => {
  const latLng = new currentWindow.google.maps.LatLng(refItem.lat, refItem.lng);
  const marker = createMarker(latLng, "", markerIcon);
  marker.info = refItem;
  marker.name = refItem.viewId;
  addMarker(marker);
  plotNearByMarkers.push(marker);
  currentWindow.google.maps.event.addListener(marker, "mouseover", showInfo);
  return marker;
};

const getMarkersForRecord = viewId => nearByMarkersMap[viewId];

export const plot = data => {
  const items = data.items || [];
  let refItem = null;
  const markerIcon = getIconForSelectedObject(data.context);
  items.map(item => {
    const { viewId } = item;
    // const markers = getMarkersForRecord(viewId);
    // if (!markers) {
    refItem = item;
    refItem.Id = refItem.id;
    refItem.hoverInfo = refItem.hoverInfo || "";
    refItem.hoverInfo = refItem.hoverInfo.replace(
      new RegExp("\\n", "g"),
      "<br/>"
    );
    refItem.hoverInfo = `<div style='text-align:left;'>${refItem.hoverInfo}</div>`;

    let marker;
    if (nearByMarkersMap[viewId]) {
      marker = nearByMarkersMap[viewId];
    } else {
      marker = [];
      nearByMarkersMap[viewId] = marker;
    }
    marker.push(createPlotMarker(data, refItem, markerIcon));
    // }
    return undefined;
  });
};

export const toggleViewSelection = (record, checked) => {
  const markers = getMarkersForRecord(record);
  if (markers) {
    markers.map(item => {
      if (checked) {
        item.setMap(mapInstance);
      } else {
        item.setMap(null);
      }
      return undefined;
    });
  }
};

export const clearRadiusModeCircle = () => {
  if (radiusModeCircle) {
    radiusModeCircle.remove();
    radiusModeCircle.setMap(null);
  }
  radiusModeCircle = null;
};

export const radiusModeNoLimitHandler = () => {
  clearRadiusModeCircle();
  noLimit = true;
  bounds = new currentWindow.google.maps.LatLngBounds();
  const zoomeLevel = mapInstance.getZoom();
  const center = mapInstance.getCenter();
  let boundFound = false;
  if (searchTechMarkers) {
    searchTechMarkers.map(item => {
      if (item.type !== MAP_WORKORDER) {
        item.setMap(mapInstance);
        boundFound = true;
        // mapInstance.panTo(item.position)
        bounds.extend(item.position);
      }
      return undefined;
    });
  }
  if (!boundFound) {
    const latlon = mapInstance.getCenter();
    bounds.extend(latlon);
  }
  mapInstance.fitBounds(bounds);
  mapInstance.setZoom(zoomeLevel);
  return undefined;
};

const isInRange = (marker, wo, radius /* in meters */) => {
  if (!marker || !wo) {
    return undefined;
  }
  const markerLatlng = marker.getPosition();
  const woLatlng = new currentWindow.google.maps.LatLng(wo.lat, wo.lng);
  let distance;
  // distance in meters
  if (typeof markerLatlng !== "undefined") {
    if (!currentWindow.google.maps.geometry)
      currentWindow.google.maps.geometry = currentWindow.document.geometry;
    distance = currentWindow.google.maps.geometry.spherical.computeDistanceBetween(
      markerLatlng,
      woLatlng
    );
  }
  return distance <= radius;
};

export const drawRadiusForSearch = (radius, techList) => {
  radiusMode = true;
  circleRadius = radius;
  selectedCircleRadius = radius;
  if (!searchTechData) {
    return undefined;
  }
  let wo;
  if (searchTechData.selectedWO) {
    wo = searchTechData.selectedWO;
  }

  clearRadiusModeCircle();
  if (wo) {
    const ll = new currentWindow.google.maps.LatLng(wo.lat, wo.lng);
    radiusModeCircle = new CustomCircleOverlay(
      mapInstance,
      ll,
      radius,
      defaultConfig.mapUnitText,
      "mile",
      "#6EA6E5",
      2,
      0.8,
      "#6EA6E5",
      0.35
    );
  }
  checkMarkerForRadius(circleRadius);
  return undefined;
};

const checkMarkerForRadius = (circleRadius = selectedCircleRadius) => {
  if (defaultConfig.mapUnit === "miles") {
    circleRadius *= 1.60934;
  }
  circleRadius = circleRadius * 1.0 * 1000;
  bounds = new currentWindow.google.maps.LatLngBounds();
  const zoomeLevel = mapInstance.getZoom();
  const center = mapInstance.getCenter();
  let boundFound = false;

  if (searchTechMarkers) {
    searchTechMarkers.map(item => {
      if (item.type === MAP_WORKORDER) {
        bounds.extend(item.position);
        boundFound = true;
        // mapInstance.panTo(item.position)
      } else {
        if (!isInRange(item, searchTechData.selectedWO, circleRadius)) {
          item.setMap(null);
        }
        if (!searchTechData.selectedWO) {
          bounds.extend(item.position);
          boundFound = true;
        }
      }
      return undefined;
    });
  }

  if (!boundFound) {
    const latlon = mapInstance.getCenter();
    bounds.extend(latlon);
  }

  /* if (searchTechMarkers) {
    searchTechMarkers.map((item) => {
      if ((item.type !== MAP_WORKORDER)
       && (isInRange(item, searchTechData.selectedWO, circleRadius))
      ) {
        //item.setMap(mapInstance);
        if (!searchTechData.selectedWO) {
        //bounds.extend(item.position);
        }
      }
      return undefined;
    });
  }  */
  mapInstance.fitBounds(bounds);
  // mapInstance.setCenter(center);
  // mapInstance.setZoom(mapInstance.getZoom());
  mapInstance.setZoom(zoomeLevel);
};

export const clearSearchTechMarkers = () => {
  if (searchTechMarkers) {
    searchTechMarkers.map(item => {
      item.setMap(null);
      return undefined;
    });

    searchTechMarkers = null;
  }
  searchAllTechMarkers.map(searchAllTechMarkerItem => {
    searchAllTechMarkerItem.setMap(null);
    return undefined;
  });
  searchTechData = null;
};

const createMarkerFrom = (
  data /* Team/Tech/WO details with lat,lng and address */,
  scale /* Boolean */,
  type /* Team/Tech/WO */
) => {
  let lat;
  let lng;
  let position;
  let marker;

  if (data.lat) {
    lat = Number(data.lat);
  }
  if (data.lng) {
    lng = Number(data.lng);
  }
  if (lat !== undefined && lng !== undefined) {
    position = new currentWindow.google.maps.LatLng(lat, lng);
  }
  let icon = defaultConfig.techIcon;
  if (type === MAP_TEAM) {
    icon = defaultConfig.teamIcon;
  } else if (type === MAP_WORKORDER) {
    icon = defaultConfig.woIcon;
  }
  let { address } = data;
  // For technician with current location, don't display address as data.
  // address has value for home address
  if (type === MAP_TECHNICIAN) {
    address = "";
  }
  marker = createMarker(position, data.name, icon, address, scale, type);
  return marker;
};

const getTechColorForRoute = (Id /* String */) => {
  let color = "";
  // Initialize color counter
  if (!getTechColorCounter.colorCounter) {
    getTechColorCounter.colorCounter = 0;
  }
  if (techColorMap[Id]) {
    color = techColorMap[Id];
  } else {
    color = TECH_ROUTE_COLORS[getTechColorCounter.colorCounter];
    getTechColorCounter.colorCounter += 1;
    techColorMap[Id] = color;
    if (getTechColorCounter.colorCounter === TECH_ROUTE_COLORS.length) {
      getTechColorCounter.colorCounter = 0;
    }
  }
  return color;
};

const createMarkerWithLabel = (
  latLng /* LatLng */,
  title /* LatLng */,
  icon /* String */,
  address /* String */,
  icontype /* String */,
  markercolor /* String */,
  FirstName /* String */,
  LastName /* String */,
  SmallPhotoUrl /* String */,
  scale /* Boolean */,
  type /* String - Tech/Team/WO */,
  techName,
  salesforceUser
) => {
  let image = icon;
  if (typeof image === "string") {
    image = {
      url: icon
    };
  }
  const firstName = FirstName;
  const lastName = LastName;
  const IconType = icontype;
  const MarkerColor = markercolor;
  let str = "";
  let arr = [];
  if (firstName) {
    str = String(firstName).substring(0, 1);
  }
  if (lastName) {
    if (lastName && firstName) {
      str =
        String(firstName).substring(0, 1) + String(lastName).substring(0, 1);
    } else {
      str = String(lastName).substring(0, 1);
    }
  }
  arr = title.split(" ");
  if (arr.length > 0) {
    if (!firstName) {
      str = String(arr[0]).substring(0, 1);
    }
  }
  if (arr.length > 1) {
    if (!lastName) {
      str = String(arr[0]).substring(0, 1) + String(arr[1]).substring(0, 1);
    }
  }
  const marker = new currentWindow.google.maps.Marker({
    // Set address as well. Its not a property of MarkerOptions
    // but can be used if latLng not available
    address,
    // Shadow wont work in v3.14
    // shadow : icon,
    anchorPoint: new currentWindow.google.maps.Point(0, 0),
    // labelContent :"ABCD",
    icon: image,
    label: {
      color: "#FFFFFF",
      text: str
    },
    position: latLng,
    title: ""
  });
  if (scale === true) {
    const iconObj = {};
    iconObj.url = icon;
    // Do not scale as it creates problem when using svg
    // iconObj.scaledSize = new google.maps.Size(25,25);
    marker.icon = iconObj;
    if (IconType === MAP_TECH_HOME) {
      marker.icon = {
        anchorPoint: new currentWindow.google.maps.Point(0, 0),
        fillColor: MarkerColor,
        fillOpacity: 1,
        path: MAP_HOME_MARKER_SVG,
        scale: 1,
        strokeColor: "black",
        strokeWeight: 0
      };
      marker.scale = 0.3;
    }
    if (IconType === MAP_TECH_CURRENT) {
      marker.icon = {
        anchor: new currentWindow.google.maps.Point(0, 0),
        fillColor: MarkerColor,
        fillOpacity: 1,
        path: MAP_CURRENT_MARKER_SVG,
        scale: 0.6,
        strokeColor: "black",
        strokeWeight: 0
      };
      marker.scale = 0.3;
    }
  }
  marker.Name = title;
  marker.type = type;
  marker.FirstName = FirstName;
  marker.LastName = LastName;
  marker.SmallPhotoUrl = SmallPhotoUrl;
  marker.initial = str;
  marker.iconType = icontype;
  marker.techName = techName;
  marker.salesforceUser = salesforceUser;
  return marker;
};

const createTechMarker = (
  data /* Team/Tech/WO details with lat,lng and address */,
  markercolor /* String */,
  scale /* Boolean */,
  type /* Team/Tech/WO */,
  markerType /* Home/Current */
) => {
  let lat;
  let lng;
  let position;
  let marker;
  let icon;
  const MarkerColor = markercolor;
  let { address } = data;
  let techName = data.Name || data.name;
  const isSalesForceUser = data.isTechSalesforceUser;
  const techNameOrg = data.Name || data.name;
  if (data.isTechSalesforceUser) {
    techName = data.isTechSalesforceUser.Name;
  }
  // For technician with current location,
  // don't display address as data.address has value for home address
  if (type === MAP_TECHNICIAN) {
    address = "";
  }

  if (type === MAP_TEAM) {
    icon = defaultConfig.teamIcon;
  } else if (type === MAP_WORKORDER) {
    icon = MAP_BALLOON_URL;
  }

  if (markerType === MAP_TECH_CURRENT) {
    if (data.lat) {
      lat = Number(data.lat);
    }
    if (data.lng) {
      lng = Number(data.lng);
    }
    icon = defaultConfig.techIcon;
    if (lat !== undefined && lng !== undefined) {
      position = new currentWindow.google.maps.LatLng(lat, lng);
    }
    marker = createMarkerWithLabel(
      position,
      techName,
      icon,
      address,
      MAP_TECH_CURRENT,
      MarkerColor,
      data.FirstName,
      data.LastName,
      data.SmallPhotoUrl,
      scale,
      type,
      techNameOrg,
      isSalesForceUser
    );
  } else {
    if (data.homeLat) {
      lat = Number(data.homeLat);
    }
    if (data.homeLng) {
      lng = Number(data.homeLng);
    }
    icon = defaultConfig.techHomeIcon;
    if (lat !== undefined && lng !== undefined) {
      position = new currentWindow.google.maps.LatLng(lat, lng);
    }
    marker = createMarkerWithLabel(
      position,
      techName,
      icon,
      data.homeAddress,
      MAP_TECH_HOME,
      MarkerColor,
      data.FirstName,
      data.LastName,
      data.SmallPhotoUrl,
      scale,
      type,
      techNameOrg,
      isSalesForceUser
    );
  }
  return marker;
};

const getFirstMarkerWithValidLatLng = (markers /* Array */) => {
  if (!markers || markers.length === 0) {
    return undefined;
  }
  let marker = null;
  markers.map(item => {
    let result = false;
    if (item.position) {
      result = true;
      marker = item;
      return marker;
    }
    return undefined;
  });
  return marker;
};

export const clearSearchTeamMarkers = () => {
  if (searchTeamMarkers) {
    searchTeamMarkers.map(item => {
      item.setMap(null);
      return undefined;
    });
    searchTeamMarkers = null;
  }
  searchTeamData = null;
  searchAllTeamMarkers.map(searchAllTeamMarkerItem => {
    searchAllTeamMarkerItem.setMap(null);
    return undefined;
  });
};

/**
 * Plot the search results for team search
 * teams - array of teams
 * selectedWO - workorder details if search is performed for a selected workorder
 */
export const drawSearchedTeams = (
  teams /* Array */,
  selectedWO /* workorder details */
) => {
  // setStautsMsgEmpty();
  // Fix for issue #10674. Allow the wo to be plotted if no team found
  if ((!teams || !teams.length) && !selectedWO) {
    return undefined;
  }

  let callLater = false;
  let added = true;

  const event = new CustomEvent(MAP_CUSTOM_EVENT_SHOW_LOCATION_BAR, {
    detail: {
      show: false
    }
  });
  // window.dispatchEvent(event);

  clearSearchTeamMarkers();

  searchTeamData = { selectedWO, teams };
  if (!searchTeamMarkers) {
    searchTeamMarkers = [];
  }

  if (selectedWO) {
    const woMarker = createMarkerFrom(selectedWO, false, MAP_WORKORDER);
    woMarker.info = selectedWO;
    added = addMarker(woMarker);
    if (!added) {
      callLater = true;
    }
    currentWindow.google.maps.event.addListener(
      woMarker,
      "mouseover",
      showInfo
    );
    searchTeamMarkers.push(woMarker);
    searchAllTeamMarkers.push(woMarker);
  }
  teams.map(item => {
    const team = item;
    const teamMarker = createMarkerFrom(team, false, MAP_TEAM);
    teamMarker.info = team;
    added = addMarker(teamMarker);
    if (!added) {
      callLater = true;
    }
    currentWindow.google.maps.event.addListener(
      teamMarker,
      "mouseover",
      showInfo
    );
    // Persist the markers
    searchTeamMarkers.push(teamMarker);
    searchAllTeamMarkers.push(teamMarker);
    return undefined;
  });
  let firstTeam = null;

  if (!callLater) {
    firstTeam = getFirstMarkerWithValidLatLng(searchTeamMarkers);
    // Pan to first team having valid lat lng
    if (firstTeam) {
      mapInstance.panTo(firstTeam.position);
    }
    displayErrorInScheduler();
  } else {
    const callAfterLatLngLookup = function() {
      firstTeam = getFirstMarkerWithValidLatLng(searchTeamMarkers);
      if (firstTeam) {
        // Pan to first team having valid lat lng
        mapInstance.panTo(firstTeam.position);
      }
      displayErrorInScheduler();
    };

    callBackStack.push({
      callBackFor: "drawSearchedTeams",
      callBack: callAfterLatLngLookup
    });
  }
};

export const displayErrorInScheduler = (message /* String */) => {
  const errorInfo = {};
  errorInfo.invalidMarkers = invalidMarkers.length == 0 ? null : invalidMarkers;

  if (message) {
    errorInfo.message = message;
  }
  showError(errorInfo);
  // handle.displayErrorInDC(errorInfo);
  // invalidMarkers = [];
};

export const setErrorConfigCallBackFunction = callbackFun => {
  errorCallBackFunction = callbackFun;
};
export const setMapContainerResetCallBackFunction = callbackFun => {
  resetCallBackFunction = callbackFun;
};
export const resetMapContainer = () => {
  const mapEnabled = JSON.parse(getUserSetting(MAP_CONFIG, false));
  if (mapEnabled) {
    resetCallBackFunction();
  }
};

export const setShowRouteCallBackFunction = callbackFun => {
  showRouteCallBackFunction = callbackFun;
};

export const showError = errorInfo => {
  if (!errorInfo) {
    return;
  }

  if (errorInfo.invalidMarkers && errorInfo.invalidMarkers.length) {
    let msgDetails = "";
    const techs = [];
    const teams = [];
    const wos = [];

    errorInfo.invalidMarkers.forEach((item, index, arr) => {
      if (item.type == "Tech") {
        techs.push(item.Name);
      } else if (item.type == "Team") {
        teams.push(item.Name);
      } else if (item.type == "WO") {
        wos.push(item.Name);
      }
    });

    if (teams.length > 0) {
      const teamsSetUnique = new Set(teams);
      const teamsUnique = [...teamsSetUnique];
      msgDetails = `${getDisplayValue("TAG339")}\n`;
      msgDetails += teamsUnique.join("\n");
    }

    if (techs.length > 0) {
      const techsSetUnique = new Set(techs);
      const techsUnique = [...techsSetUnique];
      if (msgDetails.length > 0) {
        msgDetails += "\n\n";
      }

      msgDetails = `${getDisplayValue("TAG340")}\n`;
      msgDetails += techsUnique.join("\n");
    }

    if (wos.length > 0) {
      const wosUniqueSet = new Set(wos);
      const wosUnique = [...wosUniqueSet];
      if (msgDetails.length > 0) {
        msgDetails += "\n\n";
      }

      msgDetails = `${getDisplayValue("TAG178")}\n`;
      msgDetails += wosUnique.join("\n");
    }
    if (msgDetails.length > 0) {
      // If either tech or any related WO does not have location info, throw error right away
      errorInfo.message = getDisplayValue(TAG177);
      errorInfo.markerMsg = msgDetails;
      errorInfo.errorCodeMsg = getDisplayValue(TAG260);
      errorCallBackFunction(errorInfo);
    }
  } else if (errorInfo.message) {
    errorInfo.errorCodeMsg = getDisplayValue(TAG260);
    errorCallBackFunction(errorInfo);
  }
};

/**
 * Plot the search results for technician search
 * technicians - array of technicians
 * selectedWO - workorder details if search is performed for a selected workorder
 */
export const drawSearchedTechnicians = (
  technicians /* Array */,
  selectedWO /* workorder details */
) => {
  // setStautsMsgEmpty();
  // Fix for issue #10674. Allow the wo to be plotted if no technician found
  plotMode = false;
  if ((!technicians || !technicians.length) && !selectedWO) {
    return undefined;
  }
  tempTechList = technicians;
  tempSelectedWO = selectedWO;
  let techMarker;
  let techHomeMarker;
  let woMarker;
  let callLater = false;
  let added = true;
  clearSearchTechMarkers();
  const event = new CustomEvent(MAP_CUSTOM_EVENT_SHOW_LOCATION_BAR, {
    detail: {
      show: true
    }
  });
  window.dispatchEvent(event);
  setSearchTechDone(true);
  searchTechData = { selectedWO, technicians };
  if (!searchTechMarkers) {
    searchTechMarkers = [];
  }
  if (selectedWO) {
    radiusMode = true;
    woMarker = createMarkerFrom(selectedWO, false, MAP_WORKORDER);
    woMarker.info = selectedWO;
    added = addMarker(woMarker);
    if (!added) {
      callLater = true;
    }
    currentWindow.google.maps.event.addListener(
      woMarker,
      "mouseover",
      showInfo
    );
    searchTechMarkers.push(woMarker);
    searchAllTechMarkers.push(woMarker);
  } else {
    radiusMode = false;
  }

  technicians.map(item => {
    const technician = item;
    const MarkerColor = getTechColorForRoute(technician.id);

    techMarker = createTechMarker(
      technician,
      MarkerColor,
      true,
      MAP_TECHNICIAN,
      MAP_TECH_CURRENT
    );
    techMarker.info = technician;

    techHomeMarker = createTechMarker(
      technician,
      MarkerColor,
      true,
      MAP_TECHNICIAN,
      MAP_TECH_HOME
    );
    techHomeMarker.info = technician;

    currentWindow.google.maps.event.addListener(
      techMarker,
      "mouseover",
      showInfo
    );
    currentWindow.google.maps.event.addListener(
      techHomeMarker,
      "mouseover",
      showInfo
    );

    if (homeRadio) {
      added = addMarker(techHomeMarker);
      searchTechMarkers.push(techHomeMarker);
      searchAllTechMarkers.push(techHomeMarker);
    } else if (currentRadio) {
      added = addMarker(techMarker);
      searchTechMarkers.push(techMarker);
      searchAllTechMarkers.push(techMarker);
    } else {
      added = addMarker(techHomeMarker);
      added = addMarker(techMarker);
      searchTechMarkers.push(techHomeMarker);
      searchTechMarkers.push(techMarker);
      searchAllTechMarkers.push(techHomeMarker);
      searchAllTechMarkers.push(techMarker);
    }
    if (!added) {
      callLater = true;
    }
    // return undefined;
  });
  const firstTech = null;
  if (!callLater) {
    // firstTech = getFirstMarkerWithValidLatLng(searchTechMarkers);
    // Pan to first tech having valid lat lng
    // if (firstTech) {
    // mapInstance.panTo(firstTech.position);
    // }
    // If a workorder is selected and has a valid location, then only radius mode is applicable
    if (
      selectedWO &&
      invalidMarkersIds &&
      invalidMarkersIds.indexOf(woMarker.info.WOId) === -1
    ) {
      // radiusModeControlsVisible(true);
      if (radiusMode && !noLimit) {
        circleRadius = selectedCircleRadius;
        drawRadiusForSearch(circleRadius);
      }
    } else {
      radiusModeNoLimitHandler();
    }
    displayErrorInScheduler();
  } else {
    const callAfterLatLngLookup = () => {
      // firstTech = getFirstMarkerWithValidLatLng(searchTechMarkers);
      // Pan to first tech having valid lat lng
      // if (firstTech) {
      // mapInstance.panTo(firstTech.position);
      // }
      // If a workorder is selected and has a valid location, then only radius mode is applicable
      if (
        selectedWO &&
        invalidMarkersIds &&
        invalidMarkersIds.indexOf(woMarker.info.WOId) === -1
      ) {
        // radiusModeControlsVisible(true);
        // drawRadiusForSearch(radiusComp.getValue());
        if (radiusMode && !noLimit) {
          circleRadius = selectedCircleRadius;
          drawRadiusForSearch(circleRadius);
        }
      } else {
        radiusModeNoLimitHandler();
      }
      displayErrorInScheduler();
    };
    callBackStack.push({
      callBack: callAfterLatLngLookup,
      callBackFor: "drawSearchedTechnicians"
    });
  }
  return undefined;
};

export const setLocationBaseRadio = (rValue, configSave = false) => {
  homeRadio = false;
  currentRadio = false;
  bothRadio = false;
  const changed = {};
  if (rValue === MAP_TECH_HOME) {
    homeRadio = true;
  } else if (rValue === MAP_TECH_CURRENT) {
    currentRadio = true;
  } else {
    bothRadio = true;
  }
  changed.tech_locationBase = rValue;
  if (configSave) {
    mapUserConfigChange(changed);
  }
  if (searchTechData && configSave) {
    // clearSearchTechMarkers();
    drawSearchedTechnicians(
      searchTechData.technicians,
      searchTechData.selectedWO
    );
    // clearRadiusModeCircle();
    // drawRadiusForSearch( searchTechData.technicians,searchTechData.selectedWO);
  }
  // if (plotRouteData) {
  // clearRadiusModeCircle();
  // drawRadiusForSearch(plotRouteData);
  // }
  if (techRouteData && configSave) {
    const showRouteDone = getShowRouteDataMapDone();
    if (showRouteDone) {
      drawTechRouteForDay(localCurrentDate, false, true);
    }
    drawTechRouteForDay(localCurrentDate, false, true);
  }
};

export const handleSearchRadiusChange = radius => {
  radiusMode = true;
  circleRadius = radius;
  selectedCircleRadius = radius;
  noLimit = false;
  if (searchTechData) {
    drawSearchedTechnicians(
      searchTechData.technicians,
      searchTechData.selectedWO
    );
  }
};

const createOvernightStayMarker = (
  data /* Team/Tech/WO details with lat,lng and address */,
  markercolor /* String */,
  scale /* Boolean */,
  type /* Team/Tech/WO */
) => {
  let lat;
  let lng;
  let position;
  let marker;
  if (data.lat !== "undefined") {
    lat = Number(data.lat);
  }
  if (data.lng !== "undefined") {
    lng = Number(data.lng);
  }
  if (data.lat !== "undefined" && data.lng !== "undefined") {
    position = new currentWindow.google.maps.LatLng(lat, lng);
  }
  let icon = defaultConfig.techIcon;
  const MarkerColor = markercolor;
  if (type === MAP_TEAM) {
    icon = defaultConfig.teamIcon;
  } else if (type === MAP_WORKORDER) {
    icon = MAP_BALLOON_URL;
  }
  let { address } = data;
  const { subject } = data;
  // For technician with current location,
  // don't display address as data.address has value for home address
  if (type === MAP_TECHNICIAN) {
    address = "";
  }
  marker = createMarkerWithLabel(
    position,
    data.name,
    icon,
    address,
    subject,
    "Current",
    MarkerColor,
    data.FirstName,
    data.LastName,
    data.SmallPhotoUrl,
    scale,
    "Overnight"
  );

  return marker;
};

const clearRouteForTech = (Id /* String */) => {
  let routeMarkers = null;
  let routePolylines = null;
  let rd = null;
  const rdd = null;
  const keys = Object.keys(routeData);
  keys.map(item => {
    rd = routeData[item];
    // rdd=rd.rd;
    routeMarkers = rd.routeMarkers || [];
    routePolylines = rd.routePolylines || [];
    if (routeMarkers) {
      routeMarkers.map(markerItem => {
        markerItem.setMap(null);
        return undefined;
      });
    }
    if (routePolylines) {
      routePolylines.map(polylinesItem => {
        polylinesItem.setMap(null);
        return undefined;
      });
    }
    return undefined;
  });

  routeDataArr.map(item => {
    rd = item;
    routeMarkers = rd.routeMarkers || [];
    routePolylines = rd.routePolylines || [];
    if (routeMarkers) {
      routeMarkers.map(markerItem => {
        markerItem.setMap(null);
        return undefined;
      });
    }
    if (routePolylines) {
      routePolylines.map(polylinesItem => {
        polylinesItem.setMap(null);
        return undefined;
      });
    }
    return undefined;
  });
};

const isDateToday = date => date.toDateString() === new Date().toDateString();

/**
 * Handles the logic to plot events for 3 use cases:
 * 1) When the selected/current Date is not today
 * 2) When the selected/current Date is not today
 * but the current Date and current time marker are the same day
 * 3) When the selected/current Date is today (same as current marker)
 */
const isCurrentDateEvent = (
  evt /* Obj with event details */,
  currentDate /* Date */,
  currentTimeMarker /* Date */,
  viewAllEventsForToday /* boolean */
) => {
  let result = true;
  if (!evt && !currentDate) {
    return result;
  }
  const evtStartDate = new Date(evt.startTime.time);
  const evtEndDate = new Date(evt.endTime.time);
  // compare the day first.
  if (evtStartDate.toDateString() !== currentDate.toDateString()) {
    // result = false;//Commented this as it was skipping an event in progress
    // i.e event spanning yesterday, today and tomorrow
  }
  // Dont plot the event if its today and event is before
  // current time marker and the UI setting viewAllEventsForToday is false
  if (
    isDateToday(currentDate) &&
    evtEndDate.getTime() < currentTimeMarker.getTime() &&
    viewAllEventsForToday === false
  ) {
    result = false;
  }
  // Dont plot if the current day is not today
  // (but the currentDate and currentTimeMarker are same day) and
  // event falls behind the currentTimeMarker
  else if (
    !isDateToday(currentDate) &&
    currentDate.toDateString() === currentTimeMarker.toDateString() &&
    evtEndDate.getTime() < currentTimeMarker.getTime() &&
    viewAllEventsForToday === false
  ) {
    result = false;
  }
  // if the event started yesterday or before and is ongoing,
  // consider it for plotting if the current date is not today.
  if (
    !isDateToday(currentDate) &&
    evtStartDate.toDateString() !== currentDate.toDateString() &&
    (evtEndDate.toDateString() === currentDate.toDateString() ||
      evtEndDate.getTime() > currentDate.getTime())
  ) {
    result = true;
  }
  return result;
};

const createPolyline = (polyLineOptions /* PolylineOptions */) =>
  new currentWindow.google.maps.Polyline(polyLineOptions);

const addPolyline = (polyline /* Polyline */) => {
  if (!polyline) {
    return undefined;
  }
  polyline.setMap(mapInstance);
  return undefined;
};

const plotRoute = (
  rd,
  source /* Marker */,
  destination /* Marker */,
  wayPoints /* Array */
) => {
  if (!source && !destination && !wayPoints) {
    return undefined;
  }
  const srcLocation = source.position ? source.position : source.address;
  const destLocation = destination.position
    ? destination.position
    : destination.address;
  // This for loop is added to fix issue #9773. Skip the waypoints not having the location
  wayPoints.map((item, i) => {
    const pt = item;
    if (!pt.location) {
      wayPoints.splice(i, 1);
      i -= 1;
    }
    return undefined;
  });

  const request = {
    destination: destLocation,
    origin: srcLocation,
    travelMode: currentWindow.google.maps.TravelMode.DRIVING,
    waypoints: wayPoints
  };
  directionsDisplay = new currentWindow.google.maps.DirectionsRenderer();
  directionsDisplay.setOptions({
    suppressMarkers: true,
    suppressPolylines: true
  });
  directionsDisplay.setMap(mapInstance);
  directionsService = new currentWindow.google.maps.DirectionsService();
  directionsService.route(request, (result, status) => {
    if (status === currentWindow.google.maps.DirectionsStatus.OK) {
      const route = result.routes[0];
      const { legs } = route;
      const polylines = [];
      legs.map(item => {
        const leg = item;
        const { steps } = leg;
        const polylineOptions = {};
        let color = "#24A2C1";
        // Destination, when plotting route is always tech marker
        if (destination.info) {
          // color = "#" + getTechColorForRoute(destination.info.Id);
          color = getTechColorForRoute(destination.info.id);
        }
        // Generate random color
        // "#24A2C1"; //+ Number((Math.random() * 0xFFFFFF).toFixed(0)).toString(16);
        polylineOptions.strokeColor = color;
        polylineOptions.path = [];
        polylineOptions.strokeOpacity = 1.0;
        polylineOptions.strokeWeight = 4;
        steps.map(stepitem => {
          const step = stepitem;
          const { path } = step;
          polylineOptions.path = polylineOptions.path.concat(path);
          return undefined;
        });
        const polyline = createPolyline(polylineOptions);
        addPolyline(polyline);
        polylines.push(polyline);
      });
      rd.routePolylines = polylines;
      if (wayPoints.length > 0 || srcLocation != destLocation) {
        // Though we have suppressed markers and ploylines, this applies the bounds
        directionsDisplay.setDirections(result);
      } // If there are no wayPoints, set the center to technician location
      else {
        const bnds = route.bounds;
        // mapInstance.fitBounds(bnds);
        // mapInstance.setCenter(destLocation);
      }
    } else if (
      status === currentWindow.google.maps.DirectionsStatus.NOT_FOUND
    ) {
      // At least one of the origin, destination, or waypoints could not be geocoded
      // Commented the following line as the error displayed
      // when geocoding is overwritten by following error
      // displayErrorInDC("TAG366");
      displayErrorInScheduler(getDisplayValue(TAG366));
      setDefaultMapLatLng();
    } else if (
      status === currentWindow.google.maps.DirectionsStatus.ZERO_RESULTS
    ) {
      // On failure
      // No route could be found between the origin and destination.
      // displayErrorInDC('TAG367');
      displayErrorInScheduler(getDisplayValue(TAG367));
      setDefaultMapLatLng();
      // mapInstance.setCenter(destLocation);
    } else if (
      status === currentWindow.google.maps.DirectionsStatus.UNKNOWN_ERROR
    ) {
      // A directions request could not be processed due to a server error.
      // The request may succeed if you try again
      // displayErrorInDC('TAG368');
      displayErrorInScheduler(getDisplayValue(TAG368));
      setDefaultMapLatLng();
    }
    // Enable date navigation buttons only after all routes have been plotted. Fix for issue #10924
    plotRouteCounter--;
    // routeActionMenuItemsEnabled(plotRouteCounter <= 0);
  });
};

export const drawTechRouteForDay = (
  currentDate,
  toolBarChange,
  locationChange = false,
  hideShow = false
) => {
  // setStautsMsgEmpty();
  localCurrentDate = currentDate;
  if (!toolBarChange) {
    showRouteCallBackFunction(currentDate);
  }
  techRouteData = getTechnicianRouteData();
  if (lastPlottedRoute) {
    const rd = lastPlottedRoute.routeData;
    const resourceRecords = getShowRouteTechIdsData();
    const resourceKeys = Object.keys(resourceRecords);
    resourceKeys.map(techItem => {
      // const { technician } = techItem;
      clearRouteForTech(techItem);
    });
    // const { technician } = rd;
    // clearRouteForTech(technician.id);
  }

  if (currentDate) {
    // const techRouteData = getTechnicianRouteData();
    let temp;
    const { eventsForWorkOrders, technician } = (temp = { ...techRouteData });
    if (eventsForWorkOrders[currentDate]) {
      temp.eventsForWorkOrders = eventsForWorkOrders[currentDate];
      const isDrawn = checkForPreviousTechEvents(
        currentDate,
        technician.id,
        hideShow
      );
      // if (!isDrawn) {
      setTimeout(
        () =>
          drawTechnicianRoute(
            temp,
            toolBarChange,
            currentDate,
            techRouteData,
            hideShow
          ),
        0
      );
      // drawTechnicianRoute(temp, toolBarChange, currentDate, techRouteData, hideShow);
      // }
    }
  }
};

const checkForPreviousTechEvents = (currentDate, techId, hideShow) => {
  let rd = null;
  const rdd = null;
  let techData = null;
  let techRouteDrawn = false;
  const keys = Object.keys(routeData);
  keys.map(item => {
    rd = routeData[item];
    techData = rd.routeData || [];
    const techsData = rd.originalData;
    let temp;
    const { eventsForWorkOrders, technician } = (temp = { ...techsData });
    // const { eventsForWorkOrders, technician } = { ...techsData };
    // if(currentDate === rd.currentDate){
    if (eventsForWorkOrders[currentDate]) {
      const { technician } = techData;
      temp.eventsForWorkOrders = eventsForWorkOrders[currentDate];
      if (technician.id !== techId) {
        drawTechnicianRoute(
          temp,
          false,
          currentDate,
          rd.originalData,
          hideShow
        );
        /* setTimeout(
          () =>
            drawTechnicianRoute(
              temp,
              false,
              currentDate,
              rd.originalData,
              hideShow
            ),
          0
        ); */
        techRouteDrawn = true;
      } /* else if (technician.id !== techId) {
      //techRouteDrawn = true;
      //} */
    }
  });
  return techRouteDrawn;
};

export const setStautsMsgEmpty = message => {
  if (invalidMarkers) {
    invalidMarkers = [];
  }
  errorCallBackFunction("", true);
};

export const drawTechnicianRoute = (
  data,
  toolBarChange = false,
  currentDate,
  originalData,
  hideShow = false
) => {
  if (!data || !data.technician) {
    return undefined;
  }
  let selectedDate = data.selectedCurrentDate;
  if (hideShow) {
    selectedDate = getShowRouteSelectedDate();
  }
  const event = new CustomEvent(MAP_CUSTOM_EVENT_SHOW_LOCATION_BAR, {
    detail: {
      show: true,
      showDate: true,
      minDate: data.schedulerMinDate,
      techName: data.technician.name,
      maxDate: data.schedulerMaxDate,
      selectedDate
    }
  });
  if (toolBarChange) {
    window.dispatchEvent(event);
  }
  const wayPoints = [];
  let callLater = false;
  let added = true;
  let woMarker;
  let destTechHomeMarker;
  let techHomeMarker;

  const { eventsForWorkOrders, technician } = data;
  let source;
  let destination;
  bounds = new currentWindow.google.maps.LatLngBounds();
  const MarkerColor = getTechColorForRoute(technician.id);
  const techMarker = createTechMarker(
    technician,
    MarkerColor,
    true,
    MAP_TECHNICIAN,
    MAP_TECH_CURRENT
  );
  techMarker.info = technician;
  techHomeMarker = createTechMarker(
    technician,
    MarkerColor,
    true,
    MAP_TECHNICIAN,
    MAP_TECH_HOME
  );
  techHomeMarker.info = technician;
  if (homeRadio) {
    added = addMarker(techHomeMarker);
  } else if (currentRadio) {
    added = addMarker(techMarker);
  } else {
    added = addMarker(techHomeMarker);
    added = addMarker(techMarker);
  }
  currentWindow.google.maps.event.addListener(
    techMarker,
    "mouseover",
    showInfo
  );
  currentWindow.google.maps.event.addListener(
    techHomeMarker,
    "mouseover",
    showInfo
  );
  if (!added) {
    callLater = true;
  }
  const routeMarkers = [];
  routeMarkers.push(techMarker);
  const rd = {
    routeData: data,
    routeMarkers,
    currentDate,
    originalData
  };
  routeData[technician.id] = rd;
  routeDataArr.push(rd);
  totalRoutesPlotted = 0;
  const keys = Object.keys(routeData);
  keys.map(item => {
    totalRoutesPlotted += 1;
  });
  lastPlottedRoute = rd;
  if (homeRadio || bothRadio) {
    source = techHomeMarker;
    // destTechHomeMarker = techHomeMarker;
    destTechHomeMarker = createTechMarker(
      technician,
      MarkerColor,
      true,
      MAP_TECHNICIAN
    );
    destination = destTechHomeMarker;
    destTechHomeMarker.info = technician;
    added = addMarker(destTechHomeMarker);
    currentWindow.google.maps.event.addListener(
      destTechHomeMarker,
      "mouseover",
      showInfo
    );
  }
  if (currentRadio) {
    source = techMarker;
    destination = techMarker;
  }
  let eventNotHaveLocation = false;
  const eventNotHaveLocationNameArr = [];
  eventsForWorkOrders.map((item, i) => {
    let lat;
    let lng;
    let position = null;
    const evt = item;
    if (evt.isHaveLocation) {
      if (evt.lat) {
        lat = Number(evt.lat);
      }
      if (evt.lng) {
        lng = Number(evt.lng);
      }
      if (lat !== undefined && lng !== undefined) {
        position = new currentWindow.google.maps.LatLng(lat, lng);
      }
      let markerColor = getTechColorForRoute(technician.id);
      if (markerColor) {
        markerColor = markerColor.substring(1, markerColor.length);
      }
      // This is chart api url to generate numbered markers
      const iconUrl = `${MAP_BALLOON_URL + (i += 1)}|${markerColor}|000000`;
      // var iconUrl = Literals.BALLOON_URL;
      woMarker = createMarker(
        position,
        evt.Name,
        iconUrl,
        evt.address,
        false,
        MAP_WORKORDER
      ); // routeData.woIcon
      woMarker.info = evt;
      added = addMarker(woMarker);
      // Added second condition to fix reopened issue #9773.
      // For one scenario the original fix was not working.
      // If there are 2 events to be plotted. 1st one does not
      // have location info and second one has only address info,
      // callLater was not set to true even if the lookup to address was required.
      // It was set to true only if last event had address.Hence route was not plotted
      if (!added || (!woMarker.position && woMarker.address !== "")) {
        callLater = true;
      }
      currentWindow.google.maps.event.addListener(
        woMarker,
        "mouseover",
        showInfo
      );
      routeMarkers.push(woMarker);
      const wp = {
        location: woMarker.position
          ? woMarker.position
          : position || evt.address
      };
      wayPoints.push(wp);
      // If marker does not have lat lng info,
      // then update way point with the same after lat lng lookup
      woMarker.wayPoint = wp;
    }
    if (!evt.isHaveLocation) {
      eventNotHaveLocation = true;
      eventNotHaveLocationNameArr.push(evt.Name);
    }
  });
  // Add the home location after the waypoints have beed added
  routeMarkers.push(techHomeMarker);
  if (homeRadio || bothRadio) {
    routeMarkers.push(destTechHomeMarker);
  }
  if (!callLater) {
    if (eventsForWorkOrders.length) {
      plotRoute(rd, source, destination, wayPoints);
    }
    // displayErrorInScheduler();
  } else {
    // plotRoute(rd, source, destination, wayPoints);
    (function(rd, source, destination, wayPoints) {
      const callAfterLatLngLookup = function() {
        if (eventsForWorkOrders.length) {
          plotRoute(rd, source, destination, wayPoints);
        }
      };

      callBackStack.push({
        callBackFor: "drawTechnicianRoute",
        callBack: callAfterLatLngLookup
      });
    })(rd, source, destination, wayPoints);
  }
  if (callLater == false) {
    if (techHomeMarker.position != undefined) {
      if (bounds) {
        bounds.extend(techHomeMarker.position);
        mapInstance.setCenter(bounds.getCenter());
      }
    }
    if (techMarker.position != undefined) {
      if (bounds) {
        bounds.extend(techMarker.position);
        mapInstance.setCenter(bounds.getCenter());
      }
    }
  }
  // displayErrorInScheduler();
  if (eventNotHaveLocation) {
    const errorInfo = {};
    errorInfo.message = getDisplayValue(TAG177);
    const eventNotHaveLocationNameArrUnique = new Set(
      eventNotHaveLocationNameArr
    );
    if (eventNotHaveLocationNameArrUnique.length) {
      errorInfo.markerMsg = `${getDisplayValue(
        "TAG178"
      )}\n${eventNotHaveLocationNameArrUnique.join("\n")}`;
    } else {
      errorInfo.markerMsg = `${getDisplayValue(
        "TAG178"
      )}\n${eventNotHaveLocationNameArr}`;
    }
    errorInfo.errorCodeMsg = getDisplayValue(TAG260);
    errorCallBackFunction(errorInfo);
  }
};

export const clearRoute = () => {
  const i = null;
  let routeMarkers = null;
  let routePolylines = null;
  let rd = null;
  const rdd = null;
  const keys = Object.keys(routeData);
  keys.map(item => {
    rd = routeData[item];
    routeMarkers = rd.routeMarkers || [];
    routePolylines = rd.routePolylines || [];
    if (routeMarkers) {
      routeMarkers.map(markerItem => {
        markerItem.setMap(null);
        return undefined;
      });
    }
    if (routePolylines) {
      routePolylines.map(polylinesItem => {
        polylinesItem.setMap(null);
        return undefined;
      });
    }
    return undefined;
  });

  routeDataArr.map(item => {
    rd = item;
    routeMarkers = rd.routeMarkers || [];
    routePolylines = rd.routePolylines || [];
    if (routeMarkers) {
      routeMarkers.map(markerItem => {
        markerItem.setMap(null);
        return undefined;
      });
    }
    if (routePolylines) {
      routePolylines.map(polylinesItem => {
        polylinesItem.setMap(null);
        return undefined;
      });
    }
    return undefined;
  });

  searchAllTechMarkers.map(searchAllTechMarkerItem => {
    searchAllTechMarkerItem.setMap(null);
    return undefined;
  });
  searchAllTechMarkers = [];

  searchAllTeamMarkers.map(searchAllTeamMarkerItem => {
    searchAllTeamMarkerItem.setMap(null);
    return undefined;
  });
  searchAllTeamMarkers = [];

  const tmp = routeData;
  routeData = {};
  lastPlottedRoute = null;
  totalRoutesPlotted = 0;
  techRouteData = null;
  resetShowRouteTechIdsData();
  noLimit = false;
  routeDataArr = [];
  searchTechData = null;
};

export const createCurrentMapContext = () => {
  if (plotCircle) {
    const plotCircleData = getLastPlotCircleData();
    getViewDataToPlotInternal(getSelectedRadius(), plotMode);
    const workOrderViewSelectedItems =
      getSelectedViewItems(WORKORDER_API_NAME) || [];
    const accountViewSelectedItems =
      getSelectedViewItems(ACCOUNT_API_NAME) || [];
    const locationViewSelectedItems =
      getSelectedViewItems(LOCATION_API_NAME) || [];
    // plotNearByLatLng = getLastPlottedLatLng();
    if (plotCircleData) {
      plotCircleData.map(item => {
        plot(item);
        item.items.map(viewKeys => {
          toggleViewSelection(viewKeys.viewId, false);
        });
      });

      if (workOrderViewSelectedItems.length) {
        workOrderViewSelectedItems.map(item => {
          toggleViewSelection(item.KEY, true);
        });
      }
      if (accountViewSelectedItems.length) {
        accountViewSelectedItems.map(item => {
          toggleViewSelection(item.KEY, true);
        });
      }
      if (locationViewSelectedItems.length) {
        locationViewSelectedItems.map(item => {
          toggleViewSelection(item.KEY, true);
        });
      }

      // plot(plotCircleData);
    }
  }
  // if (searchTechData) {
  // drawRadiusForSearch(getSelectedSearchRadius());
  // }

  if (searchTechData) {
    // clearSearchTechMarkers();
    drawSearchedTechnicians(
      searchTechData.technicians,
      searchTechData.selectedWO
    );
  }

  if (searchTeamData) {
    drawSearchedTeams(searchTeamData.teams, searchTeamData.selectedWO);
  }

  if (techRouteData) {
    const showRouteDone = getShowRouteDataMapDone();
    if (showRouteDone) {
      // drawTechRouteForDay(localCurrentDate, true, true, true);
      setTimeout(
        () => drawTechRouteForDay(localCurrentDate, true, true, true),
        0
      );
    }
    setTimeout(() => drawTechRouteForDay(localCurrentDate, false, true), 0);
    // drawTechRouteForDay(localCurrentDate, false, true);
  }
};

export default setMapInstance;
