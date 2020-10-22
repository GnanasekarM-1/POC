/* eslint-disable array-callback-return */
import {
  all,
  takeLatest,
  takeEvery,
  call,
  put,
  select
} from "redux-saga/effects";
import {
  compact,
  cloneDeep,
  difference,
  orderBy,
  chunk,
  uniq,
  flatMap,
  isNull,
  isUndefined
} from "lodash";
import * as moment from "moment";
import arrayToTree from "array-to-tree";
import {
  CREAT_EVENT,
  GET_SEARCH_TECH,
  KEY_CREAT_EVENT,
  KEY_SEARCH_TECH,
  KEY_TECHNICIANS,
  KEY_TECHNICIANS_DETAILS,
  GET_TECHNICIANS,
  GET_TECHNICIANS_DETAILS,
  KEY_WO_MATCH_SKILLS,
  KEY_ADV_TECH_SEARCH,
  KEY_FILTER_TECHNICIAN,
  SEARCH_TECH_DATA_CLEAR,
  SEARCH_TECH_DATA_CLEARED,
  SEARCH_TECHNICIANS_REQUESTED,
  INLINE_TECHNICIAN_SEARCH_REQUESTED,
  SEARCH_TECHNICIANS_LOADED,
  ADV_TECH_SEARCH_LOADED,
  SEARCH_TECHNICIANS_ERRORED,
  TECHNICIANS_REQUESTED,
  TECHNICIANS_DETAILS_REQUESTED,
  TECHNICIANS_LOADED,
  UPDATE_TECHNICIAN_DETAILS,
  TECHNICIANS_API_ERRORED,
  TECHNICIANS_DETAILS_API_ERRORED,
  GET_WO_MATCHING_TECH_SKILLS,
  APPLY_ADV_TECH_SEARCH,
  PERFORM_ADV_TECH_SEARCH,
  UPDATE_TECHNICIAN_TREEDATA,
  WO_MATCH_TECH_SKILLS_REQUESTED,
  WO_MATCH_TECH_SKILLS_LOADED,
  WO_MATCH_TECH_SKILLS_API_ERRORED,
  ADV_TECH_SEARCH_ERRORED,
  ADV_TECH_SEARCH_REQUESTED,
  UPDATE_SCHEDULER_STATE,
  UPDATE_USER_INFO,
  ADV_TECH_SEARCH_NO_WORKORDER_SELECTION,
  FILTER_TECHNICIAN_REQUESTED,
  FILTER_TECHNICIAN_ERRORED,
  FILTER_WORKORDER_TECHNICIANS,
  SEARCH_TECH_DATA_EMPTY,
  FILTERING_TECHNICIANS_STARTED,
  FILTERING_TECHNICIANS_FAILED,
  EVENTS_LOADING_STARTED,
  EVENTS_LOADING_COMPLETE,
  UPDATE_GRID_STATE,
  KEY_EVENTS,
  EVENTS_LOADED,
  REMOVE_ATS_RESULTS,
  SERACH_MMA_TECHNICIAN
} from "constants/ActionConstants";
import {
  OMAX003_SET042,
  OMAX003_SET043,
  OMAX003_SET044,
  OMAX003_SET047,
  getSettingValue
} from "constants/AppSettings";
import {
  NAME,
  DEFAULT_TREE_DATA,
  TEAM_API_NAME,
  TERRITORY_API_NAME,
  TEAM_API_REF,
  TECH_KEYWORD,
  TEAM_SEARCH_RESULT,
  ADV_SEARCH_RESULT,
  INITIAL_TREE_DATA,
  TECH_SEARCH_RESULT,
  TEAM_INDEX,
  QUALIFIED_TECHNICIANS_API_REF,
  FILTER_TECHNICIAN_RESULT,
  ARRAY_TO_TREE_CONFIG,
  WORKORDER_TECHNICIAN_API_NAME
} from "constants/AppConstants";
import { convertErrorToObject, getFieldValue } from "utils/DCUtils";
import { setTechPhotoUrls } from "utils/MapUtils";

