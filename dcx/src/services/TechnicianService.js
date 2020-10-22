import {
  HTTP_GET,
  HTTP_POST,
  GET_SEARCH_TECH,
  TECHNICIANS_ENDPOINT,
  TECHNICIANS_DETAILS,
  TECHNICIAN_SKILLS_ENDPOINT,
  ADVANCED_TECHNICIAN_ENDPOINT,
  TECHNICIANS_WORKING_HOURS_ENDPOINT,
  WO_MATCHING_TECH_SKILLS_ENDPOINT,
  ADVANCED_TECHNICIAN_SEARCH_ENDPOINT,
  GET_LIST_OF_TECH_SCHEDULED_ENDPOINT
} from "constants/ServiceConstants";
import { createQueryParam } from "utils/ViewUtils";
import fetchData from "./service";

const TechnicianService = {};

TechnicianService.getTechnicians = () => {
  const config = {
    method: HTTP_GET,
    url: TECHNICIANS_ENDPOINT
  };
  return fetchData(config);
};
TechnicianService.getTechniciansDetails = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: TECHNICIANS_DETAILS
  };
  return fetchData(config);
};

TechnicianService.getTechnicianSkills = () => {
  const config = {
    method: HTTP_GET,
    url: TECHNICIAN_SKILLS_ENDPOINT
  };
  return fetchData(config);
};

TechnicianService.getWOMatchTechSkills = id => {
  const config = {
    method: HTTP_GET,
    url: `${WO_MATCHING_TECH_SKILLS_ENDPOINT}?woId=${id}`
  };
  return fetchData(config);
};

TechnicianService.getSearchedTech = payload => {
  const questParamUrl = createQueryParam(GET_SEARCH_TECH, payload);
  const config = {
    method: HTTP_GET,
    url: questParamUrl
  };
  return fetchData(config);
};

TechnicianService.getTechniciansWorkingHours = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: TECHNICIANS_WORKING_HOURS_ENDPOINT
  };
  return fetchData(config);
};

TechnicianService.performATS = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: ADVANCED_TECHNICIAN_SEARCH_ENDPOINT
  };
  return fetchData(config);
};

TechnicianService.runATS = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: ADVANCED_TECHNICIAN_ENDPOINT
  };
  return fetchData(config);
};

TechnicianService.getListOfTechScheduled = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: GET_LIST_OF_TECH_SCHEDULED_ENDPOINT
  };
  return fetchData(config);
};

export default TechnicianService;
