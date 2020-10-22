import arrayToTree from "array-to-tree";
import { cloneDeep, flatten, groupBy, orderBy, isArray } from "lodash";
import { isNull, isObject } from "util";
import store from "store";
import * as moment from "moment";
import {
  NAME,
  REFERENCE,
  PARENT_ID,
  ARRAY_TO_TREE_CONFIG,
  TECH_KEYWORD,
  TECH_LATITUDE_PROPERTY,
  TECH_LONGITUDE_PROPERTY,
  TECH_HOME_LATITUDE_PROPERTY,
  TECH_HOME_LONGITUDE_PROPERTY,
  PARENT_TERRITORY_API_NAME,
  TEAM_API_NAME,
  TEAM_API_REF,
  TERRITORY_API_NAME,
  TERRITORY_API_REF,
  TERRITORY_PARENT,
  ADDRESS_FIELDS,
  DEFAULT_SORT_BY,
  DEFAULT_SORT_ORDER,
  TECH_SALESFORCE_USER_FIELD,
  TECH_SALESFORCE_USER_INFO,
  IS_ACTIVE,
  CREATEDBY,
  CREATEDBYID,
  LASTMODIFIEDBY,
  LASTMODIFIEDBYID,
  SALESFORCE_EVENT,
  TECH_ENABLE_SCHEDULING_FIELD,
  AM,
  PM,
  ID
} from "constants/AppConstants";
import { getUserSettingValue } from "constants/UserSettingConstants";
import { MEMBER_NAME } from "constants/SchedulerConstants";
import {
  getFieldValue,
  getFieldValues,
  convertUint2Hex,
  getDisplayValue
} from "utils/DCUtils";
import { getEventColorInfo } from "utils/ColorUtils";
import evalExpressions from "utils/HoverRuleUtils";

import { getUserTimeSettings } from "utils/DateAndTimeUtils";
import { GLOB001_GBL025, getSettingValue } from "constants/AppSettings";
import {
  TAG363,
  TAG362,
  EVENTSTAG104,
  EVENTSTAG105,
  EVENTSTAG106,
  EVENTSTAG107,
  EVENTSTAG108,
  EVENTSTAG109,
  EVENTSTAG110,
  EVENTSTAG111,
  EVENTSTAG112,
  EVENTSTAG113,
  EVENTSTAG114,
  EVENTSTAG115,
  EVENTSTAG116,
  EVENTSTAG117,
  EVENTSTAG118,
  EVENTSTAG119,
  EVENTSTAG120,
  EVENTSTAG121,
  EVENTSTAG122,
  TAG551,
  TAG552,
  TAG553,
  TAG554,
  TAG555,
  TAG556,
  TAG557,
  TAG534,
  TAG535,
  TAG536,
  TAG537,
  TAG540,
  TAG541,
  TAG542,
  TAG544,
  TAG545,
  TAG546,
  TAG547,
  TAG550
} from "constants/DisplayTagConstants";

let collapsedTeam = {};
let expandedTeam = {};
let collapsedTerritory = {};
let expandedTerritory = {};
let expandedTechList = [];

const PresetManager = window.bryntum.scheduler.PresetManager;
const DateHelper = window.bryntum.scheduler.DateHelper;

export const isTeamEventsLoaded = teamId => !!expandedTeam[teamId];

export const isTerritoryEventsLoaded = territoryId =>
  !!expandedTeam[territoryId];

export const setExpndedTerritory = (id, value) => {
  expandedTerritory[id] = value;
  delete collapsedTerritory[id];
};

export const resetExpndedTerritory = (id, value) => {
  expandedTerritory = {};
  collapsedTerritory = {};
};

export const setCollapsedTerritory = (id, value) => {
  collapsedTerritory[id] = value;
  delete expandedTerritory[id];
};

export const setExpandedTeam = (id, value) => {
  expandedTeam[id] = value;
  delete collapsedTeam[id];
};

export const resetExpandedTeam = (id, value) => {
  expandedTeam = {};
  collapsedTeam = {};
};

export const setCollapsedTeam = (id, value) => {
  collapsedTeam[id] = value;
  delete expandedTeam[id];
};

export const getExpandedTeam = () => expandedTeam;

export const getCollapsedTeam = () => collapsedTeam;

export const getExpandedTerritory = () => expandedTerritory;

export const getExpandedTeamTechList = () => {
  expandedTechList = [];
  Object.keys(expandedTeam).map(teamId => {
    const { children } = expandedTeam[teamId];
    children.map(techItem => {
      const { id } = techItem;
      expandedTechList.push(id);
      return undefined;
    });
  });
  return expandedTechList;
};

export const getExpandedTerritoryTechList = () => {
  expandedTechList = [];
  Object.keys(expandedTerritory).map(territoryId => {
    const { children } = expandedTerritory[territoryId];
    children.map(techItem => {
      const { id } = techItem;
      expandedTechList.push(id);
      return undefined;
    });
    return expandedTechList;
  });
};

export const getTechnicianData = () => {
  const state = store.getState();
  const { technicianData } = state;
  return technicianData;
};

export const createSchedulerTreeNode = (
  node,
  isTeamView,
  isTechnician,
  parentId
) => {
  if (!node && (!node.Name || !node.Id)) {
    return undefined;
  }
  const { Id, Name } = node;

  // Field to refer make parent/child relation.
  const parentIdField = isTeamView ? TEAM_API_NAME : TERRITORY_API_NAME;
  // Identify if the node is technician node.
  const isTech =
    getFieldValue(node, TEAM_API_REF) !== undefined ||
    getFieldValue(node, TERRITORY_API_REF) !== undefined ||
    isTechnician;
  const isTechSalesforceUser = node[TECH_SALESFORCE_USER_FIELD]
    ? node[TECH_SALESFORCE_USER_INFO]
    : "";
  const showPrevNextIcon = false;
  // Field refer for prev event.
  const isHavePrevEvent = false;
  // Field refer for next event.
  const isHaveNextEvent = false;
  // CSS class to represent parent icon based on the scheduler view
  const parentCls = isTeamView ? "b-icon b-fa-users" : "b-icon b-fa-folder";
  // Identify the parent/child relation for team/terrirtoy nodes.
  const teamTerritoryId = isTeamView
    ? null
    : getFieldValue(node, PARENT_TERRITORY_API_NAME, null) || parentId;
  const treeNode = {
    ...node,
    address: getFieldValues(node, ADDRESS_FIELDS, true).join(),
    homeAddress: getFieldValues(node, ADDRESS_FIELDS, true).join(),
    homeLat: getFieldValue(node, TECH_HOME_LATITUDE_PROPERTY, ""),
    homeLng: getFieldValue(node, TECH_HOME_LONGITUDE_PROPERTY, ""),
    iconCls: isTech ? "b-icon b-fa-user" : parentCls,
    id: Id,
    isHaveNextEvent,
    isHavePrevEvent,
    isTech,
    icon: isTech ? "user" : "",
    icon_category: isTech ? "utility" : "",
    lat: getFieldValue(node, TECH_LATITUDE_PROPERTY, ""),
    lng: getFieldValue(node, TECH_LONGITUDE_PROPERTY, ""),
    name: Name,
    [PARENT_ID]: isTech
      ? getFieldValue(node, parentIdField) || parentId
      : teamTerritoryId,
    resourceId: Id,
    showPrevNextIcon,
    isTechSalesforceUser,
    SmallPhotoUrl: getFieldValue(node, "SmallPhotoUrl", "")
  };
  return treeNode;
};

export function createTeamTerritoryTree(
  parentNodes = [],
  technicians = {},
  isTeamView
) {
  const parentMap = {};
  parentNodes.map(parentNode => {
    const { Id } = parentNode;
    if (!parentMap[Id]) {
      parentMap[Id] = createSchedulerTreeNode(
        parentNode,
        isTeamView,
        false,
        isTeamView
          ? null
          : getFieldValue(parentNode, PARENT_TERRITORY_API_NAME, null)
      );
    }
    return undefined;
  });

  const treeNodes = [];
  const pNodeIds = Object.keys(parentMap);
  Object.values(technicians).map(technician => {
    const { technician_O: technicianNode } = technician;
    const pNodeId = getFieldValue(
      technicianNode,
      isTeamView ? TEAM_API_NAME : TERRITORY_API_NAME
    );
    if (pNodeId && pNodeIds.includes(pNodeId)) {
      treeNodes.push(
        createSchedulerTreeNode(technicianNode, isTeamView, true, pNodeId)
      );
    }
    return undefined;
  });

  // Order all the displayable nodes on Name, ASC order & terrify sorted array.
  const territoryArray = Object.values(parentMap).concat(treeNodes);
  return arrayToTree(
    orderBy(territoryArray, [NAME, Number]),
    ARRAY_TO_TREE_CONFIG
  );
}