import {
  createSchedulerTreeNode,
  createTeamTerritoryTree,
  getTerritoryTeamDataOnLaunch,
  getServiceTeamDataOnLaunch,
  getAllTechniciansIdsOnLaunch,
  getSearchedTechTeamData,
  getSearchedTechTerritoryTeamData,
  getSearchTechnicians,
  getTeamIds
} from "utils/SchedulerUtils";
import TechnicianService from "services/TechnicianService";
import {
  classifySerachResults,
  createPreferredTechList,
  getQualifiedTechIds,
  treeifyClassifiedResult
} from "utils/ATSHelperUtils";
import {
  DEFAULT_END_DATE,
  DEFAULT_START_DATE
} from "constants/SchedulerConstants";
import {
  SECONDS,
  YODA_DATE_FORMAT,
  DATE_TIME_FORMAT,
  YODA_DATE_TIME_ZONE_24_HR_FORMAT
} from "constants/DateTimeConstants";
import { TECH_SEARCH_KEYWORD } from "constants/UserSettingConstants";

const getTechnicianData = ({ technicianData }) => technicianData;

const getUserSettings = ({ userSettings }) => userSettings;

const getSchedularState = ({ schedulerState }) => schedulerState;

const getSelectedWorkOrder = ({ gridState }) => {
  const { row = undefined } = gridState;
  return row;
};

const getWorkOrders = ({ workOrderData }) => {
  const { workOrders } = workOrderData;
  const { content } = workOrders;
  const { records } = content;
  return records;
};
let apiQueueTechDetails = 0;

const getListOfTechScheduled = payload =>
  TechnicianService.getListOfTechScheduled(payload).then(response =>
    response.json()
  );

const getTechnicians = () =>
  TechnicianService.getTechnicians().then(response => response.json());

const getTechniciansDetails = payload =>
  TechnicianService.getTechniciansDetails(payload).then(response =>
    response.json()
  );

const performAdvTechSearch = payload =>
  TechnicianService.performATS(payload).then(response => response.json());

const runAdvTechSearch = payload =>
  TechnicianService.runATS(payload).then(response => response.json());

const getWorkOrderMatchTechSkills = ({ id }) =>
  TechnicianService.getWOMatchTechSkills(id).then(response => response.json());

const getSearchTechData = ({ payload }) =>
  TechnicianService.getSearchedTech(payload).then(response => response.json());

