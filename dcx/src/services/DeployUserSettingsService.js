import {
  HTTP_GET,
  HTTP_POST,
  GET_DISPATCHER_LIST,
  POST_DEPLOY_USER_SETTINGS
} from "constants/ServiceConstants";

import fetchData from "services/service";

const DeployUserSettingsService = {};

DeployUserSettingsService.getDispatcherList = () => {
  const config = {
    method: HTTP_GET,
    url: GET_DISPATCHER_LIST
  };
  return fetchData(config);
};

DeployUserSettingsService.deployUserSettings = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: POST_DEPLOY_USER_SETTINGS
  };
  return fetchData(config);
};

export default DeployUserSettingsService;