export function getTerritoryTeamDataOnLaunch(payload) {
  const { territoryTechnicianMap, territoryList } = payload;
  const nodes = [];
  territoryList.map(territory => {
    const { Id: territoryId } = territory;
    const technicianList = territoryTechnicianMap[territoryId];
    technicianList.map(technician => {
      nodes.push(createSchedulerTreeNode(technician, false, true, territoryId));
      return undefined;
    });
    nodes.push(
      createSchedulerTreeNode(
        territory,
        false,
        false,
        territory[TERRITORY_PARENT]
      )
    );
    return undefined;
  });
  return arrayToTree(orderBy(nodes, [NAME, Number]), ARRAY_TO_TREE_CONFIG);
}

export function getServiceTeamDataOnLaunch(payload) {
  const { teamTechnicianMap, teamList } = payload;
  const nodes = [];
  teamList.map(team => {
    const { Id: teamId } = team;
    const technicianList = teamTechnicianMap[teamId];
    technicianList.map(technician => {
      nodes.push(createSchedulerTreeNode(technician, true, true, teamId));
      return undefined;
    });
    nodes.push(createSchedulerTreeNode(team, true, false, null));
    return undefined;
  });
  return arrayToTree(orderBy(nodes, [NAME, Number]), ARRAY_TO_TREE_CONFIG);
}

export function getAllTechniciansIdsOnLaunch(payload) {
  const { teamTechnicianMap, territoryTechnicianMap } = payload;
  const allTeamsTech = Object.values(teamTechnicianMap);
  const allTerritoryTech = Object.values(territoryTechnicianMap);
  const allTechnicians = allTeamsTech.concat(allTerritoryTech);
  let allTechniciansIds = [];
  allTechnicians.map(technicianArray => {
    const techIds = technicianArray.map(a => a.Id);
    allTechniciansIds = allTechniciansIds.concat(techIds);
    return undefined;
  });
  return new Set(allTechniciansIds);
}

function setStartAndEndTimeForDateTest(
  dateScheduler,
  startTime,
  endTime,
  convertTimeZone,
  businessHourTz,
  tzDtFormat
) {
  let date = moment(dateScheduler).format("DD-MMM-YYYY");
  let returnDateObj = {};
  try {
    //let startDate = moment(date);
    if (convertTimeZone) {
      // startDate = moment(date)
      //.add(1, "days")
      // .tz(businessHourTz);
    }
    const [sHours, sMinutes] = startTime.split(":");
    //const startTimeMoment = moment(`${sHours}:${sMinutes}`, "HH:mm");
    let startDate = moment(date)
      .add(`${sHours}`, "hour")
      .add(`${sMinutes}`, "minute");
    //startDate.set({
    // hour: startTimeMoment.get("hour"),
    //  minute: startTimeMoment.get("minute"),
    //  second: startTimeMoment.get("second")
    //});

    // let endDate = moment(date);
    if (convertTimeZone) {
      //endDate = moment(date)
      // .add(1, "days")
      // .tz(businessHourTz);
    }
    let [eHours, eMinutes] = endTime.split(":");
    if (eHours === "00") {
      eHours = "23";
      eMinutes = "59";
    }
    let endDate = moment(date)
      .add(`${eHours}`, "hour")
      .add(`${eMinutes}`, "minute");
    /*const endTimeMoment = moment(`${eHours}:${eMinutes}`, "HH:mm");
    endDate.set({
      hour: endTimeMoment.get("hour"),
      minute: endTimeMoment.get("minute"),
      second: endTimeMoment.get("second")
    });*/

    if (convertTimeZone) {
      let utcStartDate = moment(startDate)
        .add(moment(startDate).utcOffset(), "m")
        .utc()
        .format(); //moment.utc(moment(startDate)).format();
      let utcEndDate = moment(endDate)
        .add(moment(endDate).utcOffset(), "m")
        .utc()
        .format(); //moment.utc(moment(endDate)).format();
      let workinHoursTZSDate = moment(utcStartDate).tz(businessHourTz);
      let workinHoursTZEDate = moment(utcEndDate).tz(businessHourTz);
      const startDateUserTimeFormat = moment.tz(workinHoursTZSDate, tzDtFormat);
      const endDateUserTimeFormat = moment(workinHoursTZEDate).tz(tzDtFormat);
      returnDateObj = {
        startDate: startDateUserTimeFormat.format(),
        endDate: endDateUserTimeFormat.format()
      };
    } else {
      returnDateObj = {
        endDate: moment(startDate).format(),
        startDate: moment(endDate).format()
      };
    }
  } catch (e) {
    console.log("Error Occured while processing working hours");
  }

  return returnDateObj;
}

function setStartAndEndTimeForDate(
  schedulerdDate,
  startTime,
  endTime,
  convertTimeZone,
  businessHourTz,
  tzDtFormat
) {
  let date = moment(schedulerdDate).format("DD-MMM-YYYY");
  let returnDateObj = {};
  try {
    let startDate = moment(date);
    if (convertTimeZone) {
      startDate = moment(date).tz(businessHourTz);
    }
    const [sHours, sMinutes] = startTime.split(":");
    const startTimeMoment = moment(`${sHours}:${sMinutes}`, "HH:mm");
    startDate.set({
      hour: startTimeMoment.get("hour"),
      minute: startTimeMoment.get("minute"),
      second: startTimeMoment.get("second")
    });

    let endDate = moment(date);
    if (convertTimeZone) {
      endDate = moment(date).tz(businessHourTz);
    }
    let [eHours, eMinutes] = endTime.split(":");
    if (eHours === "00") {
      eHours = "23";
      eMinutes = "59";
    }
    const endTimeMoment = moment(`${eHours}:${eMinutes}`, "HH:mm");
    endDate.set({
      hour: endTimeMoment.get("hour"),
      minute: endTimeMoment.get("minute"),
      second: endTimeMoment.get("second")
    });

    if (convertTimeZone) {
      const startDateUserTimeFormat = moment.tz(startDate, tzDtFormat);
      const endDateUserTimeFormat = moment(endDate).tz(tzDtFormat);
      returnDateObj = {
        startDate: startDateUserTimeFormat.format(),
        endDate: endDateUserTimeFormat.format()
      };
    } else {
      returnDateObj = {
        endDate: moment(startDate).format(),
        startDate: moment(endDate).format()
      };
    }
  } catch (e) {
    console.log("Error Occured while processing working hours");
  }

  return returnDateObj;
}

