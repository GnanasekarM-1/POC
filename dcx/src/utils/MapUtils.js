import { flatMap } from "lodash";
import {
  MAP_VIEW_DEFAULT_SELECTED_RADIUS,
  MAP_VIEW_DEFAULT_SELECTED_TAB,
  MAP_VIEW_RECORD_LIMIT_DEFAULT,
  MAP_VIEW_PLOT_RADIUS,
  MAP_VIEW_PLOT_RADIUS_DEFAULT,
  MAP_ID,
  MAP_NAME
} from "constants/MapConstants";
import { getSettingValue, DCON001_SET005, SET059 } from "constants/AppSettings";
import {
  LOCATION_API_NAME,
  WORKORDER_API_NAME,
  TECH_KEYWORD
} from "constants/AppConstants";
import moment from "moment-timezone";

let selectedTab = MAP_VIEW_DEFAULT_SELECTED_TAB;
let selectedRadiusIndex = MAP_VIEW_DEFAULT_SELECTED_RADIUS;
let selectedRadius;
let recordLimit;
let plotView;
let selectedWorkOrderViewItems = [];
let selectedLocationViewItems = [];
let selectedAccountViewItems = [];
let showPlotOnMap = false;
let selectedSearchRadius;
let selectedSearch = TECH_KEYWORD;
let selectedWorkOrder = {};
let techSearchDone = false;
let eventCallRequested = 0;
let eventCallDone = 0;
let technicianRouteData = {};
let eventWorkOrderIds = [];
let schedulerSelectedTech;
let showRouteTechData;
let showRouteTechIdsData = {};
let showRouteDataMap = {};
let showRouteDone = false;
let showRouteSelectedDate;
let lastPlottedData = [];
let lastPlottedLatLng;

export const setMapPlotReset = () => {
  selectedRadiusIndex = configKeyMapping(
    getSettingValue(DCON001_SET005),
    MAP_VIEW_PLOT_RADIUS
  ); // || MAP_VIEW_DEFAULT_SELECTED_RADIUS;
  selectedRadius = selectedRadiusIndex;
};

export const setTechPhotoUrls = (techData, photoData) => {
  let techniciansKeys = Object.keys(techData);
  techniciansKeys.map(item => {
    techData[item].technician_O.SmallPhotoUrl = null;
    if (photoData[item]) {
      techData[item].technician_O.SmallPhotoUrl = photoData[item].SmallPhotoUrl;
    }
  });
};

export const setLastPlottedLatLng = data => {
  lastPlottedLatLng = data;
};

export const getLastPlottedLatLng = () => lastPlottedLatLng;

export const setLastPlotCircleDataReset = data => {
  lastPlottedData = [];
};

export const setLastPlotCircleData = data => {
  lastPlottedData.push(data);
};

export const getLastPlotCircleData = () => lastPlottedData;

export const setShowRouteSelectedDate = date => {
  showRouteSelectedDate = date;
};

export const getShowRouteSelectedDate = () => showRouteSelectedDate;

export const setShowRouteDataMapDone = value => {
  showRouteDone = value;
};

export const getShowRouteDataMapDone = () => showRouteDone;

export const setShowRouteDataMap = data => {
  showRouteDataMap[data.technician.id] = data;
};

export const getShowRouteDataMap = id => showRouteDataMap[id];

export const resetShowRouteData = () => {
  showRouteDataMap = {};
};

export const setShowRouteTechIdsData = record => {
  showRouteTechIdsData[record.id] = record;
};
export const getShowRouteTechIdsData = () => showRouteTechIdsData;
export const resetShowRouteTechIdsData = () => {
  showRouteTechIdsData = {};
};

export const storeSelectedViewItems = (apiName, selectedView) => {
  flatMap(selectedView, item => {
    const { value1, value } = item;
    if (apiName === WORKORDER_API_NAME) {
      selectedWorkOrderViewItems.push({
        KEY: value1,
        MAP_VIEW_OBJECT_NAME: apiName,
        VALUE: value
      });
    } else if (apiName === LOCATION_API_NAME) {
      selectedLocationViewItems.push({
        KEY: value1,
        MAP_VIEW_OBJECT_NAME: apiName,
        VALUE: value
      });
    } else {
      selectedAccountViewItems.push({
        KEY: value1,
        MAP_VIEW_OBJECT_NAME: apiName,
        VALUE: value
      });
    }
  });
};

export const getSelectedViewItems = apiName => {
  if (apiName === WORKORDER_API_NAME) {
    return selectedWorkOrderViewItems;
  }
  if (apiName === LOCATION_API_NAME) {
    return selectedLocationViewItems;
  }
  return selectedAccountViewItems;
};

export const clearViewItems = () => {
  selectedLocationViewItems = [];
  selectedWorkOrderViewItems = [];
  selectedAccountViewItems = [];
};