export function* technicianWorker() {
  try {
    yield put({ key: KEY_TECHNICIANS, type: TECHNICIANS_REQUESTED });
    const payload = yield call(getTechnicians);
    const { content } = payload;
    const {
      endDate,
      isSuperDispatcher,
      teamList,
      territoryList,
      userName,
      startDate,
      teamTechnicianMap,
      userId
    } = content;
    const teamIds = Object.keys(teamTechnicianMap);
    const teamView = getServiceTeamDataOnLaunch(content);
    const territoryView = getTerritoryTeamDataOnLaunch(content);
    const techniciansIds = getAllTechniciansIdsOnLaunch(content);
    const eventsEndDate = moment(endDate, YODA_DATE_FORMAT)
      .startOf("day")
      .add(1, SECONDS)
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    const eventsStartDate = moment(startDate, YODA_DATE_FORMAT)
      .startOf("day")
      .format(YODA_DATE_TIME_ZONE_24_HR_FORMAT);
    yield put({
      data: { eventsEndDate, eventsStartDate },
      key: KEY_EVENTS,
      type: EVENTS_LOADED
    });
    yield put({
      data: {
        teamIds,
        teamList,
        teamView,
        technicians: {},
        techniciansIds,
        territoryList,
        territoryView
      },
      key: KEY_TECHNICIANS,
      type: TECHNICIANS_LOADED
    });
    yield put({
      changed: {
        [DEFAULT_END_DATE]: eventsEndDate,
        [DEFAULT_START_DATE]: eventsStartDate,
        eventsEndDate,
        eventsStartDate,
        newViewState: INITIAL_TREE_DATA,
        teamView,
        territoryView
      },
      type: UPDATE_SCHEDULER_STATE
    });
    yield put({
      changed: {
        userInfo: {
          isDispatcher: isSuperDispatcher,
          UserName: userName,
          userId
        }
      },
      type: UPDATE_USER_INFO
    });

    const techBatchSize = 500; // getSettingValue(SET033);
    const technicianChunks = chunk(Array.from(techniciansIds), techBatchSize);
    const techTotalBatch = technicianChunks.length;
    for (let i = 0; i < techTotalBatch; i += 1) {
      yield put({
        key: KEY_TECHNICIANS_DETAILS,
        techniciansIds: technicianChunks[i],
        type: GET_TECHNICIANS_DETAILS
      });
      apiQueueTechDetails += 1;
    }
    const dummyCreateEventPayload = {
      events: [
        {
          type: "Event",
          EndDateTime: "2019-12-05T21:20:00.000Z",
          WhatId: "",
          DurationInMinutes: 2870,
          SVMXC__Service_Duration__c: 172200,
          SVMXC__Break_Time_Total__c: "0",
          SVMXC__Driving_Time__c: 240,
          IsAllDayEvent: false,
          fieldsToNull: "Id",
          ActivityDateTime: "2019-12-03T22:30:00.000Z",
          Subject: "",
          ActivityDate: "2019-12-03",
          StartDateTime: "2019-12-03T22:30:00.000Z",
          OwnerId: techniciansIds[0]
        }
      ],
      lstKeyValue: [],
      techId: techniciansIds[0],
      updatePrimaryTech: true,
      timeZone: "America/Los_Angeles"
    };
    yield put({
      dummy: true,
      key: KEY_CREAT_EVENT,
      payload: dummyCreateEventPayload,
      type: CREAT_EVENT
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      type: TECHNICIANS_API_ERRORED
    });
  }
}

export function* technicianDetailsWorker(action) {
  try {
    const { techFields = [], techniciansIds: techIds } = action;
    yield put({
      key: KEY_TECHNICIANS_DETAILS,
      type: TECHNICIANS_DETAILS_REQUESTED
    });
    const requestPayload = { techFields, techIds };
    const payload = yield call(getTechniciansDetails, requestPayload);
    const { content } = payload;
    const { techDetails, photoURL } = content;
    setTechPhotoUrls(techDetails, photoURL);
    yield put({
      data: techDetails,
      key: KEY_TECHNICIANS,
      type: UPDATE_TECHNICIAN_DETAILS
    });
    apiQueueTechDetails -= 1;
    if (apiQueueTechDetails == 0) {
      yield put({
        key: KEY_TECHNICIANS_DETAILS,
        type: UPDATE_TECHNICIAN_TREEDATA
      });
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_TECHNICIANS_DETAILS,
      type: TECHNICIANS_DETAILS_API_ERRORED
    });
  }
}

export function* updateTechnicianTreeDataWorker() {
  try {
    const technicianData = yield select(getTechnicianData);
    const { technicians: allTech } = technicianData;
    const { data } = allTech;
    const {
      technicians,
      teamIds,
      teamList,
      territoryList,
      techniciansIds
    } = data;
    const teamView = createTeamTerritoryTree(teamList, technicians, true);
    const territoryView = createTeamTerritoryTree(
      territoryList,
      technicians,
      false
    );
    yield put({
      data: {
        teamIds,
        teamList,
        teamView,
        technicians,
        techniciansIds,
        territoryList,
        territoryView
      },
      key: KEY_TECHNICIANS,
      type: TECHNICIANS_LOADED
    });
    yield put({
      changed: { newViewState: DEFAULT_TREE_DATA, teamView, territoryView },
      type: UPDATE_SCHEDULER_STATE
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_TECHNICIANS_DETAILS,
      type: TECHNICIANS_DETAILS_API_ERRORED
    });
  }
}