function holidayHoursDateWise(
  holidayDateString,
  data,
  workingHoursProcessData
) {
  const { TimeZoneSidKey, Holidays } = data;
  const {
    eventsStartDateFormatted,
    eventsEndDateFormatted,
    supportedTimeZones,
    tzDtFormat
  } = workingHoursProcessData;
  // const startDate = new Date(eventsStartDateFormatted);
  // const endDate = new Date(eventsEndDateFormatted);
  let holidayHourTz = "";
  let holidayHourTzSupport = false;
  let holidayHourDate = "";

  const rangeHolidayHour = {};
  if (TimeZoneSidKey) {
    holidayHourTz = TimeZoneSidKey;
    supportedTimeZones.map(item => {
      const { name } = item;
      if (name === holidayHourTz) {
        holidayHourTzSupport = true;
      }
    });
  }
  if (holidayHourTzSupport) {
    Holidays.map(holidayItem => {
      const startDate = new Date(eventsStartDateFormatted);
      const endDate = new Date(eventsEndDateFormatted);
      let holiday = 0;
      let currentDay = 0;
      // const currentDay = 0;
      while (startDate.getTime() < endDate.getTime()) {
        holiday = moment(startDate).day();
        currentDay = moment(holidayItem).day();
        const NewDate = moment(startDate); // .format('DD/MM/YYYY');
        const currentDateCheck = moment(startDate).format(
          getUserTimeSettings("dateFormat")
        );
        holidayHourDate = moment(startDate).format(
          getUserTimeSettings("dateFormat")
        );
        const holidayDatestr = moment(holidayItem).format(
          getUserTimeSettings("dateFormat")
        );
        // holiday = moment(holidayDatestr).day();
        // const currentDay = moment(NewDate).day();
        if (currentDateCheck === holidayDatestr) {
          if (currentDay === 0 && holiday === 0) {
            if (!rangeHolidayHour.hasOwnProperty(holidayHourDate)) {
              rangeHolidayHour[holidayHourDate] = [];
            }
            if (holidayHourTz === tzDtFormat) {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                false,
                holidayHourTz,
                tzDtFormat
              );
            } else {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                true,
                holidayHourTz,
                tzDtFormat
              );
            }
          }
          if (currentDay === 1 && holiday === 1) {
            if (!rangeHolidayHour.hasOwnProperty(holidayHourDate)) {
              rangeHolidayHour[holidayHourDate] = [];
            }
            if (holidayHourTz === tzDtFormat) {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                false,
                holidayHourTz,
                tzDtFormat
              );
            } else {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                true,
                holidayHourTz,
                tzDtFormat
              );
            }
          }
          if (currentDay === 2 && holiday === 2) {
            if (!rangeHolidayHour.hasOwnProperty(holidayHourDate)) {
              rangeHolidayHour[holidayHourDate] = [];
            }
            if (holidayHourTz === tzDtFormat) {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                false,
                holidayHourTz,
                tzDtFormat
              );
            } else {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                true,
                holidayHourTz,
                tzDtFormat
              );
            }
          }
          if (currentDay === 3 && holiday === 3) {
            if (!rangeHolidayHour.hasOwnProperty(holidayHourDate)) {
              rangeHolidayHour[holidayHourDate] = [];
            }
            if (holidayHourTz === tzDtFormat) {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                false,
                holidayHourTz,
                tzDtFormat
              );
            } else {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                true,
                holidayHourTz,
                tzDtFormat
              );
            }
          }
          if (currentDay === 4 && holiday === 4) {
            if (!rangeHolidayHour.hasOwnProperty(holidayHourDate)) {
              rangeHolidayHour[holidayHourDate] = [];
            }
            if (holidayHourTz === tzDtFormat) {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                false,
                holidayHourTz,
                tzDtFormat
              );
            } else {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                true,
                holidayHourTz,
                tzDtFormat
              );
            }
          }
          if (currentDay === 5 && holiday === 5) {
            if (!rangeHolidayHour.hasOwnProperty(holidayHourDate)) {
              rangeHolidayHour[holidayHourDate] = [];
            }
            if (holidayHourTz === tzDtFormat) {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                false,
                holidayHourTz,
                tzDtFormat
              );
            } else {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                true,
                holidayHourTz,
                tzDtFormat
              );
            }
          }
          if (currentDay === 6 && holiday === 6) {
            if (!rangeHolidayHour.hasOwnProperty(holidayHourDate)) {
              rangeHolidayHour[holidayHourDate] = [];
            }
            if (holidayHourTz === tzDtFormat) {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                false,
                holidayHourTz,
                tzDtFormat
              );
            } else {
              rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
                NewDate,
                "00:00:00.000Z",
                "23:59:00.000Z",
                true,
                holidayHourTz,
                tzDtFormat
              );
            }
          }
        }
        startDate.setDate(startDate.getDate() + 1);
      }
    });
    return rangeHolidayHour;
  }
}

function holidayHoursDateWiseModified(data, workingHoursProcessData) {
  const { TimeZoneSidKey, Holidays } = data;
  const {
    eventsStartDateFormatted,
    eventsEndDateFormatted,
    supportedTimeZones,
    tzDtFormat
  } = workingHoursProcessData;
  const holidayMap = {};
  Holidays.map(HolidayItem => {
    holidayMap[
      moment(HolidayItem).format(getUserTimeSettings("dateFormat"))
    ] = HolidayItem;
  });
  //let sDate = moment(eventsStartDateFormatted).format("DD-MM-YYYY");
  //let eDate = moment(eventsEndDateFormatted).format("DD-MM-YYYY");
  //const startDate = new Date(sDate);
  //const endDate = new Date(eDate);
  const startDate = new Date(eventsStartDateFormatted);
  const endDate = new Date(eventsEndDateFormatted);
  let holidayHourTz = "";
  let holidayHourTzSupport = false;
  let holidayHourDate = "";

  const rangeHolidayHour = {};
  if (TimeZoneSidKey) {
    holidayHourTz = TimeZoneSidKey;
    supportedTimeZones.map(item => {
      const { name } = item;
      if (name === holidayHourTz) {
        holidayHourTzSupport = true;
      }
    });
  }
  if (holidayHourTzSupport) {
    while (startDate.getTime() < endDate.getTime()) {
      const NewDate = moment(startDate);
      const currentDateCheck = moment(startDate).format(
        getUserTimeSettings("dateFormat")
      );
      holidayHourDate = moment(startDate).format(
        getUserTimeSettings("dateFormat")
      );
      if (holidayMap[currentDateCheck]) {
        if (holidayHourTz === tzDtFormat) {
          rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
            NewDate,
            "00:00:00.000Z",
            "23:59:00.000Z",
            false,
            holidayHourTz,
            tzDtFormat
          );
        } else {
          rangeHolidayHour[holidayHourDate] = setStartAndEndTimeForDate(
            NewDate,
            "00:00:00.000Z",
            "23:59:00.000Z",
            true,
            holidayHourTz,
            tzDtFormat
          );
        }
      }
      startDate.setDate(startDate.getDate() + 1);
    }
    return rangeHolidayHour;
  }
}

