import {
  HTTP_GET,
  META_DATA_ENDPOINT,
  DISPLAY_TAGS_ENDPOINT,
  APP_SETTINGS_ENDPOINT
} from "constants/ServiceConstants";
import fetchData from "./service";

const MetaDataService = {};

MetaDataService.getMetaData = () => {
  const config = {
    method: HTTP_GET,
    url: META_DATA_ENDPOINT
  };
  return fetchData(config);
};

MetaDataService.getDisplayTags = () => {
  const config = {
    method: HTTP_GET,
    url: DISPLAY_TAGS_ENDPOINT
  };
  return fetchData(config);
};

MetaDataService.getAppSettings = () => {
  const config = {
    method: HTTP_GET,
    url: APP_SETTINGS_ENDPOINT
  };
  return fetchData(config);
};

export default MetaDataService;