export function* woMatchTechSkillWorker(action) {
  try {
    yield put({
      key: KEY_WO_MATCH_SKILLS,
      type: WO_MATCH_TECH_SKILLS_REQUESTED
    });
    const response = yield call(getWorkOrderMatchTechSkills, action);
    const { content, message, success } = response;
    if (!success) {
      const error = convertErrorToObject(response);
      yield put({
        data: { error, ...error },
        message,
        key: KEY_WO_MATCH_SKILLS,
        type: WO_MATCH_TECH_SKILLS_API_ERRORED
      });
      return;
    }
    yield put({
      data: content,
      key: KEY_WO_MATCH_SKILLS,
      type: WO_MATCH_TECH_SKILLS_LOADED
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_WO_MATCH_SKILLS,
      type: WO_MATCH_TECH_SKILLS_API_ERRORED
    });
  }
}

export function* searchTechnicianWorker(action) {
  try {
    const { callback } = action;
    yield put({ key: KEY_SEARCH_TECH, type: SEARCH_TECHNICIANS_REQUESTED });
    const payload = yield call(getSearchTechData, action);
    const { content } = payload;
    if (!content) {
      const errorObj = convertErrorToObject(payload);
      const { Message, Error, errorCode, message, success } = errorObj;
      yield put({
        data: {
          error: {
            message: Message || Error || message
          },
          errorCode,
          success
        },
        key: KEY_SEARCH_TECH,
        type: SEARCH_TECHNICIANS_ERRORED
      });
      return;
    }
    const teamView = getSearchedTechTeamData(content, action);
    const territoryView = getSearchedTechTerritoryTeamData(content, action);
    const techniciansData = getSearchTechnicians(content, action, teamView);
    const teamIds = getTeamIds(teamView);
    if (!content.length) {
      yield put({
        data: [],
        key: KEY_SEARCH_TECH,
        type: SEARCH_TECH_DATA_EMPTY
      });
    } else {
      yield put({
        data: {
          teamView,
          territoryView,
          technicians: { ...techniciansData },
          teamIds
        },
        key: KEY_SEARCH_TECH,
        type: SEARCH_TECHNICIANS_LOADED
      });
    }
    const { findWhat } = action;
    yield put({
      changed: {
        newViewState:
          findWhat === TECH_KEYWORD ? TECH_SEARCH_RESULT : TEAM_SEARCH_RESULT,
        teamView,
        territoryView
      },
      type: UPDATE_SCHEDULER_STATE
    });
    callback();
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_SEARCH_TECH,
      type: SEARCH_TECHNICIANS_ERRORED
    });
  }
}

export function* getSearchTechDataClearWorker() {
  yield put({ changed: { gridActive: false }, type: UPDATE_GRID_STATE });
  yield put({
    data: [],
    key: KEY_SEARCH_TECH,
    type: SEARCH_TECH_DATA_CLEARED
  });
}