function workingHoursDateWise(data, workingHoursProcessData) {
  const {
    MondayStartTime,
    MondayEndTime,
    SundayStartTime,
    SundayEndTime,
    TuesdayStartTime,
    TuesdayEndTime,
    TimeZoneSidKey,
    WednesdayStartTime,
    WednesdayEndTime,
    ThursdayStartTime,
    ThursdayEndTime,
    FridayStartTime,
    FridayEndTime,
    SaturdayStartTime,
    SaturdayEndTime
  } = data;
  const {
    eventsStartDateFormatted,
    eventsEndDateFormatted,
    supportedTimeZones,
    tzDtFormat
  } = workingHoursProcessData;

  const startDate = new Date(eventsStartDateFormatted);
  //startDate.setDate(startDate.getDate() - 1);
  const endDate = new Date(eventsEndDateFormatted);
  //endDate.setDate(endDate.getDate() + 1);
  /* var workHours:Array = null
      workHours = []; */
  let businessHourTz = "";
  let businessHourTzSupport = false;
  let businessHourDate = "";
  const rangeBusinesHour = {};
  if (TimeZoneSidKey) {
    businessHourTz = TimeZoneSidKey;
    supportedTimeZones.map(item => {
      const { name } = item;
      if (name === businessHourTz) {
        businessHourTzSupport = true;
      }
    });
  }
  if (businessHourTzSupport) {
    while (startDate.getTime() < endDate.getTime()) {
      const NewDate = moment(startDate).format();
      const startOfTheDay = moment(startDate).day();
      // console.log(`startOfTheDay:${startOfTheDay}`);
      businessHourDate = moment(startDate).format();
      if (startOfTheDay === 0) {
        if (!rangeBusinesHour.hasOwnProperty(businessHourDate)) {
          rangeBusinesHour[businessHourDate] = [];
        }
        if (SundayStartTime) {
          if (businessHourTz === tzDtFormat) {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              SundayStartTime,
              SundayEndTime,
              false,
              businessHourTz,
              tzDtFormat
            );
          } else {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              SundayStartTime,
              SundayEndTime,
              true,
              businessHourTz,
              tzDtFormat
            );
          }
        }
      }
      if (startOfTheDay === 1) {
        if (!rangeBusinesHour.hasOwnProperty(businessHourDate)) {
          rangeBusinesHour[businessHourDate] = [];
        }
        if (MondayStartTime) {
          if (businessHourTz === tzDtFormat) {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              MondayStartTime,
              MondayEndTime,
              false,
              businessHourTz,
              tzDtFormat
            );
          } else {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              MondayStartTime,
              MondayEndTime,
              true,
              businessHourTz,
              tzDtFormat
            );
          }
        }
      }
      if (startOfTheDay === 2) {
        if (!rangeBusinesHour.hasOwnProperty(businessHourDate)) {
          rangeBusinesHour[businessHourDate] = [];
        }
        if (TuesdayStartTime) {
          if (businessHourTz === tzDtFormat) {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              TuesdayStartTime,
              TuesdayEndTime,
              false,
              businessHourTz,
              tzDtFormat
            );
          } else {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              TuesdayStartTime,
              TuesdayEndTime,
              true,
              businessHourTz,
              tzDtFormat
            );
          }
        }
      }
      if (startOfTheDay === 3) {
        if (!rangeBusinesHour.hasOwnProperty(businessHourDate)) {
          rangeBusinesHour[businessHourDate] = [];
        }
        if (WednesdayStartTime) {
          if (businessHourTz === tzDtFormat) {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              WednesdayStartTime,
              WednesdayEndTime,
              false,
              businessHourTz,
              tzDtFormat
            );
          } else {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              WednesdayStartTime,
              WednesdayEndTime,
              true,
              businessHourTz,
              tzDtFormat
            );
          }
        }
      }
      if (startOfTheDay === 4) {
        if (!rangeBusinesHour.hasOwnProperty(businessHourDate)) {
          rangeBusinesHour[businessHourDate] = [];
        }
        if (ThursdayStartTime) {
          if (businessHourTz === tzDtFormat) {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              ThursdayStartTime,
              ThursdayEndTime,
              false,
              businessHourTz,
              tzDtFormat
            );
          } else {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              ThursdayStartTime,
              ThursdayEndTime,
              true,
              businessHourTz,
              tzDtFormat
            );
          }
        }
      }
      if (startOfTheDay === 5) {
        if (!rangeBusinesHour.hasOwnProperty(businessHourDate)) {
          rangeBusinesHour[businessHourDate] = [];
        }
        if (FridayStartTime) {
          if (businessHourTz === tzDtFormat) {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              FridayStartTime,
              FridayEndTime,
              false,
              businessHourTz,
              tzDtFormat
            );
          } else {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              FridayStartTime,
              FridayEndTime,
              true,
              businessHourTz,
              tzDtFormat
            );
          }
        }
      }
      if (startOfTheDay === 6) {
        if (!rangeBusinesHour.hasOwnProperty(businessHourDate)) {
          rangeBusinesHour[businessHourDate] = [];
        }
        if (SaturdayStartTime) {
          if (businessHourTz === tzDtFormat) {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              SaturdayStartTime,
              SaturdayEndTime,
              false,
              businessHourTz,
              tzDtFormat
            );
          } else {
            rangeBusinesHour[businessHourDate] = setStartAndEndTimeForDate(
              NewDate,
              SaturdayStartTime,
              SaturdayEndTime,
              true,
              businessHourTz,
              tzDtFormat
            );
          }
        }
      }
      startDate.setDate(startDate.getDate() + 1);
    }
  }
  return rangeBusinesHour;
}

export function getTechnicianWorkingHoursData(
  payload,
  workingHoursProcessData,
  technicianIds = []
) {
  const {
    businesshrs_lstholidays,
    tech_break_hrs,
    tech_business_hrs: businessHours,
    tech_business_break_Ids: businessHourIds
  } = payload;
  const { holidayHoursColor, workingHoursColor } = workingHoursProcessData;
  let BusinessHourId = "";
  let HolidayHourId = "";
  const rangeOverAllBusinesHours = {};
  const overAllBusinessBreakHoursIds = [];
  const rangeBusinesHours = {};
  const rangeOverAllHolidayHours = {};
  const rangeHolidayHours = {};
  if (businessHourIds) {
    businessHourIds.map(reqT => {
      const { businesshrID } = reqT;
      if (businesshrID) {
        overAllBusinessBreakHoursIds.push(reqT);
      }
    });
  }
  if (businesshrs_lstholidays) {
    businesshrs_lstholidays.map(reqT => {
      const { BHID, Holidays } = reqT;
      if (BHID) {
        HolidayHourId = BHID;
        if (!rangeOverAllHolidayHours[HolidayHourId]) {
          rangeOverAllHolidayHours[HolidayHourId] = [];
        }
        rangeOverAllHolidayHours[HolidayHourId] = holidayHoursDateWiseModified(
          reqT,
          workingHoursProcessData
        );
      }
    });
  }

  if (businessHours) {
    businessHours.map(reqB => {
      const { Id } = reqB;
      if (Id) {
        BusinessHourId = Id;
        if (!rangeOverAllBusinesHours[BusinessHourId]) {
          rangeOverAllBusinesHours[BusinessHourId] = [];
        }
        rangeOverAllBusinesHours[BusinessHourId] = workingHoursDateWise(
          reqB,
          workingHoursProcessData
        );
      }
    });
  }
  overAllBusinessBreakHoursIds.map(item => {
    const { businesshrID, techID } = item;
    if (!rangeBusinesHours[techID]) {
      rangeBusinesHours[techID] = [];
    }
    if (businesshrID) {
      const businessMap = businesshrID;
      /** mapping technician id and business id* */
      if (rangeOverAllBusinesHours[businessMap]) {
        rangeBusinesHours[techID] = rangeOverAllBusinesHours[businessMap];
      }
      if (rangeOverAllHolidayHours[businessMap]) {
        if (!rangeHolidayHours[techID]) {
          rangeHolidayHours[techID] = [];
        }
        rangeHolidayHours[techID] = rangeOverAllHolidayHours[businessMap];
      }
    }
  });

  let count = 0;
  const techniciansList = [];
  technicianIds.map(item => {
    const techBussinessHours = rangeBusinesHours[item];
    const techHolidayHours = rangeHolidayHours[item];
    if (techHolidayHours) {
      const HolidayTechMap = Object.keys(techHolidayHours);
      HolidayTechMap.map(bHItem => {
        const { endDate, startDate } = techHolidayHours[bHItem];
        if (endDate && startDate) {
          const technician = {
            endDate: moment(endDate, moment.HTML5_FMT.DATETIME_LOCAL).format(
              moment.HTML5_FMT.DATETIME_LOCAL
            ),
            id: (count += 1),
            isWorkingHours: false,
            isBreakHours: false,
            isHolidayHours: true,
            resourceId: item,
            startDate: moment(
              startDate,
              moment.HTML5_FMT.DATETIME_LOCAL
            ).format(moment.HTML5_FMT.DATETIME_LOCAL),
            style: `background:${convertUint2Hex(holidayHoursColor)};
            border: 1px solid white;  
            background-repeat: no-repeat;
            background-size: contain;`
          };
          techniciansList.push(technician);
        }
      });
    }
    const TechMap = Object.keys(techBussinessHours);
    TechMap.map(bItem => {
      let checkSameDayHoliday = false;
      const { endDate, startDate } = techBussinessHours[bItem];
      if (techHolidayHours) {
        const HolidayTechMap = Object.keys(techHolidayHours);
        HolidayTechMap.map(bHItem => {
          const { endDate: endHDate, startDate: startHDate } = techHolidayHours[
            bHItem
          ];
          const isSBetween =
            moment(startDate).isBetween(startHDate, endHDate) ||
            moment(startHDate).isSame(startDate);
          const isEBetween =
            moment(endDate).isBetween(startHDate, endHDate) ||
            moment(startHDate).isSame(endDate);
          if (isSBetween || isEBetween) {
            checkSameDayHoliday = true;
          }
        });
      }
      if (!checkSameDayHoliday) {
        if (endDate && startDate) {
          const technician = {
            endDate: moment(endDate, moment.HTML5_FMT.DATETIME_LOCAL).format(
              moment.HTML5_FMT.DATETIME_LOCAL
            ),
            id: (count += 1),
            name: "",
            isWorkingHours: true,
            isBreakHours: false,
            isHolidayHours: false,
            resourceId: item,
            startDate: moment(
              startDate,
              moment.HTML5_FMT.DATETIME_LOCAL
            ).format(moment.HTML5_FMT.DATETIME_LOCAL),
            style: `background:${convertUint2Hex(workingHoursColor)};
          border: 1px solid white;  
          background-repeat: no-repeat;
          background-size: contain;`
          };
          techniciansList.push(technician);
        }
      }
    });
  });
  return techniciansList;
}

