import {
  HTTP_GET,
  HTTP_POST,
  USER_SETTINGS_ENDPOINT,
  SAVE_USER_SETTINGS_ENDPOINT,
  RESTORE_USER_SETTINGS_ENDPOINT
} from "constants/ServiceConstants";
import fetchData from "services/service";

const UserSettingService = {};

UserSettingService.getUserSettings = () => {
  const config = {
    method: HTTP_GET,
    url: USER_SETTINGS_ENDPOINT
  };
  return fetchData(config);
};

UserSettingService.saveUserSettings = payload => {
  const config = {
    method: HTTP_POST,
    payload,
    url: SAVE_USER_SETTINGS_ENDPOINT
  };
  return fetchData(config);
};

UserSettingService.resetUserSettings = () => {
  const config = {
    method: HTTP_POST,
    url: RESTORE_USER_SETTINGS_ENDPOINT
  };
  return fetchData(config);
};

export default UserSettingService;
