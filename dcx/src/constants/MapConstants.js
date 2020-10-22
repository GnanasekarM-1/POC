// Literals used for Map
export const MAP_ACCOUNT_VIEW = "account";
export const MAP_ATTRIBUTES = "attributes";
export const MAP_BALLOON_URL =
  "https://chart.googleapis.com/chart?chst=d_map_pin_letter&chld=";
export const MAP_INFO_ICON_URL =
  "https://maps.google.com/mapfiles/ms/micons/info.png";
export const MAP_INFO_PHOTO_ICON =
  "https://maps.google.com/mapfiles/ms/micons/man.png";
export const MAP_TECH_IMAGE_PATH_SVG =
  "M14.023,12.154c1.514-1.192,2.488-3.038,2.488-5.114c0-3.597-2.914-6.512-6.512-6.512 c-3.597,0-6.512,2.916-6.512,6.512c0,2.076,0.975,3.922,2.489,5.114c-2.714,1.385-4.625,4.117-4.836,7.318h1.186 c0.229-2.998,2.177-5.512,4.86-6.566c0.853,0.41,1.804,0.646,2.813,0.646c1.01,0,1.961-0.236,2.812-0.646 c2.684,1.055,4.633,3.568,4.859,6.566h1.188C18.648,16.271,16.736,13.539,14.023,12.154z M10,12.367 c-2.943,0-5.328-2.385-5.328-5.327c0-2.943,2.385-5.328,5.328-5.328c2.943,0,5.328,2.385,5.328,5.328 C15.328,9.982,12.943,12.367,10,12.367z";
// = `${window.getResourcePath()}resources/themes/images/svmx-dc-map/custom/info_icon.png`;
// Array of the colors used to plot tech current markers
export const MAP_CURRENT_MARKER_COLORS = [
  "#1B7DBC",
  "#C53922",
  "#7E8C8D",
  "#D75500",
  "#923BB0",
  "#2B3D51",
  "#7E8C8D",
  "#7E8CED",
  "#2595DF",
  "#ED4C32",
  "#01A185",
  "#F79F00"
];
// tech current marker path(svg)
export const MAP_CURRENT_MARKER_SVG =
  "M-20,0a20,20 0 1,0 40,0a20,20 0 1,0 -40,0 M-5,20 L0,35 L5,20 Z";
// Map of salesforce date fromat (key) and Ext date format (value)
export const MAP_DATE_FORMAT = {
  "DD.MM.YYYY": "d.m.Y",
  "DD.MM.YYYY.": "d.m.Y",
  "DD/MM/YYYY": "d/m/Y",
  "DD-MM-YYYY": "d-m-Y",
  "MM.DD.YYYY": "m.d.Y",
  "MM/DD/YYYY": "m/d/Y",
  "MM-DD-YYYY": "m-d-Y",
  "YYYY. MM. DD": "Y.m.d",
  "YYYY.MM.DD": "Y.m.d",
  "YYYY/MM/DD": "Y/m/d",
  "YYYY-MM-DD": "Y-m-d"
};
// Array of the colors used to plot tech home markers
export const MAP_HOME_MARKER_COLORS = [
  "#1B7DBC",
  "#C53922",
  "#02AF5B",
  "#D75500",
  "#923BB0",
  "#2B3D51",
  "#EB8000",
  "#7E8C8D",
  "#2595DF",
  "#ED4C32",
  "#01A185",
  "#F79F00"
];
// tech home marker path(svg)
export const MAP_HOME_MARKER_SVG =
  "M-14,-8 L14,-8 L14,8 L-14,8  M0,-20 L14,-8 Z M0,-20 L-14,-8 L14,-8";
export const MAP_ID = "Id";
export const MAP_LOCATION_VIEW = "location";
export const MAP_NAME = "name";
export const MAP_NEXT = "next";
// over night stay marker path(svg)
export const MAP_OVER_NIGHT_STAY_MARKER_SVG =
  "M11.7756487,4 C7.14289509,6.52840598 4,11.443911 4,17.0934786 C4,25.326123 10.673877,32 18.9065214,32 C24.556089,32 29.471594,28.8571049 32,24.2243513 C29.8818288,25.3803785 27.4522062,26.0373914 24.86913,26.0373914 C16.6364856,26.0373914 9.96260858,19.3635144 9.96260858,11.13087 C9.96260858,8.54779378 10.6196215,6.11817116 11.7756505,3.99999902 Z";