export function getSearchTechnicians(payload = [], action, teamView) {
  const techData = getTechnicianData();
  const { technicians } = techData;
  const { findWhat } = action;
  let technicianData = {};
  const searchTechList = [];
  if (findWhat !== TECH_KEYWORD) {
    teamView.map(item => {
      const { children } = item;
      if (!children) {
        return undefined;
      }
      children.filter(childitem => {
        searchTechList.push(childitem.Id);
        return undefined;
      });
    });
    searchTechList.map(techId => {
      if (technicians.data.technicians[techId]) {
        technicianData[techId] = technicians.data.technicians[techId];
      }
      return undefined;
    });
  } else {
    payload.map(techId => {
      if (technicians.data.technicians[techId]) {
        technicianData[techId] = technicians.data.technicians[techId];
      }
      return undefined;
    });
  }

  return technicianData;
}

export function getTeamIds(teamView) {
  return teamView.map(team => team.Id);
}

export function getSearchedTechTeamData(payload = [], action) {
  const techData = getTechnicianData();
  const { technicians } = techData;
  const { data } = technicians;
  const { teamView } = data;
  const searchList = [];
  const { findWhat } = action;

  if (findWhat === TECH_KEYWORD) {
    teamView.map(item => {
      const searchTechList = [];
      let checkTech = false;
      const { children } = item;
      if (!children) {
        return undefined;
      }
      payload.map(techItem => {
        children.filter(childitem => {
          if (childitem.Id === techItem) {
            searchTechList.push(childitem);
            checkTech = true;
          }
          return undefined;
        });
        return undefined;
      });
      if (checkTech) {
        // const techList = JSON.parse(JSON.stringify(item));
        const techTeam = cloneDeep(item);
        techTeam.expanded = true;
        techTeam.children = orderBy(
          searchTechList,
          [DEFAULT_SORT_BY],
          [DEFAULT_SORT_ORDER]
        );
        searchList.push(techTeam);
      }
      return undefined;
    });
  } else {
    payload.map(teamItem => {
      const teamList = teamView.filter(team => teamItem === team.id);
      if (teamList.length) {
        const [matchingTeam] = teamList;
        matchingTeam.expanded = false;
        searchList.push(matchingTeam);
      }
      return undefined;
    });
  }
  return searchList;
}
export function getSearchedTechTerritoryTeamData(payload, action) {
  const techData = getTechnicianData();
  const { technicians } = techData;
  const { data } = technicians;
  const { territoryView, territoryList, technicians: technicianMap } = data;
  const searchList = [];
  const searchTechList = [];
  const { findWhat } = action;
  const territoryMap = {};
  territoryList.map(territory => {
    const { Id } = territory;
    territoryMap[Id] = territory;
    return undefined;
  });

  if (findWhat === TECH_KEYWORD) {
    const resultArray = [];
    const searchTerritories = [];
    payload.map(techId => {
      const technician = technicianMap[techId];
      if (technician) {
        const { technician_O: techObj } = technician;
        const territoryId = getFieldValue(techObj, TERRITORY_API_NAME, null);
        const territory = territoryMap[territoryId];
        if (territory) {
          let pTerritoryId = getFieldValue(
            territory,
            PARENT_TERRITORY_API_NAME,
            null
          );
          if (!searchTerritories.includes(territoryId)) {
            searchTerritories.push(territoryId);
            const tNode = createSchedulerTreeNode(
              territory,
              false,
              false,
              pTerritoryId
            );
            tNode.expanded = true;
            resultArray.push(tNode);
          }

          while (pTerritoryId && !searchTerritories.includes(pTerritoryId)) {
            searchTerritories.push(pTerritoryId);
            const pTerritoryNode = territoryMap[pTerritoryId];
            if (pTerritoryNode) {
              pTerritoryId = getFieldValue(
                pTerritoryNode,
                PARENT_TERRITORY_API_NAME,
                null
              );
              const pNode = createSchedulerTreeNode(
                pTerritoryNode,
                false,
                false,
                pTerritoryId
              );
              pNode.expanded = true;
              resultArray.push(pNode);
            }
          }
          resultArray.push(
            createSchedulerTreeNode(techObj, false, true, territoryId)
          );
        }
      }
    });
    return arrayToTree(
      orderBy(resultArray, [NAME, Number]),
      ARRAY_TO_TREE_CONFIG
    );
  }

  // if (findWhat === TECH_KEYWORD) {
  //   territoryView.map(item => {
  //     let checkTech = false;
  //     const { children } = item;
  //     if (!children) {
  //       return undefined;
  //     }
  //     payload.map(techItem => {
  //       children.filter(childitem => {
  //         if (childitem.id === techItem) {
  //           searchTechList.push(childitem);
  //           checkTech = true;
  //         }
  //         return undefined;
  //       });
  //       return undefined;
  //     });
  //     if (checkTech) {
  //       const teamList = JSON.parse(JSON.stringify(item));
  //       teamList.expanded = true;
  //       teamList.children = orderBy(
  //         searchTechList,
  //         [DEFAULT_SORT_BY],
  //         [DEFAULT_SORT_ORDER]
  //       );
  //       searchList.push(teamList);
  //     }
  //     return undefined;
  //   });
  // }
  // else {
  territoryView.map(teamItem => {
    const teamList = payload.filter(team => teamItem.id === team);
    teamList.expanded = true;
    if (teamList.length > 0) {
      searchList.push(teamList);
    }
    return undefined;
  });
  // }
  return searchList;
}

const getColorRuleInfo = () => {
  const colorRuleInfo = {};
  colorRuleInfo.eventRules = getUserSettingValue("tech_techRules");
  colorRuleInfo.defaultEventColor = getUserSettingValue(
    "tech_defaultEventColor"
  );
  colorRuleInfo.defaultWOEventColor = getUserSettingValue(
    "tech_defaultWOEventColor"
  );
  colorRuleInfo.relatedEventColor = getUserSettingValue(
    "tech_relatedEventColor"
  );

  colorRuleInfo.overHeadEventColor = getUserSettingValue("tech_overheadColor");
  colorRuleInfo.driveTimeEventColor = getUserSettingValue("tech_driveColor");
  colorRuleInfo.overNightStayColor = getUserSettingValue(
    "tech_overNightStayColor"
  );
  return colorRuleInfo;
};

const getEventHoverInfo = (workOrder, hoverRules) => {
  const hoverFields = evalExpressions(workOrder, hoverRules);
  return { hoverFields };
};

const getEventMapDataFromWorkOrder = (woInfo = {}) => {
  const address = getFieldValues(woInfo, ADDRESS_FIELDS, true).join();
  const lat = getFieldValue(woInfo, TECH_LATITUDE_PROPERTY, "");
  const lng = getFieldValue(woInfo, TECH_LONGITUDE_PROPERTY, "");
  const isHightLight = false;
  const workOrderName = getFieldValue(woInfo, NAME, "");
  return {
    address,
    lat,
    lng,
    isHightLight,
    workOrderName
  };
};

const getWoFieldUpdates = (fieldUpdates = {}) => ({ fieldUpdates });

const getWoFields = (woFields = {}) => ({ woFields });

export const modifyDeltaEvents = (content, hoverRules) => {
  const deletedEventIds = [];

  let createdEvents = [];

  const allEvents = [];
  const { woInfoMap, events } = content;
  events.forEach(eventItem => {
    const { event_WP: eventObject } = eventItem;
    if (eventObject) {
      if (eventObject.isDeleted) {
        deletedEventIds.push(eventObject.id);
      } else {
        createdEvents = createdEvents.concat(
          getEventsData({ events: [eventItem], woInfoMap }, hoverRules)
        );
      }
      allEvents.push(eventObject);
    }
  });
  return { deletedEventIds, createdEvents, allEvents };
};