const buildFilterTechTree = (
  scheduledTechIds,
  technicians,
  teamIds,
  territoryList,
  isTeamView
) => {
  const scheduledTechnicians = [];
  uniq(scheduledTechIds).map(schTechId => {
    const technician = technicians[schTechId];
    if (technician) {
      const { technician_O: techObj } = technician;
      scheduledTechnicians.push(techObj);
    }
  });
  const treeNodes = [];
  if (isTeamView) {
    const inclusions = {};
    scheduledTechnicians.map(scheduledTechnician => {
      const teamId = getFieldValue(scheduledTechnician, TEAM_API_NAME);
      if (teamIds.includes(teamId)) {
        treeNodes.push({ isTech: true, ...scheduledTechnician });
        if (!inclusions[teamId]) {
          const serviceTeam = getFieldValue(scheduledTechnician, TEAM_API_REF);
          const serviceTeamCpy = cloneDeep(serviceTeam);
          inclusions[teamId] = serviceTeamCpy;
          serviceTeamCpy.expanded = true;
          serviceTeamCpy.isTech = false;
          treeNodes.push(serviceTeamCpy);
        }
      }
    });
  } else {
    const inclusions = {};
    const territoryIdMap = {};
    territoryList.map(territory => {
      const { Id } = territory;
      territoryIdMap[Id] = territory;
      return undefined;
    });
    scheduledTechnicians.map(scheduledTechnician => {
      const territoryId = getFieldValue(
        scheduledTechnician,
        TERRITORY_API_NAME
      );
      if (territoryIdMap[territoryId]) {
        treeNodes.push({ isTech: true, ...scheduledTechnician });
        if (!inclusions[territoryId]) {
          const territory = territoryIdMap[territoryId];
          const territoryCpy = cloneDeep(territory);
          inclusions[territoryId] = territoryCpy;
          territoryCpy.expanded = true;
          territoryCpy.isTech = false;
          treeNodes.push(territoryCpy);
        }
      }
    });
  }
  const results = flatMap(orderBy(treeNodes, [NAME]), treeNode =>
    createSchedulerTreeNode(treeNode, isTeamView, treeNode.isTech)
  );
  return arrayToTree(results, ARRAY_TO_TREE_CONFIG);
};

export function* filterWorkOrderTechnicianWorker(action) {
  try {
    let { workOrders: records } = action;
    if (!records || records.length <= 0) {
      records = yield select(getWorkOrders);
    }
    if (records && records.length) {
      yield put({ type: FILTERING_TECHNICIANS_STARTED });
      yield put({
        key: KEY_FILTER_TECHNICIAN,
        type: FILTER_TECHNICIAN_REQUESTED
      });
      const workOrderTechMap = {};
      records.map(record => {
        const { Id } = record;
        workOrderTechMap[Id] = getFieldValue(
          record,
          WORKORDER_TECHNICIAN_API_NAME,
          null
        );
        return undefined;
      });
      const workOrderIds = Object.keys(workOrderTechMap);
      const response = yield call(getListOfTechScheduled, { workOrderIds });

      const { content: scheduledTechIds, success, message } = response;
      if (!success) {
        const error = convertErrorToObject(response);
        yield put({
          data: { error, ...error },
          message,
          type: FILTERING_TECHNICIANS_FAILED
        });
        return;
      }

      let filteredTechIds = [...scheduledTechIds];
      if (filteredTechIds.length) {
        const assignedTechs = compact(Object.values(workOrderTechMap));
        const diffTechIds = difference(assignedTechs, filteredTechIds);
        if (diffTechIds.length) {
          filteredTechIds = filteredTechIds.concat(diffTechIds);
        }
      }

      yield put({ type: EVENTS_LOADING_STARTED });
      const schedulerState = yield select(getSchedularState);
      const { activeView } = schedulerState;
      let { teamView, territoryView } = schedulerState;
      const technicianData = yield select(getTechnicianData);
      const { technicians: techContent } = technicianData;
      const { data: datContent } = techContent;
      const { teamIds, technicians, territoryList } = datContent;

      const isTeamView = activeView === TEAM_INDEX;
      const tree = buildFilterTechTree(
        filteredTechIds,
        technicians,
        teamIds,
        territoryList,
        isTeamView
      );
      if (isTeamView) {
        teamView = tree;
      } else {
        territoryView = tree;
      }
      yield put({
        changed: {
          newViewState: FILTER_TECHNICIAN_RESULT,
          teamView,
          territoryView
        },
        type: UPDATE_SCHEDULER_STATE
      });
      yield put({ type: EVENTS_LOADING_COMPLETE });
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_FILTER_TECHNICIAN,
      type: FILTER_TECHNICIAN_ERRORED
    });
  }
}

