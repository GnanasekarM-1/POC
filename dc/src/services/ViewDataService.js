import {
  HTTP_GET,
  HTTP_POST,
  VIEW_DEFINITION_ENDPOINT,
  MAP_VIEW_DATA_ENDPOINT,
  VIEW_WORKORDER_COUNT_ENDPOINT
} from "constants/ServiceConstants";
import {
  ACCOUNT_API_NAME,
  LOCATION_API_NAME,
  WORKORDER_API_NAME
} from "constants/AppConstants";
import fetchData from "services/service";
import { createQueryParam } from "utils/ViewUtils";

const ViewDataService = {};

ViewDataService.getViewWorkOrderCount = viewIds => {
  const config = {
    method: HTTP_POST,
    payload: {
      viewIds
    },
    url: VIEW_WORKORDER_COUNT_ENDPOINT
  };
  return fetchData(config);
};

ViewDataService.getViewDefinition = (
  objectTypes = [WORKORDER_API_NAME, ACCOUNT_API_NAME, LOCATION_API_NAME],
  viewTypes = ["Map", "Grid And Map"]
) => {
  const config = {
    method: HTTP_POST,
    payload: {
      stringMap: [
        {
          key: "OBJECTNAME",
          valueList: objectTypes
        },
        {
          key: "VIEWFOR",
          valueList: viewTypes
        }
      ]
      // OBJECTNAME: objectTypes,
      // VIEWFOR: viewTypes,
    },
    url: VIEW_DEFINITION_ENDPOINT
  };
  return fetchData(config);
};

ViewDataService.getMapViewData = payload => {
  const questParamUrl = createQueryParam(MAP_VIEW_DATA_ENDPOINT, payload);
  const config = {
    method: HTTP_GET,
    url: questParamUrl
  };
  return fetchData(config);
};

export default ViewDataService;