export function getEventsData(payload, hoverRules = []) {
  const eventList = [];
  const { events = [], woInfoMap = {} } = isArray(payload)
    ? { events: payload }
    : payload;
  const eventColorRules = getColorRuleInfo();
  events.forEach(eventItem => {
    const { event_WP: eventObject } = eventItem;
    if (eventObject) {
      const {
        id,
        isWorkOrder,
        TechId: resourceId,
        startDateTime,
        endDateTime,
        subject: name,
        whatId: WOId
      } = eventObject;
      if (id) {
        const eventColorInfo = getEventColorInfo(
          eventObject,
          isWorkOrder && WOId ? woInfoMap[WOId] : {},
          eventColorRules
        );
        const eventMapData = getEventMapDataFromWorkOrder(woInfoMap[WOId]);
        const hoverInfo = isWorkOrder
          ? getEventHoverInfo(woInfoMap[WOId], hoverRules)
          : { hoverFields: {} };
        const fieldUpdates = isWorkOrder
          ? getWoFieldUpdates(woInfoMap[WOId])
          : { fieldUpdates: {} };
        const woFields = isWorkOrder
          ? getWoFields(woInfoMap[WOId])
          : { woFields: {} };
        const event = {
          endDate: new Date(endDateTime),
          name,
          resourceId,
          startDate: new Date(startDateTime),
          WOId
        };
        eventList.push(
          Object.assign(
            {},
            event,
            eventObject,
            hoverInfo,
            eventColorInfo,
            eventMapData,
            fieldUpdates,
            woFields
          )
        );
      }
    }
  });
  return eventList;
}

export function getAllTechniciansIds(payload) {
  const { technicians } = payload;
  return Object.keys(technicians);
}

export function getWorkOrderConfigMap(data) {
  const { Id, Name } = data;
  const workOrder = {
    address: getFieldValues(data, ADDRESS_FIELDS, true).join(),
    id: Id,
    WOId: Id,
    lat: getFieldValue(data, TECH_LATITUDE_PROPERTY, ""),
    lng: getFieldValue(data, TECH_LONGITUDE_PROPERTY, ""),
    name: Name
  };
  return workOrder;
}

const loadTechniciansFields = () => {
  const state = store.getState();
  const { metaData } = state;
  const { technicianFields } = metaData;
  const { content: allTechFields } = technicianFields;
  return allTechFields;
};

const loadTeamTerritoryFields = (selectedView = 0) => {
  const state = store.getState();
  const { metaData } = state;
  const { serviceTeamFields } = metaData;
  const { content: teamFields } = serviceTeamFields;
  return teamFields;
};

const isBoolType = fieldType =>
  fieldType && fieldType.toUpperCase() === "BOOLEAN";

const getDefaultValue = fieldInfo =>
  fieldInfo && isBoolType(fieldInfo.fieldType) ? false : null;

const referenceColSort = (techA, techB, fieldName) => {
  let refFieldName_A,
    refFieldName_B,
    refFieldName = fieldName;
  const { data: techAData } = techA;
  const { data: techBData } = techB;
  if (fieldName.endsWith("__c")) {
    refFieldName = fieldName.replace("__c", "__r");
    refFieldName_A = techAData[refFieldName]
      ? techAData[refFieldName][NAME] || ""
      : "";
    refFieldName_B = techBData[refFieldName]
      ? techBData[refFieldName][NAME] || ""
      : "";
  } else if (fieldName.endsWith(ID)) {
    refFieldName = fieldName.replace(ID, "");
    refFieldName_A = techAData[refFieldName]
      ? techAData[refFieldName][NAME] || ""
      : "";
    refFieldName_B = techBData[refFieldName]
      ? techBData[refFieldName][NAME] || ""
      : "";
  }
  return refFieldName_A.localeCompare(refFieldName_B);
};

const techColSort = (techA, techB, fieldName) => {
  let refFieldName_A,
    refFieldName_B,
    refFieldName = fieldName;
  const { data: techAData } = techA;
  const { data: techBData } = techB;
  refFieldName_A = techAData[refFieldName] || "";
  refFieldName_B = techBData[refFieldName] || "";
  return `${refFieldName_A}`.localeCompare(`${refFieldName_B}`);
};

export function getTechnicianColumn(techColumns, selectedView = 0) {
  const columns = [];
  const techFields = loadTechniciansFields();
  const teamFields = loadTeamTerritoryFields(selectedView);
  if (techColumns) {
    techColumns.forEach(item => {
      const { name, width } = item;
      const techField = techFields[name];
      if (!techField) {
        return;
      }
      const { display, fieldType } = techField;
      const column = {
        editor: false,
        field: name,
        htmlEncode: false,
        renderer: ({ record }) => {
          const { data } = record;
          const { isTech } = data;
          let value =
            data[name] ||
            getDefaultValue(isTech ? techFields[name] : teamFields[name]);
          if (isNull(value)) {
            return "";
          }

          if (name.endsWith("__c")) {
            value = data[name.replace("__c", "__r")] || value;
          } else if (name === CREATEDBYID) {
            value = data[CREATEDBY] || value;
          } else if (name === LASTMODIFIEDBYID) {
            value = data[LASTMODIFIEDBY] || value;
          }
          return `<div>${value && isObject(value) ? value[NAME] : value}</div>`;
        },
        enableHeaderContextMenu: false,
        sortable:
          fieldType === REFERENCE
            ? (techA, techB) => referenceColSort(techA, techB, name)
            : (techA, techB) => techColSort(techA, techB, name),
        draggable: false,
        text: display,
        width: typeof width === "string" ? Number(width) : width
      };
      if (name !== MEMBER_NAME) {
        columns.push(column);
      }
    });
  }

  return columns;
}

export const dateCompare = (dateTimeA, dateTimeB) => {
  let value = "None";
  if (moment(dateTimeA).isAfter(moment(dateTimeB))) {
    value = "isAfter";
  }
  if (moment(dateTimeA).isSame(moment(dateTimeB))) {
    value = "isSame";
  }
  if (moment(dateTimeA).isBefore(moment(dateTimeB))) {
    value = "isBefore";
  }
  return value;
};

export const sortTeamTerrirtoyBySequence = (
  viewNodes = [],
  sequenceList = []
) => {
  const sequenceNodes = [];
  if (sequenceList.length) {
    const groupedViews = groupBy(
      Array.from(viewNodes),
      viewNode => viewNode.Id
    );
    sequenceList.map(sequenceId => {
      const viewNode = groupedViews[sequenceId];
      if (viewNode) {
        sequenceNodes.push(viewNode[0]);
        delete groupedViews[sequenceId];
      }
      return undefined;
    });
    // Append all the new nodes without parent Territory reference
    return sequenceNodes.concat(flatten(Object.values(groupedViews)));
  }
  return orderBy(viewNodes, [NAME]);
};

export const isSchedulingEnabled = technician => {
  const isSaleforceEvent = getSettingValue(GLOB001_GBL025) === SALESFORCE_EVENT;
  const enableScheduling = getFieldValue(
    technician,
    TECH_ENABLE_SCHEDULING_FIELD,
    false
  );
  const techSFInfo = getFieldValue(technician, TECH_SALESFORCE_USER_INFO, null);
  const isActive = techSFInfo
    ? getFieldValue(techSFInfo, IS_ACTIVE, false)
    : enableScheduling;
  return isSaleforceEvent ? isActive : enableScheduling;
};

const timeFormat = getUserTimeSettings("timeFormat");
const is24HFormat = getUserTimeSettings("is24");
const hourFormat = is24HFormat ? "H" : "h A";
const dayNightFormat = is24HFormat ? "H" : "A";

