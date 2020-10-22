import arrayToTree from "array-to-tree";
import { groupBy, intersectionWith, orderBy } from "lodash";
import {
  NAME,
  TEAM_API_REF,
  TEAM_API_NAME,
  TERRITORY_API_NAME,
  TECH_HOME_LATITUDE_PROPERTY,
  TECH_HOME_LONGITUDE_PROPERTY,
  TECH_LATITUDE_PROPERTY,
  TECH_LONGITUDE_PROPERTY,
  ADDRESS_FIELDS,
  TECH_SALESFORCE_USER_FIELD,
  TECH_SALESFORCE_USER_INFO
} from "constants/AppConstants";
import { getFieldValue, getFieldValues } from "utils/DCUtils";

const TECHNICIAN_DELETED = "Deleted";
const TECHNICIAN_INSERTED = "Inserted";
const ATS_RESP_TECHNICIAN_NAME = "tName";

const createPreferredObj = (strDeleted, TechId, techPreferenceType) => ({
  strDeleted,
  TechId,
  techPreferenceType:
    strDeleted === TECHNICIAN_DELETED ? "" : techPreferenceType
});

export const createPreferredTechList = (
  original = [],
  modified = [],
  technicianIds
) => {
  const preferredList = [];
  modified.map(technician => {
    const { id, value } = technician;
    const index = original.findIndex(item => item.key === id);
    if (index !== -1) {
      preferredList.push(createPreferredObj("", id, value));
      original.splice(index, 1);
    } else {
      preferredList.push(createPreferredObj(TECHNICIAN_INSERTED, id, value));
    }
    return undefined;
  });
  original.map(technician => {
    const { key: id, value } = technician;
    if (technicianIds.includes(id)) {
      preferredList.push(createPreferredObj(TECHNICIAN_DELETED, id, value));
    }
    return undefined;
  });
  return preferredList;
};

export const getQualifiedTechIds = (
  teamView,
  technicians,
  teamIds = [],
  territoryList = []
) => {
  const lstTech = [];
  const territoryIdMap = {};
  territoryList.map(territory => {
    const { Id } = territory;
    if (!territoryIdMap[Id]) {
      territoryIdMap[Id] = territory;
    }
    return undefined;
  });

  Object.values(technicians).map(technician => {
    const { technician_O: techObj } = technician;
    const { Id } = techObj;
    const teamId = getFieldValue(techObj, TEAM_API_NAME);
    if (teamView && teamIds.includes(teamId)) {
      lstTech.push(Id);
    } else if (!teamView) {
      const territoryId = getFieldValue(techObj, TERRITORY_API_NAME);
      if (territoryId && territoryIdMap[territoryId]) {
        lstTech.push(Id);
      }
    }
    return undefined;
  });
  return lstTech;
};

export const classifySerachResults = (
  teamView,
  results = [],
  technicians,
  territoryList
) => {
  const sortedTechArray = [];
  const sortedResults = orderBy(results, [ATS_RESP_TECHNICIAN_NAME]);
  sortedResults.map(sortedResult => {
    const { tech, tName } = sortedResult;
    const techObj = technicians[tech];
    const { technician_O: technician } = techObj;
    const name = `${tName} (${getFieldValue(
      getFieldValue(technician, TEAM_API_REF),
      NAME
    )})`;
    sortedTechArray.push({
      ...sortedResult,
      ...technician,
      address: getFieldValues(technician, ADDRESS_FIELDS, true).join(),
      homeAddress: getFieldValues(technician, ADDRESS_FIELDS, true).join(),
      homeLat: getFieldValue(technician, TECH_HOME_LATITUDE_PROPERTY, ""),
      homeLng: getFieldValue(technician, TECH_HOME_LONGITUDE_PROPERTY, ""),
      iconCls: "b-icon b-fa-user",
      id: tech,
      isTech: true,
      icon: "user",
      icon_category: "utility",
      lat: getFieldValue(technician, TECH_LATITUDE_PROPERTY, ""),
      lng: getFieldValue(technician, TECH_LONGITUDE_PROPERTY, ""),
      name,
      Name: name,
      isTechSalesforceUser: technician[TECH_SALESFORCE_USER_FIELD]
        ? technician[TECH_SALESFORCE_USER_INFO]
        : undefined,
      resourceId: tech
    });
    return undefined;
  });
  if (teamView) {
    return groupBy(sortedTechArray, result => result.stackRank);
  }
  return groupBy(
    intersectionWith(
      sortedTechArray,
      territoryList,
      (source, target) => source[TERRITORY_API_NAME] === target.Id
    ),
    result => result.stackRank
  );
};

export const treeifyClassifiedResult = classifiedResult => {
  let treeNodes = [];
  const keys = Object.keys(classifiedResult);
  keys.sort((a, b) => b - a);
  keys.map(group => {
    const children = classifiedResult[group];
    const [firstChild] = children;
    const { stackRank } = firstChild;
    const name = `${stackRank * 10}%`;
    treeNodes.push({
      expanded: true,
      iconCls: "b-icon b-fa-search",
      id: stackRank,
      //   isServiceTeam: true,
      //   isTech: false,
      isTech: false,
      Name: name,
      name: `${stackRank * 10}%`,
      stackRank: null
    });
    treeNodes = treeNodes.concat(children);
    return undefined;
  });
  return arrayToTree(treeNodes, {
    customID: "id",
    parentProperty: "stackRank"
  });
};
