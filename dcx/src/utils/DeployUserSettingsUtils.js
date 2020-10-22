const userSettingsMap = {
  one_1: "wo_autorefresh",
  one_2: "wo_isAlldayEvent",
  one_3: "wo_refreshtime",
  one_4: "wo_filterColumn",
  one_5: "wo_sortColumn",
  one_6: "wo_sortOrder",
  one_7: "wo_woHoverColor",
  one_8: "wo_woSelectionColor",
  one_9: "wo_defaultView",
  // one_10: "wo_grid_conf_fields",
  one_10: "wo_woCol",
  one_11: "wo_woRules",
  one_12: "wo_unassignWO",
  one_13: "wo_deleteEventForTech",
  one_14: "wo_schedulingAsLongJob",
  one_15: "wo_respectTechnincianWorkHours",
  one_16: "wo_respectMachineAccessHours",
  one_17: "wo_doNotOverlapExistingEvents",
  two_1: "tech_dcmap",
  two_2: "tech_mapDefaultZoomLevel",
  two_3: "tech_mapDefaultLat",
  two_4: "tech_mapDefaultLng",
  two_5: "tech_techCol",
  two_6: "tech_techRules",
  two_7: "tech_noOfDays",
  two_8: "tech_refreshEventsOnChange",
  two_9: "tech_autoCalculateEndDate",
  two_10: "tech_eventRowColor",
  two_11: "tech_toolTipShowDelay",
  two_12: "tech_toolTipHideDelay",
  two_13: "tech_dataTipOnClick",
  two_14: "tech_overheadColor",
  two_15: "tech_defaultEventColor",
  two_16: "tech_defaultWOEventColor",
  two_17: "tech_relatedEventColor",
  two_18: "tech_driveColor",
  two_19: "tech_overNightStayColor",
  two_20: "tech_showTimeIndicator",
  two_21: "tech_timeIndicatorColor",
  two_22: "tech_autoSyncServiceDuration",
  two_23: "tech_teamSequence",
  two_24: "tech_territorySequence",
  two_25: "tech_pinMapActionBar", // remove
  three_1: "search_keyword",
  three_2: "search_teamKeyword",
  three_3: "search_techKeyword",
  four_1: "adv_atsSkills",
  four_2: "adv_atsExpertise",
  four_3: "adv_atsEligibility",
  four_4: "adv_atsPrefTech",
  five_1: "map_mapViewportWidth"
};

export const getDeployUserSettingsRequestPayload = (dispatcher, settings) => {
  const allSettingKeys = [];
  const allSettings = [];
  const settingKeys = Object.keys(settings);
  settingKeys.forEach(key => {
    const values = settings[key];
    values.forEach(value => {
      allSettingKeys.push(`${key}_${value}`);
    });
  });
  allSettingKeys.forEach(key => {
    if (userSettingsMap[key]) {
      allSettings.push(userSettingsMap[key]);
    }
  });
  const requestPayload = {
    settings: allSettings,
    userids: dispatcher
  };
  return requestPayload;
};
export const key = "";