const displayDateFormat = format => {
  const dateDisplayMapper = {
    AM: getDisplayValue(TAG362),
    PM: getDisplayValue(TAG363),
    Monday: getDisplayValue(EVENTSTAG104, "Monday"),
    Tuesday: getDisplayValue(EVENTSTAG105, "Tuesday"),
    Wednesday: getDisplayValue(EVENTSTAG106, "Wednesday"),
    Thursday: getDisplayValue(EVENTSTAG107, "Thursday"),
    Friday: getDisplayValue(EVENTSTAG108, "Friday"),
    Saturday: getDisplayValue(EVENTSTAG109, "Saturday"),
    Sunday: getDisplayValue(EVENTSTAG110, "Sunday"),
    January: getDisplayValue(EVENTSTAG111, "January"),
    February: getDisplayValue(EVENTSTAG112, "February"),
    March: getDisplayValue(EVENTSTAG113, "March"),
    April: getDisplayValue(EVENTSTAG114, "April"),
    May: getDisplayValue(EVENTSTAG115, "May"),
    June: getDisplayValue(EVENTSTAG116, "June"),
    July: getDisplayValue(EVENTSTAG117, "July"),
    August: getDisplayValue(EVENTSTAG118, "August"),
    September: getDisplayValue(EVENTSTAG119, "September"),
    October: getDisplayValue(EVENTSTAG120, "October"),
    November: getDisplayValue(EVENTSTAG121, "November"),
    December: getDisplayValue(EVENTSTAG122, "December"),
    Mon: getDisplayValue(TAG551, "Mon"),
    Tue: getDisplayValue(TAG552, "Tue"),
    Wed: getDisplayValue(TAG553, "Wed"),
    Thu: getDisplayValue(TAG554, "Thu"),
    Fri: getDisplayValue(TAG555, "Fri"),
    Sat: getDisplayValue(TAG556, "Sat"),
    Sun: getDisplayValue(TAG557, "Sun"),
    Jan: getDisplayValue(TAG534, "Jan"),
    Feb: getDisplayValue(TAG535, "Feb"),
    Mar: getDisplayValue(TAG536, "Mar"),
    Apr: getDisplayValue(TAG537, "Apr"),
    May: getDisplayValue(TAG540, "May"),
    Jun: getDisplayValue(TAG541, "Jun"),
    Jul: getDisplayValue(TAG542, "Jul"),
    Aug: getDisplayValue(TAG544, "Aug"),
    Sep: getDisplayValue(TAG545, "Sep"),
    Oct: getDisplayValue(TAG546, "Oct"),
    Nov: getDisplayValue(TAG547, "Nov"),
    Dec: getDisplayValue(TAG550, "Dec")
  };
  return format.replace(
    /AM|PM|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|January|February|March|April|May|June|July|August|September|October|November|December|Mon|Tue|Wed|Thu|Fri|Sat|Sun|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec/gi,
    format => dateDisplayMapper[format]
  );
};

PresetManager.registerPreset("minuteAndHour-50by60", {
  timeResolution: {
    unit: "minute",
    increment: 5
  },
  headers: [
    {
      increment: 1,
      unit: "hour",
      dateFormat: `dddd MMMM DD YYYY, ${hourFormat}`,
      renderer: start =>
        displayDateFormat(
          DateHelper.format(start, `dddd MMMM DD YYYY, ${hourFormat}`)
        )
    },
    {
      unit: "minute",
      increment: 5,
      dateFormat: "mm",
      renderer: start => displayDateFormat(DateHelper.format(start, "mm"))
    }
  ],
  id: "minuteAndHour-50by60",
  rowHeight: 24,
  name: "Minutes",
  tickWidth: 50,
  tickHeight: 100,
  displayDateFormat: `dddd MMMM DD YYYY, ${hourFormat}`,
  shiftIncrement: 1,
  shiftUnit: "hour",
  defaultSpan: 24
});

PresetManager.registerPreset("minuteAndHour-30by60", {
  timeResolution: {
    unit: "minute",
    increment: 5
  },
  headers: [
    {
      increment: 1,
      unit: "hour",
      dateFormat: `dddd MMMM DD YYYY, ${hourFormat}`,
      renderer: start =>
        displayDateFormat(
          DateHelper.format(start, `dddd MMMM DD YYYY, ${hourFormat}`)
        )
    },
    {
      unit: "minute",
      increment: 5,
      dateFormat: "mm",
      renderer: start => displayDateFormat(DateHelper.format(start, "mm"))
    }
  ],
  id: "minuteAndHour-30by60",
  rowHeight: 24,
  name: "Minutes",
  tickWidth: 30,
  tickHeight: 60,
  displayDateFormat: `dddd MMMM DD YYYY, ${hourFormat}`,
  shiftIncrement: 1,
  shiftUnit: "hour",
  defaultSpan: 24
});

PresetManager.registerPreset("minuteAndHour-36by60", {
  timeResolution: {
    unit: "minute",
    increment: 5
  },
  headers: [
    {
      increment: 1,
      unit: "hour",
      dateFormat: `ddd MMMM DD ‘YY, ${hourFormat}`,
      renderer: start =>
        displayDateFormat(
          DateHelper.format(start, `ddd MMMM DD ‘YY, ${hourFormat}`)
        )
    },
    {
      unit: "minute",
      increment: 15,
      dateFormat: "mm",
      renderer: start => displayDateFormat(DateHelper.format(start, "mm"))
    }
  ],
  id: "minuteAndHour-36by60",
  rowHeight: 24,
  name: "Minutes",
  tickWidth: 36,
  tickHeight: 60,
  displayDateFormat: `ddd MMMM DD ‘YY, ${hourFormat}`,
  shiftIncrement: 1,
  shiftUnit: "hour",
  defaultSpan: 24
});

PresetManager.registerPreset("hourAndDay", {
  timeResolution: {
    unit: "minute",
    increment: 15
  },
  headers: [
    {
      unit: "day",
      increment: 1,
      dateFormat: "dddd MMMM DD, YYYY",
      renderer: start =>
        displayDateFormat(DateHelper.format(start, "dddd MMMM DD, YYYY"))
    },
    {
      increment: 1,
      unit: "hour",
      dateFormat: `${hourFormat}`,
      renderer: start =>
        displayDateFormat(DateHelper.format(start, `${hourFormat}`))
    }
  ],
  name: "hourAndDay",
  id: "hourAndDay",
  rowHeight: 24,
  tickWidth: 70
});

PresetManager.registerPreset("hourAndDay-38by60", {
  timeResolution: {
    unit: "minute",
    increment: 30
  },
  defaultSpan: 24,
  mainHeaderLevel: 1,
  headers: [
    {
      unit: "day",
      increment: 1,
      dateFormat: "dddd MMMM DD, YYYY",
      renderer: start =>
        displayDateFormat(DateHelper.format(start, "dddd MMMM DD, YYYY"))
    },
    {
      increment: 1,
      unit: "hour",
      dateFormat: `${hourFormat}`,
      renderer: start =>
        displayDateFormat(DateHelper.format(start, `${hourFormat}`))
    }
  ],
  id: "hourAndDay-38by60",
  name: "hourAndDay",
  tickWidth: 38,
  rowHeight: 60,
  tickHeight: 60,
  displayDateFormat: "dddd MMMM DD, YYYY",
  shiftIncrement: 1,
  shiftUnit: "HOUR"
});

PresetManager.registerPreset("hourAndDay-38by60-2", {
  timeResolution: {
    unit: "minute",
    increment: 45
  },
  headers: [
    {
      increment: 1,
      unit: "day",
      dateFormat: "dddd MMMM DD, YYYY",
      renderer: start =>
        displayDateFormat(DateHelper.format(start, "dddd MMMM DD, YYYY"))
    },
    {
      increment: 2,
      unit: "hour",
      dateFormat: `${hourFormat}`,
      renderer: start =>
        displayDateFormat(DateHelper.format(start, `${hourFormat}`))
    }
  ],
  id: "hourAndDay-38by60-2",
  rowHeight: 24,
  name: "Hours",
  tickWidth: 38,
  tickHeight: 60,
  displayDateFormat: "dddd MMMM DD, YYYY",
  shiftIncrement: 1,
  shiftUnit: "day",
  defaultSpan: 24
});

PresetManager.registerPreset("hourAndDay-38by60-4", {
  timeResolution: {
    unit: "hour",
    increment: 1
  },
  headers: [
    {
      increment: 1,
      unit: "day",
      dateFormat: "dddd MMMM DD, YYYY",
      renderer: start =>
        displayDateFormat(DateHelper.format(start, "dddd MMMM DD, YYYY"))
    },
    {
      increment: 4,
      unit: "hour",
      dateFormat: `${hourFormat}`,
      renderer: start =>
        displayDateFormat(DateHelper.format(start, `${hourFormat}`))
    }
  ],
  id: "hourAndDay-38by60-4",
  rowHeight: 24,
  name: "Hours",
  tickWidth: 38,
  tickHeight: 60,
  displayDateFormat: "dddd MMMM DD, YYYY",
  shiftIncrement: 1,
  shiftUnit: "day",
  defaultSpan: 24
});

PresetManager.registerPreset("hourAndDay-56by60", {
  timeResolution: {
    unit: "hour",
    increment: 1
  },
  headers: [
    {
      increment: 1,
      unit: "day",
      dateFormat: "ddd MMM DD, YY",
      renderer: start =>
        displayDateFormat(DateHelper.format(start, "ddd MMM DD, YY"))
    },
    {
      increment: 12,
      unit: "hour",
      dateFormat: `${dayNightFormat}`,
      renderer: start =>
        displayDateFormat(DateHelper.format(start, `${dayNightFormat}`))
    }
  ],
  id: "hourAndDay-56by60",
  rowHeight: 24,
  name: "Hours",
  tickWidth: 56,
  tickHeight: 60,
  displayDateFormat: "ddd MMM DD, YY",
  shiftIncrement: 1,
  shiftUnit: "day",
  defaultSpan: 24
});