export const setSelectedTab = tabKey => {
  selectedTab = tabKey;
};

export const getSelectedTab = () => selectedTab;

export const getPlotView = () => plotView;

export const setPlotView = value => {
  plotView = value;
};
export const getSelectedRadius = () => selectedRadius;

export const setSelectedRadius = value => {
  selectedRadius = value;
  selectedRadiusIndex = configKeyMapping(value, MAP_VIEW_PLOT_RADIUS); // |
};

export const configKeyMapping = (value, list) => {
  let mapId;
  list.forEach(val => {
    if (val[MAP_NAME] === value) {
      mapId = val[MAP_NAME];
    }
  });
  if (mapId) {
    return [mapId];
  }
  return null;
};

export const setSelectedConfigRadius = () => {
  const sRadius = getSelectedRadius();
  let radiusToPlot;
  if (sRadius) {
    radiusToPlot = typeof sRadius === "object" ? sRadius[0] : sRadius;
  }
  if (getSelectedRadius()) {
    selectedRadiusIndex = configKeyMapping(radiusToPlot, MAP_VIEW_PLOT_RADIUS);
    selectedRadiusIndex = selectedRadiusIndex || radiusToPlot;
  } else {
    selectedRadiusIndex =
      configKeyMapping(getSettingValue(DCON001_SET005), MAP_VIEW_PLOT_RADIUS) ||
      getSettingValue(DCON001_SET005); // || MAP_VIEW_DEFAULT_SELECTED_RADIUS;
  }

  selectedRadius = selectedRadiusIndex; // || MAP_VIEW_PLOT_RADIUS_DEFAULT;
};

export const getSelectedRadiusIndex = () => selectedRadiusIndex;

export const getRecordLimit = () => recordLimit;

export const setRecordLimit = value => {
  recordLimit = value;
};

export const setConfigRecordLimit = () => {
  recordLimit =
    Number(getSettingValue(SET059)) || MAP_VIEW_RECORD_LIMIT_DEFAULT;
};

export const setShowPlotOnMap = value => {
  showPlotOnMap = value;
};

export const getShowPlotOnMap = () => showPlotOnMap;

export const getSelectedSearchRadius = () => selectedSearchRadius;

export const setSelectedSearchRadius = value => {
  selectedSearchRadius = value;
};

export const getSelectedSearch = () => selectedSearch;

export const setSelectedSearch = value => {
  selectedSearch = value;
};

export const getSelectedWorkOrder = () => selectedWorkOrder;

export const setSelectedWorkOrder = value => {
  selectedWorkOrder = value;
};

export const setShowRouteTechData = data => {
  showRouteTechData = data;
};
export const getShowRouteTechData = () => showRouteTechData;

export const getSearchTechDone = () => techSearchDone;

export const setSearchTechDone = value => {
  techSearchDone = value;
};

export const getEventCallRequested = () => eventCallRequested;

export const setEventCallRequested = () => {
  eventCallRequested += 1;
};

export const getEventCallDone = () => eventCallDone;

export const setEventCallDone = () => {
  eventCallDone += 1;
};

export const initiateEventCall = () => {
  eventCallRequested = 0;
  eventCallDone = 0;
};

export const getTechnicianRouteData = () => technicianRouteData;

export const setTechnicianRouteData = value => {
  technicianRouteData = value;
};

export const getEventWorkOrderIds = () => eventWorkOrderIds;

export const setEventWorkOrderIds = value => {
  eventWorkOrderIds = value;
};

export const getSchedulerSeletecdTech = () => schedulerSelectedTech;

export const setSchedulerSeletecdTech = value => {
  schedulerSelectedTech = value;
};

export const dateTimeCheckForSame = (startdate, enddate) => {
  const isSame = moment(startdate).isSame(enddate);
  return isSame;
};

export const openPopUp = (id, forRankedAppoinment = false) => {
  // const baseURL = window.configData && window.configData.baseUrl || 'https://svmxdev-dev-ed.my.salesforce.com';
  let url = `${document.location.protocol}//${document.location.host}/${id}?isdtp=mn`;
  if (forRankedAppoinment) {
    url = `${document.location.protocol}//${document.location.host}/${id}`;
  }
  // const URL = `${baseURL}${url}`;
  window.open(
    url,
    "_blank",
    "width=800,height=600,resizable=1,status=0,scrollbars=1"
  );
  return false;
};

export const checkForTechAndWoLocation = (data, isTech) => {
  let isHaveLocation = false;
  const { address, lat, lng, homeAddress, homeLat, homeLng } = data;
  if (isTech) {
    isHaveLocation =
      address !== "" ||
      homeAddress !== "" ||
      (lat && lng !== "") ||
      (homeLng && homeLat !== "");
  } else {
    isHaveLocation = address !== "" || (lat && lng !== "");
  }
  return isHaveLocation;
};