export function* performATSWorker(action) {
  try {
    yield put({ key: KEY_ADV_TECH_SEARCH, type: ADV_TECH_SEARCH_REQUESTED });
    const { atsData } = action;
    const {
      isEligibilityEnabled = false,
      isproductExpertiseEnabled = false,
      isPreferredTechEnabled = false,
      isSkillsEnabled = false,
      lstSkill,
      lstEligibility,
      productExpertise,
      preferredTechList
    } = atsData;
    const schedulerState = yield select(getSchedularState);
    const technicianData = yield select(getTechnicianData);
    const selectedWO = yield select(getSelectedWorkOrder);
    const { activeView } = schedulerState;
    const { Id: WOid } = selectedWO;
    const {
      technicians: techContent,
      woMatchSkills,
      searchTeachnicians
    } = technicianData;
    let datContent, territoryList;
    if (searchTeachnicians && searchTeachnicians.data) {
      datContent = searchTeachnicians.data;
      territoryList = datContent.territoryView;
    } else {
      datContent = techContent.data;
      territoryList = datContent.territoryList;
    }
    const { teamIds, technicians } = datContent;
    const { data: woMatchData } = woMatchSkills;
    const { lstCandidatePrefTechId = [] } = woMatchData;
    const isTeamView = activeView === TEAM_INDEX;
    const lstTech = getQualifiedTechIds(
      isTeamView,
      technicians,
      teamIds,
      territoryList
    );
    const lstMPXTechnicans = createPreferredTechList(
      [...lstCandidatePrefTechId],
      preferredTechList,
      lstTech
    );

    const techChnuks = chunk(lstTech, 200);
    const blockingCalls = flatMap(techChnuks, lstTech =>
      call(performAdvTechSearch, {
        isSkillsEnabled,
        isproductExpertiseEnabled,
        isEligibilityEnabled,
        isPreferredTechEnabled,
        lstskill: isSkillsEnabled
          ? flatMap(lstSkill, skill => {
              // In case of empty Skill level, make mandatory skill to false
              const { skillLevel, isSkillMandatory } = skill;
              if (
                isSkillMandatory &&
                (isNull(skillLevel) || isUndefined(skillLevel))
              ) {
                skill.skillLevel = 0;
              }
              return skill;
            })
          : [],
        productExpertise: isproductExpertiseEnabled ? productExpertise : null,
        lstEligibility: isEligibilityEnabled ? lstEligibility : [],
        lstMPXTechnicans: isPreferredTechEnabled ? lstMPXTechnicans : [],
        lstTech,
        WOid
      })
    );

    let results = [];
    let responseError = false;
    const responseArray = yield all(blockingCalls);
    responseArray.map(response => {
      const { content, success } = response;
      if (!success) {
        responseError = { ...response };
        return;
      }

      const { valueMap } = content;
      if (!valueMap || !valueMap.length) {
        return;
      }
      const [resultValue] = valueMap;
      const { record } = resultValue;
      const result = record[QUALIFIED_TECHNICIANS_API_REF];
      if (result) {
        results = results.concat(JSON.parse(result));
      }
      return undefined;
    });

    if (responseError) {
      const error = convertErrorToObject(responseError);
      const { message } = error;
      yield put({
        data: { error, ...error },
        key: KEY_ADV_TECH_SEARCH,
        type: ADV_TECH_SEARCH_ERRORED,
        message
      });
      return;
    }

    const classifiedResult = classifySerachResults(
      isTeamView,
      results,
      technicians,
      territoryList
    );
    const atsResults = treeifyClassifiedResult(classifiedResult);
    let { teamView, territoryView } = schedulerState;
    if (isTeamView) {
      teamView = atsResults;
    } else {
      territoryView = atsResults;
    }

    yield put({
      data: atsResults,
      key: KEY_ADV_TECH_SEARCH,
      type: ADV_TECH_SEARCH_LOADED
    });
    yield put({
      changed: { newViewState: ADV_SEARCH_RESULT, teamView, territoryView },
      type: UPDATE_SCHEDULER_STATE
    });

    if (atsResults.length) {
      yield put({ type: EVENTS_LOADING_COMPLETE });
    } else {
      yield put({ type: SEARCH_TECH_DATA_EMPTY });
    }
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_ADV_TECH_SEARCH,
      type: ADV_TECH_SEARCH_ERRORED
    });
  }
}

