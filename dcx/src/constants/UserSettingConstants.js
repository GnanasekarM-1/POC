import store from "store";

export const FILTER_COLUMN = "wo_filterColumn";
export const SORT_COLUMN = "wo_sortColumn";
export const SORT_ORDER = "wo_sortOrder";
export const VIEW_COUNTER = "wo_viewCounter";
export const SORTED_VIEWS = "wo_sortedViews";
export const WO_COL = "wo_woCol";
export const TECH_COL = "tech_techCol";
export const DEFAULT_VIEW = "wo_defaultView";
export const REQ_WO_FIELDS = "wo_grid_col_fields";
export const WO_GRID_CONF_FIELDS = "wo_grid_conf_fields";
export const USER_DATE_FORMAT = "userDateFormat";
export const WO_SEARCH_KEYWORD = "search_keyword";
export const TECH_SEARCH_KEYWORD = "search_techKeyword";
export const TEAM_SEARCH_KEYWORD = "search_teamKeyword";
export const TECH_HOLIDAYHOURS_COLOR = "tech_holidayHoursColor";
export const TECH_WORKINGHOURS_COLOR = "tech_workingHoursColor";
export const TECH_SHOWTIME_INDICATOR = "tech_showTimeIndicator";
export const TECH_TIMEINDICATOR_COLOR = "tech_timeIndicatorColor";

export const TECH_TERRITORY_SEQUENCE = "tech_territorySequence";
export const TECH_TEAM_SEQUENCE = "tech_teamSequence";
export const TECH_REFRESH_EVENTS_ONCHANGE = "tech_refreshEventsOnChange";

export const AUTO_CALC_END_DATE = "tech_autoCalculateEndDate";
export const AUTO_SYNC_SVC_DURATION = "tech_autoSyncServiceDuration";

// Scheduler
export const EXPANDED_TEAM = "tech_ExpandedTeam";
export const EXPANDED_TERRITORY = "tech_expandedTerritory";

const loadUserSettings = () => {
  const state = store.getState();
  const { userSettings } = state;
  return userSettings;
};

export const getUserSettingValue = (key, defValue) => {
  let value = defValue;
  const settings = loadUserSettings();
  if (settings && settings[key] !== undefined) {
    value = settings[key];
  }
  return value;
};
