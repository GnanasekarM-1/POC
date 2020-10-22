import store from "store";

// Custom Application Settings
export const CACHE_WORKORDERS = false;

/** ****** Module: Dispatch Management *********** */

/** ****** Sub Module: Dispatch Console Flex ******** */
// Default calendar duration (Number of days)
export const DCON001_SET001 = "DCON001_SET001";
// Auto-search When Work order is selected
export const DCON001_SET003 = "DCON001_SET003";
// Default radius (in miles)
export const DCON001_SET005 = "DCON001_SET005";
// Default Status (All, Assigned, Queued, New)
export const DCON001_SET007 = "DCON001_SET007";
// Auto-select Work Order
export const DCON001_SET008 = "DCON001_SET008";
// Set owner on assignment
export const DCON001_SET009 = "DCON001_SET009";
// Auto-Refresh Work Order List upon status change
export const DCON001_SET010 = "DCON001_SET010";
// GANTT Drop Event Roundoff Time
export const DCON001_SET011 = "DCON001_SET011";
// Allow Color Coding
export const DCON001_SET012 = "DCON001_SET012";
// Allow Technician Field Selection (NOT AVAILABLE FOR USE YET)
export const DCON001_SET017 = "DCON001_SET017";
// Allow Time Zone Selection (NOT AVAILABLE FOR USE YET)
export const DCON001_SET018 = "DCON001_SET018";
// Allow double booking of technician on creation of new Event
export const DCON001_SET025 = "DCON001_SET025";
// Refresh calendar when refreshing work order list explicitly
export const DCON001_SET032 = "DCON001_SET032";
// Allow , Disallow or Warn Assign WO to Tree
export const DCON001_SET036 = "DCON001_SET036";
// Is Work Order Event Subject editable
export const DCON001_SET037 = "DCON001_SET037";
// Default event start time for Multi Assign of WorkOrder
export const DCON001_SET052 = "DCON001_SET052";
export const DEFAULT_EVENT_DURATION_SECONDS = 3600;
// Allow deploying of settings to other Super Dispatchers
export const DCON001_SET053 = "DCON001_SET053";
// Show Service Duration in HH:MM or Minutes
export const DCON001_SET054 = "DCON001_SET054";
// Apply Event Subject Rule for Multi Assign
export const DCON001_SET057 = "DCON001_SET057";
// Show End Date time or Duration in minutes for Manage Multi Assign
export const DCON001_SET064 = "DCON001_SET064";
// Category of users allowed to Reset User Settings
export const DCON001_SET065 = "DCON001_SET065";
// Enable filtering by technicians assigned/scheduled to the listed work orders
export const DCON001_SET066 = "DCON001_SET066";
// Enable Advanced Technician Search (MCTM) in Dispatch Console
export const DCON001_SET067 = "DCON001_SET067";
// Map Allowed
export const DCON001_SET071 = "DCON001_SET071";
// Map Key
export const GLOB001_GBL011 = "GLOB001_GBL011";
// Default event duration (Number of minutes)
export const DCON001_SET002 = "DCON001_SET002";

/** ****** Sub Module: Event Management ******** */
// Drive Time
export const DCON005_SET002 = "DCON005_SET002";
// OverHead Time
export const DCON005_SET003 = "DCON005_SET003";
// Break Time
export const DCON005_SET004 = "DCON005_SET004";
// JDM Enable/Disable
export const DCON005_SET006 = "DCON005_SET006";
// LJD Enable/Disable
export const DCON005_SET007 = "DCON005_SET007";
// Event Type Enable/Disable
export const DCON005_SET005 = "DCON005_SET005";

export const DCON005_SET012 = "DCON005_SET012";

// config tech column
export const SET013 = "DCON005_SET013";
export const SET014 = "DCON001_SET014";
export const SET015 = "DCON001_SET015";
export const SET016 = "DCON001_SET016";
export const SET020 = "DCON001_SET020";
export const SET021 = "DCON001_SET021";
export const SET024 = "DCON001_SET024";
export const SET037 = "DCON001_SET037";
export const SET048 = "DCON001_SET048";
export const SET049 = "DCON001_SET049";
export const SET050 = "DCON001_SET050";
export const SET054 = "DCON001_SET054"; // minutes,hours
export const SET055 = "DCON001_SET055";
export const SET059 = "DCON001_SET059";
export const SET060 = "DCON001_SET060";
export const SET061 = "DCON001_SET061";
export const SET068 = "DCON001_SET068";
export const SET072 = "DCON001_SET072";
export const SET073 = "DCON001_SET073";
export const SET074 = "DCON001_SET074"; // Fetch Event Ids for # number of technicians per year in a request.
export const SET075 = "DCON001_SET075"; // Fetch # number of Event details per request
export const SET051 = "DCON001_SET051";
export const SET056 = "DCON001_SET056";
export const SET058 = "DCON001_SET058";
export const SET032 = "DCON001_SET032";
export const SET010 = "DCON001_SET010";
export const SET002 = "DCON001_SET002";

// Optimax Settings which will impact ATS.
export const OMAX003_SET042 = "OMAX003_SET042"; // Default weight value for Technician Eligibility Match
export const OMAX003_SET043 = "OMAX003_SET043"; // Default weight value for Technician Product Match
export const OMAX003_SET044 = "OMAX003_SET044"; // Default weight value for Technician Product Match
export const OMAX003_SET047 = "OMAX003_SET047"; // 	Default weight value for Technician Skill Match

// Scheduler
export const SET0235 = "DCON001_SET00235";
export const SET033 = "DCON001_SET033";
export const SET034 = "DCON001_SET034";
export const SLAT003_SET001 = "SLAT003_SET001";
export const GLOB001_GBL025 = "GLOB001_GBL025";
export const MAPS_API_KEY_DC = "MAPS_API_KEY_DC";

export const DEFAULT_PAGE_SIZE = 200;

export const SET048_DEFAULT =
  "http://maps.google.com/mapfiles/kml/pal4/icon55.png";
export const SET049_DEFAULT =
  "http://maps.google.com/mapfiles/kml/pal4/icon53.png";
export const SET050_DEFAULT =
  "http://maps.google.com/mapfiles/kml/pal2/icon5.png";
export const SET060_DEFAULT =
  "http://maps.google.com/mapfiles/kml/pal2/icon6.png";
export const SET061_DEFAULT =
  "http://maps.google.com/mapfiles/kml/pal3/icon21.png";
export const SET068_DEFAULT =
  "https:// www.google.com/mapfiles/ms/micons/man.png";

// Km,Mile
export const MAP_UNIT_MILE = "miles";
export const MAP_UNIT_KILOMETER = "km";

// All Possible values of DCON001_SET007
export const ALL = "All";
export const ASSIGNED = "Assigned";
export const QUEUED = "Queued";
export const NEW = "New";
export const DEFAULT_CALENDAR_DURATION = 7;

// Scheduler settings
export const SET004 = "DCON001_SET004";

let settings;
const loadSettings = () => {
  const state = store.getState();
  const { metaData } = state;
  const { appSettings = {} } = metaData || {};
  const { content } = appSettings || {};
  return content;
};

export const getSettingValue = (key, defValue) => {
  let value = defValue;
  if (!settings) settings = loadSettings();
  if (settings && settings[key]) {
    value = settings[key];
  }
  return value;
};