export function* applyATSWorker(action) {
  try {
    yield put({ key: KEY_ADV_TECH_SEARCH, type: ADV_TECH_SEARCH_REQUESTED });
    const selectedWO = yield select(getSelectedWorkOrder);
    if (!selectedWO) {
      yield put({ type: ADV_TECH_SEARCH_NO_WORKORDER_SELECTION });
      return;
    }

    const userSettings = yield select(getUserSettings);
    const {
      adv_atsSkills: atsSkills,
      adv_atsPrefTech: atsPrefTech,
      adv_atsExpertise: atsExpertise,
      adv_atsEligibility: atsEligibility
    } = userSettings;

    const { search: includeSkillInSearch = false } = atsSkills;
    const { search: includeProductExpInSearch = false } = atsExpertise;
    const { search: includeEligibilityInSearch = false } = atsEligibility;
    const { search: includePreferredTechInSearch = false } = atsPrefTech;

    const showSkillsTab = JSON.parse(getSettingValue(OMAX003_SET047, 0));
    const showProductTab = JSON.parse(getSettingValue(OMAX003_SET043, 0));
    const showEligibitityTab = JSON.parse(getSettingValue(OMAX003_SET042, 0));
    const showConstraintsTab = JSON.parse(getSettingValue(OMAX003_SET044, 0));

    const isSkillsEnabled = showSkillsTab
      ? JSON.parse(includeSkillInSearch)
      : false;
    const isproductExpertiseEnabled = showProductTab
      ? JSON.parse(includeProductExpInSearch)
      : false;
    const isEligibilityEnabled = showEligibitityTab
      ? JSON.parse(includeEligibilityInSearch)
      : false;
    const isPreferredTechEnabled = showConstraintsTab
      ? JSON.parse(includePreferredTechInSearch)
      : false;

    const schedulerState = yield select(getSchedularState);
    const technicianData = yield select(getTechnicianData);

    const { activeView } = schedulerState;
    const { technicians: techContent, searchTeachnicians } = technicianData;
    let datContent, territoryList;
    if (searchTeachnicians && searchTeachnicians.data) {
      datContent = searchTeachnicians.data;
      territoryList = datContent.territoryView;
    } else {
      datContent = techContent.data;
      territoryList = datContent.territoryList;
    }
    const { teamIds, technicians } = datContent;
    const isTeamView = activeView === TEAM_INDEX;
    const lstTech = getQualifiedTechIds(
      isTeamView,
      technicians,
      teamIds,
      territoryList
    );

    const { Id: woId } = selectedWO;
    const techChnuks = chunk(lstTech, 200);
    const blockingCalls = flatMap(techChnuks, lstTech =>
      call(runAdvTechSearch, {
        woId,
        isSkillsEnabled,
        isproductExpertiseEnabled,
        isEligibilityEnabled,
        isPreferredTechEnabled,
        lstTech
      })
    );

    let results = [];
    let responseError = false;
    const responseArray = yield all(blockingCalls);
    responseArray.map(response => {
      const { content, success } = response;
      if (!success) {
        responseError = { ...response };
        return;
      }

      const { valueMap } = content;
      if (!valueMap || !valueMap.length) {
        return;
      }
      const [resultValue] = valueMap;
      const { record } = resultValue;
      const result = record[QUALIFIED_TECHNICIANS_API_REF];
      if (result) {
        results = results.concat(JSON.parse(result));
      }
      return undefined;
    });

    if (responseError) {
      const error = convertErrorToObject(responseError);
      const { message } = error;
      yield put({
        data: { error, ...error },
        key: KEY_ADV_TECH_SEARCH,
        type: ADV_TECH_SEARCH_ERRORED,
        message
      });
      return;
    }

    const classifiedResult = classifySerachResults(
      isTeamView,
      results,
      technicians,
      territoryList
    );
    const atsResults = treeifyClassifiedResult(classifiedResult);
    let { teamView, territoryView } = schedulerState;
    if (isTeamView) {
      teamView = atsResults;
    } else {
      territoryView = atsResults;
    }
    yield put({
      data: atsResults,
      key: KEY_ADV_TECH_SEARCH,
      type: ADV_TECH_SEARCH_LOADED
    });
    yield put({
      changed: { newViewState: ADV_SEARCH_RESULT, teamView, territoryView },
      type: UPDATE_SCHEDULER_STATE
    });

    if (atsResults.length) {
      yield put({ type: EVENTS_LOADING_COMPLETE });
    } else {
      yield put({ type: SEARCH_TECH_DATA_EMPTY });
    }
    yield put({
      keys: [KEY_WO_MATCH_SKILLS, KEY_ADV_TECH_SEARCH],
      type: REMOVE_ATS_RESULTS
    });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    yield put({
      data: { error: { errorCode, message } },
      key: KEY_ADV_TECH_SEARCH,
      type: ADV_TECH_SEARCH_ERRORED
    });
  }
}