PresetManager.registerPreset("monthAndDay-40by60", {
  timeResolution: {
    unit: "hour",
    increment: 1
  },
  headers: [
    {
      increment: 1,
      unit: "month",
      dateFormat: "MMMM YYYY",
      renderer: start =>
        displayDateFormat(DateHelper.format(start, "MMMM YYYY"))
    },
    {
      unit: "day",
      increment: 1,
      dateFormat: "ddd DD",
      renderer: start => displayDateFormat(DateHelper.format(start, "ddd DD"))
    }
  ],
  id: "monthAndDay-40by60",
  rowHeight: 24,
  name: "Days",
  tickWidth: 44,
  tickHeight: 60,
  displayDateFormat: "MMMM YYYY",
  shiftIncrement: 1,
  shiftUnit: "day",
  defaultSpan: 24
});

PresetManager.registerPreset("monthAndDay-20by60", {
  timeResolution: {
    unit: "hour",
    increment: 4
  },
  headers: [
    {
      increment: 1,
      unit: "month",
      dateFormat: "MMMM YYYY",
      renderer: start =>
        displayDateFormat(DateHelper.format(start, "MMMM YYYY"))
    },
    {
      unit: "day",
      increment: 1,
      dateFormat: "DD",
      renderer: start => displayDateFormat(DateHelper.format(start, "DD"))
    }
  ],
  id: "monthAndDay-20by60",
  rowHeight: 24,
  name: "Days",
  tickWidth: 20,
  tickHeight: 60,
  displayDateFormat: "MMMM YYYY",
  shiftIncrement: 1,
  shiftUnit: "month",
  defaultSpan: 24
});

PresetManager.registerPreset("weekAndMonth", {
  timeResolution: {
    unit: "week"
  },
  headerConfig: {
    middle: {
      unit: "week",
      dateFormat: "W",
      renderer: start => `W${DateHelper.format(start, "W")}`
    },
    top: {
      unit: "month",
      dateFormat: "MMMM YYYY",
      renderer: start =>
        displayDateFormat(DateHelper.format(start, "MMMM YYYY"))
    }
  },
  headers: [
    {
      increment: 1,
      unit: "month",
      dateFormat: "MMMM YYYY",
      renderer: start =>
        displayDateFormat(DateHelper.format(start, "MMMM YYYY"))
    },
    {
      unit: "week",
      increment: 1
    }
  ],
  id: "weekAndMonth",
  rowHeight: 24,
  name: "Weeks",
  tickWidth: 75,
  tickHeight: 60,
  displayDateFormat: "MMMM YYYY",
  shiftIncrement: 1,
  shiftUnit: "month",
  defaultSpan: 24
});

PresetManager.registerPreset("weekAndMonth-36by60", {
  timeResolution: {
    unit: "week"
  },
  headerConfig: {
    middle: {
      unit: "week",
      dateFormat: "W",
      renderer: start => `W${DateHelper.format(start, "W")}`
    },
    top: {
      unit: "month",
      dateFormat: "MMMM YYYY",
      renderer: start =>
        displayDateFormat(DateHelper.format(start, "MMMM YYYY"))
    }
  },
  headers: [
    {
      increment: 1,
      unit: "month",
      dateFormat: "MMMM YYYY",
      renderer: start =>
        displayDateFormat(DateHelper.format(start, "MMMM YYYY"))
    },
    {
      unit: "week",
      increment: 1
    }
  ],
  id: "weekAndMonth-36by60",
  rowHeight: 24,
  name: "Weeks",
  tickWidth: 35,
  tickHeight: 60,
  displayDateFormat: "MMMM YYYY",
  shiftIncrement: 1,
  shiftUnit: "month",
  defaultSpan: 24
});

PresetManager.registerPreset("monthAndYear", {
  timeResolution: {
    unit: "quarter"
  },
  headerConfig: {
    middle: {
      unit: "month",
      increment: 1,
      dateFormat: "MMMM",
      renderer: start => displayDateFormat(DateHelper.format(start, "MMMM"))
    },
    top: {
      unit: "quarter",
      dateFormat: "Q",
      renderer: start => `Q${DateHelper.format(start, "Q, YYYY")}`
    }
  },
  headers: [
    {
      increment: 1,
      unit: "quarter",
      dateFormat: "Q, YYYY",
      renderer: start => displayDateFormat(DateHelper.format(start, "Q, YYYY"))
    },
    {
      unit: "month",
      increment: 1,
      dateFormat: "MMMM",
      renderer: start => displayDateFormat(DateHelper.format(start, "MMMM"))
    }
  ],
  id: "monthAndYear",
  rowHeight: 24,
  name: "Months",
  tickWidth: 78,
  tickHeight: 60,
  displayDateFormat: "Q, YYYY",
  shiftIncrement: 1,
  shiftUnit: "quarter",
  defaultSpan: 24
});

PresetManager.registerPreset("monthAndYear-40by60", {
  timeResolution: {
    unit: "quarter"
  },
  headerConfig: {
    middle: {
      unit: "month",
      increment: 1,
      dateFormat: "MMM",
      renderer: start => displayDateFormat(DateHelper.format(start, "MMM"))
    },
    top: {
      unit: "quarter",
      dateFormat: "Q",
      renderer: start => `Q${DateHelper.format(start, "Q, YYYY")}`
    }
  },
  headers: [
    {
      increment: 1,
      unit: "quarter",
      dateFormat: "Q, YYYY",
      renderer: start => displayDateFormat(DateHelper.format(start, "Q, YYYY"))
    },
    {
      unit: "month",
      increment: 1,
      dateFormat: "MMM",
      renderer: start => displayDateFormat(DateHelper.format(start, "MMM"))
    }
  ],
  id: "monthAndYear-40by60",
  rowHeight: 24,
  name: "Quarters",
  tickWidth: 40,
  tickHeight: 60,
  displayDateFormat: "Q, YYYY",
  shiftIncrement: 1,
  shiftUnit: "quarter",
  defaultSpan: 24
});

PresetManager.registerPreset("monthAndHalfYear-60by60", {
  timeResolution: {
    unit: "year"
  },
  headers: [
    {
      increment: 1,
      unit: "year",
      dateFormat: "YYYY",
      renderer: start => displayDateFormat(DateHelper.format(start, "YYYY"))
    },
    {
      increment: 1,
      unit: "quarter",
      renderer: start => `Q${DateHelper.format(start, "Q")}`
    }
  ],
  id: "monthAndHalfYear-60by60",
  rowHeight: 24,
  name: "Years",
  tickWidth: 60,
  tickHeight: 50,
  displayDateFormat: "YYYY",
  shiftIncrement: 1,
  shiftUnit: "year",
  defaultSpan: 12
});

export const getSupportedPresets = () => {
  const requiredPresetIds = {
    "minuteAndHour-50by60": 1,
    "minuteAndHour-30by60": 1,
    "minuteAndHour-36by60": 1,
    hourAndDay: 1,
    "hourAndDay-38by60": 1,
    "hourAndDay-38by60-2": 1,
    "hourAndDay-38by60-4": 1,
    "hourAndDay-56by60": 1,
    "monthAndDay-40by60": 1,
    "monthAndDay-30by60": 1,
    "monthAndDay-20by60": 1,
    weekAndMonth: 1,
    "weekAndMonth-36by60": 1,
    monthAndYear: 1,
    "monthAndYear-40by60": 1,
    "monthAndHalfYear-60by60": 1
  };
  return PresetManager.records.filter(p => requiredPresetIds[p.id]);
};

let userLocale = "";
export const getUserLocale = (locale = "en_US") => {
  let convertedLocale = locale;
  // norway has 3 locales. And the nb-NO is the one being used and others are deprecated.
  // need to be addressed for others also in case any locale has different condition like norway;
  if (locale.toLowerCase() === "no_no" || locale.toLowerCase() === "no-no")
    convertedLocale = "nb-NO";
  const tokens = convertedLocale.split("_");
  userLocale =
    tokens.length > 1 ? `${tokens[0]}-${tokens[1]}` : convertedLocale;
};