export const MAP_PLOT_CENTER_ICON = "https://www.google.com/mapfiles/arrow.png";
export const MAP_PREVIOUS = "prev";
export const MAP_TAB_EVENTKEY = "Team";
export const MAP_TECHNICIAN = "Tech";
export const MAP_TEAM = "Team";
export const MAP_TECH_CURRENT = "current";
export const MAP_TECH_HOME = "home";
export const MAP_TECH_BOTH = "both";
export const MAP_TECH_DAILY_ROUTE = "Daily route for";
// Array of the colors used to plot technician route
export const MAP_TECH_ROUTE_COLORS = [
  "#1B7DBC",
  "#C53922",
  "#02AF5B",
  "#D75500",
  "#923BB0",
  "#2B3D51",
  "#EB8000",
  "#7E8C8D",
  "#2595DF",
  "#ED4C32",
  "#01A185",
  "#F79F00"
];
export const MAP_VIEW_HEADER = "header";
export const MAP_VIEW_GRID_KEY = "value1";
export const MAP_VIEW_LATITUDE = "LATITUDE";
export const MAP_VIEW_LONGITUDE = "LONGITUDE";
export const MAP_VIEW_OBJECTNAME = "OBJECTNAME";
export const MAP_VIEW_RADIUS = "RADIUS";
export const MAP_VIEW_RECORD_LIMIT = "RECORDLIMIT";
export const MAP_VIEW_RECORDS_MAX = 100;
export const MAP_VIEW_RECORDS_MIN = 1;
export const MAP_VIEW_PLOT_RADIUS_DEFAULT = 180;
export const MAP_VIEW_RECORD_LIMIT_DEFAULT = "25";
export const MAP_VIEW_DEFAULT_SELECTED_RADIUS = ["1"];
export const MAP_VIEW_DEFAULT_SELECTED_TAB = "1";
export const MAP_VIEW_PLOT_RADIUS = [
  { [MAP_ID]: "0", [MAP_NAME]: "25" },
  { [MAP_ID]: "1", [MAP_NAME]: "50" },
  { [MAP_ID]: "2", [MAP_NAME]: "75" },
  { [MAP_ID]: "3", [MAP_NAME]: "100" }
];
export const SEARCH_RADIUS_MENU_ITEM = [5, 10, 15, 20, 25, 30, 40, 50];
export const MAP_VIEW_ROW = "row";
export const MAP_VIEW_VIEW_ID = "VIEWID";
export const MAP_WORKORDER = "WO";
export const MAP_WORKORDER_VIEW = "workOrder";
export const MAP_VIEW_OBJECT_NAME = "objectName";
export const MAP_DEFAULT_LAT = "tech_mapDefaultLat";
export const MAP_DEFAULT_LNG = "tech_mapDefaultLng";
export const MAP_DEFAULT_ZOOM_LEVEL = "tech_mapDefaultZoomLevel";
export const MAP_DEFAULT_LOCATION_BASE = "tech_locationBase";
export const MAP_CUSTOM_EVENT_SHOW_LOCATION_BAR = "showLocationBar";
export const MAP_CUSTOM_EVENT_LOAD_EVENTS = "loadEventsAfterMapLaunch";
// export const MAP_CUSTOM_EVENT_PLOT_ON_MAP = 'plotOnMap';
export const MAP_CUSTOM_EVENT_MAP_CONFIG_CHANGE = "mapConfigChange";
export const MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN = "showFullScreen";
export const MAP_CUSTOM_EVENT_CLOSE_CHILD_WINDOW = "closeChildWindow";
export const MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN_HIDE = "showFullScreenHide";
export const MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN_SETVALUE =
  "showFullScreenSetValue";
export const MAP_CUSTOM_EVENT_WORKORDER_SELECTED = "workOrderSelcted";
export const MAP_SEARCH_RADIUS_LABEL = "Enter Search Radius";
export const MAP_VIEW_NAME_LABEL = "View Name";
export const MAP_WORKORDER_LABEL = "Work Order";
export const MAP_ACCOUNT_LABEL = "Account";
export const MAP_LOCATION_LABEL = "Location";
export const MAP_RECORDS_LABEL = "No. of records";
export const MAP_PLOT_ON_MAP_LABEL = "Plot On Map";
export const MAP_CLEAR_LABEL = "Clear Map";

export const TECH_ROUTE_COLORS = [
  "#1B7DBC",
  "#C53922",
  "#02AF5B",
  "#D75500",
  "#923BB0",
  "#2B3D51",
  "#EB8000",
  "#7E8C8D",
  "#2595DF",
  "#ED4C32",
  "#01A185",
  "#F79F00"
];