export function* searchMMATechnicianWorker(action) {
  const { keyword, successCb, failureCb, findWhat = TECH_KEYWORD } = action;
  try {
    yield put({
      key: KEY_SEARCH_TECH,
      type: INLINE_TECHNICIAN_SEARCH_REQUESTED
    });

    const userSettings = yield select(getUserSettings);
    let { col: keywordMatch = [], matchcriteria: searchType } =
      (userSettings && userSettings[TECH_SEARCH_KEYWORD]) || {};
    if (keywordMatch) {
      keywordMatch = compact(
        flatMap(keywordMatch, column => column.name)
      ).join();
    } else {
      // Default Search to Name field.
      keywordMatch = NAME;
    }
    const payload = [
      { key: "keyword", value: keyword },
      { key: "findWhat", value: findWhat },
      { key: "keywordMatch", value: keywordMatch },
      { key: "searchType", value: searchType }
    ];
    const response = yield call(getSearchTechData, { payload });
    const { content } = response;
    if (!content) {
      const errorObj = convertErrorToObject(response);
      const { Message, Error, errorCode, message, success } = errorObj;
      failureCb &&
        failureCb({ message: Message || Error || message, errorCode, success });
      return;
    }
    const teamView = getSearchedTechTeamData(content, action);
    const territoryView = getSearchedTechTerritoryTeamData(content, action);
    successCb && successCb({ teamView, territoryView });
  } catch (e) {
    const { name: errorCode, stack: message } = e;
    failureCb && failureCb({ message, errorCode, success: false });
  }
}

export function* techniciansWatcher() {
  yield takeLatest(GET_TECHNICIANS, technicianWorker);
  yield takeEvery(GET_TECHNICIANS_DETAILS, technicianDetailsWorker);
  yield takeLatest(UPDATE_TECHNICIAN_TREEDATA, updateTechnicianTreeDataWorker);
  yield takeLatest(GET_WO_MATCHING_TECH_SKILLS, woMatchTechSkillWorker);
  yield takeLatest(GET_SEARCH_TECH, searchTechnicianWorker);
  yield takeLatest(SERACH_MMA_TECHNICIAN, searchMMATechnicianWorker);
  yield takeLatest(SEARCH_TECH_DATA_CLEAR, getSearchTechDataClearWorker);
  yield takeLatest(PERFORM_ADV_TECH_SEARCH, performATSWorker);
  yield takeLatest(APPLY_ADV_TECH_SEARCH, applyATSWorker);
  yield takeLatest(
    FILTER_WORKORDER_TECHNICIANS,
    filterWorkOrderTechnicianWorker
  );
}
